<#
.SYNOPSIS
  Usuwa HEXART Video Edit / Uninstalls HEXART Video Edit.

.DESCRIPTION
  Zatrzymuje program i serwer agenta w tle, usuwa autostart, rejestracje MCP w Claude Code,
  skroty i pliki programu. Dane uzytkownika (ustawienia, cache) zostaja, chyba ze podasz -Purge.
  Twoich projektow wideo nie dotyka nigdy.
  Stops the app and the background agent server, removes autostart, the Claude Code MCP
  registration, shortcuts and program files. User data (settings, cache) stays unless -Purge.
  Your video projects are never touched.

  irm https://github.com/lazniak/hexart-video-edit/releases/latest/download/uninstall.ps1 | iex

.PARAMETER InstallDir
  Folder instalacji (domyslnie %LOCALAPPDATA%\Programs\HEXART Video Edit). / Install folder.
.PARAMETER Purge
  Usun tez ustawienia i cache programu. / Also delete the app settings and cache.
.PARAMETER Yes
  Nie pytaj. / Do not ask.
.PARAMETER Force
  Zakoncz procesy HEXART bez pytania (po lagodnej probie). / End HEXART processes without asking.
.PARAMETER NoMcp
  Nie ruszaj wpisow MCP (Claude Code, Claude Desktop, .mcp.json folderu). / Leave the MCP entries
  alone (Claude Code, Claude Desktop, the folder's .mcp.json).
.PARAMETER NoAutostart
  Nie ruszaj wpisu autostartu. / Leave the autostart entry alone.

  Parametry -ShortcutsDir, -RunKeyPath, -ClassesPath, -ClaudeCli, -DataDir, -CacheDir sluza testom
  (HVE_AGENT_HOME kieruje wpisy Claude Desktop do folderu testowego).
  -ShortcutsDir, -RunKeyPath, -ClassesPath, -ClaudeCli, -DataDir, -CacheDir exist for tests
  (HVE_AGENT_HOME points the Claude Desktop entries into a test folder).
#>
[CmdletBinding()]
param(
    [string]$InstallDir,
    [switch]$Purge,
    [switch]$Yes,
    [switch]$Force,
    [switch]$NoMcp,
    [switch]$NoAutostart,
    [string]$ShortcutsDir,
    [string]$RunKeyPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run',
    [string]$ClassesPath = 'HKCU:\Software\Classes',
    [string]$ClaudeCli,
    [string]$DataDir,
    [string]$CacheDir
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$AppName = 'HEXART Video Edit'
$RunValueName = 'HEXART Video Edit agent server'
$McpName = 'hexart-video-edit'
$UrlScheme = 'hve'
$InstallMarker = '.hve-install'

# Messages carry \uXXXX escapes instead of Polish letters: this file is plain ASCII, so Windows
# PowerShell 5.1 reads it the same from a file, from irm | iex, with or without a BOM.
function U {
    param([string]$Text)
    return [regex]::Replace($Text, '\\u([0-9a-fA-F]{4})', { param($m) [string][char][Convert]::ToInt32($m.Groups[1].Value, 16) })
}

function Fail {
    param([string]$Pl, [string]$En)
    throw (U "$Pl`n$En")
}

function Say {
    param([string]$Pl, [string]$En, [string]$Kind = 'info')
    $color = 'White'
    if ($Kind -eq 'ok') { $color = 'Green' } elseif ($Kind -eq 'warn') { $color = 'Yellow' } elseif ($Kind -eq 'err') { $color = 'Red' }
    Write-Host (U $Pl) -ForegroundColor $color
    Write-Host (U $En) -ForegroundColor DarkGray
}

function Ask {
    param([string]$Pl, [string]$En, [bool]$Default)
    if ($Yes) { return $Default }
    $interactive = $true
    try { if ([Console]::IsInputRedirected) { $interactive = $false } } catch { }
    if (-not $interactive) { return $Default }
    $hint = '[t/N | y/N]'
    if ($Default) { $hint = '[T/n | Y/n]' }
    Write-Host (U $Pl) -ForegroundColor White
    Write-Host (U $En) -ForegroundColor DarkGray
    $a = Read-Host $hint
    if ($a -match '^\s*(t|y|tak|yes)') { return $true }
    if ($a -match '^\s*(n|nie|no)') { return $false }
    return $Default
}

function Get-Procs {
    param([string]$Dir)
    $names = @('hexart-video-edit', 'hve', 'hve-vfi', 'hve-braw', 'hve-r3d', 'ffmpeg', 'ffprobe')
    $prefix = $Dir.TrimEnd('\') + '\'
    $found = @()
    foreach ($p in @(Get-Process -Name $names -ErrorAction SilentlyContinue)) {
        $path = $null
        try { $path = $p.Path } catch { }
        if ($path -and $path.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) { $found += $p }
    }
    return $found
}

function Wait-Gone {
    param([string]$Dir, [string[]]$Names, [int]$Seconds)
    $end = (Get-Date).AddSeconds($Seconds)
    do {
        $left = @(Get-Procs $Dir | Where-Object { $Names -contains $_.Name })
        if ($left.Count -eq 0) { return $true }
        Start-Sleep -Milliseconds 400
    } while ((Get-Date) -lt $end)
    return $false
}

function Stop-Hve {
    param([string]$Dir)
    $running = @(Get-Procs $Dir)
    if ($running.Count -eq 0) { return }

    $windows = @($running | Where-Object { $_.Name -eq 'hexart-video-edit' -and $_.MainWindowHandle -ne 0 })
    if ($windows.Count -gt 0) {
        $ok = $Force -or (Ask 'Program HEXART Video Edit jest otwarty. Zamkn\u0105\u0107 go teraz? (zapyta o niezapisane zmiany)' 'HEXART Video Edit is open. Close it now? (it will ask about unsaved changes)' $true)
        if (-not $ok) { Fail 'Zamknij HEXART Video Edit i uruchom skrypt ponownie.' 'Close HEXART Video Edit and run the script again.' }
        foreach ($w in $windows) { [void]$w.CloseMainWindow() }
        [void](Wait-Gone $Dir @('hexart-video-edit') 60)
        if (@(Get-Procs $Dir | Where-Object { $_.Name -eq 'hexart-video-edit' -and $_.MainWindowHandle -ne 0 }).Count -gt 0) {
            Fail 'Okno programu nadal jest otwarte. Zamknij je i uruchom skrypt ponownie.' 'The editor window is still open. Close it and run the script again.'
        }
    }

    $bg = @(Get-Procs $Dir | Where-Object { $_.Name -eq 'hexart-video-edit' })
    if ($bg.Count -gt 0) {
        $hve = Join-Path $Dir 'hve.exe'
        if (Test-Path -LiteralPath $hve) {
            Say 'Zatrzymuj\u0119 serwer agenta w tle...' 'Stopping the background agent server...'
            try {
                $proc = Start-Process -FilePath $hve -ArgumentList @('mcp', '--stop') -WindowStyle Hidden -PassThru
                if (-not $proc.WaitForExit(30000)) { try { $proc.Kill() } catch { } }
            } catch { }
        }
        if (-not (Wait-Gone $Dir @('hexart-video-edit') 30)) {
            $kill = $Force -or (Ask 'Serwer agenta w tle nie zatrzyma\u0142 si\u0119 sam. Zako\u0144czy\u0107 proces?' 'The background agent server did not stop by itself. End the process?' $false)
            if (-not $kill) { Fail 'Zatrzymaj proces hexart-video-edit.exe i uruchom skrypt ponownie.' 'Stop hexart-video-edit.exe and run the script again.' }
            foreach ($p in @(Get-Procs $Dir | Where-Object { $_.Name -eq 'hexart-video-edit' })) { try { $p.Kill() } catch { } }
            [void](Wait-Gone $Dir @('hexart-video-edit') 10)
        }
    }

    if (-not (Wait-Gone $Dir @('hve-vfi', 'hve-braw', 'hve-r3d', 'ffmpeg', 'ffprobe') 20)) {
        $kill = $Force -or (Ask 'Procesy pomocnicze (FFmpeg, dekodery) jeszcze pracuj\u0105. Zako\u0144czy\u0107 je?' 'Helper processes (FFmpeg, decoders) are still running. End them?' $true)
        if (-not $kill) { Fail 'Poczekaj na koniec zada\u0144 i uruchom skrypt ponownie.' 'Wait for the jobs to finish and run the script again.' }
        foreach ($p in @(Get-Procs $Dir | Where-Object { @('hve-vfi', 'hve-braw', 'hve-r3d', 'ffmpeg', 'ffprobe') -contains $_.Name })) { try { $p.Kill() } catch { } }
    }
    # hve.exe (the MCP relay of a Claude Code session) may still run; its file is renamed
    # below like in the installer, and the session ends with Claude Code.
}

function Find-Claude {
    if ($ClaudeCli) { if (Test-Path -LiteralPath $ClaudeCli) { return $ClaudeCli } else { return $null } }
    $c = Get-Command claude -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($c) { return $c.Source }
    return $null
}

function Remove-Tree {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return }
    try { Remove-Item -LiteralPath $Path -Recurse -Force }
    catch { Say "Nie mog\u0119 usun\u0105\u0107 $Path ($($_.Exception.Message))." "Cannot delete $Path ($($_.Exception.Message))." 'warn' }
}

function Get-DataDir {
    if ($DataDir) { return $DataDir }
    if ($env:HVE_APP_DIR) { return $env:HVE_APP_DIR }
    return (Join-Path $env:APPDATA 'HEXART\HEXART Video Edit')
}

function Invoke-Agent {
    # hve.exe agent ...: JSON on stdout; $null when it could not run.
    param([string]$Hve, [string[]]$AgentArgs)
    $old = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $out = & $Hve @('agent') @AgentArgs 2>$null | Out-String
        if ($LASTEXITCODE -ne 0) { return $null }
        return ($out | ConvertFrom-Json)
    } catch { return $null } finally { $ErrorActionPreference = $old }
}

function Main {
    if (-not $InstallDir) {
        $InstallDir = Join-Path $env:LOCALAPPDATA "Programs\$AppName"
        # The copy of this script inside an installation in another folder removes that one.
        if ($PSScriptRoot -and (Test-Path -LiteralPath (Join-Path $PSScriptRoot $InstallMarker))) { $InstallDir = $PSScriptRoot }
    }
    $InstallDir = [IO.Path]::GetFullPath($InstallDir)
    Say "HEXART Video Edit: usuwanie z $InstallDir" "HEXART Video Edit: removing from $InstallDir"

    if (-not $Yes) {
        if (-not (Ask 'Usun\u0105\u0107 HEXART Video Edit z tego komputera?' 'Remove HEXART Video Edit from this computer?' $true)) {
            Say 'Anulowano.' 'Cancelled.'
            return
        }
    }

    # ---- processes ---------------------------------------------------------------------
    if (Test-Path -LiteralPath $InstallDir) { Stop-Hve $InstallDir }

    # ---- autostart ---------------------------------------------------------------------
    if (-not $NoAutostart) {
        $has = $false
        if (Test-Path -LiteralPath $RunKeyPath) {
            $has = $null -ne (Get-ItemProperty -Path $RunKeyPath -Name $RunValueName -ErrorAction SilentlyContinue)
        }
        if ($has) {
            Remove-ItemProperty -Path $RunKeyPath -Name $RunValueName -ErrorAction SilentlyContinue
            Say 'Autostart serwera agenta: usuni\u0119ty.' 'Agent server autostart: removed.' 'ok'
        }
    }

    # ---- hve:// links: only when they open this installation ------------------------------
    $schemeKey = Join-Path $ClassesPath $UrlScheme
    $cmdKey = "$schemeKey\shell\open\command"
    if (Test-Path -LiteralPath $cmdKey) {
        $cmd = [string](Get-ItemProperty -LiteralPath $cmdKey -ErrorAction SilentlyContinue).'(default)'
        $ours = '"' + (Join-Path $InstallDir 'hexart-video-edit.exe') + '"'
        if ($cmd -and $cmd.StartsWith($ours, [StringComparison]::OrdinalIgnoreCase)) {
            Remove-Item -LiteralPath $schemeKey -Recurse -Force -ErrorAction SilentlyContinue
            Say 'Linki hve://: usuni\u0119te.' 'hve:// links: removed.' 'ok'
        }
    }

    # ---- MCP in Claude Code -----------------------------------------------------------------
    if (-not $NoMcp) {
        $claude = Find-Claude
        if ($claude) {
            $old = $ErrorActionPreference
            $ErrorActionPreference = 'Continue'
            try {
                $out = & $claude mcp remove --scope user $McpName 2>&1 | Out-String
                $code = $LASTEXITCODE
            } finally { $ErrorActionPreference = $old }
            if ($code -eq 0) { Say 'Rejestracja MCP w Claude Code: usuni\u0119ta.' 'Claude Code MCP registration: removed.' 'ok' }
        }
        # Claude Desktop and the one folder chosen in Preferences > Agent: only entries that
        # start this installation (another copy keeps its own).
        $hve = Join-Path $InstallDir 'hve.exe'
        if (Test-Path -LiteralPath $hve) {
            $r = Invoke-Agent $hve @('disconnect', 'claude-desktop', '--if-current')
            if ($r -and $r.changed) { Say 'Wpis w Claude Desktop: usuni\u0119ty (kopia konfiguracji obok pliku).' 'Claude Desktop entry: removed (a backup sits next to its config).' 'ok' }
            $prefsFile = Join-Path (Get-DataDir) 'prefs.json'
            $folder = $null
            if (Test-Path -LiteralPath $prefsFile) {
                try { $folder = [string](Get-Content -LiteralPath $prefsFile -Raw | ConvertFrom-Json).agent_code_folder } catch { }
            }
            if ($folder -and (Test-Path -LiteralPath $folder)) {
                $r = Invoke-Agent $hve @('disconnect', 'claude-code', '--folder', $folder, '--if-current')
                if ($r -and $r.changed) { Say "Wpis w $folder\.mcp.json: usuni\u0119ty." "Entry in $folder\.mcp.json: removed." 'ok' }
            }
        }
    }

    # ---- shortcuts ------------------------------------------------------------------------
    $startDir = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs'
    $deskDir = [Environment]::GetFolderPath('Desktop')
    if ($ShortcutsDir) {
        $startDir = Join-Path $ShortcutsDir 'Programs'
        $deskDir = Join-Path $ShortcutsDir 'Desktop'
    }
    foreach ($lnk in @((Join-Path $startDir "$AppName.lnk"), (Join-Path $deskDir "$AppName.lnk"))) {
        if (Test-Path -LiteralPath $lnk) { Remove-Item -LiteralPath $lnk -Force -ErrorAction SilentlyContinue }
    }

    # ---- program files: only what the installer put there ------------------------------------
    if (Test-Path -LiteralPath $InstallDir) {
        $files = @('hexart-video-edit.exe', 'hve.exe', 'hve-vfi.exe', 'hve-braw.exe', 'LICENSE.txt', 'THIRD-PARTY-NOTICES.txt', 'README.txt', 'install.ps1', 'uninstall.ps1', $InstallMarker)
        foreach ($f in $files) {
            foreach ($suffix in @('', '.old')) {
                $p = Join-Path $InstallDir ($f + $suffix)
                if (Test-Path -LiteralPath $p) {
                    try { Remove-Item -LiteralPath $p -Force }
                    catch {
                        # A running exe cannot be deleted but can be renamed; it goes with the next reboot or restart of its session.
                        try { Rename-Item -LiteralPath $p -NewName ((Split-Path $p -Leaf) + '.del-' + [guid]::NewGuid().ToString('N').Substring(0, 6)) -Force } catch { }
                    }
                }
            }
        }
        foreach ($stale in @(Get-ChildItem -LiteralPath $InstallDir -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -like '*.exe.old.*' -or $_.Name -like '*.del-*' })) {
            Remove-Item -LiteralPath $stale.FullName -Force -ErrorAction SilentlyContinue
        }
        Remove-Tree (Join-Path $InstallDir 'ffmpeg')
        Remove-Tree (Join-Path $InstallDir 'licenses')
        $left = @(Get-ChildItem -LiteralPath $InstallDir -Force -ErrorAction SilentlyContinue)
        if ($left.Count -eq 0) {
            Remove-Item -LiteralPath $InstallDir -Force -ErrorAction SilentlyContinue
            Say 'Pliki programu: usuni\u0119te.' 'Program files: removed.' 'ok'
        } else {
            $names = ($left | ForEach-Object { $_.Name }) -join ', '
            Say "Pliki programu usuni\u0119te. W folderze zosta\u0142o co\u015b, czego instalator nie za\u0142o\u017cy\u0142: $names" "Program files removed. Left in the folder (not installed by us): $names" 'warn'
        }
    } else {
        Say 'Folder instalacji nie istnieje, nic do usuni\u0119cia.' 'The install folder does not exist, nothing to remove.'
    }

    # ---- user data --------------------------------------------------------------------------
    $DataDir = Get-DataDir
    if (-not $CacheDir) { $CacheDir = Join-Path $env:LOCALAPPDATA 'HEXART\HEXART Video Edit' }
    if ($Purge) {
        Remove-Tree $DataDir
        Remove-Tree $CacheDir
        Say 'Ustawienia i cache programu: usuni\u0119te. Projekty wideo nietkni\u0119te.' 'App settings and cache: deleted. Your video projects are untouched.' 'ok'
    } else {
        Say "Ustawienia ($DataDir) i cache ($CacheDir) zostaj\u0105. Usu\u0144 je ponownie z -Purge, je\u015bli chcesz." "Settings ($DataDir) and cache ($CacheDir) stay. Run again with -Purge to delete them."
    }
    Say 'Gotowe.' 'Done.' 'ok'
}

Main
