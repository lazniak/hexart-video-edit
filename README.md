# HEXART Video Edit

[Polski](#polski) | [English](#english)

Pobierz / Download: [najnowsze wydanie / latest release](https://github.com/lazniak/hexart-video-edit/releases/latest)

---

## Polski

HEXART Video Edit to edytor wideo dla Windows. Ma oś czasu, korekcję koloru, efekty z wyrażeniami w JavaScript, warstwy web, sekwencje zagnieżdżone, nagrywanie lektora i eksport z gotowymi presetami. Agent AI, na przykład Claude Code, edytuje ten sam projekt co Ty, w tej samej osi czasu i z tą samą historią cofania.

To repozytorium nie zawiera kodu źródłowego. Są tu gotowe wydania, instalator, informacje o wersjach i zgłoszenia błędów. Program jest bezpłatny (freeware), licencja w [LICENSE.txt](LICENSE.txt).

### Wymagania

- Windows 10 albo 11, 64-bit.
- Karta graficzna z DirectX 12.
- RAM: 16 GB wystarczy do FullHD, do 4K zalecane 32 GB.
- Do zakodowania eksportu sprzętowo przydaje się karta NVIDIA (NVENC), AMD (AMF) albo Intel (QSV). Bez nich program koduje procesorem.
- Chrome albo Edge, jeśli używasz warstw web (opcjonalnie).
- FFmpeg jest w paczce, nic nie musisz doinstalowywać.

### Instalacja

Jedna linia w PowerShell:

```powershell
irm https://github.com/lazniak/hexart-video-edit/releases/latest/download/install.ps1 | iex
```

Instalator pobiera najnowszy zip z GitHub Releases, sprawdza sumę SHA-256, instaluje program w `%LOCALAPPDATA%\Programs\HEXART Video Edit` i zakłada skrót w menu Start. Zapyta, czy włączyć autostart serwera agenta i czy zarejestrować MCP w Claude Code. Nie potrzebuje uprawnień administratora.

Opcje (zamiast jednej linii):

```powershell
& ([scriptblock]::Create((irm https://github.com/lazniak/hexart-video-edit/releases/latest/download/install.ps1))) -Version 0.15.0 -Desktop -Autostart -Mcp
```

| Opcja | Co robi |
|---|---|
| `-Version x.y.z` | konkretna wersja zamiast najnowszej |
| `-Desktop` | dodatkowo skrót na pulpicie |
| `-Autostart` / `-NoAutostart` | włącza bez pytania / nie pyta |
| `-Mcp` / `-NoMcp` | rejestruje MCP w Claude Code bez pytania / nie pyta |
| `-Yes` | nie pyta o nic, bierze odpowiedzi domyślne |
| `-InstallDir` | inny folder instalacji |

Ręcznie: pobierz `hexart-video-edit-<wersja>-windows-x64.zip` z [Releases](https://github.com/lazniak/hexart-video-edit/releases), rozpakuj do dowolnego folderu i uruchom `hexart-video-edit.exe`. Obok zipa leży plik `.sha256` do sprawdzenia: `Get-FileHash plik.zip -Algorithm SHA256`. Przy pierwszym uruchomieniu krótki kreator ustawia język, folder projektów i podłącza agenta AI. Rozpakowaną kopię zainstalujesz później instalatorem, który jest w zipie: `powershell -ExecutionPolicy Bypass -File install.ps1` w tym folderze (instaluje pliki z folderu, nic nie pobiera).

### Aktualizacja

Od wersji 0.16.0 program aktualizuje się sam: krótko po starcie i co kilka godzin sprawdza, czy jest nowe wydanie, pobiera je w tle, sprawdza sumę SHA-256 i instaluje, gdy zamykasz edytor (albo gdy serwer agenta w tle nic nie robi). Gdy nowa wersja czeka, na pasku stanu jest przycisk „Aktualizacja X”, który od razu uruchamia program ponownie. Wyłączysz to w Preferencjach, sekcja Aktualizacje. Z wiersza poleceń: `hve update` (albo `hve update --check`).

Ręcznie: uruchom ten sam instalator jeszcze raz. Zamknie program i serwer agenta w tle (jeśli działają), zostawi kopię poprzednich plików jako `*.exe.old` i podmieni pliki. Twoje projekty i ustawienia zostają. Sesję Claude Code uruchom po aktualizacji od nowa.

### Pierwsze kroki

1. Uruchom HEXART Video Edit z menu Start. Utwórz projekt (wybierz pusty folder).
2. Przeciągnij pliki wideo, audio i obrazy do panelu mediów.
3. Przeciągnij klip na oś czasu. Tnij, przesuwaj, dodawaj efekty i przejścia.
4. Eksport: wybierz preset (YouTube, ProRes, DNxHR, sekwencja PNG, HDR i inne).
5. Dokumentacja jest w menu Pomoc w programie.

Linia poleceń: `hve.exe --help` w folderze instalacji. `hve new`, `hve import`, `hve render` i inne działają bez okna programu.

### Agent AI i MCP (Claude Code, Claude Desktop)

Program ma wbudowany serwer MCP. Agent widzi oś czasu, media i historię, a każda jego zmiana jest osobną rewizją, którą cofniesz zwykłym Ctrl+Z.

Najprościej z programu: Preferencje, sekcja Agent, „Podłącz” przy Claude Code albo Claude Desktop (to samo w kreatorze pierwszego uruchomienia, menu Pomoc). Program sam wpisuje polecenie z właściwą ścieżką, także dla kopii rozpakowanej z zipa. Claude Desktop dostaje wpis w `claude_desktop_config.json` (z kopią poprzedniego pliku, inne serwery zostają) i trzeba go potem całkiem zamknąć (także z zasobnika) i uruchomić ponownie. W Claude Code wybierasz zakres: wszystkie projekty (wpis w głównej konfiguracji Claude Code) albo jeden folder (plik `.mcp.json` w tym folderze, główna konfiguracja bez zmian); „Przenieś tutaj” zmienia zakres. Wolisz poprosić Claude? Program daje gotowe polecenie do wklejenia. Z terminala: `hve agent status`, `hve agent connect claude-desktop`, `hve agent connect claude-code` (z `--folder <folder>` tylko dla jednego folderu).

Ręcznie w Claude Code (instalator robi to za Ciebie, jeśli się zgodzisz):

```powershell
claude mcp add --scope user hexart-video-edit -- "%LOCALAPPDATA%\Programs\HEXART Video Edit\hve.exe" mcp --connect
```

`hve mcp --connect` łączy Claude Code z serwerem agenta na porcie 47960. Jeśli okno programu nie jest otwarte, serwer startuje sam w tle (`hexart-video-edit.exe --background`) i trzyma projekt, więc sesja agenta nie traci kontekstu, gdy zamkniesz okno. Chcesz, żeby serwer wstawał po zalogowaniu? Zaznacz autostart w instalatorze albo w ustawieniach programu. Zatrzymanie: `hve mcp --stop`. Stan: `hve mcp --status`.

Zapłacone i zewnętrzne akcje (generowanie, transkrypcja, wysyłka, publikacja, kasowanie plików, długie eksporty) czekają na Twoje potwierdzenie w oknie programu. Agent sam ich nie zatwierdzi.

### Warto zainstalować OpenRouter MCP

[OpenRouter MCP](https://github.com/lazniak/OpenRouter-MCP) odblokowuje pełnię możliwości edytora: generowanie obrazów i wideo przez AI prosto na oś czasu. To osobny, lokalny program HEXART (Windows 10/11, Node.js 24+, konto OpenRouter). Daje:

- generowanie obrazów i wideo z wyceną przed zapłatą: widzisz cenę, model i parametry, a dopiero Twoje potwierdzenie uruchamia płatne wywołanie,
- osobne klucze API na projekt z limitem wydatków na każdym kluczu, statystyki kosztów i możliwość rotacji kluczy,
- katalog modeli aktualizowany na bieżąco, z dokumentacją parametrów każdego modelu,
- pamięć Twojego gustu i strategii cena/jakość, żeby kolejne propozycje trafiały lepiej,
- działa tylko na Twoim komputerze (127.0.0.1), klucze są szyfrowane.

Bez niego edytor działa w pełni, tylko bez generowania AI. Instalacja i konfiguracja: opis w [repozytorium OpenRouter MCP](https://github.com/lazniak/OpenRouter-MCP).

### Zgłaszanie błędów z programu

W programie jest przycisk zgłoszenia błędu. Opisujesz problem tekstem albo nagraniem głosowym. Zgłoszenie trafia tu jako publiczny issue.

- Nagranie głosowe jest zamieniane na tekst na serwerze HEXART. Samo nagranie nie jest publikowane, w issue ląduje tylko transkrypcja.
- Log i informacje o urządzeniu (wersja programu, Windows, karta graficzna, pamięć) widzisz i możesz poprawić albo skasować przed wysłaniem. Nic nie idzie bez Twojego kliknięcia.
- Ponieważ issue jest publiczny, nie wpisuj w nim haseł, kluczy ani danych klientów.

Możesz też zgłosić błąd ręcznie: [nowy issue](https://github.com/lazniak/hexart-video-edit/issues/new/choose) (formularz pyta o wersję, kroki, oczekiwany i faktyczny wynik oraz log).

### Prywatność

- Projekty, media i ustawienia zostają na Twoim dysku. Program nie wysyła statystyk użycia i sam nie sprawdza aktualizacji.
- Połączenia sieciowe uruchamiasz Ty: pobranie czcionki z Google Fonts, pobranie modelu Pixel Motion, transkrypcja (ElevenLabs, Twoim kluczem), wysyłka pliku przez transfer.hexart.io, generowanie przez OpenRouter MCP, zgłoszenie błędu. Płatne i zewnętrzne akcje wymagają potwierdzenia w programie.
- Serwer MCP słucha tylko na 127.0.0.1 i wymaga tokenu.
- Zgłoszenie błędu jest publiczne, szczegóły wyżej.

### Licencja i komponenty

Program: [LICENSE.txt](LICENSE.txt) (freeware, bez prawa do redystrybucji i inżynierii wstecznej). W paczce jest FFmpeg na licencji GPL v3 uruchamiany jako osobny proces. Źródło i licencje komponentów: [THIRD-PARTY-NOTICES.txt](THIRD-PARTY-NOTICES.txt) w paczce.

Dekoder RED R3D nie jest w paczce. Dekoder Blackmagic RAW (`hve-braw.exe`) korzysta ze środowiska Blackmagic RAW zainstalowanego w systemie.

### Linki

- Zmiany: [CHANGELOG.md](CHANGELOG.md)
- Bezpieczeństwo: [SECURITY.md](SECURITY.md)
- Błędy i pomysły: [Issues](https://github.com/lazniak/hexart-video-edit/issues)
- HEXART: [hexart.pl](https://hexart.pl)

---

## English

HEXART Video Edit is a video editor for Windows. It has a timeline, colour grading, effects with JavaScript expressions, web layers, nested sequences, voice-over recording and ready-made export presets. An AI agent such as Claude Code edits the same project as you, in the same timeline, with the same undo history.

This repository contains no source code. It holds the releases, the installer, release notes and bug reports. The program is free (freeware), licence in [LICENSE.txt](LICENSE.txt).

### Requirements

- Windows 10 or 11, 64-bit.
- A DirectX 12 graphics card.
- RAM: 16 GB is enough for Full HD, 32 GB recommended for 4K.
- For hardware encoding an NVIDIA (NVENC), AMD (AMF) or Intel (QSV) card helps. Without one the program encodes on the CPU.
- Chrome or Edge if you use web layers (optional).
- FFmpeg is in the package, nothing else to install.

### Install

One line in PowerShell:

```powershell
irm https://github.com/lazniak/hexart-video-edit/releases/latest/download/install.ps1 | iex
```

The installer downloads the latest zip from GitHub Releases, checks its SHA-256, installs the program to `%LOCALAPPDATA%\Programs\HEXART Video Edit` and adds a Start menu shortcut. It asks whether to start the agent server at sign-in and whether to register the MCP in Claude Code. No administrator rights needed.

Options (instead of the one-liner):

```powershell
& ([scriptblock]::Create((irm https://github.com/lazniak/hexart-video-edit/releases/latest/download/install.ps1))) -Version 0.15.0 -Desktop -Autostart -Mcp
```

| Option | What it does |
|---|---|
| `-Version x.y.z` | a specific version instead of the latest |
| `-Desktop` | also a desktop shortcut |
| `-Autostart` / `-NoAutostart` | turn it on without asking / do not ask |
| `-Mcp` / `-NoMcp` | register the MCP in Claude Code without asking / do not ask |
| `-Yes` | ask nothing, take the default answers |
| `-InstallDir` | another install folder |

Manually: download `hexart-video-edit-<version>-windows-x64.zip` from [Releases](https://github.com/lazniak/hexart-video-edit/releases), unzip anywhere and run `hexart-video-edit.exe`. A `.sha256` file next to the zip lets you verify it: `Get-FileHash file.zip -Algorithm SHA256`. At the first start a short wizard sets the language and the projects folder and connects an AI agent. To install an unpacked copy later, run the installer that comes in the zip: `powershell -ExecutionPolicy Bypass -File install.ps1` in that folder (it installs the files of the folder and downloads nothing).

### Update

From version 0.16.0 the program updates itself: shortly after it starts and every few hours it checks for a new release, downloads it in the background, verifies its SHA-256 and installs it when you close the editor (or when the background agent server is idle). While a new version waits, the status bar shows an "Update X" button that restarts the program right away. Turn it off in Preferences, Updates. From the command line: `hve update` (or `hve update --check`).

Manually: run the same installer again. It closes the program and the background agent server (if running), keeps a copy of the previous files as `*.exe.old` and replaces the files. Your projects and settings stay. Restart your Claude Code session after an update.

### First steps

1. Start HEXART Video Edit from the Start menu. Create a project (pick an empty folder).
2. Drag video, audio and image files into the media panel.
3. Drag a clip onto the timeline. Cut, move, add effects and transitions.
4. Export: pick a preset (YouTube, ProRes, DNxHR, PNG sequence, HDR and more).
5. The documentation is in the Help menu of the program.

Command line: `hve.exe --help` in the install folder. `hve new`, `hve import`, `hve render` and others work without the program window.

### AI agents and MCP (Claude Code, Claude Desktop)

The program has a built-in MCP server. The agent sees the timeline, the media and the history, and each of its changes is a separate revision that you undo with a plain Ctrl+Z.

The simplest way is from the program: Preferences, Agent section, "Connect" next to Claude Code or Claude Desktop (the same in the first-run wizard, Help menu). The program writes the command with the right path itself, also for a copy unpacked from the zip. Claude Desktop gets an entry in `claude_desktop_config.json` (the previous file is backed up, other servers stay); quit it completely (the tray icon too) and start it again. In Claude Code you choose where: all projects (an entry in Claude Code's main config) or one folder (a `.mcp.json` file in that folder, the main config untouched); "Move here" switches between them. Rather ask Claude? The program gives a ready request to paste. From a terminal: `hve agent status`, `hve agent connect claude-desktop`, `hve agent connect claude-code` (with `--folder <folder>` for one folder only).

By hand in Claude Code (the installer does it for you if you agree):

```powershell
claude mcp add --scope user hexart-video-edit -- "%LOCALAPPDATA%\Programs\HEXART Video Edit\hve.exe" mcp --connect
```

`hve mcp --connect` connects Claude Code to the agent server on port 47960. If the program window is not open, the server starts by itself in the background (`hexart-video-edit.exe --background`) and holds the project, so the agent session keeps its context when you close the window. Want the server to start at sign-in? Tick autostart in the installer or in the program settings. Stop it with `hve mcp --stop`, check it with `hve mcp --status`.

Paid and outward actions (generation, transcription, sending, publishing, deleting files, long exports) wait for your confirmation in the program window. The agent cannot approve them itself.

### Recommended: OpenRouter MCP

[OpenRouter MCP](https://github.com/lazniak/OpenRouter-MCP) unlocks the full potential of the editor: AI image and video generation straight onto the timeline. It is a separate local HEXART program (Windows 10/11, Node.js 24+, an OpenRouter account). It gives you:

- image and video generation with a price quote before you pay: you see the price, model and parameters, and only your confirmation starts the paid call,
- separate API keys per project with a spending limit on each key, cost statistics and key rotation,
- a model catalog kept up to date, with documentation of each model's parameters,
- a memory of your taste and your price/quality strategy, so later suggestions fit better,
- it runs on your computer only (127.0.0.1), keys are encrypted.

Without it the editor works fully, just without AI generation. Install and set-up: see the [OpenRouter MCP repository](https://github.com/lazniak/OpenRouter-MCP).

### Bug reports from inside the app

The app has a bug report button. You describe the problem in text or with a voice note. The report lands here as a public issue.

- A voice note is turned into text on HEXART's server. The recording itself is not published, only the transcript goes into the issue.
- You see the log and the device info (program version, Windows, graphics card, memory) and can edit or delete them before sending. Nothing is sent without your click.
- Because the issue is public, do not put passwords, keys or client data in it.

You can also report a bug by hand: [new issue](https://github.com/lazniak/hexart-video-edit/issues/new/choose) (the form asks for version, steps, expected and actual result, and a log).

### Privacy

- Projects, media and settings stay on your disk. The program sends no usage statistics and does not check for updates by itself.
- Network calls happen when you start them: downloading a font from Google Fonts, downloading the Pixel Motion model, transcription (ElevenLabs, with your key), sending a file through transfer.hexart.io, generation through OpenRouter MCP, a bug report. Paid and outward actions need your confirmation in the program.
- The MCP server listens on 127.0.0.1 only and requires a token.
- A bug report is public, details above.

### Licence and components

The program: [LICENSE.txt](LICENSE.txt) (freeware, no redistribution and no reverse engineering). The package includes FFmpeg under GPL v3, run as a separate process. Sources and licences of components: [THIRD-PARTY-NOTICES.txt](THIRD-PARTY-NOTICES.txt) in the package.

The RED R3D decoder is not in the package. The Blackmagic RAW decoder (`hve-braw.exe`) uses the Blackmagic RAW runtime installed on your system.

### Links

- Changes: [CHANGELOG.md](CHANGELOG.md)
- Security: [SECURITY.md](SECURITY.md)
- Bugs and ideas: [Issues](https://github.com/lazniak/hexart-video-edit/issues)
- HEXART: [hexart.pl](https://hexart.pl)
