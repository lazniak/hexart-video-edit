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
  Folder instalacji. Bez niego pierwsza instalacja pyta o folder (Enter = domyslny
  %LOCALAPPDATA%\Programs\HEXART Video Edit), a istniejaca jest aktualizowana tam, gdzie jest.
  Install folder. Without it a first install asks for the folder (Enter = the default
  %LOCALAPPDATA%\Programs\HEXART Video Edit) and an existing one is updated where it is.
.PARAMETER ZipPath
  Lokalny zip zamiast pobierania (obok moze lezec plik .sha256). / Local zip instead of a download.
  Bez -ZipPath i -Version skrypt uruchomiony z rozpakowanej paczki (obok hexart-video-edit.exe)
  instaluje pliki z tego folderu. / Without -ZipPath and -Version, run from an unpacked package
  (next to hexart-video-edit.exe), the script installs the files of that folder.
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
  Nie pytaj: domyslne odpowiedzi (folder domyslny, MCP tak, jesli jest `claude`; autostart tylko
  z -Autostart). / Do not ask: default answers (the default folder, MCP yes when `claude` exists;
  autostart only with -Autostart).
.PARAMETER Force
  Zamknij uruchomione procesy HEXART bez pytania (po lagodnej probie). / Stop running HEXART
  processes without asking (after a graceful attempt).

  Linki wspolpracy hve:// otwieraja program: schemat URL jest rejestrowany dla biezacego
  uzytkownika (HKCU\Software\Classes\hve, bez praw administratora).
  Collaboration links (hve://) open the app: the URL scheme is registered for the current user
  (HKCU\Software\Classes\hve, no administrator rights).

  Program jest wpisany w "Zainstalowane aplikacje" biezacego uzytkownika (HKCU\...\Uninstall),
  wiec odinstalowuje sie z menu Start (prawy klik, Odinstaluj) albo skrotem "Odinstaluj HEXART
  Video Edit" w jego folderze menu Start. / The app is listed in the user's "Installed apps"
  (HKCU\...\Uninstall): uninstall it from the Start menu (right-click, Uninstall) or with the
  "Uninstall HEXART Video Edit" shortcut in its Start menu folder.

  Parametry -ApiBase, -ShortcutsDir, -RunKeyPath, -ClassesPath, -UninstallKeyPath, -ClaudeCli
  sluza testom (HVE_INSTALL_FORCE_ASK=1 pyta takze bez konsoli).
  -ApiBase, -ShortcutsDir, -RunKeyPath, -ClassesPath, -UninstallKeyPath, -ClaudeCli exist for
  tests (HVE_INSTALL_FORCE_ASK=1 asks even without a console).
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
    [string]$UninstallKeyPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\HEXARTVideoEdit',
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
$InstallMarker = '.hve-install'              # marks a folder as an installation
$UrlScheme = 'hve'                          # the same values the app writes at start
$UrlSchemeName = 'URL:HEXART Video Edit'
# The entry in "Installed apps"; the app keeps DisplayVersion current at start with the same
# values (hve_os::uninstall).
$Publisher = 'HEXART sp. z o.o.'
$HelpUrl = 'https://github.com/lazniak/hexart-video-edit'
# What Move-Aside renames to <name>.old[.<6 hex>]; the app's own cleanup at start knows the
# same names.
$AsideNames = @('hexart-video-edit.exe', 'hve.exe', 'hve-vfi.exe', 'hve-braw.exe', 'hve-decklink.exe', 'hve-r3d.exe', 'ffmpeg', 'library')
# Every entry the program keeps at the root of its folder (what an automatic update may rename
# to <name>.old-<version>).
$ProgramNames = $AsideNames + @('LICENSE.txt', 'THIRD-PARTY-NOTICES.txt', 'README.txt', 'install.ps1', 'uninstall.ps1', 'licenses', 'update')
# An uninstall that could not finish leaves this name instead of the marker.
$UninstallingMarker = '.hve-uninstalling'
# The files of a packaged copy: an install made before the marker existed (v0.14.0 to v0.18.1,
# and every copy the automatic update kept current) has them and no marker.
$PackagedFiles = @('THIRD-PARTY-NOTICES.txt', 'hexart-video-edit.exe', 'hve.exe')

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

# Questions need a person at a console: never with -Yes, never with redirected input (irm | iex
# keeps the console; a scheduled task or CI does not). HVE_INSTALL_FORCE_ASK=1 asks anyway
# (tests answer through a Read-Host function of their own).
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
    if (-not (Wait-Gone $Dir @('hve-vfi', 'hve-braw', 'hve-decklink', 'hve-r3d', 'ffmpeg', 'ffprobe') 20)) {
        $kill = $Force -or (Ask 'Procesy pomocnicze (FFmpeg, dekodery) jeszcze pracuj\u0105. Zako\u0144czy\u0107 je?' 'Helper processes (FFmpeg, decoders) are still running. End them?' $true)
        if (-not $kill) { Fail 'Poczekaj na koniec zada\u0144 i uruchom instalator ponownie.' 'Wait for the jobs to finish and run the installer again.' }
        # A killed process holds its exe and DLLs until it is really gone.
        foreach ($p in @(Get-Procs $Dir | Where-Object { @('hve-vfi', 'hve-braw', 'hve-decklink', 'hve-r3d', 'ffmpeg', 'ffprobe') -contains $_.Name })) { try { $p.Kill(); [void]$p.WaitForExit(10000) } catch { } }
    }
    # hve.exe may stay: it is the MCP relay of a Claude Code session. Its exe, and whatever
    # else a process still holds, is moved aside below (Move-Aside). That session needs a
    # restart afterwards.
}

# A folder entry that is a link (a junction or a symbolic link): removed or moved as a link,
# never entered.
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
# Remove-Item -Recurse goes into a junction or a directory symlink and deletes what it points
# to. Goes on past what is in use; an error when something stayed.
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

# Deletes a file or folder as far as Windows lets; $true when it is gone.
function Remove-Entry {
    param([string]$Path)
    if (Test-Path -LiteralPath $Path) { try { Remove-TreeSafe $Path } catch { } }
    return -not (Test-Path -LiteralPath $Path)
}

# Moves every file under folder $From to the same place under $To; a link moves as a link.
function Move-Files {
    param([string]$From, [string]$To)
    foreach ($c in @((New-Object IO.DirectoryInfo $From).GetFileSystemInfos())) {
        $dst = Join-Path $To $c.Name
        if ($c -is [IO.DirectoryInfo] -and -not (Test-Link $c)) { Move-Files $c.FullName $dst; continue }
        New-Item -ItemType Directory -Force -Path $To | Out-Null
        if ($c -is [IO.DirectoryInfo]) { [IO.Directory]::Move($c.FullName, $dst) }
        else { Move-Item -LiteralPath $c.FullName -Destination $dst -Force }
    }
}

# Windows does not delete a file a running process has loaded (a running exe, the DLLs of
# a running FFmpeg, whichever process loaded them), but it lets the file and its folder be
# renamed. So nothing is deleted in place: an entry to replace goes aside to <name>.old
# (<name>.old.<6 hex> while that is taken) and Remove-Leftovers deletes it once nothing
# holds it. A folder some process works in (its current folder) cannot be renamed: its
# files go aside one by one and the emptied folder takes the new ones. A file open without
# delete sharing cannot even be renamed: then the install stops and puts everything back.
function Move-Aside {
    param([string]$Path)
    $old = "$Path.old"
    if (Test-Path -LiteralPath $old) { [void](Remove-Entry $old) }
    while (Test-Path -LiteralPath $old) { $old = "$Path.old." + [guid]::NewGuid().ToString('N').Substring(0, 6) }
    $aside = [pscustomobject]@{ Target = $Path; Old = $old }
    try {
        Move-Item -LiteralPath $Path -Destination $old
        return $aside
    } catch {
        if (-not (Test-Path -LiteralPath $Path -PathType Container)) { throw }
    }
    try {
        Move-Files $Path $old
    } catch {
        $reason = $_.Exception.Message
        try { Move-Files $old $Path } catch { }
        [void](Remove-Entry $old)
        Fail "Plik w $Path jest otwarty w innym programie, kt\u00f3ry nie pozwala zmieni\u0107 jego nazwy. Zamknij ten program i uruchom instalator ponownie. ($reason)" "A file in $Path is open in another program that does not let it be renamed. Close that program and run the installer again."
    }
    return $aside
}

# Puts an entry moved aside back (the install failed): the new copy goes, the old one
# takes its name again (into the same folder, when that folder could not move).
function Restore-Aside {
    param($Aside)
    [void](Remove-Entry $Aside.Target)
    if ((Test-Path -LiteralPath $Aside.Target -PathType Container) -and (Test-Path -LiteralPath $Aside.Old -PathType Container)) {
        Move-Files $Aside.Old $Aside.Target
        [void](Remove-Entry $Aside.Old)
    } else {
        Move-Item -LiteralPath $Aside.Old -Destination $Aside.Target -Force
    }
}

# Copies the content of folder $From into folder $To (made when missing).
function Copy-Tree {
    param([string]$From, [string]$To)
    New-Item -ItemType Directory -Force -Path $To | Out-Null
    foreach ($c in @(Get-ChildItem -LiteralPath $From -Force)) { Copy-Item -LiteralPath $c.FullName -Destination $To -Recurse -Force }
}

# Removes what earlier installs and updates moved aside: <name>.old and <name>.old.<6 hex>
# (Move-Aside) and <name>.old-<x.y.z>[-n] (the app's automatic update), once <name> is in
# place again. What a process still holds stays; their names come back.
function Remove-Leftovers {
    param([string]$Dir)
    $busy = @()
    foreach ($e in @(Get-ChildItem -LiteralPath $Dir -Force -ErrorAction SilentlyContinue)) {
        $base = $null
        if ($e.Name -match '^(.+)\.old(\.[0-9a-f]{6})?$') {
            if ($AsideNames -contains $Matches[1]) { $base = $Matches[1] }
        } elseif ($e.Name -match '^(.+)\.old-[0-9]+\.[0-9]+\.[0-9]+(-[0-9]+)?$') {
            if ($ProgramNames -contains $Matches[1]) { $base = $Matches[1] }
        }
        if (-not $base -or -not (Test-Path -LiteralPath (Join-Path $Dir $base))) { continue }
        if (-not (Remove-Entry $e.FullName)) { $busy += $e.Name }
    }
    return $busy
}

function New-Shortcut {
    param([string]$Path, [string]$Target, [string]$WorkDir, [string]$Description, [string]$Arguments = '', [string]$Icon = '')
    $dir = Split-Path $Path -Parent
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    $shell = New-Object -ComObject WScript.Shell
    $lnk = $shell.CreateShortcut($Path)
    $lnk.TargetPath = $Target
    if ($Arguments) { $lnk.Arguments = $Arguments }
    $lnk.WorkingDirectory = $WorkDir
    $lnk.Description = $Description
    if ($Icon) { $lnk.IconLocation = $Icon } else { $lnk.IconLocation = "$Target,0" }
    $lnk.Save()
    [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($shell)
}

# The name of the uninstall shortcut in the language of Windows (Polish or English).
function Get-UninstallLinkName {
    $pl = $false
    try { $pl = (Get-UICulture).Name -like 'pl*' } catch { }
    if ($pl) { return 'Odinstaluj HEXART Video Edit.lnk' }
    return 'Uninstall HEXART Video Edit.lnk'
}

# Creates a registry key with every missing parent.
function New-Key {
    param([string]$Path)
    if (Test-Path -LiteralPath $Path) { return }
    $parent = Split-Path $Path -Parent
    if ($parent -and -not (Test-Path -LiteralPath $parent)) { New-Key $parent }
    New-Item -Path $Path -Force | Out-Null
}

# The folder the entry in "Installed apps" names ($null without an entry).
function Get-RegisteredLocation {
    try {
        $loc = [string](Get-ItemProperty -LiteralPath $UninstallKeyPath -Name 'InstallLocation' -ErrorAction Stop).InstallLocation
        if ($loc) { return (Get-FullDir $loc) }
    } catch { }
    return $null
}

# The installation the entry in "Installed apps" points to, when it is still there.
function Get-RegisteredDir {
    $loc = Get-RegisteredLocation
    if ($loc -and ((Test-Marked $loc) -or (Test-PackageFiles $loc))) { return $loc }
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

# A folder with the files of a packaged copy (an unpacked zip has them too).
function Test-PackageFiles {
    param([string]$Dir)
    if (-not $Dir -or -not (Test-Path -LiteralPath $Dir -PathType Container)) { return $false }
    foreach ($f in $PackagedFiles) {
        if (-not (Test-Path -LiteralPath (Join-Path $Dir $f) -PathType Leaf)) { return $false }
    }
    return $true
}

# A folder that holds an installation of the program: a marked one, or one an installer made
# before the marker existed, which has the package files and no marker. An unpacked zip has
# the same files, so without the marker only the default folder and the folder of the entry in
# "Installed apps" count. Installing there again writes the marker.
function Test-Installed {
    param([string]$Dir)
    if (-not $Dir -or -not (Test-Path -LiteralPath $Dir -PathType Container)) { return $false }
    if (Test-Marked $Dir) { return $true }
    if (-not (Test-PackageFiles $Dir)) { return $false }
    $full = Get-FullDir $Dir
    $default = Get-FullDir (Join-Path $env:LOCALAPPDATA "Programs\$AppName")
    if ([string]::Equals($full, $default, [StringComparison]::OrdinalIgnoreCase)) { return $true }
    $reg = Get-RegisteredLocation
    return [bool]($reg -and [string]::Equals($full, $reg, [StringComparison]::OrdinalIgnoreCase))
}

# The program's own name behind an entry at the root of its folder, also when an install or an
# update set it aside (<name>.old, .old.<6 hex>, .old-<x.y.z>[-n], .del-<6 hex>); $null else.
function Get-ProgramBase {
    param([string]$Name, [string[]]$Names)
    $base = $Name
    if ($Name -match '^(.+?)\.(old|old\.[0-9a-f]{6}|old-[0-9]+\.[0-9]+\.[0-9]+(-[0-9]+)?|del-[0-9a-f]{6})$') { $base = $Matches[1] }
    foreach ($n in $Names) { if ([string]::Equals($n, $base, [StringComparison]::OrdinalIgnoreCase)) { return $n } }
    return $null
}

# A full folder path without its trailing separator, except a drive root (D:\ stays D:\, so
# it is never read as "the current folder of drive D:").
function Get-FullDir {
    param([string]$Path)
    $full = [IO.Path]::GetFullPath($Path)
    if ([IO.Path]::GetPathRoot($full) -ne $full) { $full = $full.TrimEnd('\') }
    return $full
}

# A folder that holds something else than an installation (see Test-Installed).
function Test-Foreign {
    param([string]$Dir)
    if (-not (Test-Path -LiteralPath $Dir -PathType Container)) { return $false }
    if (Test-Installed $Dir) { return $false }
    return @(Get-ChildItem -LiteralPath $Dir -Force -ErrorAction SilentlyContinue).Count -gt 0
}

# Where the program goes for the folder $Dir the user named, $null when it cannot go there.
# The program never shares a folder with other files: a drive root, or a folder that holds
# something else than an installation, gets the subfolder "HEXART Video Edit" (refused when
# that one holds other files too), so installing, updating and uninstalling only ever touch
# the program's own folder. The folder must be one the user may write to (Program Files
# needs administrator rights).
function Resolve-InstallTarget {
    param([string]$Dir)
    if ($Dir -notmatch '^([a-zA-Z]:\\|\\\\[^\\]+\\[^\\]+)') {
        Say "To nie jest pe\u0142na \u015bcie\u017cka folderu: $Dir (np. D:\Programy\HEXART Video Edit)." "Not a full folder path: $Dir (e.g. D:\Apps\HEXART Video Edit)." 'warn'
        return $null
    }
    try { $Dir = Get-FullDir $Dir } catch {
        Say "Nieprawid\u0142owa \u015bcie\u017cka: $Dir" "Not a valid path: $Dir" 'warn'
        return $null
    }
    $isRoot = [IO.Path]::GetPathRoot($Dir).TrimEnd('\') -eq $Dir.TrimEnd('\')
    if ($isRoot -or (Test-Foreign $Dir)) {
        $sub = Join-Path $Dir $AppName
        if ($isRoot) {
            Say "Program potrzebuje w\u0142asnego folderu, nie ca\u0142ego dysku: instaluj\u0119 do $sub." "The program needs a folder of its own, not a whole drive: installing to $sub." 'warn'
        } else {
            Say "W folderze $Dir s\u0105 inne pliki: program idzie do w\u0142asnego podfolderu $sub." "The folder $Dir holds other files: the program goes to a subfolder of its own, $sub." 'warn'
        }
        $Dir = $sub
        if (Test-Foreign $Dir) {
            Say "W folderze $Dir te\u017c s\u0105 inne pliki. Wybierz pusty albo nowy folder." "The folder $Dir holds other files too. Choose an empty or a new folder." 'warn'
            return $null
        }
    }
    if ((Test-Path -LiteralPath $Dir) -and -not (Test-Path -LiteralPath $Dir -PathType Container)) {
        Say "$Dir jest plikiem, nie folderem." "$Dir is a file, not a folder." 'warn'
        return $null
    }
    $made = -not (Test-Path -LiteralPath $Dir)
    $probe = Join-Path $Dir ('.hve-write-test-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
    try {
        New-Item -ItemType Directory -Force -Path $Dir | Out-Null
        Set-Content -LiteralPath $probe -Value 'x' -Encoding ASCII
        Remove-Item -LiteralPath $probe -Force
        if ($made) { Remove-Item -LiteralPath $Dir -Force -ErrorAction SilentlyContinue }
        return $Dir
    } catch {
        Remove-Item -LiteralPath $probe -Force -ErrorAction SilentlyContinue
        if ($made) { Remove-Item -LiteralPath $Dir -Force -ErrorAction SilentlyContinue }
        Say "Brak prawa zapisu w $Dir. Wybierz folder w swoim profilu albo na innym dysku (Program Files wymaga praw administratora)." "No permission to write to $Dir. Choose a folder in your profile or on another drive (Program Files needs administrator rights)." 'warn'
        return $null
    }
}

# Asks where to install; Enter keeps the default. Quotes around the path and %VARIABLES% work.
function Read-InstallDir {
    param([string]$Default)
    for ($try = 0; $try -lt 5; $try++) {
        Write-Host ''
        Write-Host (U "Gdzie zainstalowa\u0107 HEXART Video Edit? Enter = $Default") -ForegroundColor White
        Write-Host (U "Where should HEXART Video Edit go? Enter = $Default") -ForegroundColor DarkGray
        Write-Host (U "Folder z innymi plikami albo ca\u0142y dysk dostaje podfolder $AppName. Odinstalowanie usuwa tylko pliki programu.") -ForegroundColor DarkGray
        Write-Host (U "A folder with other files, or a whole drive, gets the subfolder $AppName. Uninstalling removes only the program's files.") -ForegroundColor DarkGray
        $a = Read-Host (U 'Folder')
        if ($null -eq $a) { $a = '' }
        $a = ([string]$a).Trim().Trim('"').Trim("'").Trim()
        if (-not $a) { $a = $Default }
        $a = [Environment]::ExpandEnvironmentVariables($a)
        # A relative answer would land in whatever folder the console is in.
        if ($a -notmatch '^([a-zA-Z]:\\|\\\\)') {
            Say "Podaj pe\u0142n\u0105 \u015bcie\u017ck\u0119, np. D:\Programy\HEXART Video Edit." "Give a full path, e.g. D:\Apps\HEXART Video Edit." 'warn'
            continue
        }
        $full = Resolve-InstallTarget $a
        if ($full) { return $full }
    }
    Fail 'Nie wybrano folderu instalacji.' 'No install folder was chosen.'
}

# The entry in "Installed apps" (Settings > Apps) of the current user: right-click, Uninstall on
# the Start menu entry and the Uninstall button in Settings run uninstall.ps1 of this folder.
function Register-Uninstall {
    param([string]$Dir, [string]$Ver)
    $appExe = Join-Path $Dir 'hexart-video-edit.exe'
    $un = Join-Path $Dir 'uninstall.ps1'
    $ps = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
    $run = '"' + $ps + '" -NoProfile -ExecutionPolicy Bypass -File "' + $un + '" -InstallDir "' + $Dir + '"'
    $sum = (Get-ChildItem -LiteralPath $Dir -Recurse -File -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    $kb = [int][math]::Min([math]::Ceiling([double]$sum / 1KB), [int]::MaxValue)
    New-Key $UninstallKeyPath
    $k = $UninstallKeyPath
    Set-ItemProperty -LiteralPath $k -Name 'DisplayName' -Value $AppName -Type String
    if ($Ver) { Set-ItemProperty -LiteralPath $k -Name 'DisplayVersion' -Value $Ver -Type String }
    Set-ItemProperty -LiteralPath $k -Name 'Publisher' -Value $Publisher -Type String
    Set-ItemProperty -LiteralPath $k -Name 'DisplayIcon' -Value ('"' + $appExe + '",0') -Type String
    Set-ItemProperty -LiteralPath $k -Name 'InstallLocation' -Value $Dir -Type String
    Set-ItemProperty -LiteralPath $k -Name 'UninstallString' -Value ($run + ' -Pause') -Type String
    Set-ItemProperty -LiteralPath $k -Name 'QuietUninstallString' -Value ($run + ' -Yes -Force') -Type String
    Set-ItemProperty -LiteralPath $k -Name 'URLInfoAbout' -Value $HelpUrl -Type String
    Set-ItemProperty -LiteralPath $k -Name 'HelpLink' -Value "$HelpUrl/issues" -Type String
    Set-ItemProperty -LiteralPath $k -Name 'InstallDate' -Value (Get-Date -Format 'yyyyMMdd') -Type String
    Set-ItemProperty -LiteralPath $k -Name 'EstimatedSize' -Value $kb -Type DWord
    Set-ItemProperty -LiteralPath $k -Name 'NoModify' -Value 1 -Type DWord
    Set-ItemProperty -LiteralPath $k -Name 'NoRepair' -Value 1 -Type DWord
    return [pscustomobject]@{ PowerShell = $ps; Script = $un }
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

    if (-not $InstallDir) {
        $default = Join-Path $env:LOCALAPPDATA "Programs\$AppName"
        # An existing installation is updated where it is: the one this copy of the script
        # lives in, the one "Installed apps" points to, the default folder. Only a first
        # install asks where to go.
        $existing = $null
        # The folder of this script only when it is marked: an unpacked zip has the package
        # files too, and is the source of the install, not its target.
        if ($PSScriptRoot -and (Test-Marked $PSScriptRoot)) { $existing = $PSScriptRoot }
        if (-not $existing) { $existing = Get-RegisteredDir }
        if (-not $existing -and (Test-Installed $default)) { $existing = $default }
        if ($existing) {
            $InstallDir = $existing
            Say "Aktualizuj\u0119 instalacj\u0119 w $existing (inny folder: -InstallDir)." "Updating the installation in $existing (another folder: -InstallDir)."
        } elseif (Test-Interactive) {
            $InstallDir = Read-InstallDir $default
        } else {
            $InstallDir = Resolve-InstallTarget $default
            if (-not $InstallDir) { Fail "Nie mo\u017cna instalowa\u0107 w $default." "Cannot install to $default." }
        }
    } else {
        # The same rule as the question: never into a folder that holds other files.
        $asked = [Environment]::ExpandEnvironmentVariables($InstallDir.Trim().Trim('"'))
        $InstallDir = Resolve-InstallTarget $asked
        if (-not $InstallDir) { Fail "Nie mo\u017cna instalowa\u0107 w $asked." "Cannot install to $asked." }
    }
    $InstallDir = Get-FullDir $InstallDir

    Say "HEXART Video Edit: instalacja w $InstallDir" "HEXART Video Edit: installing to $InstallDir"

    $work = Join-Path ([IO.Path]::GetTempPath()) ("hve-install-" + [guid]::NewGuid().ToString('N').Substring(0, 8))
    New-Item -ItemType Directory -Force -Path $work | Out-Null
    try {
        # ---- 1. Source: the unpacked package this script came in, else a zip ------------
        # install.ps1 also ships inside the zip: run from an unpacked package (next to
        # hexart-video-edit.exe and hve.exe) without -ZipPath or -Version, it installs those
        # files. Run from the installation itself (an update copied it there), it downloads.
        $src = $null
        $inPlace = $false
        if (-not $ZipPath -and -not $Version -and $PSScriptRoot) {
            $here = [IO.Path]::GetFullPath($PSScriptRoot).TrimEnd('\')
            $hasExes = (Test-Path -LiteralPath (Join-Path $here 'hexart-video-edit.exe')) -and (Test-Path -LiteralPath (Join-Path $here 'hve.exe'))
            $isTarget = [string]::Equals($here, $InstallDir.TrimEnd('\'), [StringComparison]::OrdinalIgnoreCase)
            if ($hasExes -and -not $isTarget) {
                $src = $here
                Say "Instaluj\u0119 z rozpakowanej paczki: $here" "Installing from the unpacked package: $here"
                # Unpacked from a downloaded zip, the files carry the "from the internet" mark.
                Get-ChildItem -LiteralPath $src -Recurse -File | Unblock-File -ErrorAction SilentlyContinue
            } elseif ($hasExes -and -not (Test-Marked $here)) {
                # A package unpacked straight into the target folder (the default one, say): it
                # is installed where it is, nothing is copied or downloaded. A marked folder is
                # an installation, and its own install.ps1 downloads the latest release.
                $src = $here
                $inPlace = $true
                Say "Instaluj\u0119 rozpakowan\u0105 kopi\u0119 tam, gdzie jest: $here" "Installing the unpacked copy where it is: $here"
                Get-ChildItem -LiteralPath $src -Recurse -File | Unblock-File -ErrorAction SilentlyContinue
            }
        }
        if (-not $src) {
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
        }

        # ---- 3. Stop what runs, replace files ------------------------------------------
        # A folder an older installer marked although it holds other files: the program's
        # folders are still replaced whole (their DLLs belong to one version, D144).
        if (Test-Path -LiteralPath $InstallDir) {
            $own = @($ProgramNames + @($InstallMarker, $UninstallingMarker, 'portable.txt', 'data'))
            $others = @(Get-ChildItem -LiteralPath $InstallDir -Force -ErrorAction SilentlyContinue | Where-Object { -not (Get-ProgramBase $_.Name $own) })
            if ($others.Count -gt 0) {
                $names = ($others | ForEach-Object { $_.Name }) -join ', '
                Say "W folderze $InstallDir s\u0105 te\u017c inne pliki ($names): zostaj\u0105, ale foldery programu ffmpeg\, library\ i update\ s\u0105 podmieniane w ca\u0142o\u015bci." "The folder $InstallDir also holds other files ($names): they stay, but the program's folders ffmpeg\, library\ and update\ are replaced whole." 'warn'
            }
        }
        if (Test-Path -LiteralPath $InstallDir) { Stop-Hve $InstallDir }
        New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

        $moved = @()
        if (-not $inPlace) { try {
            foreach ($f in @(Get-ChildItem -LiteralPath $src -File -Filter '*.exe')) {
                $target = Join-Path $InstallDir $f.Name
                if (Test-Path -LiteralPath $target) { $moved += Move-Aside $target }
                Copy-Item -LiteralPath $f.FullName -Destination $target -Force
            }
            # Bundled FFmpeg (its DLLs belong together) and the web component library (read
            # only, D58): each folder is replaced whole.
            foreach ($name in @('ffmpeg', 'library')) {
                $dirSrc = Join-Path $src $name
                if (-not (Test-Path -LiteralPath $dirSrc)) { continue }
                $dirDst = Join-Path $InstallDir $name
                if (Test-Path -LiteralPath $dirDst) { $moved += Move-Aside $dirDst }
                Copy-Tree $dirSrc $dirDst
            }
            foreach ($name in @('LICENSE.txt', 'THIRD-PARTY-NOTICES.txt', 'README.txt', 'install.ps1', 'uninstall.ps1')) {
                $p = Join-Path $src $name
                if (Test-Path -LiteralPath $p) { Copy-Item -LiteralPath $p -Destination (Join-Path $InstallDir $name) -Force }
            }
            $licSrc = Join-Path $src 'licenses'
            if (Test-Path -LiteralPath $licSrc) { Copy-Item -LiteralPath $licSrc -Destination $InstallDir -Recurse -Force }
        } catch {
            Say 'Instalacja nie powiod\u0142a si\u0119, przywracam poprzednie pliki.' 'Install failed, restoring the previous files.' 'err'
            [array]::Reverse($moved)
            foreach ($m in $moved) { try { Restore-Aside $m } catch { } }
            throw
        } }
        # A staged automatic update and the record of the last one describe the files just
        # replaced: the app must not swap or trust them over this install. A link inside goes
        # as a link.
        $upd = Join-Path $InstallDir 'update'
        if (Test-Path -LiteralPath $upd) { [void](Remove-Entry $upd) }
        # Marks the folder as an installation (its install.ps1 and uninstall.ps1 then work on it).
        Set-Content -LiteralPath (Join-Path $InstallDir $InstallMarker) -Value 'HEXART Video Edit installation' -Encoding ASCII
        $unfinished = Join-Path $InstallDir $UninstallingMarker
        if (Test-Path -LiteralPath $unfinished) { Remove-Item -LiteralPath $unfinished -Force -ErrorAction SilentlyContinue }
        # The old files go now, this install's and earlier ones'; what a process still holds
        # (an agent session's hve.exe, the DLLs it has loaded) waits for a later install or
        # the next start of the app.
        $busy = @(Remove-Leftovers $InstallDir)
        if ($busy.Count -gt 0) {
            Say "Stare pliki wci\u0105\u017c w u\u017cyciu (np. przez sesj\u0119 agenta AI) czekaj\u0105 obok: $($busy -join ', '). Usunie je p\u00f3\u017aniejsza instalacja albo start programu, gdy nic ich ju\u017c nie u\u017cywa." "Old files still in use (e.g. by an AI agent session) wait next to the new ones: $($busy -join ', '). A later install or the next start of the app removes them once nothing uses them."
        }
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
        # The latest install wins (D144): the entry and the Start menu shortcuts point here from
        # now on, also when another installation had them; that one stays and is named.
        $previous = $null
        try {
            $loc = [string](Get-ItemProperty -LiteralPath $UninstallKeyPath -Name 'InstallLocation' -ErrorAction Stop).InstallLocation
            if ($loc) { $previous = Get-FullDir $loc }
        } catch { }
        # Asked before the entry names this folder: an installation without the marker counts
        # only while the entry still names it.
        $previousStays = $previous -and -not [string]::Equals($previous, $InstallDir, [StringComparison]::OrdinalIgnoreCase) -and (Test-Installed $previous)
        # The entry in "Installed apps" comes first: the uninstall shortcut runs the same command.
        $entry = Register-Uninstall $InstallDir $(if ($installed -match '(\d+\.\d+\.\d+)') { $Matches[1] } else { '' })
        Say 'Wpis w Zainstalowanych aplikacjach: gotowy (odinstalowanie z menu Start i z Ustawie\u0144).' 'Entry in Installed apps: done (uninstall from the Start menu and from Settings).' 'ok'
        if ($previousStays) {
            Say "Wpis w Zainstalowanych aplikacjach i skr\u00f3ty w menu Start wskazuj\u0105 teraz na $InstallDir. Instalacja w $previous zostaje: usuniesz j\u0105 jej w\u0142asnym uninstall.ps1, a gdy zniknie ta tutaj, tamta odzyska wpis i skr\u00f3ty przy swoim starcie." "The Installed apps entry and the Start menu shortcuts now point to $InstallDir. The installation in $previous stays: remove it with its own uninstall.ps1. When this one goes, that one takes the entry and the shortcuts back at its next start." 'warn'
        }
        if (-not $NoStartMenu) {
            # A folder of its own: the app and its uninstall shortcut. The shortcut of older
            # installs sat directly in Programs.
            $startFolder = Join-Path $startDir $AppName
            $oldLnk = Join-Path $startDir "$AppName.lnk"
            if (Test-Path -LiteralPath $oldLnk) { Remove-Item -LiteralPath $oldLnk -Force -ErrorAction SilentlyContinue }
            New-Shortcut (Join-Path $startFolder "$AppName.lnk") $appExe $InstallDir 'HEXART Video Edit'
            foreach ($n in @('Uninstall HEXART Video Edit.lnk', 'Odinstaluj HEXART Video Edit.lnk')) {
                $p = Join-Path $startFolder $n
                if (Test-Path -LiteralPath $p) { Remove-Item -LiteralPath $p -Force -ErrorAction SilentlyContinue }
            }
            $unArgs = '-NoProfile -ExecutionPolicy Bypass -File "' + $entry.Script + '" -InstallDir "' + $InstallDir + '" -Pause'
            # Its window works in TEMP: a console in the install folder would keep the folder
            # from being deleted.
            New-Shortcut (Join-Path $startFolder (Get-UninstallLinkName)) $entry.PowerShell ([IO.Path]::GetTempPath()) 'Uninstall HEXART Video Edit' $unArgs "$appExe,0"
            Say 'Skr\u00f3ty w menu Start (program i odinstalowanie): gotowe.' 'Start menu shortcuts (the app and uninstall): done.'
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
        Line '     Claude Desktop i inne / and others: Preferencje > Agent > Pod\u0142\u0105cz / Preferences > Agent > Connect'

        Line '  4. Aktualizacje / Updates: program aktualizuje si\u0119 sam (Preferencje > Aktualizacje) / the app updates itself (Preferences > Updates).'
        Line '  5. Zg\u0142oszenia b\u0142\u0119d\u00f3w / Bug reports: w programie lub https://github.com/lazniak/hexart-video-edit/issues'
        Line "  6. Odinstalowanie / Uninstall: Ustawienia > Aplikacje albo menu Start > $AppName / Settings > Apps or the Start menu > $AppName"
        Write-Host ''
    } finally {
        Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Main
