# Zmiany

Notatki o wersjach są po polsku. / Release notes are written in Polish.

## 0.19.9 (2026-11-04)

- Source: kliknięcie albo przeciągnięcie paska pod obrazem skacze od razu w to miejsce, także
  na końcu bardzo długiego klipu. Przewijanie z dźwiękiem jak taśma jest teraz pod Ctrl.
- Project: Del usuwa zaznaczone klipy, sekwencje i folder (pyta najpierw, z polem „Pytaj
  następnym razem”), F2 zmienia nazwę.
- Project: foldery i sekwencje wyglądają jak klipy, w tej samej liście i tej samej siatce.
  Folder otwiera się dwuklikiem.
- „Pokaż w projekcie” z osi czasu otwiera folder z klipem i zaznacza go.
- Układ okien: panel upuszczony na przycisku przy krawędzi doku staje obok całego układu.
  Chwytak na prawym końcu paska zakładek przenosi całą grupę naraz.
- „Pokaż na osi czasu” nie otwiera drugiej zakładki dla sekwencji, z której główna oś weszła
  do zagnieżdżenia: główna zakładka wraca do niej w górę.
- Project: „Zastąp materiał…” podmienia plik klipu wszędzie, gdzie jest użyty (ten sam klip,
  nowe źródło, jedno Ctrl+Z).
- Project: F2 zmienia nazwę w miejscu, na samej nazwie, bez okna. Enter albo kliknięcie obok
  zapisuje, Esc zostawia starą.
- Maski jak w After Effects: wiele masek na klipie z nazwą, kolorem i kolejnością, tryby
  Brak, Dodaj, Odejmij, Część wspólna, Rozjaśnij, Przyciemnij, Różnica, przełącznik
  Odwrócona, a do tego ścieżka, wtapianie (X i Y), krycie i rozszerzenie z klatkami kluczowymi.
- Maski rysuje się na monitorze Program: prostokąt, zaokrąglony prostokąt, elipsa, wielokąt
  i gwiazda (Q), pióro z dodawaniem, usuwaniem i zamianą wierzchołków oraz zmiennym
  wtapianiem (G), swobodne przekształcenie (Ctrl+T). Skróty jak w After Effects: M, MM, F,
  TT, Ctrl+Shift+N, Ctrl+Shift+I, Ctrl+Shift+M, Ctrl+Shift+F, Ctrl+Shift+H.
- Wtapianie maski z gładkim albo liniowym spadkiem i rozmycie ruchu maski. Podgląd i eksport
  wyglądają tak samo.
- Agent AI dodaje i zmienia maski przez MCP (add_mask, set_mask, move_mask, remove_mask).
- Klip połączony przesuwany razem z rodzicem albo podpinany do innego klipu zabiera ze sobą
  swój dźwięk i resztę połączonych części.

## 0.19.5 (2026-11-03)

Szybszy eksport, licencje przy każdym elemencie filmu, nowa przeglądarka warstw web i agent AI
pracujący w tle na dowolnym projekcie.

Eksport:

- Kolory przy eksporcie liczy karta graficzna: klatki trafiają do FFmpeg od razu w formacie
  kodeka, więc do FFmpeg idzie 2 do 2,7 raza mniej danych i niczego już nie konwertuje. Jakość
  obrazu zostaje ta sama.
- Kolejne klatki są odczytywane z karty graficznej z wyprzedzeniem, a zapis do kodeka idzie osobnym
  wątkiem. Dekodery źródeł przygotowują następne klatki wcześniej. Pętla eksportu UHD H.264 skróciła
  się na naszej stacji z 29,6 do 23,5 s, HD z 14,9 do 11,4 s.
- ProRes bez kanału alfa przy szybkościach Szybko i Zrównoważona używa szybszego kodera ProRes:
  4K ProRes HQ liczy się w edytorze około 20 klatek na sekundę zamiast 5,5. Pliki są większe (o
  28 do 72%), a jakość obrazu zostaje bardzo wysoka. Szybkość Jakość i ProRes 4444 z alfą zostają
  przy dotychczasowym koderze.
- NVENC przy szybkości Zrównoważona używa presetu p5: na teście 4K około 40 klatek na sekundę
  zamiast 20. Jakość i Najmniejszy plik zostają przy p7.
- Okno eksportu pokazuje szybkość kodera także dla ProRes.

Oś czasu:

- Przełączenie na zakładkę osi innej sekwencji od razu pozwala ją edytować. Wcześniej zakładka
  reagowała dopiero po drugim kliknięciu.
- Zoom osi (klawisze, Ctrl i Alt z kółkiem, suwak) trzyma głowicę na środku widoku. Wyłączysz to w
  Preferencjach.
- Własne kursory dla każdego narzędzia na osi i pokazywanie, co zrobi kliknięcie. Żyletka rysuje
  linię cięcia przez wszystkie klipy, które przetnie. Przycinanie, Ripple, Roll i Rate pokazują
  nawiasy na punkcie edycji i podświetlają krawędzie, które się zmienią. Slip pokazuje, o ile można
  przesunąć źródło, a Slide krawędzie sąsiadów. Zaznaczanie ścieżki i Tekst pokazują, co obejmą.
- Markery przeciągasz na linijce (z przyciąganiem, Alt je wyłącza, Esc anuluje). Panel Markery
  podświetla bieżący marker podczas odtwarzania i przewija do niego.
- Kliknięcie w pustym miejscu ścieżki i zaznaczanie ramką nie przesuwają już głowicy. Przesuwa ją
  tylko linijka i linia głowicy.
- Przeciągany klip przyciąga się także do własnego początku i końca z chwili sprzed przeciągania.
- Kopiuj i wklej od nowa: schowek pamięta ścieżki, wklejenie niczego nie nadpisuje (całość ląduje
  na pierwszych wolnych ścieżkach, w razie potrzeby powstają nowe), a Ctrl+Shift+V wkleja z
  przesunięciem. Wklejone klipy są zaznaczone, a głowica staje na ich końcu.
- Klawisze zoomu działają na panel pod kursorem albo ostatnio klikany (Effect Controls, monitory),
  a w pozostałych przypadkach na oś.
- Drugie kliknięcie w zaznaczoną lukę odznacza ją.
- Linijka jest wyższa (42 zamiast 28 punktów), z większą głowicą i znacznikami markerów.
- Lift i Extract działają tylko przy ustawionych In i Out, a przyciski mówią, czego brakuje. Pełny
  zakres jest mocniej podświetlony na osi, a po wycięciu pojawia się komunikat, ile i z ilu
  ścieżek wycięto.
- Alt z przeciąganiem klucza głośności albo krycia: uchwyty Béziera rosną razem z przeciągnięciem,
  zamiast od razu skakać do 100%.

Projekt:

- Polecenia z menu kontekstowego panelu Projekt działają na całym zaznaczeniu: jedna zmiana w
  historii, liczba w nazwie polecenia i informacja o pominiętych elementach. Wiersze sekwencji
  zaznaczasz z Ctrl i Shift.
- „Pokaż na osi czasu” otwiera wszystkie sekwencje używające zaznaczonego medium. Aktywna zostaje
  ta z największą liczbą trafień, pozostałe mają jasnozłoty odcień do pierwszego kliknięcia.
- Nowy panel Kolejka proxy (Okno > Wyjście), otwierany z paska stanu: anulowanie, ponawianie,
  pokazanie pliku i usuwanie z listy.
- Pokaż w Eksploratorze zaznacza plik także wtedy, gdy ścieżka ma spację (wcześniej otwierał
  Dokumenty). Gdy pliku już nie ma, otwiera najbliższy istniejący folder.
- Interpolacja klatek dla zaznaczenia: w menu klipu, zaraz pod Prędkość / Czas trwania, jedno
  polecenie dla wszystkich zaznaczonych klipów wideo, ze stanem mieszanym, gdy klipy mają różne
  tryby.

AI Assets:

- Panel jest prawdziwym generatorem: rodzaj, wieloliniowy opis, karty referencji z miniaturami i
  wybór modelu. Galeria używa tej samej siatki i listy co panel Projekt (suwak wielkości, Ctrl z
  kółkiem, kolumny wypełniają szerokość), a kafelki nie skaczą po najechaniu. Podgląd ruchem po
  najechaniu zostaje.

Efekty, kolor i warstwy web:

- Jedna przeglądarka w panelu Warstwy web: warstwy projektu, wbudowane i biblioteka w jednym
  widoku, bez zakładek. Wyszukiwanie obejmuje wszystko, po lewej drzewo (Źródło i kategorie z
  podkategoriami), filtry tagów jako chipy. Widok siatki i listy, suwak wielkości, podgląd ruchem
  po najechaniu, plakietki (proporcje, alfa, pętla, źródło, problemy), podwójne kliknięcie kładzie
  na osi, przeciągnięcie upuszcza na oś.
- Biblioteka komponentów web ma 455 pozycji w 26 kategoriach: nowe wykresy (słupkowe, liniowe,
  udziałowe, wskaźniki, przepływy i specjalne), mapy, infografiki i komponenty 3D.
- Rozmycie ruchu zawartości warstw web: przełącznik w Effect Controls rozmywa ruch wewnątrz
  strony, nie tylko ruch samej warstwy. Zamknięcie migawki (domyślnie 180°) i liczba próbek (domyślnie
  8) są parametrami z kluczami. Strony, które trzymają stan w czasie (animacje, liczniki), dostają
  ostrzeżenie zamiast cichego braku efektu.
- Warstwy web szybciej pokazują klatki: kilka przeglądarek w tle zamiast jednej, a podczas
  odtwarzania klatki przed głowicą są przygotowywane z wyprzedzeniem. Na teście z sześcioma
  warstwami 1080p liczba renderów na sekundę wzrosła z 32 do 65.
- Uchwyty punktów efektów na monitorze Program: środek maski, punkt ostrości Camera Lens Blur,
  środek okna w korekcji wtórnej i punkt efektu Controls przeciągasz bezpośrednio na obrazie.
  Przełącznik edycji bezpośredniej jest w pasku monitora, między timecodem a menu skali.
- Widok grupowy w Effect Controls: przy kilku zaznaczonych klipach z tym samym efektem parametry
  są pokazane razem (przełącznik „Każdy klip | Wszystkie klipy”), wartości różne między klipami to
  „mieszane”, a podgląd celu podświetla klipy, które zmieni dane pole. Parametry można łączyć w
  grupy klipów.
- Interpolacja RIFE przy 4K na DirectML nie daje już pionowych smug w trybie Pixel Motion. Obraz
  dużych klatek jest liczony w nakładających się pasach, a źle policzone klatki z cache zostaną
  przeliczone.
- Liczby, które po zaokrągleniu są zerem, nie pokazują już minusa (na przykład „-0,00 px/s” pod
  wykresem klucza).

Czas i pola liczbowe:

- Wszystkie pola czasu to jeden składnik: zatwierdzają się Enterem, Tabem, utratą fokusu i
  kliknięciem poza polem (Esc anuluje), wolne przeciąganie przesuwa o ułamki klatki, a wyświetlają
  czas w wybranym trybie (Ctrl z kliknięciem przełącza: timecode, klatki, sekundy). Pole czasu ma
  teraz także trwanie przejścia, limit długości w AI Wstępny montaż, długość In do Out na monitorze
  Program i okno eksportu.
- Długie nazwy presetów eksportu kończą się wielokropkiem, a pełna nazwa jest w dymku.

Dźwięk:

- Monitor Source gra dźwięk: odtwarzanie, J/K/L i tył, pętla In/Out, przewijanie w trakcie gry,
  jak na monitorze Program. Przeciąganie paska Source i timecodu przewija dźwięk jak taśmę.
- Fader Master w Audio Mixerze: regulacja od -96 do +15 dB z podwójnym kliknięciem na 0 dB, jeden
  krok cofania na przeciągnięcie. Obejmuje odtwarzanie, eksport, pomiar głośności i zagnieżdżone
  sekwencje.

Licencje:

- Licencje przy każdym elemencie (plik, wtyczka, font, warstwa web, komponent, referencja,
  generator, efekt). Projekt ma typ pracy: prywatny, niekomercyjny, komercyjny (domyślnie), dla
  klienta albo emisja. Każdy element dostaje werdykt: w porządku, obowiązek, ostrożnie, warunek
  niespełniony, nieznane albo kolizja. Okno Licencje opisuje każdy typ pracy.
- Obok wyeksportowanego filmu powstają plik z pełnym zrzutem licencji (`NAZWA.LICENSE.txt`) i lista
  uznań do opisu albo napisów końcowych (`NAZWA.ATTRIBUTIONS.txt`). Oba można wyłączyć w
  Preferencjach, a eksport roboczy agenta ich nie tworzy.
- Tryb ubiegania się o licencję: dla każdego elementu pokazuje, u kogo i o co poprosić. Szkic
  prośby to tylko plik w folderze projektu, nic nie jest wysyłane.
- Agent AI nie może zwiększyć użycia elementu zablokowanego (nowy klip, kopia, dłuższy albo
  szybszy), a eksport końcowy, wysyłka i publikacja są sprawdzane przed pytaniem o zgodę i jeszcze
  raz po niej. Deklaracje i typ pracy zmieniasz tylko Ty. To pomoc, nie porada prawna: raporty
  mówią wprost, czego nie obejmują.

Agent AI (MCP):

- Agent pracuje na dowolnym projekcie w tle i nie przełącza okna programu: projekt jest
  kontekstem sesji agenta, a okno i agenci na tym samym folderze dzielą jedną historię. Projekty w
  tle mają autozapis i zwalniają się po 30 minutach ciszy.
- Po przekazaniu do okna (`show_editor`) trwające eksporty dokańczają się w tle i `export_status`
  dalej o nich mówi. Gdy działają inne zadania (transkrypcja, analiza), okno czeka na nie albo
  je anuluje na wyraźne polecenie.
- `export_status` podaje upływ czasu, szacowany koniec i klatki na sekundę, a z `wait` czeka do
  końca eksportu. Bez zadania wymienia wszystkie eksporty sesji.
- `normalize_audio` ma limity: największe wzmocnienie, bramkę ciszy i maksymalny szczyt (domyślnie
  -1 dBTP, mierzony jako true peak). Wynik mówi, które klipy ograniczono i dlaczego.
- Lokalny Whisper ma limity czasu na klip, a nieudany klip nie zatrzymuje całego zadania. Ciche
  fragmenty, stopki napisów i typowe zmyślone frazy nad ciszą są usuwane z transkrypcji.
- `render_frame` czeka do 30 s na warstwy, które się jeszcze ładują, zamiast oddać niepełną
  klatkę, a przy niepełnej mówi dlaczego.
- `edit` przyjmuje nazwy ścieżek (`V1`, `A1`) i pliki z poleceniami, zwraca identyfikatory
  zagnieżdżonych obiektów, a `write_component` akceptuje opcje wyliczeniowe jako zwykłe teksty.
- Tryb Recenzja: przycisk „Zmień z agentem” na środku dolnego paska. Włączasz go, mówisz i
  pokazujesz kursorem, co zmienić, a po wyłączeniu program przekazuje to agentowi jako jedną
  wytyczną. Ramka w oknach programu świeci zgodnie z poziomem mikrofonu.

Instalacja:

- Aktualizacja instalatorem przechodzi także wtedy, gdy jakiś program trzyma pliki HEXART Video
  Edit, na przykład sesja agenta AI połączona przez MCP z załadowanymi bibliotekami FFmpeg. Zajęte
  pliki czekają obok nowych i znikają przy następnej instalacji albo starcie programu, gdy nic ich
  już nie używa.
- Deinstalator usuwa też bibliotekę komponentów i pobrane aktualizacje.

Okna i układ:

- Okna dialogowe, w tym Preferencje i Licencje, mieszczą się w małych ekranach (1280x720 i mniej)
  z przyciskami zawsze w zasięgu. Okna mierzą własny pasek tytułu i ramkę, a na środku zostawiają
  margines u góry i na dole. Otwierają się od razu w dobrym miejscu, bez skoku po pierwszej klatce.
- Preferencje i ustawienia mają jedne kolumny etykiet i pól w każdej sekcji, a zawinięte chipy
  („Panele, które się rozszerzają”, „Ustawienia domyślne”) nie zasłaniają sąsiednich pól.
- Inteligentne poszerzanie paneli czyta zamiar kursora: martwa strefa przy krawędziach, liczy się
  tylko czas spędzony głęboko i powoli w grupie, kursor wracający do grupy z miejscem niczego nie
  zabiera, a kliknięcie albo kółko biorą miejsce od razu. Zmiana zakładki w grupie nie składa jej z
  powrotem. Nowe ustawienia „Opóźnienie przejęcia” i „Martwe pole przy krawędzi” w Preferencjach >
  Interfejs.
- Gdy zakładki grupy się nie mieszczą, przycisk „+N” zostaje przypięty z lewej, lista oznacza
  ukryte zakładki, a krawędzie bledną tam, gdzie coś jest ukryte. Paski przewijania są widoczne,
  gdy treść wystaje, i jaśnieją po najechaniu.

## 0.19.0 (2026-10-30)

Poprawki po drugim teście z montażystą i nowe uwagi do interfejsu.

Okna i układ:

- Nic nie wychodzi poza ekran: okna, dialogi, menu, listy rozwijane i dymki mieszczą się w
  ekranie (także 1280x720), długa treść się przewija, a tytuł i przyciski zostają widoczne.
- Okna AI osobno: Agent, Prośby o zgodę, Analiza, Szukaj w materiałach, Wstępny montaż oraz
  Rotoskopia i ścieżki to osobne panele. Menu Okno ma kategorie (Montaż, Efekty i grafika, Kolor,
  Dźwięk i tekst, AI, Wyjście), a otwarty panel ma złotą ikonę.
- Zakładki doku: złoty pasek nie zostaje na zakrytej zakładce, a gdy zakładki się nie mieszczą,
  przycisk na końcu paska pokazuje pozostałe.
- Przeciąganie między panelami: efekt z panelu Efekty na Effect Controls, na monitor Program i na
  klip, presety efektów, efekty w stosie (zmiana kolejności, na inny klip: przenosi, z Ctrl
  kopiuje).
- Inteligentne poszerzanie paneli: przełącznik w górnym pasku obok Workspace (na start
  wyłączony, także w Preferencjach > Interfejs). Grupa paneli pod kursorem po chwili bierze
  miejsce sąsiadów; Twój układ zostaje bazą, a ręczne przesunięcie krawędzi ustawia nową.
- Ustawienia projektu mają własne okno (Plik > Ustawienia projektu), Preferencje nie powtarzają
  już sekcji Interfejs.

Projekt:

- Suwak wielkości w trybie listy i siatki (także Ctrl + kółko). Siatka zawsze wypełnia szerokość
  panelu.
- Podgląd pod kursorem przewija klip ruchem w poziomie (Projekt i AI Assets).

Oś czasu:

- Każda sekwencja może mieć własną zakładkę osi czasu (menu sekwencji w Projekcie i klipu
  zagnieżdżonego), a głowica idzie przez zagnieżdżenia.
- Pasy nad najwyższą ścieżką wideo i pod najniższą ścieżką audio: upuszczony tam klip tworzy nową
  ścieżkę. Na dole „+” dodaje ścieżkę wideo i audio, a „−” usuwa puste.
- Ostatnia klatka filmstripu na końcu klipu to naprawdę ostatnia klatka klipu.
- Podmiana klipu: klip z Projektu upuszczony z Alt na klip osi podmienia go (jak Replace w
  Premiere), Shift+Alt z synchronizacją czasu źródła.
- Markery na osi: najechanie je podświetla, kliknięcie zaznacza jak w panelu Markery, prawy
  przycisk otwiera ich menu.
- Panel narzędzi ma stałą szerokość i stały rozmiar ikon.
- Rolka nad ścieżkami może przewijać oś w poziomie (Preferencje).
- Przewijanie z dźwiękiem jak taśma: jog/shuttle i Ctrl z przeciąganiem głowicy grają płynnie, z
  wysokością idącą za prędkością, bez trzasków przy zmianie kierunku i zatrzymaniu.

Efekty, kolor i warstwy web:

- Lista efektów to drzewo z chowanymi gałęziami i sortowaniem (polskie litery na swoim miejscu),
  z presetami efektów jako osobną gałęzią.
- Wysokość wykresów w Effect Controls zmieniasz chwytem krawędzi, a krzywa głośności klipu ma
  widoczne uchwyty Béziera.
- Ujemna skala w Effect Controls odbija obraz w tej osi, jak w After Effects.
- Z-depth z Video Depth Anything ze stałym zakresem głębi w czasie i efekt Camera Lens Blur.
- Tryby mieszania liczone poprawnie: Multiply, Darken i pozostałe nie zaciemniają tła sekwencji,
  a Add i Screen wyglądają różnie.
- Warstwy web nie pokazują już migających resztek starych klatek po zmianie bez klucza, a
  rozmycie ruchu działa także wewnątrz strony.
- Biblioteka komponentów web w panelu Warstwy web (pierwsze komponenty), parametry z danymi JSON i
  edytor danych.
- Podgląd sekwencji Rec.709 (monitor, NDI, `render_frame`) ma te same kolory co eksport. Mapowanie
  tonów podglądu SDR działa już tylko w sekwencjach HDR, więc szczyt monitora masteringowego nie
  przyciemnia i nie ściska świateł klipów SDR.
- Listy rozwijane nie skaczą przy najechaniu, a wektoroskop ma wyższą rozdzielczość.

Dźwięk:

- Submiksy z własnym łańcuchem efektów: ścieżka idzie na Master albo na submiks. Podziałki dB
  przy suwakach w Audio Mixerze.
- Efekty w łańcuchu ścieżki i submiksu: kolejność zmieniasz przeciąganiem, przeciągnięcie na
  inny pasek przenosi efekt z ustawieniami, z Ctrl kopiuje.
- 5.1 i 7.1: panorama surround, osobny center i LFE na ścieżce i na klipie, ścieżki
  wielokanałowe na osi i eksport wielościeżkowy z ustawieniami zaawansowanymi.
- Stemy filmowe w panelu AI i w `separate_stems`: dialog, muzyka i efekty, a także muzyka z
  efektami, głos i reszta oraz sześć stemów (z gitarą i pianinem). Nowy silnik CASS (Bandit v2
  i DBS-TIGER); ostatni stem bierze resztę, więc stemy sumują się do źródła.
- Transkrypcje słów, które idą za montażem: lokalny Whisper (darmowy, offline, instalowany w
  Preferencjach > Transkrypcja) albo ElevenLabs Scribe (płatny, z mówcami, po wycenie).

Praca razem online:

- Sesja trwa bez gospodarza: goście pracują dalej, gdy host wyjdzie albo zamknie program, a media
  raz pobrane zostają.
- Po restarcie program proponuje „Wróć do sesji online” jednym kliknięciem.
- Przy udostępnianiu ustalasz, czy goście mogą zapraszać kolejne osoby.
- Przesyłanie mediów mieści się w limitach serwera: odmowy serwera kończą się odczekaniem i
  ponowieniem, postęp jest na każdy plik, a okno sesji z długą listą plików mieści się w ekranie.

Agent i program:

- Eksport do HXC, kodeka HEXART: presety „HXC” i „HXC bezstratny” w grupie montażowej, dźwięk w
  pliku `.hxc.m4a` obok. To plik pośredni dla HEXART Video Edit (inne programy go nie otworzą), nie
  plik dla klienta. Plik `.hxc` można zaimportować z powrotem jak każde media.
- Podłączenie agenta AI z programu: Preferencje > Agent pokazują, czy Claude Code i Claude
  Desktop są na komputerze i czy widzą program, a przycisk „Podłącz” wpisuje właściwe polecenie
  (także dla kopii rozpakowanej z zipa). Konfiguracja Claude Desktop dostaje kopię zapasową, a
  inne serwery i ustawienia zostają bez zmian. W Claude Code wybierasz zakres: wszystkie projekty
  albo jeden folder (jego `.mcp.json`), z przeniesieniem między nimi, a dla wolących poprosić
  Claude jest gotowe polecenie do wklejenia. Z terminala: `hve agent status|connect|disconnect`.
- Kreator przy pierwszym uruchomieniu: język, folder projektów, podłączenie agenta,
  automatyczne aktualizacje i zgłoszenia błędów. Można go pominąć; wraca z menu Pomoc.
- Instalator jest też w zipie: uruchomiony z rozpakowanego folderu instaluje te pliki.
- `hve mcp --connect` kończy się razem ze swoim klientem i nie zostawia procesów.
- Zgłoszenie błędu może mieć zrzut okna programu (pole „Dołącz zrzut ekranu”, domyślnie
  wyłączone): miniatura, duży podgląd i „Zrób ponownie”. HEXART przechowuje zrzut prywatnie,
  nie jest publikowany.
- Okno „Licencje i komponenty” wymienia modele stemów filmowych i ich licencje.

## 0.18.1 (2026-10-29)

- Okno „Licencje i komponenty” z listą składników programu i ich licencjami. Przeznaczenie
  projektu (komercyjne albo prywatne) w ustawieniach projektu; eksport mówi, gdy projekt używa
  składnika dozwolonego tylko do użytku niekomercyjnego, i prosi o jedno potwierdzenie.
- Pełne teksty licencji, umowa licencyjna i informacje o prawach w paczce.
- Program nie zamyka się już zaraz po starcie, gdy panel Fonty był otwarty z pobranym fontem.

## 0.18.0 (2026-10-29)

Poprawki po pierwszym teście z montażystą.

Linki do współpracy:

- Kliknięcie linku `hve://` w przeglądarce otwiera program (instalator rejestruje link, a
  zainstalowany program naprawia rejestrację przy starcie). Gdy edytor już działa, link trafia do
  otwartego okna, które wychodzi na wierzch z wypełnionym formularzem dołączania. Dołączenie
  zawsze potwierdzasz sam.
- Linki wklejone z czatu albo maila działają także bez `https://`, z tekstem dookoła, z `%23`
  zamiast `#` i z dopisanym ukośnikiem. Uszkodzony link mówi, co jest nie tak.

Praca razem online:

- Link do podglądu daje tryb tylko do oglądania: zmiany nie znikają już po cichu. Okno
  udostępniania pokazuje najpierw link do edycji.
- Projekt otwiera się u gościa od razu, a pliki dociągają się w tle z postępem (najpierw te przy
  głowicy) i podmieniają same.
- „Śledź” (prawy przycisk na etykiecie głowicy innej osoby albo lista osób): głowica,
  odtwarzanie, powiększenie i przewijanie osi, sekwencja i aktywny monitor idą za tą osobą, dopóki
  nie przerwiesz (Esc, kliknięcie albo własna akcja).
- W sesji online Ctrl+Z cofa najnowszą zmianę wspólnej historii, czyjąkolwiek, a komunikat mówi,
  czyja to była zmiana. Cofanie nie gubi już zmian współpracowników. Schowek zostaje osobisty.
- Dwie osoby o tej samej nazwie rozróżnia kolor i krótki kod przy nazwie.
- Plik > „Otwórz link do wspólnego projektu…” i przycisk w oknie projektów; link można też po
  prostu wkleić (Ctrl+V poza polami tekstowymi).
- Klipy jeszcze niepobrane mają znacznik z postępem wysyłania albo pobierania.

Oś czasu i przejścia:

- Uchwyty przejść: krawędź zmienia długość tylko po swojej stronie, z Alt obie
  naraz, środek przesuwa całe przejście wzdłuż cięcia. Kursor pokazuje tryb.
- Część przejścia poza materiałem źródłowym jest zakreskowana, a podpowiedź mówi, ilu klatek
  brakuje z każdej strony.
- Ctrl+D ma jedną zasadę: zaznaczone sąsiednie klipy dostają przejście tylko między sobą, jeden
  zaznaczony klip na cięciu najbliższym głowicy, bez zaznaczenia na cięciu pod głowicą. Jedno
  naciśnięcie nigdy nie dodaje dwóch przejść.
- Krótkie przejścia ze starszych projektów znowu pokazują nazwę.
- Rolka nad linijką czasu przesuwa głowicę o klatkę, Shift o 5 klatek.

Monitory:

- Powiększenie 10 do 400% działa w Program i Source (100% to piksel obrazu na piksel ekranu),
  przesuwanie środkowym przyciskiem albo narzędziem Rączka (H), Ctrl + rolka powiększa wokół
  kursora, podwójne kliknięcie menu powiększenia albo Backslash wraca do dopasowania.
- Rolka nad monitorem: klatka po klatce, Shift o 5 klatek.
- Jog/shuttle pod przyciskami transportu: chwytasz suwak, wychylenie to prędkość i kierunek (do
  8x), puszczenie zatrzymuje. J/L zmieniają prędkość bez przeskoku.

Klatki kluczowe:

- Przeciągana klatka kluczowa idzie za kursorem (Shift przyciąga do głowicy i innych kluczy, Esc
  anuluje), całe przeciągnięcie to jedna zmiana w historii i nie uruchamia odtwarzania.
- W edytorze wykresu przeciągany klucz zabiera pozostałe zaznaczone.
- Głowicę w panelu Effect Controls można chwycić i przewijać.

Audio:

- Przebieg na osi pokazuje głośność klipu (także klucze i wyciszenie), na żywo przy
  przeciąganiu; przester ma czerwoną końcówkę.
- „Normalizuj audio…” w menu klipu: do szczytu dBFS albo głośności LUFS, każdy klip osobno albo
  wszystkie razem, z podglądem zmiany i jedną zmianą w historii. To samo dla agenta w MCP.

Projekt i pliki:

- Nazwa projektu wynika z folderu albo z dialogu tworzenia; „Projekt bez nazwy” już się nie
  pojawia. „Zapisz jako” ma ten sam dialog nazwy i miejsca i nie gubi mediów.
- Przeciągnięcie klipu na „+” w panelu Projekt (albo „Nowa sekwencja z klipu”) tworzy sekwencję z
  ustawieniami klipu: rozmiar, klatkaż, HDR i audio.
- Plik > „Zbierz pliki…” kopiuje wszystkie media do folderu projektu (identyczne pliki raz).
  Opcjonalne kopiowanie przy imporcie w preferencjach.

Eksport:

- Filmy z dźwiękiem mają zawsze wszystkie klatki i dźwięk dokładnie tak długi jak obraz (wcześniej
  bywało o klatkę mniej, np. w MXF).

Pamięć podręczna:

- Ustawienia > Pamięć podręczna: wybór folderu cache (np. na innym dysku). Zmiana działa od
  następnego uruchomienia: fonty i generacje przechodzą do nowego folderu, podglądy i klatki
  Pixel Motion ze starego znikają.
- Podglądy (miniatury galerii, przebiegi audio) mają limit rozmiaru (domyślnie 5 GB) i wieku
  (domyślnie 30 dni bez użycia); najdawniej używane znikają same. „Wyczyść podglądy” usuwa je od
  razu.
- Miniatury i filmstripy zapisują się jako WebP zamiast PNG: kilka razy mniej miejsca na dysku.

Proxy w kodeku HXC:

- Nowy format proxy HXC (kodek HEXART): menu Widok „Utwórz proxy HXC zaznaczonych mediów”.
  Szorowanie bez czekania (każda klatka osobno), mniejszy podgląd dekoduje tylko potrzebną
  rozdzielczość, dekodowanie na karcie graficznej. Dźwięk proxy obok, w pliku `.m4a`.
- Proxy gra samo, gdy oryginału nie ma na dysku (także dźwięk), a po włączeniu w preferencjach
  także dla ciężkich źródeł (ProRes, DNx, RAW, powyżej UHD). „Wyłącz proxy zaznaczonych mediów”
  zdejmuje proxy z wybranych mediów.
- Folder proxy ma limit i wiek w preferencjach (domyślnie 50 GB, 60 dni), pokazany rozmiar i
  przycisk „Usuń nieużywane proxy”; proxy otwartego projektu nigdy nie znikają.

## 0.17.0 (2026-10-29)

Okna na wszystkich monitorach i workspaces:

- Każdy panel można wypiąć do osobnego okna systemu i przenieść na dowolny monitor: przeciągnij
  kartę poza okno albo wybierz „Wypnij do osobnego okna” (cała grupa: „Wypnij grupę do osobnego
  okna”) w menu karty. W oknie może być wiele kart i podziałów, jak w głównym.
- Karty przenoszą się między oknami przeciąganiem: nad grupą innego okna pokazują się te same
  przyciski co w doku (do grupy albo na jej bok). Zamknięcie okna przypina jego panele z
  powrotem do okna głównego; menu karty ma też „Przypnij do głównego okna” i „Przypnij całe okno
  do głównego”, a menu Okno „Przypnij wszystkie okna do głównego”.
- Skróty klawiszowe i skupienie paneli działają w wypiętych oknach.
- Program zapamiętuje układ wszystkich okien: miejsce, rozmiar, maksymalizację i monitor. Gdy
  monitora już nie ma albo okno wypadłoby poza ekrany, ląduje na monitorze głównym w tym samym
  miejscu względem ekranu; zmiana skali (DPI) i rozdzielczości nie psuje układu.
- Nowe menu Workspace obok wyboru projektu, z nazwą bieżącego: Montaż, Kolor, Audio i mikser,
  Efekty i animacja, Napisy i tekst, AI i generacje, Recenzja. Przełączenie jednym kliknięciem,
  workspace pamięta, jak go zostawiłeś. „Zapisz zmiany”, „Zapisz bieżący jako nowy…”, „Przywróć
  zapisany układ”, „Przywróć domyślny preset”, zmiana nazwy i usuwanie własnych. Workspace
  obejmuje okno główne i wszystkie wypięte okna na wszystkich ekranach; zapamiętany jest
  ostatnio użyty.

Praca razem online przez link:

- „Praca razem online”: „Zacznij udostępniać” daje link, z którym inne osoby pracują w tym
  samym projekcie na żywo, także w jednej osi czasu; zmiany każdego, również agenta, widać u
  wszystkich od razu. Osobny „Link do podglądu” daje dostęp tylko do oglądania.
- Projekt jest szyfrowany od końca do końca. Pliki zaimportowane u jednej osoby same trafiają na
  dysk pozostałych i zostają na serwerze najwyżej 24 godziny; ścieżki do plików są prywatne. Głowice innych osób są na osi czasu przygaszone na
  błękitno.

Markery:

- Edytor markera: nazwa, etykiety i opis. Opis to zwykły tekst albo, po przełączeniu na
  JSON, dokument z rozmową z agentem i listą zadań do poprawek. Wszystko to także w narzędziach
  MCP dla agenta. Eksport markerów do Premiere, EDL i OTIO bez zmian.

## 0.16.0 (2026-10-29)

Automatyczne aktualizacje:

- Zainstalowany program sam sprawdza, czy na GitHubie jest nowa wersja (krótko po starcie i co 6
  godzin), pobiera ją w tle, sprawdza sumę SHA-256 i numer wersji, a instaluje bez pytania, gdy
  edytor się zamyka albo gdy serwer agenta w tle od 10 minut nic nie robi (potem sam wraca w nowej
  wersji z tym samym projektem). Nieudana podmiana niczego nie psuje: pliki wracają na miejsce.
- Na pasku stanu złoty przycisk „Aktualizacja X”: zamyka edytor (najpierw pyta o niezapisane
  zmiany) i uruchamia go w nowej wersji.
- Preferencje, sekcja Aktualizacje: „Aktualizuj automatycznie” (domyślnie włączone), numer wersji,
  „Sprawdź teraz” i stan.
- `hve update` aktualizuje z wiersza poleceń, `hve update --check` tylko sprawdza.

Mikser audio i oś czasu dokończone:

- Mikser: wskaźniki szczytu L i P przy suwaku każdej ścieżki (po suwaku i balansie, z
  przytrzymaniem i znacznikiem przesterowania jak na masterze).
- 35 wbudowanych efektów audio z około 90 presetami: kompresor wielopasmowy (4 pasma, zwrotnice
  Linkwitz-Riley, presety Stare radio, Krótkofalówka, Telefon, Zabawka, Radio AM, Megafon,
  Broadcast, Podcast i inne), kompresor jednopasmowy, limiter, bramka, de-esser, kompresor
  lampowy, dynamika; dolno-, górno-, pasmowo- i wieloprzepustowy, korektor parametryczny (7 pasm)
  i graficzny (10 pasm), bas, sopran; pogłos studyjny (FDN) i pogłos przestrzenny (splot z
  wygenerowanymi odpowiedziami 10 pomieszczeń albo z własnego pliku WAV, kanały 5.1 i 7.1);
  delay, multitap, chorus i flanger, phaser; odszumianie, usuwanie przydźwięku; przester,
  bitcrusher, wzmacniacz wokalu; narzędzia stereo i mastering; declicker (trzaski i trzeszczenie
  płyty). Przester z nadpróbkowaniem (do 8x), limiter i maksymalizer z wyprzedzeniem i szczytem
  rzeczywistym; ich opóźnienie jest kompensowane jak we wtyczkach. Plik odpowiedzi impulsowej
  ze ścieżką względną do folderu projektu.
- MCP: `list_effects` i `list_bus_effects` pokazują presety, nowe narzędzie `apply_effect_preset`
  (jedna rewizja).
- Presety w nagłówku efektu w Ustawieniach efektów: jeden krok cofania, parametry, których preset
  nie zmienia, wracają do domyślnych. Wyszukiwarka efektów znajduje też po identyfikatorze
  („multiband”).
- Linie klatek kluczowych na klipach osi: głośność dla audio i krycie dla wideo, rozwijana lista w
  nagłówku ścieżki wybiera dowolny parametr klipu, efektu na szynie ścieżki albo wtyczki (także
  automatyzacja głośności i panoramy ścieżki). Ctrl i klik dodaje klucz, przeciąganie linii
  podnosi cały odcinek, Alt i przeciągnięcie klucza robi Beziera (także w Ustawieniach efektów i
  w edytorze wykresu), Alt i klik przełącza liniowy i automatyczny Bezier.
- Lasso wyrażeń także między klipami, szynami ścieżek i masterem: `thisComp.track("A1")` i
  `thisComp.master` z `effect()`, `effects` i `numEffects`; wskaźniki powiązań skaczą do szyny.
- Prawy klik na klipie: „Rozwiń audio ze źródła” i „Rozwiń wideo ze źródła” dokłada drugi
  strumień na pierwszej wolnej ścieżce i łączy go z klipem.
- Ścieżki zawsze wypełniają panel; Shift i plus albo minus nad osią delikatnie powiększa albo
  zmniejsza wszystkie ścieżki; przeciągnięcie granicy między ścieżkami zmienia całą grupę
  sprężyście (chwycona granica idzie za kursorem), środkowy separator dzieli wysokość między
  wideo i audio proporcjonalnie.
- Szerokość kolumny nagłówków przeciąga się za jej prawą krawędź (pamiętana), narożnik z nazwą
  narzędzia i czasem końca zniknął, długie nazwy ścieżek kończą się wielokropkiem (pełna nazwa w
  podpowiedzi).
- Ctrl i klik na timecode przełącza timecode, numer klatki i sekundy; linijki osi i Ustawień
  efektów pokazują to samo.
- Każde pole liczbowe przyjmuje działania: `*2`, `+10%`, `/4`, `-=1.5`, `(1920-40)/2`, funkcje
  (`round`, `min`, `max`, `clamp`, `db`), jednostki czasu w polach czasu (`+2s`, `-12f`,
  `1:30`), przecinek dziesiętny.
- Przejścia: rysowane nad oboma klipami z nazwą, krawędzie ciągną się we właściwą stronę
  (wyśrodkowane rosną symetrycznie), Delete na zaznaczonym przejściu usuwa przejście, nie klip;
  przejście wejściowe na cięciu, którego odtwarzanie i tak nie używa, nie jest już pokazywane.

## 0.15.0 (2026-10-28)

Pierwsze wydanie publiczne: https://github.com/lazniak/hexart-video-edit (instalator jedną linią
w PowerShell, FFmpeg w paczce).

- Zgłaszanie błędów z programu: Pomoc > Zgłoś błąd albo ikona w pasku menu. Opis tekstem albo
  notatka głosowa do 3 minut, domyślnie dołączony log z ostatniej minuty (suwak od 10 s do
  10 min, tekst do poprawienia) i informacje o urządzeniu, ścieżki i nazwa użytkownika ukryte.
  Zgłoszenie trafia jako issue na GitHubie; nagranie przepisuje na tekst serwer HEXART
  (ElevenLabs Scribe v2), samo nagranie nie jest publikowane. Gdy wysyłka się nie uda,
  zgłoszenie zostaje zapisane na dysku.
- Nigdy czarna klatka przy klipach na kilku ścieżkach wideo: dekoder, który padł w trakcie,
  nie jest już brany za koniec pliku, chwilowa awaria nie zostawia dziury, za końcem pliku
  monitor pokazuje ostatnią klatkę jak eksport, a warstwa bez obrazu jest trzymana, dopóki nie
  przyjdzie klatka. Monitory nie dekodują warstw zasłoniętych w całości przez klip powyżej, więc
  przewijanie i skoki po materiale 4K na kilku ścieżkach stoją wyraźnie krócej (skoki
  kliknięciem bez zamrożeń, przewijanie w tę i z powrotem najwyżej 0,2 s).
- Głowica na środku osi czasu, opcja w Preferencjach (domyślnie wyłączona): głowica stoi
  pośrodku, a sekwencja przesuwa się pod nią przy odtwarzaniu, scrubie i przewijaniu. Druga
  opcja: kółko myszy przybliża wokół głowicy, Shift i kółko przewija w poziomie, Alt i kółko
  albo kółko nad nagłówkami przewija ścieżki.
- Przewijanie i kliki w pauzie bez czarnych klatek i bez przycięć UI: wątek UI nie czeka
  już na koniec procesu FFmpeg (do 0,8 s przy 4K), po skoku monitor trzyma obraz tylko dla
  warstwy bez niczego, klatki zastępcze z całego zakresu klipu, seek w pauzie dekoduje klatkę
  i 3 następne, sesje, o które głowica już nie pyta, stają, a wokół zatrzymanej głowicy
  dekoduje się podgląd ±3 s. Nowy pomiar `hve scrub`.
- Zoom osi czasu kotwiczy się na głowicy.
- FFmpeg dołączony do paczki (9.0.2); program szuka go najpierw obok siebie.

## 0.14.0 (2026-10-26)

Pierwsze wydanie z tagiem. Zawiera wszystko, co powstało do tej pory.

Nowe od ostatniej wersji testowej (25.10):

- Wyrażenia w pełnym JavaScript: silnik QuickJS-ng z API obiektów, zmienne
  sekwencji, `hve.vars` i `hve.publish` w warstwach web, edytor wyrażeń z kolorowaniem,
  podpowiedziami i pomocą sygnatur, panel Zmienne, dokumentacja z menu Pomoc (PL, EN),
  narzędzia MCP `validate_expression`, `evaluate_expression`, `expression_docs`.
- Sekwencje zagnieżdżone: zagnieżdżanie obrazu i dźwięku z zapasem materiału,
  spłaszczanie bez zmiany wyniku albo odmowa z powodem, otwieranie zagnieżdżeń, ścieżka powrotu.
- Nagrywanie lektora z mikrofonu prosto na oś czasu: REC w pasku osi (Shift+R),
  odliczanie, żywa fala, start od punktu In albo głowicy, naprawa ujęć po awarii.
- Effect Controls i Time Remapping jak w After Effects, Pixel Motion, panel Narzędzia w doku.
- Eksport profesjonalny: formaty, 79 presetów, podgląd In/Out, kontrole przed eksportem,
  QSV sprawdzony na sprzęcie Intel, poprawione argumenty AMF, wszystkie presety dostępne dla agentów.
- Własna ikona aplikacji (kadr z głowicą).
- Audio: utrata urządzenia albo zawieszony sterownik nie blokują silnika.
- FFmpeg i dekodery RAW zawsze podają powód zakończenia.

Wcześniej: oś czasu od wciśnięcia myszy, przeciąganie z systemem, HDR według norm,
korekcja koloru jak w DaVinci Resolve, biblioteka warstw web i MCP, odtwarzanie co
do klatki z pracą w tle, serwer agenta w tle i przełącznik projektów.
