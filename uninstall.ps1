<#
.SYNOPSIS
  Usuwa HEXART Video Edit / Uninstalls HEXART Video Edit.

.DESCRIPTION
  Zatrzymuje program i serwer agenta w tle, usuwa autostart, rejestracje MCP w Claude Code,
  skroty i pliki programu. Dane uzytkownika (ustawienia, cache) zostaja, chyba ze podasz -Purge.
  Twoich projektow wideo nie dotyka nigdy. Folder, ktory nie jest instalacja programu (bez
  znacznika .hve-install i bez plikow paczki), nie jest ruszany. W folderze z innymi plikami
  usuwa tylko pliki programu po nazwie, a jego podfoldery zostawia.
  Stops the app and the background agent server, removes autostart, the Claude Code MCP
  registration, shortcuts and program files. User data (settings, cache) stays unless -Purge.
  Your video projects are never touched. A folder that is not an installation (no
  .hve-install marker and no package files) is left alone. In a folder that holds other files
  only the program's files go, by name, and its subfolders stay.

  irm https://github.com/lazniak/hexart-video-edit/releases/latest/download/uninstall.ps1 | iex

.PARAMETER InstallDir
  Folder instalacji (domyslnie ten z wpisu w "Zainstalowanych aplikacjach", potem
  %LOCALAPPDATA%\Programs\HEXART Video Edit). / Install folder (default: the one of the entry in
  "Installed apps", then %LOCALAPPDATA%\Programs\HEXART Video Edit).
.PARAMETER Purge
  Usun tez ustawienia, liste ostatnich projektow, pobrane modele i cache programu bez pytania.
  Bez -Purge skrypt pyta (domyslnie zostawia). Folder danych spoza domyslnego miejsca
  (HVE_APP_DIR, kopia przenosna) traci tylko to, co zapisuje program. / Also delete the app
  settings, the list of recent projects, the downloaded models and the cache without asking.
  Without -Purge the script asks (default: keep). A data folder outside the default place
  (HVE_APP_DIR, a portable copy) loses only what the program writes there.
.PARAMETER Yes
  Nie pytaj (ustawienia zostaja, chyba ze -Purge). / Do not ask (settings stay unless -Purge).
.PARAMETER Pause
  Na koncu czekaj na Enter (skrot w menu Start i Ustawienia > Aplikacje uruchamiaja skrypt w
  nowym oknie). / Wait for Enter at the end (the Start menu shortcut and Settings > Apps run the
  script in a new window).
.PARAMETER Force
  Zakoncz procesy HEXART bez pytania (po lagodnej probie). / End HEXART processes without asking.
.PARAMETER NoMcp
  Nie ruszaj wpisow MCP (Claude Code, Claude Desktop, .mcp.json folderu). / Leave the MCP entries
  alone (Claude Code, Claude Desktop, the folder's .mcp.json).
.PARAMETER NoAutostart
  Nie ruszaj wpisu autostartu. / Leave the autostart entry alone.

  Parametry -ShortcutsDir, -RunKeyPath, -ClassesPath, -UninstallKeyPath, -ClaudeCli, -DataDir,
  -CacheDir sluza testom (HVE_AGENT_HOME kieruje wpisy Claude Desktop do folderu testowego,
  HVE_INSTALL_FORCE_ASK=1 pyta takze bez konsoli).
  -ShortcutsDir, -RunKeyPath, -ClassesPath, -UninstallKeyPath, -ClaudeCli, -DataDir, -CacheDir
  exist for tests (HVE_AGENT_HOME points the Claude Desktop entries into a test folder,
  HVE_INSTALL_FORCE_ASK=1 asks even without a console).
#>
[CmdletBinding()]
param(
    [string]$InstallDir,
    [switch]$Purge,
    [switch]$Yes,
    [switch]$Force,
    [switch]$NoMcp,
    [switch]$NoAutostart,
    [switch]$Pause,
    [string]$ShortcutsDir,
    [string]$RunKeyPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run',
    [string]$ClassesPath = 'HKCU:\Software\Classes',
    [string]$UninstallKeyPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\HEXARTVideoEdit',
    [string]$ClaudeCli,
    [string]$DataDir,
    [string]$CacheDir
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
# -DataDir given (tests): HVE_APP_DIR is not used.
$DataDirParam = [bool]$DataDir

$AppName = 'HEXART Video Edit'
$RunValueName = 'HEXART Video Edit agent server'
$McpName = 'hexart-video-edit'
$UrlScheme = 'hve'
$InstallMarker = '.hve-install'
# The marker becomes this name while the uninstall runs and goes last: an uninstall that could
# not finish (a file still in use) can be run again on the same folder.
$UninstallingMarker = '.hve-uninstalling'
# The files of a packaged copy: an install made before the marker existed has them and no marker.
$PackagedFiles = @('THIRD-PARTY-NOTICES.txt', 'hexart-video-edit.exe', 'hve.exe')
# What the program keeps at the root of its folder.
$ProgramFiles = @('hexart-video-edit.exe', 'hve.exe', 'hve-vfi.exe', 'hve-braw.exe', 'hve-decklink.exe', 'hve-r3d.exe', 'LICENSE.txt', 'THIRD-PARTY-NOTICES.txt', 'README.txt', 'install.ps1', 'uninstall.ps1')
$ProgramDirs = @('ffmpeg', 'licenses', 'library', 'update')
# What the program writes into its data folder and into its cache folder, by name (a trailing
# * matches the start of a name). The program holds the same lists (DATA_ENTRIES and
# CACHE_ENTRIES), and one of its tests keeps both equal: a new entry goes into both.
# Recordings made without a project ("recordings") are the user's takes and stay.
$DataEntries = @('prefs.json*', 'projects.json', 'copies.json*', 'workspaces.json', 'layout.json', 'layouts', 'export-presets.json', 'audio-fx-presets.json', 'plugins.json', 'plugin-installs.json', 'agent-server.json', 'agent-exports.json', 'agent-hold', 'agent-notes.md', 'agent-notes.lock', 'mcp-token', 'install-id', 'logs', 'docs', 'bug-reports', 'vfi', 'models', 'sidecars', 'venvs', 'cache')
$CacheEntries = @('.hve-cache.lock', 'adr', 'documents', 'export', 'fonts', 'gallery', 'gop', 'openrouter-gallery', 'proxies', 'render', 'review', 'review-run', 'vfi', 'vst-catalog', 'waveforms', 'web-audio', 'web-profile', 'whatsapp')
# A data or cache folder outside the default place is touched only when it holds one of these.
$DataSigns = @('prefs.json', 'projects.json', 'mcp-token', 'install-id', 'agent-server.json')
$CacheSigns = @('.hve-cache.lock')

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

function Test-Interactive {
    if ($Yes) { return $false }
    if ($env:HVE_INSTALL_FORCE_ASK -eq '1') { return $true }
    try { if ([Console]::IsInputRedirected) { return $false } } catch { }
    return [Environment]::UserInteractive
}

function Ask {
    param([string]$Pl, [string]$En, [bool]$Default)
    if (-not (Test-Interactive)) { return $Default }
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
    $names = @('hexart-video-edit', 'hve', 'hve-vfi', 'hve-braw', 'hve-decklink', 'hve-r3d', 'ffmpeg', 'ffprobe')
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

    if (-not (Wait-Gone $Dir @('hve-vfi', 'hve-braw', 'hve-decklink', 'hve-r3d', 'ffmpeg', 'ffprobe') 20)) {
        $kill = $Force -or (Ask 'Procesy pomocnicze (FFmpeg, dekodery) jeszcze pracuj\u0105. Zako\u0144czy\u0107 je?' 'Helper processes (FFmpeg, decoders) are still running. End them?' $true)
        if (-not $kill) { Fail 'Poczekaj na koniec zada\u0144 i uruchom skrypt ponownie.' 'Wait for the jobs to finish and run the script again.' }
        foreach ($p in @(Get-Procs $Dir | Where-Object { @('hve-vfi', 'hve-braw', 'hve-decklink', 'hve-r3d', 'ffmpeg', 'ffprobe') -contains $_.Name })) { try { $p.Kill() } catch { } }
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

# A folder that must never be deleted whole: a drive root, the user's profile, the system's
# and the user's program and data folders, and every folder above one of them.
function Test-Protected {
    param([string]$Path)
    try { $full = Get-FullDir $Path } catch { return $true }
    if ([IO.Path]::GetPathRoot($full) -eq $full) { return $true }
    $keep = @($env:USERPROFILE, $env:APPDATA, $env:LOCALAPPDATA, $env:ProgramFiles, ${env:ProgramFiles(x86)}, $env:ProgramW6432, $env:ProgramData, $env:SystemRoot, $env:PUBLIC, [IO.Path]::GetTempPath())
    foreach ($k in $keep) {
        if (-not $k) { continue }
        try { $kf = Get-FullDir $k } catch { continue }
        if ([string]::Equals($kf, $full, [StringComparison]::OrdinalIgnoreCase)) { return $true }
        if ($kf.StartsWith($full.TrimEnd('\') + '\', [StringComparison]::OrdinalIgnoreCase)) { return $true }
    }
    return $false
}

# A folder entry that is a link (a junction or a symbolic link): removed as a link, never
# entered.
function Test-Link {
    param($Item)
    return (($Item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0)
}

# Removes one file, or one link as a link (what it points to stays).
function Remove-One {
    param($Item)
    if (($Item.Attributes -band [IO.FileAttributes]::ReadOnly) -ne 0) { $Item.Attributes = $Item.Attributes -band (-bnot [IO.FileAttributes]::ReadOnly) }
    if ($Item -is [IO.DirectoryInfo]) { [IO.Directory]::Delete($Item.FullName, $false) } else { $Item.Delete() }
}

# Deletes a file or a folder tree without following links: Windows PowerShell 5.1's
# Remove-Item -Recurse goes into a junction or a directory symlink (a models folder moved to
# another disk, say) and deletes what it points to. Goes on past what is in use; an error when
# something stayed.
function Remove-TreeSafe {
    param([string]$Path)
    $item = Get-Item -LiteralPath $Path -Force
    if ((Test-Link $item) -or -not $item.PSIsContainer) { Remove-One $item; return }
    foreach ($c in @($item.GetFileSystemInfos())) {
        try {
            if ($c -is [IO.DirectoryInfo] -and -not (Test-Link $c)) { Remove-TreeSafe $c.FullName } else { Remove-One $c }
        } catch { }
    }
    Remove-One $item
}

function Remove-Tree {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return $true }
    if (Test-Protected $Path) {
        Say "$Path to folder systemu albo profilu, nie programu: zostaje." "$Path is a system or profile folder, not the program's: it stays." 'warn'
        return $false
    }
    try { Remove-TreeSafe $Path; return $true }
    catch {
        Say "Nie mog\u0119 usun\u0105\u0107 $Path ($($_.Exception.Message))." "Cannot delete $Path ($($_.Exception.Message))." 'warn'
        return $false
    }
}

# A name in a list of entries ($DataEntries, $CacheEntries).
function Test-Entry {
    param([string]$Name, [string[]]$Entries)
    foreach ($p in $Entries) {
        if ($p.EndsWith('*')) {
            if ($Name.StartsWith($p.TrimEnd('*'), [StringComparison]::OrdinalIgnoreCase)) { return $true }
        } elseif ([string]::Equals($p, $Name, [StringComparison]::OrdinalIgnoreCase)) { return $true }
    }
    return $false
}

# -Purge of a data or cache folder. Its default place goes whole (links inside removed as
# links). Any other folder (HVE_APP_DIR, a portable copy's data, -DataDir) may be the user's
# own: only the entries the program writes go, by name, and only when the folder holds one of
# $Signs; the folder itself goes when nothing else is left, and what stays is named.
function Remove-DataFolder {
    param([string]$Path, [string]$Default, [string[]]$Entries, [string[]]$Signs)
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) { return }
    $full = Get-FullDir $Path
    if (Test-Protected $full) {
        Say "$full to folder systemu albo profilu, nie programu: zostaje." "$full is a system or profile folder, not the program's: it stays." 'warn'
        return
    }
    if ([string]::Equals($full, (Get-FullDir $Default), [StringComparison]::OrdinalIgnoreCase)) {
        [void](Remove-Tree $full)
        return
    }
    if (@($Signs | Where-Object { Test-Path -LiteralPath (Join-Path $full $_) }).Count -eq 0) {
        Say "$full nie wygl\u0105da na folder danych programu (brak $($Signs -join ', ')): zostaje, usu\u0144 go sam, je\u015bli trzeba." "$full does not look like a data folder of the program (no $($Signs -join ', ')): it stays, delete it yourself if needed." 'warn'
        return
    }
    foreach ($e in @(Get-ChildItem -LiteralPath $full -Force -ErrorAction SilentlyContinue)) {
        if (Test-Entry $e.Name $Entries) { [void](Remove-Tree $e.FullName) }
    }
    $left = @(Get-ChildItem -LiteralPath $full -Force -ErrorAction SilentlyContinue)
    if ($left.Count -eq 0) {
        Remove-Item -LiteralPath $full -Force -ErrorAction SilentlyContinue
    } else {
        $names = ($left | ForEach-Object { $_.Name }) -join ', '
        Say "W $full zosta\u0142o to, czego program nie zapisuje (albo co jest w u\u017cyciu): $names" "Left in $full (not written by the program, or in use): $names" 'warn'
    }
}

# A full path (C:\..., D:/..., \\server\share\...), not one relative to the current folder.
function Test-FullPath {
    param([string]$Path)
    return ($Path -match '^[A-Za-z]:[\\/]' -or $Path -match '^[\\/]{2}[^\\/]')
}

function Get-DataDir {
    if ($DataDir) { return $DataDir }
    if ($env:HVE_APP_DIR) { return $env:HVE_APP_DIR }
    # A portable copy (portable.txt next to the exe) keeps its data in its own folder.
    if (Test-Path -LiteralPath (Join-Path $InstallDir 'portable.txt')) { return (Join-Path $InstallDir 'data') }
    return (Join-Path $env:APPDATA 'HEXART\HEXART Video Edit')
}

# The installation the entry in "Installed apps" points to ($null when there is none).
function Get-RegisteredDir {
    try {
        $loc = [string](Get-ItemProperty -LiteralPath $UninstallKeyPath -Name 'InstallLocation' -ErrorAction Stop).InstallLocation
        if ($loc) { return (Get-FullDir $loc) }
    } catch { }
    return $null
}

# A folder with the installer's marker, or the name an unfinished uninstall left.
function Test-Marked {
    param([string]$Dir)
    if (-not $Dir) { return $false }
    foreach ($m in @($InstallMarker, $UninstallingMarker)) {
        if (Test-Path -LiteralPath (Join-Path $Dir $m) -PathType Leaf) { return $true }
    }
    return $false
}

# A folder that holds an installation of the program: a marked one, or one an installer made
# before the marker existed (the package files, no marker). An unpacked zip has the same
# files, so without the marker only the default folder and the folder of the entry in
# "Installed apps" count.
function Test-Installed {
    param([string]$Dir)
    if (-not (Test-Path -LiteralPath $Dir -PathType Container)) { return $false }
    if (Test-Marked $Dir) { return $true }
    foreach ($f in $PackagedFiles) {
        if (-not (Test-Path -LiteralPath (Join-Path $Dir $f) -PathType Leaf)) { return $false }
    }
    $full = Get-FullDir $Dir
    $default = Get-FullDir (Join-Path $env:LOCALAPPDATA "Programs\$AppName")
    if ([string]::Equals($full, $default, [StringComparison]::OrdinalIgnoreCase)) { return $true }
    $reg = Get-RegisteredDir
    return [bool]($reg -and [string]::Equals($full, $reg, [StringComparison]::OrdinalIgnoreCase))
}

# The program's own name behind an entry at the root of its folder, also when an install or
# an update set it aside (the installer's <name>.old and .old.<6 hex>, the update's
# .old-<x.y.z>[-n], this script's .del-<6 hex>); $null for anything else.
function Get-ProgramBase {
    param([string]$Name, [string[]]$Names)
    $base = $Name
    if ($Name -match '^(.+?)\.(old|old\.[0-9a-f]{6}|old-[0-9]+\.[0-9]+\.[0-9]+(-[0-9]+)?|del-[0-9a-f]{6})$') { $base = $Matches[1] }
    foreach ($n in $Names) { if ([string]::Equals($n, $base, [StringComparison]::OrdinalIgnoreCase)) { return $n } }
    return $null
}

# A full folder path without its trailing separator, except a drive root (D:\ stays D:\).
function Get-FullDir {
    param([string]$Path)
    $full = [IO.Path]::GetFullPath($Path)
    if ([IO.Path]::GetPathRoot($full) -ne $full) { $full = $full.TrimEnd('\') }
    return $full
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
        # The copy of this script inside an installation removes that one, else the one
        # "Installed apps" points to, else the default folder.
        # The folder of this script only when it is marked: an unpacked zip has the package
        # files too and is not the installation.
        if ($PSScriptRoot -and (Test-Marked $PSScriptRoot)) { $InstallDir = $PSScriptRoot }
        if (-not $InstallDir) { $InstallDir = Get-RegisteredDir }
        if (-not $InstallDir) { $InstallDir = Join-Path $env:LOCALAPPDATA "Programs\$AppName" }
    }
    $script:InstallDir = Get-FullDir $InstallDir
    $InstallDir = $script:InstallDir
    # Only an installation is uninstalled: never a drive root, never a folder without the
    # marker or the package files (the user's own files could sit there). A folder that is
    # already gone still gets its entry and shortcuts cleaned up.
    if ([IO.Path]::GetPathRoot($InstallDir) -eq $InstallDir) {
        Fail "$InstallDir to ca\u0142y dysk, nie folder programu. Nic nie usuni\u0119to." "$InstallDir is a whole drive, not the program folder. Nothing was removed."
    }
    $installed = Test-Installed $InstallDir
    if ((Test-Path -LiteralPath $InstallDir) -and -not $installed) {
        Fail "W $InstallDir nie ma instalacji HEXART Video Edit (brak znacznika $InstallMarker i plik\u00f3w programu). Nic nie usuni\u0119to." "$InstallDir holds no HEXART Video Edit installation (no $InstallMarker marker, no program files). Nothing was removed."
    }
    Say "HEXART Video Edit: usuwanie z $InstallDir" "HEXART Video Edit: removing from $InstallDir"

    if (-not $Yes) {
        if (-not (Ask 'Usun\u0105\u0107 HEXART Video Edit z tego komputera?' 'Remove HEXART Video Edit from this computer?' $true)) {
            Say 'Anulowano.' 'Cancelled.'
            return
        }
    }
    # Settings and the list of recent projects: asked before anything goes, kept by default.
    # Video projects are never touched.
    $purgeData = [bool]$Purge
    if (-not $purgeData) {
        $purgeData = -not (Ask 'Zachowa\u0107 ustawienia programu, list\u0119 ostatnich projekt\u00f3w i pobrane modele? (projekty wideo zostaj\u0105 zawsze)' 'Keep the app settings, the list of recent projects and the downloaded models? (your video projects always stay)' $true)
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
    # Only shortcuts that start this installation (another copy keeps its own).
    $startFolder = Join-Path $startDir $AppName
    $links = @((Join-Path $startDir "$AppName.lnk"), (Join-Path $deskDir "$AppName.lnk"),
        (Join-Path $startFolder "$AppName.lnk"), (Join-Path $startFolder 'Uninstall HEXART Video Edit.lnk'),
        (Join-Path $startFolder 'Odinstaluj HEXART Video Edit.lnk'))
    $shell = $null
    try { $shell = New-Object -ComObject WScript.Shell } catch { }
    foreach ($lnk in $links) {
        if (-not (Test-Path -LiteralPath $lnk)) { continue }
        $ours = $true
        if ($shell) {
            try {
                $s = $shell.CreateShortcut($lnk)
                $where = ([string]$s.TargetPath + ' ' + [string]$s.Arguments)
                $ours = $where.IndexOf($InstallDir, [StringComparison]::OrdinalIgnoreCase) -ge 0
            } catch { }
        }
        if ($ours) { Remove-Item -LiteralPath $lnk -Force -ErrorAction SilentlyContinue }
    }
    if ($shell) { [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($shell) }
    if ((Test-Path -LiteralPath $startFolder) -and @(Get-ChildItem -LiteralPath $startFolder -Force -ErrorAction SilentlyContinue).Count -eq 0) {
        Remove-Item -LiteralPath $startFolder -Force -ErrorAction SilentlyContinue
    }
    Say 'Skr\u00f3ty: usuni\u0119te.' 'Shortcuts: removed.' 'ok'

    # ---- entry in "Installed apps": only when it points here (or nowhere any more) ------------
    # The marker becomes the "uninstalling" one first: an editor of this folder starting
    # meanwhile no longer counts as installed and cannot write the entry back, while a second
    # run of this script still accepts the folder. It goes last.
    $registered = Get-RegisteredDir
    $markerFile = Join-Path $InstallDir $InstallMarker
    $unfinished = Join-Path $InstallDir $UninstallingMarker
    if ($installed -and (Test-Path -LiteralPath $InstallDir)) {
        try { Set-Content -LiteralPath $unfinished -Value 'HEXART Video Edit uninstall' -Encoding ASCII } catch { }
        if (Test-Path -LiteralPath $markerFile) { Remove-Item -LiteralPath $markerFile -Force -ErrorAction SilentlyContinue }
    }
    if ((Test-Path -LiteralPath $UninstallKeyPath) -and (-not $registered -or [string]::Equals($registered, $InstallDir, [StringComparison]::OrdinalIgnoreCase) -or -not (Test-Path -LiteralPath $registered))) {
        Remove-Item -LiteralPath $UninstallKeyPath -Recurse -Force -ErrorAction SilentlyContinue
        Say 'Wpis w Zainstalowanych aplikacjach: usuni\u0119ty.' 'Entry in Installed apps: removed.' 'ok'
    }

    # ---- program files: only the program's own, by name -------------------------------------
    if ($installed -and (Test-Path -LiteralPath $InstallDir)) {
        # A folder that also holds other entries (an older installer accepted any folder) keeps
        # them and the program's subfolders, which the user may have added files to: only the
        # program's root files go.
        $own = @($ProgramFiles + $ProgramDirs + @($InstallMarker, $UninstallingMarker, 'portable.txt'))
        if (Test-Path -LiteralPath (Join-Path $InstallDir 'portable.txt')) { $own += 'data' }
        $others = @(Get-ChildItem -LiteralPath $InstallDir -Force -ErrorAction SilentlyContinue | Where-Object { -not (Get-ProgramBase $_.Name $own) })
        $shared = $others.Count -gt 0
        foreach ($e in @(Get-ChildItem -LiteralPath $InstallDir -File -Force -ErrorAction SilentlyContinue)) {
            if (-not (Get-ProgramBase $e.Name $ProgramFiles)) { continue }
            try { Remove-Item -LiteralPath $e.FullName -Force }
            catch {
                # A running exe cannot be deleted but can be renamed; it goes with the next reboot or restart of its session.
                if ($e.Name -notmatch '\.del-[0-9a-f]{6}$') {
                    try { Rename-Item -LiteralPath $e.FullName -NewName ($e.Name + '.del-' + [guid]::NewGuid().ToString('N').Substring(0, 6)) -Force } catch { }
                }
            }
        }
        $keptDirs = @()
        foreach ($d in @(Get-ChildItem -LiteralPath $InstallDir -Directory -Force -ErrorAction SilentlyContinue)) {
            if (-not (Get-ProgramBase $d.Name $ProgramDirs)) { continue }
            if ($shared) { $keptDirs += $d.Name } else { [void](Remove-Tree $d.FullName) }
        }
        # What of the program is still there although it should have gone (held by a process):
        # files, and folders unless they were kept on purpose. Then the "uninstalling" name
        # stays, so the next run still accepts the folder.
        $locked = @(Get-ChildItem -LiteralPath $InstallDir -File -Force -ErrorAction SilentlyContinue | Where-Object { Get-ProgramBase $_.Name $ProgramFiles })
        if (-not $shared) {
            $locked += @(Get-ChildItem -LiteralPath $InstallDir -Directory -Force -ErrorAction SilentlyContinue | Where-Object { Get-ProgramBase $_.Name $ProgramDirs })
        }
        if ($locked.Count -eq 0 -and (Test-Path -LiteralPath $unfinished)) { Remove-Item -LiteralPath $unfinished -Force -ErrorAction SilentlyContinue }
        if ($locked.Count -gt 0) {
            Say "Pliki w u\u017cyciu zostan\u0105 do ponownego uruchomienia: $(($locked | ForEach-Object { $_.Name }) -join ', '). Uruchom odinstalowanie jeszcze raz p\u00f3\u017aniej." "Files in use stay until a restart: $(($locked | ForEach-Object { $_.Name }) -join ', '). Run the uninstall again later." 'warn'
        }
        if ($shared) {
            $otherNames = ($others | ForEach-Object { $_.Name }) -join ', '
            Say "Folder $InstallDir zawiera te\u017c inne pliki ($otherNames), wi\u0119c usuni\u0119to tylko pliki programu po nazwie." "The folder $InstallDir also holds other files ($otherNames), so only the program's files were removed, by name." 'warn'
            if ($keptDirs.Count -gt 0) {
                Say "Zosta\u0142y foldery programu: $($keptDirs -join ', '). Mog\u0105 mie\u0107 Twoje pliki; sprawd\u017a je i usu\u0144 sam." "These program folders were left: $($keptDirs -join ', '). They may hold your files; check them and delete them yourself." 'warn'
            }
        }
        $left = @(Get-ChildItem -LiteralPath $InstallDir -Force -ErrorAction SilentlyContinue)
        if ($shared) {
            # Said above.
        } elseif ($left.Count -eq 0) {
            Remove-Item -LiteralPath $InstallDir -Force -ErrorAction SilentlyContinue
            if (Test-Path -LiteralPath $InstallDir) {
                Say "Pliki programu usuni\u0119te. Pusty folder $InstallDir zosta\u0142, bo jaki\u015b program go u\u017cywa (np. otwarte okno konsoli albo Eksploratora). Usu\u0144 go p\u00f3\u017aniej." "Program files removed. The empty folder $InstallDir stays because a program uses it (an open console or Explorer window, for example). Delete it later." 'warn'
            } else {
                Say 'Pliki programu: usuni\u0119te.' 'Program files: removed.' 'ok'
            }
        } else {
            $names = ($left | ForEach-Object { $_.Name }) -join ', '
            Say "Pliki programu usuni\u0119te. W folderze zosta\u0142o co\u015b, czego instalator nie za\u0142o\u017cy\u0142: $names" "Program files removed. Left in the folder (not installed by us): $names" 'warn'
        }
    } else {
        Say 'Folder instalacji nie istnieje, nic do usuni\u0119cia.' 'The install folder does not exist, nothing to remove.'
    }

    # ---- user data --------------------------------------------------------------------------
    $DataDir = Get-DataDir
    if (-not $CacheDir) {
        $CacheDir = Join-Path $env:LOCALAPPDATA 'HEXART\HEXART Video Edit'
        if ($DataDir.StartsWith($InstallDir, [StringComparison]::OrdinalIgnoreCase)) { $CacheDir = Join-Path $DataDir 'cache' }
    }
    if ($purgeData) {
        $defaultData = Join-Path $env:APPDATA "HEXART\$AppName"
        $defaultCache = Join-Path $env:LOCALAPPDATA "HEXART\$AppName"
        if (-not $script:DataDirParam -and $env:HVE_APP_DIR -and -not (Test-FullPath $env:HVE_APP_DIR)) {
            # The program resolved it against its own current folder, unknown here.
            Say "HVE_APP_DIR ($env:HVE_APP_DIR) to \u015bcie\u017cka wzgl\u0119dna: folder danych zostaje. Usu\u0144 go sam albo podaj pe\u0142n\u0105 \u015bcie\u017ck\u0119." "HVE_APP_DIR ($env:HVE_APP_DIR) is a relative path: the data folder stays. Delete it yourself or give a full path." 'warn'
        } else {
            Remove-DataFolder $DataDir $defaultData $DataEntries $DataSigns
        }
        Remove-DataFolder $CacheDir $defaultCache $CacheEntries $CacheSigns
        $marker = Join-Path $InstallDir 'portable.txt'
        if (Test-Path -LiteralPath $marker) { Remove-Item -LiteralPath $marker -Force -ErrorAction SilentlyContinue }
        if ($installed -and (Test-Path -LiteralPath $InstallDir) -and @(Get-ChildItem -LiteralPath $InstallDir -Force -ErrorAction SilentlyContinue).Count -eq 0) {
            Remove-Item -LiteralPath $InstallDir -Force -ErrorAction SilentlyContinue
        }
        Say 'Ustawienia, lista ostatnich projekt\u00f3w, pobrane modele i cache programu: usuni\u0119te (poza tym, co wy\u017cej zosta\u0142o). Projekty wideo nietkni\u0119te.' 'App settings, the list of recent projects, the downloaded models and the cache: deleted (except what is named above). Your video projects are untouched.' 'ok'
    } else {
        Say "Ustawienia ($DataDir) i cache ($CacheDir) zostaj\u0105 na wypadek ponownej instalacji. Usu\u0144 je ponownie z -Purge, je\u015bli chcesz." "Settings ($DataDir) and cache ($CacheDir) stay for a later install. Run again with -Purge to delete them."
    }
    Say 'Gotowe.' 'Done.' 'ok'
}

# The script works in TEMP, so neither its console nor the process the system started it in
# keeps the install folder from being deleted; the caller's folder comes back at the end.
$callerDir = Get-Location
if ($InstallDir) {
    try { $InstallDir = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($InstallDir) } catch { }
}
try {
    Set-Location -LiteralPath ([IO.Path]::GetTempPath())
    [Environment]::CurrentDirectory = [IO.Path]::GetTempPath()
} catch { }
# Started from the Start menu or Settings the window would close at once: it waits for Enter,
# also after an error.
$failedRun = $null
try { Main } catch { $failedRun = $_ }
try { if (Test-Path -LiteralPath $callerDir.Path) { Set-Location -LiteralPath $callerDir.Path } } catch { }
if ($failedRun) { Write-Host ($failedRun.Exception.Message) -ForegroundColor Red }
if ($Pause -and (Test-Interactive)) {
    Write-Host ''
    [void](Read-Host (U 'Enter zamyka okno / Enter closes the window'))
}
# A non-zero exit code only when run from a file: under irm | iex an exit would close the
# user's console before the message could be read.
if ($failedRun -and $PSCommandPath) { exit 1 }
