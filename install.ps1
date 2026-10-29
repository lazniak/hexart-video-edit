<#
.SYNOPSIS
  Instaluje HEXART Video Edit / Installs HEXART Video Edit (Windows 10/11 x64).

.DESCRIPTION
  Pobiera najnowsze wydanie z GitHub Releases (albo wskazane przez -Version), sprawdza SHA-256,
  instaluje do %LOCALAPPDATA%\Programs\HEXART Video Edit, zaklada skrot w menu Start.
  Downloads the latest release (or -Version) from GitHub Releases, verifies SHA-256, installs to
  %LOCALAPPDATA%\Programs\HEXART Video Edit and adds a Start menu shortcut.

  Jedna linia / One line:
    irm https://github.com/lazniak/hexart-video-edit/releases/latest/download/install.ps1 | iex

  Z opcjami / With options:
    & ([scriptblock]::Create((irm https://github.com/lazniak/hexart-video-edit/releases/latest/download/install.ps1))) -Desktop -Autostart

.PARAMETER Version
  Wersja x.y.z (domyslnie najnowsza). / Version x.y.z (default: latest).
.PARAMETER InstallDir
  Folder instalacji. / Install folder.
.PARAMETER ZipPath
  Lokalny zip zamiast pobierania (obok moze lezec plik .sha256). / Local zip instead of a download.
.PARAMETER Desktop
  Dodatkowo skrot na pulpicie. / Also a desktop shortcut.
.PARAMETER Autostart
  Uruchamiaj serwer agenta w tle po zalogowaniu (jak opcja w programie). / Start the background
  agent server at sign-in (same as the option in the app).
.PARAMETER NoAutostart
  Nie pytaj o autostart i go nie zakladaj. / Do not ask about autostart.
.PARAMETER Mcp
  Zarejestruj MCP w Claude Code bez pytania. / Register the MCP in Claude Code without asking.
.PARAMETER NoMcp
  Nie pytaj o MCP i go nie rejestruj. / Do not ask about MCP.
.PARAMETER NoStartMenu
  Bez skrotu w menu Start. / No Start menu shortcut.
.PARAMETER Yes
  Nie pytaj: domyslne odpowiedzi (MCP tak, jesli jest `claude`; autostart tylko z -Autostart).
  Do not ask: default answers (MCP yes when `claude` exists; autostart only with -Autostart).
.PARAMETER Force
  Zamknij uruchomione procesy HEXART bez pytania (po lagodnej probie). / Stop running HEXART
  processes without asking (after a graceful attempt).

  Linki wspolpracy hve:// otwieraja program: schemat URL jest rejestrowany dla biezacego
  uzytkownika (HKCU\Software\Classes\hve, bez praw administratora).
  Collaboration links (hve://) open the app: the URL scheme is registered for the current user
  (HKCU\Software\Classes\hve, no administrator rights).

  Parametry -ApiBase, -ShortcutsDir, -RunKeyPath, -ClassesPath, -ClaudeCli sluza testom.
  -ApiBase, -ShortcutsDir, -RunKeyPath, -ClassesPath, -ClaudeCli exist for tests.
#>
[CmdletBinding()]
param(
    [string]$Version,
    [string]$InstallDir,
    [string]$ZipPath,
    [switch]$Desktop,
    [switch]$Autostart,
    [switch]$NoAutostart,
    [switch]$Mcp,
    [switch]$NoMcp,
    [switch]$NoStartMenu,
    [switch]$Yes,
    [switch]$Force,
    [string]$ApiBase = 'https://api.github.com/repos/lazniak/hexart-video-edit',
    [string]$ShortcutsDir,
    [string]$RunKeyPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run',
    [string]$ClassesPath = 'HKCU:\Software\Classes',
    [string]$ClaudeCli
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
} catch { }

$AppName = 'HEXART Video Edit'
$RunValueName = 'HEXART Video Edit agent server'   # the same value the app writes itself
$McpName = 'hexart-video-edit'
$UrlScheme = 'hve'                          # the same values the app writes at start
$UrlSchemeName = 'URL:HEXART Video Edit'

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

function Line {
    param([string]$Text)
    Write-Host (U $Text)
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

# Closes the editor, stops the background agent server (hve mcp --stop), waits for helpers.
function Stop-Hve {
    param([string]$Dir)
    $running = @(Get-Procs $Dir)
    if ($running.Count -eq 0) { return }

    $windows = @($running | Where-Object { $_.Name -eq 'hexart-video-edit' -and $_.MainWindowHandle -ne 0 })
    if ($windows.Count -gt 0) {
        $ok = $Force -or (Ask 'Program HEXART Video Edit jest otwarty. Zamkn\u0105\u0107 go teraz? (zapyta o niezapisane zmiany)' 'HEXART Video Edit is open. Close it now? (it will ask about unsaved changes)' $true)
        if (-not $ok) { Fail 'Zamknij HEXART Video Edit i uruchom instalator ponownie.' 'Close HEXART Video Edit and run the installer again.' }
        foreach ($w in $windows) { [void]$w.CloseMainWindow() }
        if (-not (Wait-Gone $Dir @('hexart-video-edit') 60)) {
            if (@(Get-Procs $Dir | Where-Object { $_.Name -eq 'hexart-video-edit' -and $_.MainWindowHandle -ne 0 }).Count -gt 0) {
                Fail 'Okno programu nadal jest otwarte. Zamknij je i uruchom instalator ponownie.' 'The editor window is still open. Close it and run the installer again.'
            }
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
            if (-not $kill) { Fail 'Zatrzymaj proces hexart-video-edit.exe i uruchom instalator ponownie.' 'Stop hexart-video-edit.exe and run the installer again.' }
            foreach ($p in @(Get-Procs $Dir | Where-Object { $_.Name -eq 'hexart-video-edit' })) { try { $p.Kill() } catch { } }
            [void](Wait-Gone $Dir @('hexart-video-edit') 10)
        }
    }

    # Helpers (Pixel Motion, RAW decoders, FFmpeg) end with their job.
    if (-not (Wait-Gone $Dir @('hve-vfi', 'hve-braw', 'hve-r3d', 'ffmpeg', 'ffprobe') 20)) {
        $kill = $Force -or (Ask 'Procesy pomocnicze (FFmpeg, dekodery) jeszcze pracuj\u0105. Zako\u0144czy\u0107 je?' 'Helper processes (FFmpeg, decoders) are still running. End them?' $true)
        if (-not $kill) { Fail 'Poczekaj na koniec zada\u0144 i uruchom instalator ponownie.' 'Wait for the jobs to finish and run the installer again.' }
        foreach ($p in @(Get-Procs $Dir | Where-Object { @('hve-vfi', 'hve-braw', 'hve-r3d', 'ffmpeg', 'ffprobe') -contains $_.Name })) { try { $p.Kill() } catch { } }
    }
    # hve.exe may stay: it is the MCP relay of a Claude Code session. Windows lets us rename a
    # running exe, and that is how it is replaced below. That session needs a restart afterwards.
}

function New-Shortcut {
    param([string]$Path, [string]$Target, [string]$WorkDir, [string]$Description)
    $dir = Split-Path $Path -Parent
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    $shell = New-Object -ComObject WScript.Shell
    $lnk = $shell.CreateShortcut($Path)
    $lnk.TargetPath = $Target
    $lnk.WorkingDirectory = $WorkDir
    $lnk.Description = $Description
    $lnk.IconLocation = "$Target,0"
    $lnk.Save()
    [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($shell)
}

function Find-Claude {
    if ($ClaudeCli) { if (Test-Path -LiteralPath $ClaudeCli) { return $ClaudeCli } else { return $null } }
    $c = Get-Command claude -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($c) { return $c.Source }
    return $null
}

function Invoke-Claude {
    param([string]$Cli, [string[]]$CliArgs)
    $old = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $out = & $Cli @CliArgs 2>&1 | Out-String
        $code = $LASTEXITCODE
    } finally { $ErrorActionPreference = $old }
    return [pscustomobject]@{ Code = $code; Output = $out }
}

function Main {
    if ($env:OS -ne 'Windows_NT') { Fail 'Ten instalator jest tylko dla Windows.' 'This installer is for Windows only.' }
    if (-not [Environment]::Is64BitOperatingSystem) { Fail 'Wymagany Windows 64-bit.' '64-bit Windows is required.' }
    if ($Version) { $Version = $Version.TrimStart('v') }

    if (-not $InstallDir) { $InstallDir = Join-Path $env:LOCALAPPDATA "Programs\$AppName" }
    $InstallDir = [IO.Path]::GetFullPath($InstallDir)

    Say "HEXART Video Edit: instalacja w $InstallDir" "HEXART Video Edit: installing to $InstallDir"

    $work = Join-Path ([IO.Path]::GetTempPath()) ("hve-install-" + [guid]::NewGuid().ToString('N').Substring(0, 8))
    New-Item -ItemType Directory -Force -Path $work | Out-Null
    try {
        # ---- 1. Zip + checksum --------------------------------------------------------
        $zip = $null
        $expected = $null
        if ($ZipPath) {
            if (-not (Test-Path -LiteralPath $ZipPath)) { Fail "Brak pliku $ZipPath." "File not found: $ZipPath" }
            $zip = (Resolve-Path -LiteralPath $ZipPath).Path
            $shaFile = "$zip.sha256"
            if (Test-Path -LiteralPath $shaFile) {
                $expected = ((Get-Content -LiteralPath $shaFile -Raw).Trim() -split '\s+')[0].ToLowerInvariant()
            } else {
                Say 'Brak pliku .sha256 obok zipa, pomijam sprawdzanie sumy.' 'No .sha256 next to the zip, skipping the checksum check.' 'warn'
            }
        } else {
            $headers = @{ 'User-Agent' = 'hexart-video-edit-installer'; 'Accept' = 'application/vnd.github+json' }
            $url = "$ApiBase/releases/latest"
            if ($Version) { $url = "$ApiBase/releases/tags/v$Version" }
            Say 'Sprawdzam wydanie na GitHub...' 'Checking the release on GitHub...'
            try { $rel = Invoke-RestMethod -UseBasicParsing -Uri $url -Headers $headers }
            catch { Fail "Nie uda\u0142o si\u0119 pobra\u0107 informacji o wydaniu ($url): $($_.Exception.Message)" "Could not read the release info." }
            $ver = ([string]$rel.tag_name).TrimStart('v')
            $zipName = "hexart-video-edit-$ver-windows-x64.zip"
            $zipAsset = @($rel.assets | Where-Object { $_.name -eq $zipName }) | Select-Object -First 1
            $shaAsset = @($rel.assets | Where-Object { $_.name -eq "$zipName.sha256" }) | Select-Object -First 1
            if (-not $zipAsset) { Fail "Wydanie v$ver nie ma pliku $zipName." "Release v$ver has no $zipName." }
            if (-not $shaAsset) { Fail "Wydanie v$ver nie ma pliku $zipName.sha256, nie instaluj\u0119 bez sumy kontrolnej." "No checksum asset, refusing to install." }
            $sizeMb = [math]::Round($zipAsset.size / 1MB)
            Say "Pobieram wersj\u0119 $ver (oko\u0142o $sizeMb MB)..." "Downloading version $ver (about $sizeMb MB)..."
            $zip = Join-Path $work $zipName
            Invoke-WebRequest -UseBasicParsing -Uri $zipAsset.browser_download_url -OutFile $zip -Headers @{ 'User-Agent' = 'hexart-video-edit-installer' }
            $shaText = (Invoke-WebRequest -UseBasicParsing -Uri $shaAsset.browser_download_url -Headers @{ 'User-Agent' = 'hexart-video-edit-installer' }).Content
            if ($shaText -is [byte[]]) { $shaText = [Text.Encoding]::UTF8.GetString($shaText) }
            $expected = (([string]$shaText).Trim() -split '\s+')[0].ToLowerInvariant()
        }
        if ($expected) {
            $actual = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash.ToLowerInvariant()
            if ($actual -ne $expected) {
                Fail "Suma SHA-256 si\u0119 nie zgadza (jest $actual, powinno by\u0107 $expected). Nic nie zainstalowano." "SHA-256 mismatch. Nothing was installed."
            }
            Say 'Suma SHA-256 zgodna.' 'SHA-256 verified.' 'ok'
        }

        # ---- 2. Unpack ----------------------------------------------------------------
        Say 'Rozpakowuj\u0119...' 'Unpacking...'
        $unz = Join-Path $work 'unz'
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($zip, $unz)
        $exeHit = Get-ChildItem -LiteralPath $unz -Recurse -Filter 'hexart-video-edit.exe' -File | Select-Object -First 1
        if (-not $exeHit) { Fail 'W zipie nie ma hexart-video-edit.exe.' 'hexart-video-edit.exe is not in the zip.' }
        $src = $exeHit.DirectoryName
        Get-ChildItem -LiteralPath $src -Recurse -File | Unblock-File -ErrorAction SilentlyContinue

        # ---- 3. Stop what runs, replace files ------------------------------------------
        if (Test-Path -LiteralPath $InstallDir) { Stop-Hve $InstallDir }
        New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

        $moved = @()
        try {
            foreach ($f in @(Get-ChildItem -LiteralPath $src -File -Filter '*.exe')) {
                $target = Join-Path $InstallDir $f.Name
                $old = "$target.old"
                if (Test-Path -LiteralPath $target) {
                    if (Test-Path -LiteralPath $old) { Remove-Item -LiteralPath $old -Force -ErrorAction SilentlyContinue }
                    if (Test-Path -LiteralPath $old) { $old = "$target.old." + [guid]::NewGuid().ToString('N').Substring(0, 6) }
                    Move-Item -LiteralPath $target -Destination $old -Force
                    $moved += [pscustomobject]@{ Target = $target; Old = $old }
                }
                Copy-Item -LiteralPath $f.FullName -Destination $target -Force
            }
            # Bundled FFmpeg: the whole folder is replaced (its DLLs belong together).
            $ffSrc = Join-Path $src 'ffmpeg'
            if (Test-Path -LiteralPath $ffSrc) {
                $ffDst = Join-Path $InstallDir 'ffmpeg'
                if (Test-Path -LiteralPath $ffDst) { Remove-Item -LiteralPath $ffDst -Recurse -Force }
                Copy-Item -LiteralPath $ffSrc -Destination $ffDst -Recurse -Force
            }
            foreach ($name in @('LICENSE.txt', 'THIRD-PARTY-NOTICES.txt', 'README.txt')) {
                $p = Join-Path $src $name
                if (Test-Path -LiteralPath $p) { Copy-Item -LiteralPath $p -Destination (Join-Path $InstallDir $name) -Force }
            }
            $licSrc = Join-Path $src 'licenses'
            if (Test-Path -LiteralPath $licSrc) { Copy-Item -LiteralPath $licSrc -Destination $InstallDir -Recurse -Force }
        } catch {
            Say 'Instalacja nie powiod\u0142a si\u0119, przywracam poprzednie pliki.' 'Install failed, restoring the previous files.' 'err'
            foreach ($m in $moved) {
                try {
                    if (Test-Path -LiteralPath $m.Target) { Remove-Item -LiteralPath $m.Target -Force }
                    Move-Item -LiteralPath $m.Old -Destination $m.Target -Force
                } catch { }
            }
            throw
        }
        # A staged automatic update and the record of the last one describe the files just
        # replaced: the app must not swap or trust them over this install.
        $upd = Join-Path $InstallDir 'update'
        if (Test-Path -LiteralPath $upd) { Remove-Item -LiteralPath $upd -Recurse -Force -ErrorAction SilentlyContinue }
        Get-ChildItem -LiteralPath $InstallDir -Recurse -File -ErrorAction SilentlyContinue | Unblock-File -ErrorAction SilentlyContinue

        $appExe = Join-Path $InstallDir 'hexart-video-edit.exe'
        $hveExe = Join-Path $InstallDir 'hve.exe'
        $installed = ''
        try {
            $old = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
            $installed = ((& $hveExe --version 2>&1) | Out-String).Trim()
            $ErrorActionPreference = $old
        } catch { }
        Say "Zainstalowano: $installed" "Installed: $installed" 'ok'

        # ---- 4. Shortcuts ---------------------------------------------------------------
        $startDir = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs'
        $deskDir = [Environment]::GetFolderPath('Desktop')
        if ($ShortcutsDir) {
            $startDir = Join-Path $ShortcutsDir 'Programs'
            $deskDir = Join-Path $ShortcutsDir 'Desktop'
        }
        if (-not $NoStartMenu) {
            New-Shortcut (Join-Path $startDir "$AppName.lnk") $appExe $InstallDir 'HEXART Video Edit'
            Say 'Skr\u00f3t w menu Start: gotowy.' 'Start menu shortcut: done.'
        }
        if ($Desktop) {
            New-Shortcut (Join-Path $deskDir "$AppName.lnk") $appExe $InstallDir 'HEXART Video Edit'
            Say 'Skr\u00f3t na pulpicie: gotowy.' 'Desktop shortcut: done.'
        }

        # ---- 4b. hve:// links (collaboration) open this installation ------------------------
        # The same values the app writes itself at start (the scheme module of the editor), so it
        # finds them current and leaves them alone.
        $schemeKey = Join-Path $ClassesPath $UrlScheme
        foreach ($k in @($ClassesPath, $schemeKey, "$schemeKey\DefaultIcon", "$schemeKey\shell", "$schemeKey\shell\open", "$schemeKey\shell\open\command")) {
            if (-not (Test-Path -LiteralPath $k)) { New-Item -Path $k -Force | Out-Null }
        }
        Set-ItemProperty -LiteralPath $schemeKey -Name '(default)' -Value $UrlSchemeName -Type String
        Set-ItemProperty -LiteralPath $schemeKey -Name 'URL Protocol' -Value '' -Type String
        Set-ItemProperty -LiteralPath "$schemeKey\DefaultIcon" -Name '(default)' -Value ('"' + $appExe + '",0') -Type String
        Set-ItemProperty -LiteralPath "$schemeKey\shell\open\command" -Name '(default)' -Value ('"' + $appExe + '" --link "%1"') -Type String
        Say 'Linki hve:// (wsp\u00f3\u0142praca): otwieraj\u0105 program.' 'hve:// links (collaboration): open the app.' 'ok'

        # ---- 5. Autostart of the background agent server (same value as the app) ---------
        $doAuto = $false
        if ($Autostart) { $doAuto = $true }
        elseif (-not $NoAutostart) {
            $doAuto = Ask 'Uruchamia\u0107 serwer agenta w tle po zalogowaniu? (agenci AI, np. Claude Code, \u0142\u0105cz\u0105 si\u0119 wtedy od razu)' 'Start the background agent server at sign-in? (AI agents such as Claude Code can then connect right away)' $false
        }
        if ($doAuto) {
            if (-not (Test-Path -LiteralPath $RunKeyPath)) { New-Item -Path $RunKeyPath -Force | Out-Null }
            Set-ItemProperty -Path $RunKeyPath -Name $RunValueName -Value ('"' + $appExe + '" --background') -Type String
            Say 'Autostart serwera agenta: w\u0142\u0105czony.' 'Agent server autostart: on.' 'ok'
        }

        # ---- 6. MCP for Claude Code --------------------------------------------------------
        $mcpDone = $false
        if (-not $NoMcp) {
            $claude = Find-Claude
            if ($claude) {
                $doMcp = $false
                if ($Mcp) { $doMcp = $true }
                else { $doMcp = Ask 'Zarejestrowa\u0107 HEXART Video Edit jako serwer MCP w Claude Code (zakres u\u017cytkownika)?' 'Register HEXART Video Edit as an MCP server in Claude Code (user scope)?' $true }
                if ($doMcp) {
                    [void](Invoke-Claude $claude @('mcp', 'remove', '--scope', 'user', $McpName))
                    $r = Invoke-Claude $claude @('mcp', 'add', '--scope', 'user', $McpName, '--', $hveExe, 'mcp', '--connect')
                    if ($r.Code -eq 0) {
                        $mcpDone = $true
                        Say 'MCP w Claude Code: zarejestrowany (uruchom ponownie sesj\u0119 Claude Code).' 'MCP in Claude Code: registered (restart your Claude Code session).' 'ok'
                    } else {
                        Say "Nie uda\u0142o si\u0119 zarejestrowa\u0107 MCP: $($r.Output.Trim())" "Could not register the MCP: $($r.Output.Trim())" 'warn'
                    }
                }
            } else {
                Say 'Nie znaleziono polecenia `claude`, pomijam MCP.' 'The `claude` command was not found, skipping MCP.'
            }
        }

        # ---- 7. Next steps ----------------------------------------------------------------
        Write-Host ''
        Say 'Gotowe. Co dalej:' 'Done. Next:' 'ok'
        Line "  1. Uruchom / Start: menu Start > $AppName   ($appExe)"
        Line "  2. CLI / CLI: `"$hveExe`" --help"
        if (-not $mcpDone) {
            Line "  3. Agent AI (Claude Code): claude mcp add --scope user $McpName -- `"$hveExe`" mcp --connect"
        } else {
            Line '  3. Agent AI: serwer MCP jest zarejestrowany / the MCP server is registered.'
        }
        Line '  4. Aktualizacje / Updates: program aktualizuje si\u0119 sam (Preferencje > Aktualizacje) / the app updates itself (Preferences > Updates).'
        Line '  5. Zg\u0142oszenia b\u0142\u0119d\u00f3w / Bug reports: w programie lub https://github.com/lazniak/hexart-video-edit/issues'
        Write-Host ''
    } finally {
        Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Main
