# Zmiany

Notatki o wersjach są po polsku. / Release notes are written in Polish.

## 0.19.32 (2026-11-13)

- Poprawka: klipy dźwiękowe nie gubią już początków przy odtwarzaniu. Mikser gra ciszę,
  dopóki plik nie jest zdekodowany, a o dekodowanie prosił dopiero w chwili, gdy głowica doszła do
  klipu, więc pierwsze klatki dźwięku przepadały (krótki lektor albo efekt tracił kilka klatek,
  długi plik więcej). Tak było z każdym plikiem, którego program nie zdążył zdekodować wcześniej:
  po przełączeniu sekwencji, po położeniu nowego klipu na osi, w zagnieżdżonej sekwencji i przez
  pierwsze chwile po otwarciu dużego projektu. Teraz pliki aktywnej sekwencji dekodują się z
  wyprzedzeniem, gdy tylko zmieni się ich zestaw, a pliki z najbliższych 3 sekund przed głowicą
  idą przed resztą, także gdy odtwarzanie stoi. Jeden z trzech wątków dekodera jest zawsze wolny
  dla pliku, na który czeka mikser.
- Poprawka: klatka Pixel Motion nie jest już ciemniejsza od zwykłej klatki tego samego
  klipu. Przy zwolnieniu i zmianie klatkażu obraz migotał tam, gdzie klatki liczone przez silnik
  (przepływ albo RIFE) przeplatały się z klatkami źródła: dekoder oddawał silnikowi obraz
  ciemniejszy o pół do jednej wartości kodu (8 bitów), a przy nasyconych kolorach do dwóch. Teraz
  obie klatki mają te same poziomy co do zaokrąglenia, w podglądzie i w eksporcie. Dotyczy źródeł
  8-bitowych Y'CbCr (H.264, HEVC, większość kamer, telefonów i generatorów). Ta sama poprawka
  wyrównuje eksport takiego klipu skalowanego z eksportem 1:1 oraz obrazy JPEG. Klatki Pixel
  Motion i klatki z renderu In do Out policzone wcześniej liczą się od nowa (stare pliki usuwa
  limit pamięci podręcznej).

## 0.19.31 (2026-11-13)

- Effect Controls: przycisk „Idź do klipu” w nagłówku klipu przenosi głowicę na jego
  początek, gdy jest poza klipem. Linia głowicy idzie przez całą wysokość panelu, także nad
  pustym miejscem i zwiniętymi grupami.
- Effect Controls: pod Skalą Ruchu widać, że obraz klipu jest dopasowany do kadru (na
  przykład 50 % dla klipu 4K w sekwencji HD), z przełącznikiem „Dopasuj do kadru”. Położenie
  takiego klipu mówi o tym komunikatem (można go wyłączyć w menu tej linii). Agenci widzą to
  samo w `get_timeline` i w wyniku edycji (`fit`). Istniejące projekty renderują się bez zmian.
- Effect Controls: stoper mówi prawdę. Złoty tylko przy klatkach kluczowych, stan
  wyrażenia ma osobny znak (kropka: działa, pierścień: wyłączone). Parametr z wyłączonym
  wyrażeniem przyjmuje klatki kluczowe, a klik przy działającym wyrażeniu pyta i może je
  zastąpić klatkami bez skoku obrazu (jeden krok cofania).
- Effect Controls: grupy parametrów komponentów web i efektów mają nagłówek z nazwą,
  wcięcie i linię wzdłuż wierszy grupy.
- Paleta efektów: skrót (Ctrl+Shift+P w układzie Premier, Ctrl+Space albo
  Ctrl+Shift+Space w innych, zmienisz go w edytorze skrótów) otwiera małe okno wyszukiwania
  efektów, presetów i przejść. Szuka w nazwie polskiej i angielskiej, także bez polskich
  liter. Na górze są ulubione (gwiazdka), potem ostatnio użyte. Strzałki i Enter dodają
  efekt do zaznaczonych klipów, przejście idzie na cięcie jak Ctrl+D. Ulubione (efekty,
  presety i przejścia) są w edytorze skrótów i mogą dostać własny skrót; po zdjęciu gwiazdki
  ten skrót znika. Paleta otwiera się w oknie, w którym naciśnięto skrót, także w oknie
  odłączonym, a dopóki jest otwarta, klawisze nie uruchamiają skrótów.
- Nowy projekt bez decyzji za Ciebie: pusta sekwencja nowego projektu ma format „z pierwszego
  klipu” (widać to w zakładce, w Info i w ustawieniach sekwencji), a pierwszy klip wideo ustawia
  jej rozmiar, klatkaż i dźwięk bez pytania, w tej samej rewizji (zdjęcie, sam dźwięk ani plansza
  formatu nie ustalają). Nazwy, które edytor nadaje sam
  (sekwencja, nowy projekt), są w języku interfejsu, a wybór języka przy pierwszym uruchomieniu
  przemianowuje nieruszone nazwy pustego projektu. Menu Edycja ma przełącznik „Cofnięcie przenosi
  głowicę do zmiany” (domyślnie wyłączony); wyłączony, cofnięcie zmiany poza widokiem osi mówi to w
  komunikacie z przyciskiem „Pokaż”. Agenci widzą `format_unset` w `project_info` i `get_timeline`.
- Okno niezgodności ustawień po uwagach testera: „Zmień
  ustawienia sekwencji” nie oddala już osi do całej sekwencji, więc klipy upuszczone w
  powiększeniu zostają tam, gdzie widać je przed pytaniem, z tym samym zoomem i głowicą. Jedno
  Ctrl+Z zabiera klipy i nowe ustawienia, a kolejne upuszczenie na pustą sekwencję znów pyta.
  Pytanie o ustawienia nie przepada, gdy przy upuszczeniu jest otwarte inne okno albo klip nie
  jest jeszcze zbadany: pojawia się, gdy tylko może. Upuszczenie przenosi ramkę na oś,
  więc Delete usuwa upuszczone klipy, a nie pliki z projektu.
- Panel z klawiaturą ma złotą ramkę i tylko on bierze klawisze. Klik albo upuszczenie
  (także plików z Eksploratora) przenosi ramkę, skróty przełączania paneli i menu Okno też.
  Delete, Ctrl+A, Ctrl+C/X/V nad osią nie usuwają już niczego z panelu Projekt, gdy ramka jest
  na osi, i nie edytują osi, gdy ramka jest na innym panelu; inne skróty na tych klawiszach
  (cofnij w Las Vegas, krok w Mozarcie, czyszczenie wejścia i wyjścia) działają dalej. Złota
  linia na górze monitorów to teraz ta sama ramka; zakładki grup bez ramki mają szary pasek.
- Linie krycia i głośności na klipach są domyślnie ukryte i nie łapią się przypadkiem.
  Pokazuje je przełącznik „Linie klatek kluczowych na klipach” w nowym menu „Ustawienia
  wyświetlania osi” w pasku osi (Ctrl+Alt+Shift+K, zapamiętany), a na chwilę wystarczy
  przytrzymać Ctrl+Alt nad ścieżkami (gesty Ctrl+Alt na klipach działają przy tym jak zawsze).
  Parametr wybrany w nagłówku ścieżki i narzędzie Pióro pokazują linie jak dotąd, obwiednie
  VEGAS też.
- Link to nie grupa. „Połącz” łączy jeden obraz z jego dźwiękiem (z tego samego pliku
  albo z osobnego rejestratora) i nigdy jednego klipu samego ze sobą; połączone części mają
  znak łańcucha. Dwa obrazy, tytuły i inne klipy łączy nowe „Grupuj” (Ctrl+G, „Rozgrupuj”
  Ctrl+Shift+G): grupa ma swój znak i przerywaną górną krawędź, klik zaznacza całą grupę,
  Alt+klik jeden klip. Projekty, w których połączono różne klipy, otwierają się z tymi
  klipami w grupie (raz pojawia się komunikat), nic nie ginie; dźwięk z rejestratora zostaje
  połączony z obrazem.
- Alt+klik zaznacza jedną część połączonego klipu, a jej przeciągnięcie przesuwa tylko ją, bez
  rozłączania. Części, które się rozjechały, pokazują czerwoną plakietkę z przesunięciem
  w klatkach, a menu klipu ma „Przesuń do synchronizacji” i „Przesuń źródło do
  synchronizacji”.
- Modele, które już masz: Whisper i RIFE mogą korzystać z pliku z innego programu albo
  wcześniejszego pobrania („Użyj istniejącego pliku…”, „Poszukaj w typowych miejscach”), bez
  kopiowania, po sprawdzeniu formatu, rozmiaru i sumy kontrolnej. Brak pliku jest opisany
  wprost.
- Pobieranie modeli: przycisk Whispera podaje osobno rozmiar modelu i środowiska,
  postęp pokazuje prędkość i pozostały czas w Preferencjach i w pasku zadań, a przerwane
  pobieranie można wznowić.
- Aktualizacje po Twojemu: w Preferencjach do wyboru Automatycznie (jak dotąd), Pytaj
  (program mówi, że jest nowa wersja, a pobiera ją dopiero po kliknięciu; gotową instaluje po
  „Uruchom ponownie teraz” albo, jeśli wybierzesz Później, przy następnym starcie) albo
  Ręcznie (nic nie sprawdza samo). Widać zainstalowaną wersję, kiedy program ostatnio sprawdzał
  i co znalazł. Pierwszy start po aktualizacji mówi „Zaktualizowano do X (było Y)” i pokazuje,
  co nowego. Program nigdy nie uruchamia się ponownie sam i nie przerywa eksportu, renderu,
  nagrywania, generowania, transkrypcji, wysyłki ani sesji online.

## 0.19.30 (2026-11-13)

- Przeciąganie liczb (D149, uwagi testera JD.20 i JD.21): każda liczba w aplikacji (Effect
  Controls, mikser, eksport, kolor, DAW, maski, pokrętła efektów audio) przesuwa się o jedną
  jednostkę na punkt ruchu, z Shift o dziesięć, z Ctrl o jedną dziesiątą. Uwaga: Shift
  przyspiesza, a nie zwalnia jak dotąd w polach liczb, pokrętłach efektów audio i pasku master
  Koloru. Jednostka zależy od zakresu: 1 dla Pozycji, Skali, stopni, procentów, klatek i pikseli,
  drobniej dla wąskich zakresów (0,01 dla krycia 0..1, 0,1 dla zaniku pogłosu), okrągła większa
  liczba dla bardzo szerokich (20 Hz dla częstotliwości korektora 100..8000 Hz). Z Ctrl pole
  pokazuje miejsca po przecinku. Kursor w trakcie jest ukryty i stoi w miejscu, więc
  przeciąganie nie kończy się na krawędzi ekranu; po puszczeniu kursor wraca. Przez pulpit
  zdalny, piórem i dotykiem kursor zostaje widoczny i zawija się na krawędzi okna. Alt+Tab albo
  wyskakujące okno kończy przeciąganie. Esc w trakcie przywraca wartość sprzed przeciągania i
  nic nie zapisuje w historii (także na parametrze z kluczami i przy kilku klipach), a dialog,
  filtr, zaznaczenie kluczy i zaznaczenie nut w MIDI zostają. Szerokość i wysokość eksportu i sekwencji idą po 2 piksele
  i zawsze są parzyste.
- Poprawka: wyrażenie wpisane w pole liczby (`*2`, `+10%`) liczy się raz, od wartości
  sprzed edycji. Wcześniej część pól stosowała je dwa razy (Skala 100 po `*2` dawała 400).
- Enter w polach tekstowych (D149, JD.30): w polach wielowierszowych (wyrażenia, tekst, notatki
  znaczników, edytor kodu i JSON, prompty) Return dodaje wiersz, a Ctrl+Return i Enter z
  klawiatury numerycznej zatwierdzają (Ctrl+Return także w odczepionych oknach). W polach
  jednowierszowych zatwierdzają oba Entery.
- Gotowe wyrażenia (D149, JD.32): lista pod plusem mówi, co zastępuje całe wyrażenie (albo
  zaznaczenie), a co wstawia się w miejscu kursora. Jedno Ctrl+Z przywraca poprzednie wyrażenie.
- Poprawka (D149, JD.33): plus w edytorze wyrażeń przy zaznaczonym tekście nie zatwierdza już
  niedokończonego wyrażenia, nie przesuwa panelu i nie zamyka edytora.
- Preferencje w sekcjach (D150, uwagi testera): lista sekcji z boku (Ogólne, Język i
  wygląd, Oś czasu, Odtwarzanie i pamięć podręczna, Media, Transkrypcja, AI i modele, Agent,
  Dokumenty, Aktualizacje, Skróty klawiszowe) zamiast jednej długiej strony. Pole wyszukiwania
  znajduje ustawienie po polsku i po angielsku, także wpisane bez polskich znaków, i przewija do
  niego. Okno wraca do ostatniej sekcji, mieści się w 1280x720, a wyszukiwarka, lista i
  Zamknij są zawsze widoczne. Ogólne pokazują folder ustawień z przyciskiem Otwórz.
- Skróty klawiszowe pod ręką: Edycja > Skróty klawiszowe… i Ctrl+Alt+K (Premier,
  Cupertino, Leonardo, Las Vegas, Mozart, Studio) otwierają edytor skrótów jako sekcję
  Preferencji. Edytor szuka po nazwie polecenia w każdym języku i po klawiszu, wpisanym albo
  naciśniętym („Szukaj po klawiszu”), a akord zajęty przez inne polecenie jest czerwony przy
  obu, z podpowiedzią które; „Tylko konflikty” pokazuje same takie wiersze.
- Pierwsze uruchomienie bez zgadywania (D144, uwagi testera JD.1 do JD.6). Instalator pyta,
  gdzie zainstalować program (Enter zostawia folder domyślny, `-InstallDir` i `-Yes` bez
  pytania), a istniejącą instalację aktualizuje tam, gdzie jest. Folder z innymi plikami albo
  cały dysk dostaje podfolder „HEXART Video Edit”. Odinstalowanie usuwa pliki programu po
  nazwie, a w folderze, który poprzedni instalator przyjął mimo innych plików, zostawia też
  podfoldery programu i mówi, które. Instalacje starsze niż znacznik `.hve-install` (v0.14.0 do
  v0.18.1) są rozpoznawane i dostają znacznik. Program jest w Ustawieniach,
  Aplikacje: prawy klik na nim w menu Start daje „Odinstaluj”, a w jego folderze menu Start jest
  skrót „Odinstaluj HEXART Video Edit”. Odinstalowanie pyta, czy zachować ustawienia i listę
  ostatnich projektów, projektów nie rusza nigdy. Wersja we wpisie idzie za samoaktualizacją.
  Junction w folderach programu i danych (np. modele przeniesione na inny dysk) znika jako
  dowiązanie, a to, na co wskazuje, zostaje. `-Purge` z folderu danych spoza domyślnego miejsca
  usuwa tylko to, co zapisuje program.
- Okno Projekty bez „Anuluj”: „Nowy projekt”, „Otwórz projekt…” i „Otwórz”; pierwsze
  uruchomienie idzie prosto do pustego projektu, bez listy do wyboru.
- Wiadomo, gdzie są ustawienia: Pomoc, „Otwórz folder ustawień”, i ścieżka w „O programie”.
  Plik `portable.txt` obok programu robi z kopii kopię przenośną z ustawieniami, krokami
  pierwszego uruchomienia i cache w folderze `data` obok niej i z własnym portem agenta. Kopia z
  innego folderu pyta raz, czy użyć wspólnych ustawień, czy zostać osobno.
- Panel Project: podgląd po najechaniu da się wyłączyć (menu Filtra, Shift+H w panelu),
  wtedy najechanie niczego nie dekoduje. Zaznaczone klipy upuszczone na przycisk „Nowy kosz”
  trafiają do nowego kosza jednym krokiem; menu klipu ma „Przenieś do nowego kosza” i
  „Przenieś do kosza” z listą koszy.
- Panel edycji tekstem pokazuje transkrypcję klipu klikniętego w panelu Project albo na osi,
  bez otwierania monitora Source; pinezka trzyma bieżący klip.
- Sześciokropkowe uchwyty paneli nie przebijają już przez okna modalne.
- „Change with Agent” nie mówi „brak mikrofonu”, gdy mikrofon działa: przerwy zgłaszane przez
  sterownik nie kończą nagrania, a komunikat podaje prawdziwą przyczynę (brak urządzenia, brak
  zgody Windows, odłączony, nie otworzył się, sama cisza).
- Effect Controls (D148, uwagi testera): Delete albo Backspace przy zaznaczonej masce usuwa
  maskę, a nie cały klip. Panel z fokusem nie oddaje już Delete osi czasu: działa na kluczach,
  efektach i wartościach albo masce, a bez zaznaczenia nic nie robi. Wiersz maski ma menu
  kontekstowe (Zmień nazwę, Odwróć, Zablokuj, Usuń maskę), także z nazwy maski. Przy fokusie w
  panelu Shift+Delete, Alt+Backspace i inne skróty layoutu usuwające klipy nic nie robią,
  przytrzymany Delete usuwa raz, a kliknięcie maski i efektu daje jedno zaznaczenie naraz.
- Oś czasu po uwagach testera: klipy upuszczone dalej na pustą sekwencję zostają na
  miejscu po „Zmień ustawienia sekwencji”, a upuszczenie z nowymi ustawieniami cofa jedno Ctrl+Z.
  Przeciąganie klipu nad nagłówki ścieżek już go nie gubi: puszczenie nad nagłówkiem kładzie klip
  na początku tej ścieżki (samo przejście nad nagłówkami w drodze z panelu Projekt niczego nie
  przesuwa), a nad linijką podgląd stoi; przeciąganie kończy się poza panelem osi albo klawiszem Esc.
  Prawy przycisk na pustym miejscu ścieżki stawia tam głowicę i zatrzymuje odtwarzanie, jak
  kliknięcie w linijkę, przeciąganie prawym przewija jak po linijce (z Ctrl z dźwiękiem), a
  kliknięcie dalej otwiera menu miejsca. Ukośnik (\) pokazuje całą
  sekwencję, a drugie naciśnięcie wraca do poprzedniego zoomu i przewinięcia, osobno w każdym
  panelu osi.
- Skrubowanie w monitorze Program i Źródło: gdy zatrzymasz mysz z wciśniętym przyciskiem,
  monitor nie udaje już, że obraz zastępczy z innej chwili to klatka głowicy. Do czasu, aż klatka
  głowicy będzie gotowa, obraz jest przyciemniony z napisem „Czekam na klatkę głowicy”, a potem
  pokazuje dokładnie czas głowicy; gdy klatki nie da się zdekodować, napis to mówi. W ruchu i przy
  edycji pod stojącą głowicą obraz zastępczy zostaje jak był, z kreską w rogu.
- Paski nad obrazem Programu i ukośna kreska w rogu mają legendę w podpowiedzi (ramka fokusu,
  kolory pamięci podglądu, głowica), opis jest w README.
- Dwuklik w obrazie Programu zaznacza najwyższy klip pod kursorem i włącza transformację, jak w
  Premiere (bez zablokowanych ścieżek, warstw dopasowania i klipów z kryciem 0; tytuł na cały
  kadr nie zasłania klipu pod nim); pełny ekran ma swój przycisk w pasku monitora i dalej Ctrl+`.
- Menu Sekwencja: „Zaznacz klip pod głowicą” (D w układzie Premier, na wskazanych ścieżkach) i
  przełącznik „Zaznaczenie podąża za głowicą” (domyślnie wyłączony, zapamiętany).
- Maski i inne nakładki monitora Program nie wychodzą poza obszar obrazu: nie zasłaniają
  transportu, pasków ani innych paneli. Po oddaleniu widoku punkty maski można stawiać i
  przeciągać poza kadrem.
- Potrójny klik na ścieżce maski zaznacza wszystkie jej punkty: ramka przesuwa, skaluje i obraca
  całą maskę jednym krokiem cofania.

## 0.19.29 (2026-11-11)

- Dokumenty przez konwersję (D136, część trzecia): HTML, pliki biurowe (DOC, DOCX, ODT, RTF,
  PPT, PPTX, ODP, XLS) i EPS wchodzą do projektu jako obraz ze stronami, jak PDF. HTML drukuje
  Chrome albo Edge na stronie 16:9: strona dostaje pliki ze swojego folderu, bez sieci i bez
  innych plików komputera, a zmiana pliku obok niej (arkusz stylów, obraz) daje nowy obraz.
  Pliki biurowe konwertuje LibreOffice:
  Twój albo zainstalowany jednym przyciskiem w Preferencjach, sekcja Dokumenty (373 MB, do
  folderu narzędzi edytora, bez instalacji w systemie). EPS konwertuje Ghostscript, jeśli go
  masz w wersji 10.03.1 albo nowszej (starsza ma znane luki i nie jest uruchamiana, tak samo
  program, który nie podaje swojej wersji). Każdy z
  nich działa jako osobny program, a wynik leży w cache i liczy się do jego limitu. Konwersję
  zatrzymuje Anuluj importu, eksportu albo innego zadania w tle (render podglądu, zapis klatki) i
  zamknięcie edytora, a program kończy się razem ze wszystkim, co
  uruchomił. Gdy programu nie ma albo konwersja się nie uda, import mówi, co się stało; eksport
  z takim dokumentem zatrzymuje się z tym samym komunikatem.

## 0.19.28 (2026-11-11)

- Match Color: nowy efekt dopasowuje kolor całego klipu do wybranych klatek odniesienia
  (klip z osi i klatka w nim, do 16). W Effect Controls lista referencji z miniaturą i timecode,
  „Dodaj referencję” kliknięciem w klip na osi, „Klip pod wskaźnikiem”, a parametr „Referencja” ma
  klatki kluczowe (liniowe mieszają odniesienia, Hold przełącza). Siła, osobno jasność i kolor,
  ochrona neutralnych. Analiza w tle z postępem i pamięcią na dysku, to samo w podglądzie i
  eksporcie. Agent: `match_color` z `mode: effect` i `match_color_status`. Klip ze stabilizacją
  jest mierzony po jej analizie, drugi Match Color na klipie po pierwszym, usunięcie referencji
  przenumerowuje klucze, a zagnieżdżony klip referencji nadal działa. Kopia sekwencji,
  „Uczyń unikalnym”, wklejanie i kopia przez Alt razem z klipem referencji dopasowują do kopii
  klipów, a warstwa korekcyjna nie może być referencją. Referencja na elemencie sekwencji z
  prędkością albo wstecz wskazuje tę samą klatkę.
- Dokumenty jako strony (D136, część druga): pliki tekstowe (TXT, LOG, INI, TOML, YAML),
  Markdown, JSON, XML, CSV i TSV oraz arkusze (XLSX, XLSM, XLSB, ODS) wchodzą do projektu jako
  obraz ze stronami, jak PDF. Stronę 16:9 (1920 x 1080) układa edytor w czcionkach aplikacji:
  jasny tekst na przezroczystości, ciemny po ustawieniu jasnego tła w Interpret Footage. JSON i
  XML są kolorowane, Markdown ma nagłówki, listy, cytaty, kod i tabele, tabela powtarza nagłówek
  na każdej stronie, arkusz to jego zakładki po kolei. Strony są wektorowe, więc ostre w każdej
  skali. Dokument wchodzi, gdy wskażesz go z nazwy; import folderu oraz wybór razem z wideo,
  dźwiękiem albo folderem go pomija i liczy w podsumowaniu. Pliki SRT i VTT zostają napisami.
  Plik JSON albo XML nazwany jak zdjęcie z tego samego wyboru (`IMG_1.jpg.json`, także
  `IMG_1.jpg.supplemental-metadata.json` z Google Takeout) to dane tego
  zdjęcia i też zostaje pominięty. Plik płynie na strony w miarę czytania, do 2000 stron, więc
  nawet bardzo duży albo spreparowany plik zajmuje tyle pamięci, ile pokażą jego strony.
  Markdown powyżej 2 MB jest pokazany jak zwykły tekst.
  MCP: `import_media` przyjmuje te pliki po ścieżce według tych samych reguł, `media_info` podaje
  `document.pages`.
- Interpret Footage: prawy klik na jednym albo wielu elementach panelu Projekt otwiera okno
  z ustawieniami według rodzaju medium. Wideo: klatkaż z pliku albo przyjęty (gra każdą klatkę
  pliku, długość i dźwięk idą za nim), proporcje piksela, kolejność pól, alfa (prosta, ignorowana,
  premultiplikowana na kolorze), interpretacja i zakres koloru, obrót, timecode początku. Sekwencja
  obrazów: klatkaż, pierwsza klatka, luki trzymają poprzednią klatkę albo są puste. Obraz: własna
  długość nowych klipów. Dźwięk: mono, stereo, jeden kanał, mapa kanałów (podwójne mono), inna
  częstotliwość próbkowania. Przy wielu elementach zmienia się tylko to, czego dotkniesz. Klipy
  leżące już na osiach zachowują miejsce, długość i czasy źródła, a okno mówi, ile z nich pokazuje
  teraz inne klatki i ile wychodzi poza koniec źródła. Jedna rewizja, z undo.
- Więcej typów plików: wszystkie obrazy, które dekoduje dołączony FFmpeg (m.in. JPEG XL,
  AVIF, HDR, DDS, PSD, ICO, QOI, JPEG 2000, PCX, SGI, PNM), SVG, PDF i AI zgodny z PDF. Źródła
  wektorowe zostają ostre w każdej skali (rysowanie wektorowe) albo są rysowane raz w wybranym
  DPI, z przezroczystym tłem albo kolorem. PDF, AI i wielostronicowy TIFF mają strony: liczba
  stron jest sprawdzana przy imporcie, stronę domyślną ustawia Interpret Footage, a pojedynczy klip
  ma własną w Effect Controls (Źródło, Strona; klucze trzymają wartość, więc jeden PDF może
  przewracać strony w czasie).
- MCP: `update_media` ustawia interpretację tymi samymi słowami co okno (`rate`,
  `pixel_aspect`, `fields`, `alpha`, `rotation`, `range`, `start_timecode`, `start_frame`,
  `missing_frames`, `still_duration`, `rendering`, `dpi`, `page`, `page_box`, `background`,
  `audio_channels`, `sample_rate`; `file` wraca do pliku) i zwraca `items_retimed` oraz
  `items_past_end`. `media_info` pokazuje `interpretable`, `interpretation`, `file_probe` i
  `document`. Strona klipu: `set_param` i `set_keyframe` z parametrem `page`.
- Medium czytane z innym klatkażem albo częstotliwością próbkowania: słowa transkrypcji,
  bity, cisza, trafienia wyszukiwania i stabilizator idą razem z obrazem i dźwiękiem (analiza
  trzyma czas pliku, czytający przelicza go na czas medium). Rotoskopia, głębia i rozdzielanie
  ścieżek na takim medium mówią, że najpierw trzeba wrócić do wartości z pliku. Strona TIFF i
  strona dokumentu mają limit wielkości zamiast alokacji bez granic; podgląd w pliku TIFF nie
  jest już liczony jako strona, a strony czarno-białe są czytane.
- Skopy na GPU z każdej klatki: pomiar pełnej klatki wyjścia w precyzji float zamiast
  próbki 1920 px i 8 bitów, obraz w pikselach ekranu (także HiDPI), odświeżanie z każdą pokazaną
  klatką zamiast ok. 8 razy na sekundę. Osiem trybów (przebieg luminancji i RGB, parada RGB i
  YCbCr, wektoroskop z celami 75 i 100 %, linią skóry i powiększeniem, histogram RGB, kanałów i
  luminancji z 256 do 4096 koszyków, liniowy i log, CIE 1931 xy z gamutami Rec.709, P3 i
  Rec.2020, fałszywe kolory), do czterech skopów naraz w pięciu układach, skale w procentach,
  nitach (PQ), HLG i wartościach kodowych 8 i 10 bitów, wskaźniki przepaleń i wyjścia poza gamut,
  obszar pomiaru wybierany na monitorze Programu, poświata i jasność śladu. Zatrzymana klatka
  jest mierzona w rozdzielczości sekwencji. Skale PQ i HLG pokazują też to, co wychodzi poza
  gamut i ponad zakres (sekwencja PQ z ograniczeniem do szczytu liczy przepalenie na szczycie),
  płaski obraz nie spowalnia pomiaru, a karta bez shaderów obliczeniowych dostaje komunikat
  zamiast pustego panelu.
- Speed na sekwencjach: sekwencja położona na osi (nest) przyjmuje to samo co klip: prędkość
  w procentach, rewers, dopasowanie do długości, narzędzie Rate Stretch, slip i Time Remap. Obraz,
  dźwięk, słowa transkrypcji i związane głowice idą za prędkością; wysokość dźwięku zmienia się
  razem z nią. Zagnieżdżenia z inną prędkością, wstecz albo z Time Remap nie da się spłaszczyć,
  dopóki nie wróci do 100% do przodu. Okno Speed / Duration otwiera się ze stanem rewersu elementu.
- Sekwencja jako nest albo klip natywny: nowy przełącznik „Interpretacja sekwencji” w menu
  elementu i w Effect Controls. Nest działa jak dotąd (dokładny czas w środku, bez końca źródła).
  Klip natywny traktuje sekwencję jak plik: własne klatki w klatkażu sekwencji, Frame Blending
  (Frame Mix; Pixel Motion pokazuje na razie Frame Mix), trym i slip w długości sekwencji,
  trzymanie pierwszej i ostatniej klatki poza nią. Przełączanie tam i z powrotem niczego nie gubi.
  Agent: `set_speed`, `slip` i `set_frame_blend` na elementach sekwencji, nowe `set_nest_mode`,
  pełniejsze `nest_info`.
- Poprawka: odwrócony klip (także w odwróconej sekwencji) pokazywał każdą klatkę o jedną za późno,
  a pierwsza klatka wypadała tuż za zakresem. Stopklatka w układzie Cupertino zaczyna na klatce
  widocznej przy każdej prędkości i kierunku.
- Oś czasu: przeciągnięcie klipu z Altem zostawia kopię w miejscu upuszczenia, a oryginał
  stoi. Kopiuje się całe zaznaczenie, obraz razem z dźwiękiem, także na inną ścieżkę, z
  przyciąganiem i z wstawieniem (Ctrl) albo nadpisaniem jak przy przenoszeniu; jedna rewizja i
  jedno cofnięcie. Alt można wcisnąć i puścić w trakcie, podgląd od razu pokazuje kopię albo
  przeniesienie, a kursor mówi, który to tryb. W układzie LasVegas kopiuje Ctrl. Sam klip bez
  partnera przenosi teraz Alt+klik i zwykłe przeciągnięcie; przyciąganie w trakcie wyłącza S.
  Kopia, także wklejona Ctrl+V, ma własne identyfikatory efektów, masek, znaczników i ujęć.
- Lewy i prawy Alt działają tak samo w gestach myszy: krzywe na klatkach kluczowych klipów
  i w Effect Controls, kopia klipu, przycinanie jednej strony. Na polskiej klawiaturze prawy Alt
  (AltGr) nie docierał dotąd do gestów; pisanie polskich znaków i skróty zostają bez zmian.
- Tempo jak klatki kluczowe: nagłówek pasa tempa w trybie taktów ma przyciski poprzedni
  punkt, punkt na głowicy (dodaj albo usuń) i następny punkt, pole BPM do przeciągania i wpisania
  oraz przełącznik skok albo rampa. W trybie taktów klatki kluczowe na linii klipu lądują na
  siatce taktów. Agent czyta mapę tempa w `get_timeline` (`tempo_map`).
- Dwie osie czasu obok siebie: oś, która nie edytuje, rysuje cały interfejs (pasek,
  nagłówki z przełącznikami, paski przewijania, pas tempa). Jej przełączniki ścieżek i widok
  działają na jej sekwencji bez przełączania edycji, a kliknięcie w klip albo linijkę od razu
  edytuje w tej osi.
- Panel Projekt: po imporcie panel otwiera kosz, do którego trafiły pliki, zaznacza je i
  przewija do pierwszego, w liście i w siatce; czeka, aż puścisz mysz, i nie zabiera klawiatury
  osi czasu. Lista ma nagłówki kolumn: klik sortuje (drugi klik odwraca), menu nagłówka pokazuje
  i ukrywa metadane (typ, czas, klatkaż, rozdzielczość, kodek, format pikseli, kolor, dźwięk,
  rozmiar, data zmiany, ścieżka, użycia, ocena, tagi, rolka, status), nagłówek da się przeciągnąć
  w inne miejsce, krawędź zmienia szerokość, dwuklik ją dopasowuje. Układ i sortowanie zapisują
  się w preferencjach programu. Import folderów (Plik > Importuj folder, menu panelu,
  upuszczenie) odtwarza strukturę jako kosze w jednej rewizji, pomija pliki ukryte i śmieci
  systemowe, a po imporcie mówi, ile plików pominął, z listą. Agent: `import_media` z
  `recursive: true` importuje folder ze strukturą i zwraca kosze oraz pominięte pliki.
- Listy rozwijane i menu nie poszerzają się same: lista presetów eksportu z zapisanym presetem
  rosła o 4 punkty w każdej klatce (wiersz z przyciskami zmiany nazwy i usuwania prosił o 4
  punkty więcej, niż lista miała, a egui daje liście szerokość z poprzedniej klatki), a pasek
  przewijania długiej listy (efekty i wtyczki w mikserze) wjeżdżał przez pierwsze klatki i
  poszerzał ją o swoją szerokość. Każda lista i menu ma teraz stałą szerokość od pierwszej
  klatki i poszerza się tylko dla dłuższej nazwy, która do niej przyszła, najwyżej do ekranu;
  nazwy dłuższe niż ekran kończą się wielokropkiem (nazwy wtyczek z pełną nazwą w dymku).
- Effect Controls: przyciski poprzedniej i następnej klatki kluczowej, romb i reset pokazują
  najechanie i wciśnięcie, mają dymki i szarzeją, gdy nie ma dokąd skoczyć. Skok do klatki
  kluczowej nie staje już w miejscu przy kluczu między klatkami sekwencji i pomija klucze poza
  widoczną częścią przyciętego klipu; przyciski, J i K oraz panele Korekcja i Kolor liczą to
  tak samo. W panelu Kolor przyciski klatek kluczowych działają (wcześniej nie robiły nic), a
  skrót dodania klucza nie dokłada drugiego klucza w tej samej klatce.
- „Pokaż w projekcie” w menu zakładki: zakładka osi czasu pokazuje swoją sekwencję, monitor
  Źródło i edytor tekstu swój klip. Panel Projekt wychodzi na wierzch, otwiera folder elementu,
  zaznacza go i przewija do niego, w liście i w siatce.

## 0.19.27 (2026-11-09)

- Dźwięk komponentów web: komponent z `audio` w `layer.json` liczy dźwięk offline z tego
  samego czasu, parametrów i kluczy co obraz (`hve.onAudio` blok po bloku albo
  `hve.renderAudio`). Na osi to para obraz i dźwięk zlinkowana jak klip z dźwiękiem, render idzie
  w tle z cache na dysku i w pamięci, eksport na niego czeka. Agent: `add_web_layer` kładzie parę,
  `preview_component_audio` zapisuje WAV z poziomem i obwiednią.

## 0.19.26 (2026-11-09)

- Sekwencje obrazów: ponumerowane klatki PNG, EXR, DPX, TIFF, JPEG i WebP wchodzą jako
  jeden klip z klatkażem do wyboru w oknie importu (domyślnie klatkaż aktywnej sekwencji), także
  przy przeciąganiu na oś. Klatkaż zmienia się później w menu klipu (Interpret Footage), z
  ostrzeżeniem, gdy klipy sięgną poza koniec sekwencji. Brakująca klatka pokazuje klatkę sprzed
  luki, nigdy czarną, a okno importu, panel Info i MCP mówią, ilu klatek brakuje. Cała sekwencja
  to jeden dekoder, także gdy klatki są co drugą. MCP: `import_media` z wzorcem (`%04d`, `####`)
  albo `sequence: true`, `media_info` z numerami i lukami, `update_media` z `rate`.

- Plik offline: klip, którego pliku nie ma, pokazuje w monitorach Program i Źródło planszę
  „Plik offline” z nazwą pliku zamiast czerni. Eksport wypisuje brakujące pliki przed startem i
  rusza dopiero po zgodzie na te pliki (wtedy z planszą; plik, który zniknie później, nadal go
  zatrzymuje). Agent dostaje listę w `render_frame` i `export`, a zgodę daje użytkownik w oknie
  edytora.

## 0.19.25 (2026-11-09)

- Import FCPXML z Final Cut Pro: pliki `.fcpxml` i paczki `.fcpxmld`, także z ZIP-a z
  Maca (nazwy w NFD). Oś główna, ścieżki połączone, conform 24p do projektu 50p (25 kl./s),
  retime z krzywą prędkości jako Time Remap, przenikania, krycie, transformacja, głośność i
  znaczniki. Przejścia i efekty bez odpowiednika w HVE (Simple Camera Slide, mLut, Match Color,
  krzywe) dostają znacznik do przeglądu i wpis w raporcie wierności. Cięcia J i L, wyłączony
  dźwięk kamery w klipach synchronizowanych i wyłączone kanały przechodzą jak w FCP; pliku na
  udziale sieciowym import nie dotyka bez zgody.
- Ostatnia klatka źródła nie ginie już przy prędkości równej długości źródła przez długość
  klipu.
- MCP: `render_frame` zapisuje kopię klatki w projekcie (`out_path`) i pomija wybrane ścieżki
  (`exclude_tracks`); `match_color` porównuje klatki w jednym czasie sekwencji (`at`); `trim`
  przesuwa klucze efektów z krawędzią na życzenie (`keys: "edge"`) i ostrzega o kluczach poza
  klipem; `edit` zachowuje aktywną sekwencję przy przebudowie i zgłasza jej zmianę; opis `edit`
  ma ściągę nazw pól; `get_timeline` pokazuje Time Remap klipu i liczy z niego początek i koniec
  w źródle.
- Agent zapisuje swoje sugestie i zgłoszenia błędów w lokalnym pliku (D128, `feedback_note`), a
  `feedback_send` otwiera je w oknie zgłoszenia, tylko prywatnie do HEXART; wysyła użytkownik.
- Akcje edytora z zewnątrz, na przykład ze Stream Decka: `hve action <id>`, HTTP
  `/admin/action`, lista akcji `hve action --list`; opis w `docs/stream-deck.md`. Działają jak
  skrót (nie przy otwartym oknie dialogowym, menu ani polu tekstowym), odpowiedź mówi, czy akcja
  się wykonała, a ich zmiany mają w Historii własnego autora. Cofnij, ponów, nagrywanie
  mikrofonu i zastąpienie otwartego projektu nigdy z zewnątrz.
- Agent mierzy kolor ujęć liczbami (D129, `color_stats`): luma, średnie RGB, ciepło i odcień
  półtonów, chroma i przepalenia każdego ujęcia oraz skoki między sąsiednimi ujęciami, bez
  oglądania obrazu każdego z nich. Klatki z wnętrza ujęcia, poza przejściami, renderowane w
  pamięci, z limitem czasu.
- Efekty od pierwszego upuszczenia: NTSC z listy startuje od wyglądu VHS, a gdy Ustawienia
  efektów nie są na wierzchu, komunikat mówi, gdzie są, i otwiera je kliknięciem. Pasy kinowe mają
  presety z proporcjami kina (2,39:1, 1,85:1, 2:1, 4:3, 1:1).
- Przejścia wideo są w Efektach zaraz pod efektami wideo, każde z opisem w podpowiedzi
  (przybliżenie, wypchnięcie, wsunięcie i inne).
- Ścieżka audio dodaje efekt albo wtyczkę VST z własnego menu, nie tylko w mikserze.
- Nagrania: ujęcie z przypadkowego nagrania usuwa się w panelu Nagrywanie jedną rewizją, a
  nagrania, których projekt już nie ma, przycisk przy komunikacie albo w panelu przenosi do kosza
  projektu (sprawdzając w chwili kliknięcia, czego projekt używa), a komunikat po wszystkim ma
  przycisk Przywróć.
- Monitor Program: środek warstwy ją przesuwa (punkt zakotwiczenia z Altem), uchwyty małej
  warstwy maleją, a nacisk przesunięty o włos niczego nie zmienia. Przeciągnięcie warstwy przy
  wyłączonej edycji podpowiada, gdzie ją włączyć.
- Wygaszanie Ctrl+D na wolnym brzegu klipu gaśnie równo w jasności (D125, także w starych
  projektach), a pas między ścieżkami wideo i audio jest szerszy: klip przeciągnięty w dół zostaje
  na V1.
- Stabilizator obrazu, żyroskop z pliku (D122, ST6): analiza czyta żyroskop i akcelerometr
  zapisane przez kamerę (DJI, GoPro, Sony, Insta360, Blackmagic, RED, aplikacje iPhone, logi
  Gyroflow `.gcsv` obok pliku), sama dopasowuje czas i ułożenie czujnika do obrazu na trzech
  krótkich odcinkach i liczy resztę ujęcia z żyroskopu bez dekodowania klatek. Horyzont trzyma
  się grawitacji. Profile obiektywów: ten zapisany w pliku przez kamerę albo baza Gyroflow
  (domena publiczna, pobierana na żądanie: `hve stab lens-db --download`), z ogniskową i
  dystorsją z profilu zamiast szacowania. `hve stab analyze` ma `--source auto|optical|gyro`,
  `--gyro-offset-ms`, `--lens` i `--lens-profile`. Uszkodzony plik z kamery nie zamyka programu
  (odczyt w osobnym procesie z limitem pamięci), log, który zaczął się sam, znajduje się w
  całości (także przy chodzie), a profil GoPro pasuje do trybu obiektywu z pliku (Wide,
  Linear, SuperView), także gdy baza ma kilka ustawień tego trybu. Długi odczyt z dysku
  sieciowego trwa, dopóki idzie, a gdy się nie uda (także plik zablokowany albo dysk, który
  zniknął), powód widać w wyniku analizy, a następne analizy próbują znowu, najwyżej trzy razy.
  Efekt Stabilizacja w edytorze analizuje już z żyroskopem, gdy plik go ma i zgadza się z
  obrazem, i z ogniskową z profilu obiektywu prostoliniowego (z pliku albo z bazy
  zainstalowanej przez `hve stab lens-db --download`); profilu rybiego oka, poziomowania do
  grawitacji, dystorsji w renderze i wyboru źródła oraz obiektywu w efekcie jeszcze nie ma.
  Po aktualizacji każdy klip z efektem Stabilizacja raz analizuje się od nowa (silnik analizy
  w wersji 2).
- Jeden stan połączenia agenta: okno Agent, jego pasek i Preferencje mówią to samo, także
  gdy klient ze starym kluczem albo klient innej kopii programu puka na port. Taki klient dostaje
  wiadomość, jak połączyć się ponownie (odpowiedź 401 zaczyna się od „unauthorized: ” z radą, a
  nie jest samym „unauthorized”), serwer liczy odrzucone próby z kluczem zamiast zapisywać każdą
  do logu, a `hve mcp --connect` po zmianie klucza czyta go ponownie i działa dalej.
- Okno Agent zaczyna się od zwięzłego podsumowania: jedna linia na zmianę albo krok
  agenta, powtórzenia zliczone; połączenie, sesje, wywołania i wiadomości są pod „Szczegóły”.
- Co wyłączone, tego nie ma: bez serwera agenta znika przycisk „Zmień z agentem” i lista
  wytycznych dla agenta.
- Warstwy web z WebGL, także mapy MapLibre GL i Mapbox GL: każda klatka pokazuje stan
  ustawiony dla jej czasu (dotąd mapa sterowana z `hve.onFrame` pokazywała kamerę z poprzedniej
  klatki, a zatrzymana głowica zostawała z kadrem sprzed ruchu). Mapa czeka na swój styl i
  kafle, więc `hve.ready(map.once('load'))` nie wisi już 15 s na klatce. Eksport renderuje
  następne klatki takich warstw na wszystkich wątkach przeglądarek naraz. Przeglądarka wybiera
  wydajną kartę graficzną, a gdy WebGL rysuje procesor (SwiftShader, WARP), monitor Program
  pokazuje odznakę „WebGL bez GPU”, a `debug_web` to zgłasza.
- Parametry komponentów web w Ustawieniach efektów: podpowiedź nazwy mówi, co parametr
  robi, w jakim zakresie i jednostce i jaka jest wartość domyślna; grupy z manifestu są razem
  pod swoją nazwą i można je zwinąć strzałką, a ustawienia zaawansowane są w zwiniętej grupie
  na końcu. Agenci dostają przewodnik `hve://docs/web-components` i podpowiedzi `advice` przy
  zapisie komponentu. Stare manifesty działają bez zmian.
  Wartości warstwy spoza manifestu (ustawione przez agenta) mają teraz własne kontrolki w
  grupie „Spoza manifestu”, zamiast być tylko w JSON projektu.
- Pasek pamięci w monitorze Program: cienki pasek pod tytułem pokazuje, co z sekund
  wokół głowicy jest gotowe do odtworzenia od razu (złote w pamięci, zielone wyrenderowane,
  niebieskie wczytuje się, ciemne jeszcze nie wczytane); podpowiedź podaje, ile sekund przed
  głowicą jest gotowe.

## 0.19.24 (2026-11-08)

- Agent (poprawki API z raportów stillomatic): `clear_markers` bez `kind` czyści znaczniki
  wszystkich rodzajów jedną rewizją, `place` warstwy web przyjmuje zwykłe wartości parametrów,
  `render_frame` przyjmuje `time` zamiast `at`, nowe narzędzie `reset_web_params` przywraca
  parametrom komponentu wartości domyślne, a `preview_component` składa do 36 klatek w jedną
  stykówkę WebP z czasem i parametrami każdej klatki.
- Poprawka: komponent web, który uruchamia Web Workera, nie zawiesza już serwera stron edytora.
- Stabilizator obrazu w edytorze (D122, ST2): efekt Stabilizacja w grupie Przekształcenia. Po
  dodaniu do klipu wideo sam ustawia analizę w kolejce (klip pod głowicą i to, na co czeka
  eksport, najpierw; jedna analiza naraz, w tle, z częścią mocy karty graficznej), a monitor od
  pierwszych przeanalizowanych fragmentów pokazuje obraz już stabilizowany. Prosty widok: Rezultat
  (Gładki ruch, Kinowy, Statyw, Z ręki, Tylko rolling shutter), Gładkość, Metoda, Kadr „Przytnij i
  powiększ” do 115 % i wiersz Analiza z przyciskiem Analizuj. Zmiana szybkości, Time Remap albo
  przycięcia klipu nie wymaga nowej analizy, ścieżka liczy się od nowa w milisekundach. Obraz
  próbkowany jest raz (Lanczos 3), a klatka, której nie trzeba korygować, przechodzi do pliku bez
  zmian, co do bitu. Eksport czeka na analizę; okno eksportu mówi, ile klipów na nią czeka.
- Stabilizator obrazu, krok drugi (D122, ST1): analiza ruchu kamery z prawdziwego materiału.
  Punkty śledzone na GPU, obrót kamery z każdej pary klatek, samokalibracja ogniskowej (z
  zabezpieczeniem przed paralaksą drona i spaceru), czas odczytu rolling shuttera, cięcia,
  powtórzone klatki i ujęcia płaskie. Analiza idzie fragmentami w czasie źródła, zapisuje się w
  folderze projektu i po przerwaniu rusza od miejsca, w którym stanęła. Pomiar:
  `hve stab analyze` z czasem każdego etapu i wynikiem każdego fragmentu.
- Wtyczki VST3 i CLAP włączają się pierwszym kliknięciem: przy odtwarzaniu wyłączona
  wtyczka ma już wczytaną instancję, więc po włączeniu od razu słychać przetworzony dźwięk.
- Licencje nie przeszkadzają w pracy: sprawdzanie licencji w trakcie pracy (znacznik na
  pasku, pytania przy eksporcie, odmowy dla agenta) jest domyślnie wyłączone i włącza się w
  Preferencjach > Licencje. Raport jest zawsze na żądanie (Pomoc > Licencje i komponenty).
  Przycisk „Wpisz licencje” zapisuje w folderze projektu `licenses/` skąd pochodzi każdy plik i
  na jakiej jest licencji, a przy każdym elemencie można zaznaczyć, że wolno go pokazać
  publicznie (lista w `public.txt`).
- Okno pewniej przejmuje serwer agenta z tła: zajęty serwer jest pytany ponownie, okno
  nie otwiera drugi raz projektu, który trzyma proces w tle, próbuje znowu co 10 s, a znacznik
  „AGENT: BRAK POŁĄCZENIA” znika sam, gdy połączenie wróci. `show_editor` z tła otwiera jedno
  okno. „Zmień z agentem” pyta przed włączeniem nagrywania mikrofonu i kursora.
- Zgłoszenia błędów są domyślnie prywatne: trafiają tylko do HEXART, bez publicznego
  zgłoszenia na GitHubie, z opcją dołączenia projektu bez mediów (bez folderów, nazw bibliotek i
  nazwy projektu; „Pokaż, co zostanie wysłane” pokazuje dokładny tekst). Za duże zgłoszenie traci
  najpierw projekt, potem zrzut ekranu, i okno mówi, co pominięto. Publiczne zgłoszenie to osobny
  wybór ze zgodą. Polityka prywatności i regulamin w wersji 1.1.
- Lektor ElevenLabs domyślnie na najnowszym modelu `eleven_v4_turbo`.
- Effect Controls: kopiowanie efektów i wartości także w widoku grupy, „Wklej ze
  skalowaniem czasu kluczy” (klucze dopasowane do długości klipu docelowego, jak Paste Attributes w
  Premiere), Ctrl+V w panelu wkleja efekty klipu skopiowanego na osi, a agent ma narzędzia
  `copy_effects` i `paste_effects` (wklejanie jedną rewizją, ten sam schowek co panel).
- Oś czasu: Shift+klik na cięciu innej ścieżki dodaje punkt edycji (HVE i Premier), każdy
  punkt ma swój znak, a Trim Backward i Forward przesuwają wszystkie naraz jedną rewizją.
- Asysta zrzutu wszędzie: edycje źródła wszystkich layoutów (Leonardo, Mozart, Cupertino,
  Edison, LasVegas) nie nadpisują już dźwięku pod spodem, dźwięk idzie na wolną albo nową
  ścieżkę; narzędzia MCP `place_clip`, `insert_clip` i `overwrite_clip` mają opcję `assist`, a
  wynik podaje ścieżki.
- Zaznaczanie do przodu i do tyłu w każdym layoutcie: Edycja, Zaznacz klipy do przodu i do
  tyłu, na wszystkich ścieżkach albo na tej ścieżce, od głowicy; w LasVegas „Zaznacz zdarzenia do
  końca”, w Mozart Select Right i Select Left.
- Ripple zablokowany przez muzykę z blokadą synchronizacji: komunikat mówi, która ścieżka
  blokuje, a przycisk obok zamyka lukę bez niej jedną rewizją.
- Menu Okno: Resetuj układ (panele z osobnych okien wracają) i najczęstsze panele na górze,
  z Ustawieniami efektów, w każdym layoutcie.
- Zakładki osi wracają po ponownym otwarciu projektu, każda raz.
- Nadpisanie zastępuje klip w całości (D121, TA9): edycja źródła albo zrzut z asystą nad klipem z
  obrazem i dźwiękiem zdejmuje w nadpisanym zakresie także jego własny dźwięk (częściowe nakrycie
  tnie go na krawędzi), a nowy dźwięk ląduje na jego miejscu. Muzyka, lektor i efekty pod spodem
  zostają nietknięte.
- Katalog wtyczek: wtyczka wstawiona innym instalatorem do folderów użytkownika jest
  pokazana jako znaleziona, bez instalacji; znaleziona w innym folderze ma przycisk „Zainstaluj drugą
  kopię” z ostrzeżeniem.
- Poprawki: wtyczki VST3 kompilują się na Linuksie, losowo padający test zaproszeń w pracy
  zespołowej naprawiony.
- Stabilizator obrazu, krok pierwszy (D122, ST0): nowy moduł obliczeń stabilizacji. Zapisuje
  analizę ruchu kamery w folderze projektu (pliki fragmentów sprawdzane sumą kontrolną, zapis bez
  ryzyka uszkodzenia), wygładza ścieżkę kamery w milisekundach (Gładki ruch, Kinowy, Statyw, Z ręki,
  horyzont, kadr z automatycznym powiększeniem do 115 %) i liczy siatkę warpu z błędem poniżej
  1/64 piksela. Pomiar: `hve stab bench`. Efektu w edytorze jeszcze nie ma.
- Studio: ruch tłumika, panoramy i gałek wtyczek w trybie zapisu automatyki słychać od
  razu, a nie dopiero po zatrzymaniu; gałki wtyczek z okna edytora wtyczki zapisują się w tym
  samym przebiegu. Komping zakresu ujęcia nie tnie już klipu: klip zostaje w całości, gra
  odcinki wybranych ujęć z krótkim przenikaniem, a połączony obraz się nie zmienia. Ocena ujęć
  jest polem ujęcia (stare projekty przenoszą ją same przy otwarciu). Pętla ADR i Foley wraca do
  pre-rollu, więc beepy i streamer są w każdym okrążeniu; streamer może być też na monitorze
  Source. Listę cue ADR i Foley można zapisać do CSV i PDF (z polskimi literami) i wczytać z CSV
  (przecinek albo średnik, także zapis polskiego Excela, kolumny po polsku albo angielsku, bez
  dubli). Nowe: Scrubber (F9,
  przeciągnięcie po ścieżkach przewija dźwięk), Consolidate (Alt+Shift+3, klipy w zakresie w
  jeden plik) i Tab to Transient (Ctrl+Alt+T, Tab skacze po uderzeniach w dźwięku).
- Eksport 4K szybciej: ujęcie 4K HEVC z drona albo aparatu dekoduje się w eksporcie
  dwoma procesami naraz, a płaszczyzny obrazu przychodzą z karty graficznej bez przeliczania,
  więc etap źródła jest krótszy (pomiar w D119). Obraz w pliku jest identyczny jak dotąd, co do
  bitu.
- Eksport przy pełnej maszynie nie przełącza już po 20 s dekodera na procesor, gdy dekoder
  karty graficznej jest wolny, ale wciąż dostarcza klatki: czeka na niego dalej (do 5 minut
  ponad limit). Zawieszony dekoder jest wymieniany jak dotąd.
- Procesy FFmpeg (dekodery, enkodery, proxy) kończą się zawsze razem z edytorem albo komendą
  `hve`, także po awarii albo zamknięciu z Menedżera zadań. Skrypt, który czytał wyjście
  `hve play`, nie czeka już na dekodery, które przeżyły komendę.
- Maski z długą ścieżką (gwiazdy, kształty z tysiącami punktów) renderują się kilka razy
  szybciej: na klatce 4K gwiazda z 2016 punktami ścieżki kosztuje około 21 ms zamiast
  103 ms. Obraz jest identyczny jak dotąd, bajt w bajt.
- Panel Kolor nie zatrzymuje już edytora przy dopasowaniu koloru: kadr wzorcowy i
  klatka dopasowania dekodują się w tle, a przycisk czeka z kółkiem postępu.
- Test enkoderów sprzętowych (NVENC, QSV, AMF) rusza w tle kilka sekund po starcie programu, więc okno eksportu i pierwszy eksport nie czekają na niego, także przy zajętym GPU.
- Kolejka renderu: kopia dla WhatsApp z materiału HDR (PQ, HLG) ma mapowanie tonów do
  SDR i nie wygląda już blado; przy wysyłce WhatsApp z paska można dopisać podpis, widoczny w
  oknie zgody; eksporty agenta, które proces w tle kończy po otwarciu okna, pojawiają się w
  kolejce jako paski z postępem i oznaczeniem „W tle”.
- Pixel Motion z RIFE: kopia modelu w połowie precyzji (fp16) powstaje na tym komputerze
  przy instalacji modelu albo przy pierwszym włączeniu fp16 w Preferencjach. Do Full HD liczy
  około trzy razy szybciej niż fp32, przy 4K wolniej, więc domyślnie zostaje fp32. Preferencje
  ostrzegają, gdy najdłuższy bok klatki 3840 px i więcej wydłuży eksport zwolnionego tempa.
- Pixel Motion przy odtwarzaniu według terminów: klatki pośrednie liczą się w kolejności,
  w jakiej monitor je pokaże, od głowicy w kierunku i z prędkością odtwarzania (także w pętli In
  do Out). Klatka, której silnik nie zdąży zrobić na czas, wypada z kolejki i zamiast niej gra
  Frame Mix, więc silnik nie traci czasu na klatki spóźnione i robi te, które jeszcze zdąży.
  Render w bezczynności Pixel Motion idzie od głowicy w kierunku ostatniego odtwarzania.
- Render w tle po bezczynności (D118, Preferencje > Render podglądu, domyślnie wyłączony): gdy
  przez chwilę nic nie robisz, edytor sam renderuje podgląd od In do Out (bez nich okolice
  głowicy), z limitem GPU w procentach czasu. Klawisz, kliknięcie, odtwarzanie, eksport albo
  edycja go zatrzymuje; postęp i zajęcie GPU widać na liście pracy w tle w pasku stanu.
- Render Source od In do Out (D118, menu Sekwencja, albo Render In do Out przy monitorze Source
  w fokusie): zdekodowane klatki klipu między znacznikami trafiają do pamięci renderu i monitor
  Source gra je stamtąd (odznaka WYRENDEROWANE), bez dekodera.
- Monitor Source odtwarza z przewidywaniem klatek jak Program: klatki najbliższych sekund
  dekodują się według terminów, także wstecz i w pętli między znacznikami.

## 0.19.23 (2026-11-07)

- Nowy efekt ASCII (D112, Stylizacja): obraz rysowany znakami dowolnej czcionki zainstalowanej
  w systemie, pobranej z Google Fonts albo leżącej w folderze `fonts` projektu (najlepiej o stałej
  szerokości; brakująca czcionka zastępowana wbudowaną Hack z ostrzeżeniem). Czcionka dodana do
  folderu `fonts` w trakcie pracy pojawia się sama, a plik czcionki wybrany z dysku jest kopiowany
  do tego folderu, więc projekt działa też na innym komputerze. 60 parametrów:
  wielkość i proporcje komórek albo liczba kolumn, odstępy, skala glifu, obrót i przesunięcie
  siatki, 15 zestawów znaków i własny, wybór znaku po jasności, po krawędziach i ich kierunku
  albo po obu, dithering, jasność, kontrast i gamma przed mapowaniem, kolor jeden, ze źródła, z
  gradientu, z palety (ANSI, CGA, Game Boy, C64, PICO-8 i inne) albo kwantyzowany, tło, oryginał
  pod znakami, tryby mieszania, grubość i kontur znaków, stabilność w czasie oraz animacje deszczu
  i mieszania znaków z ziarnem. 34 gotowe presety, od zielonego terminala i deszczu Matrix po
  gazetę, Game Boya i mozaikę. Działa w czasie rzeczywistym na GPU, eksport jest taki sam jak
  podgląd; agent widzi efekt i presety przez MCP.
- Okna ustawień wbudowanych efektów audio: każdy wbudowany efekt audio otwiera się w
  osobnym oknie, przyciskiem w nagłówku efektu w Effect Controls, podwójnym kliknięciem slotu
  w mikserze (ścieżka i master) albo z menu slotu. Okno ma wykres na żywo dla swojego efektu:
  krzywą EQ na widmie przed i po z pasmami do przeciągania i solo pasma, krzywą przenoszenia
  kompresorów, limiterów i bramek z GR i jego historią, zanik pogłosu, echa opóźnienia, LFO,
  profil szumu z przyciskiem „Przechwyć profil”, krzywą przesteru i saturacji, głośność i
  szczyt rzeczywisty masteringu, goniometr. Każdą wartość można wpisać z jednostką, Shift
  zmienia dokładnie, podwójne kliknięcie przywraca domyślną, a cały gest cofa jedno Ctrl+Z.
  Do tego A/B, bypass bez trzasku, wejście, miks i wyjście oraz odsłuch side chain, pasma i
  tego, co efekt zabiera.
- Presety efektów audio: 499 presetów fabrycznych (od 8 do 15 na efekt) w kategoriach
  dialog, lektor, podcast, muzyka, emisja, Foley, ADR, czyszczenie, mastering i sound design,
  w przeglądarce z wyszukiwaniem, kategoriami i ulubionymi. Własne presety: zapis, zmiana
  nazwy, nadpisanie, usuwanie, import i eksport; agent ma je też przez MCP
  (`list_effect_presets`, `save_effect_preset`, `delete_effect_preset`, `user:<nazwa>` w
  `apply_effect_preset`). Preset nie kasuje przechwyconego profilu szumu odszumiania, a
  „Zapisz jako” go nie zabiera. Gdy pliku własnych presetów nie da się odczytać, HVE go nie
  nadpisuje i mówi, że zapis się nie udał.
- Nowe efekty audio: ekspander, kształtowanie transjentów, ducker, de-plosive, leveler
  głośności (cel w LUFS), declipper, tremolo i auto-pan, pitch shifter, filtr DC, utility
  (biegunowość, M/S, szerokość, mono, panorama), saturacja i de-reverb.
- Poprawki efektów audio: bez trzasków przy zmianach parametrów i przełączaniu
  (nachylenie filtrów, typy pasm, sekcje, bypass), włączony ponownie delay ani pogłos nie
  odtwarza starych próbek, pogłos surround nie przycina odtwarzania i ma poprawne mapy
  kanałów, chorus, flanger i phaser brzmią w podglądzie od środka klipu tak jak w eksporcie,
  odszumianie pamięta przechwycony profil po przewinięciu, declicker działa tak samo przy
  44,1, 48 i 96 kHz, głośność kanałów zna układy quad, 5.0 i 6.1. Ustawienia domyślne brzmią
  dokładnie jak wcześniej na ścieżkach mono i stereo. Inaczej mogą zabrzmieć stare projekty,
  w których jest: pasmo cięcia PEQ z Q powyżej 1,93 (teraz najwyżej 1,93, rezonans do +6 dB),
  własny plik IR w innej częstotliwości próbkowania albo dłuższy niż 10 s (przepróbkowanie
  filtrem sinc zamiast liniowego, 50 ms wyciszenia przy cięciu), declicker przy 44,1 albo
  96 kHz (okna według częstotliwości), głośność kanałów albo pogłos surround w układach quad,
  5.0 i 6.1 (poprawne mapy kanałów), chorus, flanger i phaser na ścieżce z kanałem LFE (LFE
  już nie jest modulowany) oraz odtwarzanie tych trzech efektów od środka klipu (faza LFO z
  czasu elementu, jak w eksporcie).
- Kontrolki wyrażeń: efekt Kontrolki wyrażeń ma teraz osiemnaście typów kontrolek z
  własnymi nazwami: suwak (z zakresem i jednostką), procent, liczba całkowita, kąt pokazany
  jak w After Effects jako obroty i stopnie (`2x +45°`), orientacja 3D, pole wyboru, kolor z
  pipetą z monitora Program, punkt z uchwytem na monitorze, punkt 3D, wektor 2D i 3D, lista
  rozwijana z nazwanymi pozycjami, warstwa (wybór klipu), zakres, czas, tekst, ziarno
  losowania z przyciskiem nowego ziarna i krzywa. Kontrolkę dodajesz przyciskiem „+ Kontrolka”
  pod efektem albo z menu efektów (Kontrolki wyrażeń, potem typ); menu kontekstowe wiersza
  otwiera ustawienia (nazwa, typ, granice, zakres suwaka, krok, jednostka, pozycje listy,
  podpowiedź), powiela, przesuwa i usuwa kontrolkę, a każda zmiana to jeden krok cofania.
  Wyrażenia czytają kontrolki po nazwie: `ctrl("Prędkość") * time`, `ctrl("Obrót").revolutions`,
  `ctrl("Tryb").item`, `ctrl("Cel").value.position`, `ctrl("Okno").lerp(0.5)`,
  `ctrl("Krzywa").at(time / 4)`, a zapis z After Effects `effect("Speed")("Slider")` też
  działa. Kopiowanie i wklejanie wartości kontrolki na inny klip tworzy tam brakującą
  kontrolkę. Starsze projekty z pięcioma dawnymi kontrolkami otwierają się bez zmian. Agenci
  dostali narzędzia MCP `list_controls`, `set_control` i `remove_control`.
- Wtyczki VST: nowe okno z katalogiem vst.hexart.io (ponad 1100 opisanych wtyczek, z
  recenzjami, licencjami i linkami), z wyszukiwarką i filtrami, także bez sieci. Darmowe
  wtyczki VST3 i CLAP HVE instaluje jednym kliknięciem po potwierdzeniu: pobiera plik prosto
  od producenta, sprawdza SHA-256 i kopiuje do folderów użytkownika, bez uprawnień
  administratora; potem są od razu w przeglądarce efektów. Aktualizacja i odinstalowanie w tym
  samym oknie. Płatne i z kontem otwierają stronę producenta. Agent przez MCP szuka w katalogu
  i prosi o instalację, która zawsze czeka na Twoją zgodę.
- Kolor źródła bez zmian: pliki dronów DJI i telefonów, które w materiale HD zapisują
  stary tag transferu z czasów SD (`bt470m`), HVE czyta jak BT.709, tak jak Premiere i
  Resolve, więc render takich ujęć ma dokładnie kolor źródła i może iść prosto do enkodera.
  Zmiana widoczna w starych projektach: render tych plików (do tej pory przeliczany z gammy
  2,2, jaśniejszy w cieniach) zmienia się na zgodny ze źródłem. Dawne odczytanie zostaje w
  menu materiału w panelu Projekt: Interpretacja koloru, Tagi jak zapisane (do wyboru także
  Rec.709 wymuszone i krzywe log, PQ, HLG; w MCP `update_media` z `color`, pisownia
  dowolna, np. „BT.709” albo „S-Log3”). Wybrane ręcznie PQ i HLG działają jak tagi HDR:
  plakietka HDR i podgląd SDR.
- Ujęcie narysowane 1:1 (bez skali, obrotu i efektów) wychodzi z renderu z próbkami źródła
  także wtedy, gdy klatka idzie przez kartę graficzną (tytuł nad ujęciem, przejście, inna
  głębia albo podpróbkowanie pliku wyjściowego): karta sama przelicza płaszczyzny Y'CbCr
  źródła, bez przycinania kolorów spoza RGB. Różnica wobec źródła spada z do 50 wartości kodu
  w ponad jednej trzeciej próbek do najwyżej 1 przy tej samej głębi i podpróbkowaniu (0 poza
  tytułem i w H.264). Materiał 4:4:4 tak samo, do każdego wyjścia: do 4:4:4 z do 54 wartości
  w 24 % próbek na najwyżej 1, do 4:2:0 i 4:2:2 tak samo luminancja. Takie ujęcie 4K
  renderuje się też o około 20 % szybciej, bo dekoder nie przelicza go na RGB. Bez zmian
  zostają: ujęcie 4:2:0 albo 4:2:2 w eksporcie z drobniejszą chrominancją (4:4:4, RGB), które
  bierze chrominancję interpolowaną jak dotąd, i ujęcie przesunięte o nieparzystą liczbę
  pikseli w poziomie (przy 4:2:0 także wierszy), które idzie dawną drogą.
- Warstwa położona 1:1 w całych pikselach (ujęcie, tytuł, plansza) kopiuje się piksel w
  piksel zamiast przez filtr, w podglądzie i w każdym eksporcie. Dawny filtr wpuszczał w górny
  wiersz i lewą kolumnę klatki ślad tła, a przy ostrych krawędziach odrobinę sąsiednich
  pikseli. Zmienia się od 0,014 do 0,038 % próbek, w 95 do 99 % z nich o 1 wartość kodu,
  najwyżej o 10 (eksport 4:4:4 10-bit), a średni błąd wobec źródła w tych pikselach spada z
  0,95 do 0,34 wartości kodu.

## 0.19.22 (2026-11-07)

- Zrzut klipu z obrazem i dźwiękiem na oś: część pod kursorem trafia na wskazaną
  ścieżkę, druga na ścieżkę obok, która jest wolna (sparowaną, najbliższą wolną albo nową),
  więc niczego nie nadpisuje. Nowa ścieżka pokazuje się w trakcie przeciągania jako zarys pod
  ścieżkami, dochodzi po puszczeniu, a całość cofa jedno Ctrl+Z. Tak samo przy przyciskach
  Wstaw i Nadpisz monitora Source. Wstawienie z Ctrl nie rozsynchronizowuje już obrazu z
  dźwiękiem.
- Delete i Backspace przy zaznaczonej jednej części zlinkowanego klipu (Alt+klik) usuwają tylko
  ją, we wszystkich layoutach. Ctrl+C i Ctrl+X biorą tak samo tylko ją, więc wklejenie nie
  dubluje części, która została.
- Klik na końcówce klipu zaznacza punkt edycji z jego stroną każdym narzędziem do trymowania i w
  każdym layoutzie, także wolny koniec klipu; Roll zaznacza obie strony.
- Dwuklik na klip na osi otwiera go w Source każdym narzędziem i w każdym layoutzie.
- Start bez mrugania: okno edytora pojawia się raz, od razu w zapisanym miejscu i
  rozmiarze, z ciemnym paskiem tytułu. Nie ma już białego okna w rogu ekranu ani skoku przy
  maksymalizacji, a okna wypięte pokazują się dopiero na swoim miejscu.
- Ekran startowy: znak programu z animacją, numer wersji i postęp startu (grafika,
  ustawienia, usługi, układ, serwer agenta, projekt) na monitorze, na którym otworzy się
  okno. Gaśnie nad gotowym edytorem. Wyłączysz go w Preferencjach > Ogólne > Ekran startowy.
- Gdy okno edytora nie może się otworzyć (na przykład bez sterownika grafiki), program mówi to
  w oknie komunikatu z błędem i folderem dziennika, zamiast zamknąć się bez słowa.
- Kolejka renderu od nowa: każdy render to pasek, a oczekujące przeciągasz za uchwyt
  w kolejności, w jakiej mają się renderować (renderują się po kolei). W pasku widać klatkę,
  którą FFmpeg właśnie koduje, nazwę pliku (pełna ścieżka w podpowiedzi, klik pokazuje plik w
  folderze), procent z dwoma miejscami po przecinku, timecode i czas do końca.
  Transfer jednym przyciskiem: w trakcie renderu pole „Transfer po renderze”, potem przycisk,
  a po wysłaniu „Link”, który kopiuje link do schowka, aż link wygaśnie. WhatsApp tak samo, z
  wyborem odbiorców i jedną zgodą przed wysłaniem, gdy działa whatsapp-scrap; plik większy niż
  16 MB HVE najpierw zmniejsza w tle do kopii tymczasowej. Kolejka zapisuje się w projekcie i
  wraca po restarcie (przerwany render z przyciskiem „Renderuj ponownie”).

## 0.19.21 (2026-11-06)

- Efekt NTSC i VHS (`hve.ntsc`, D106): port zhuker/ntsc na GPU, prawdziwa deformacja sygnału
  (kodowanie i dekodowanie kompozytowe, dzwonienie, szum, filtry taśmy VHS), nie nakładka.
  Najlepiej na warstwie korekcyjnej nad całym montażem. Presety `broadcast`, `vhs` i `vhs_lp`,
  szum losowany z ziarna i numeru klatki, więc podgląd i eksport wyglądają tak samo.
- Szybszy eksport bez zmiany ani jednej próbki: klip bez efektów, który ma już układ
  pikseli pliku wyjściowego (to samo podpróbkowanie, ta sama głębia, macierz i zakres, ten sam
  rozmiar), idzie z dekodera prosto do enkodera w Y'CbCr, więc render jest identyczny ze
  źródłem co do bitu (wcześniej przechodził przez RGB i z powrotem). Warstwy całkiem zakryte
  nieprzezroczystym klipem, który wystaje poza kadr, nie są w eksporcie dekodowane ani
  liczone (wynik ten sam co do bitu, a projekt z czterema ścieżkami 4K renderuje się kilka do
  kilkunastu razy szybciej). Wideo 10-bit idzie z dekodera do karty graficznej w połowie
  bajtów, kopie do i z GPU są równoległe, a potok do enkodera ma większy bufor. Wszystko to
  sprawdza porównanie klatek przed enkoderem ze starą drogą i ze źródłem (różnica 0).
  `hve render --stages` pokazuje czasy etapów, `--spec` przyjmuje dowolne ustawienia eksportu.
- Przejścia: przejście widać na całej wysokości klipu, z narysowaną krzywą.
  Przeciąganie w górę i w dół pod paskiem przejścia zmienia krzywą (w górę szybciej na
  początku, w dół wolniej), dla obrazu i dźwięku, w podglądzie i w eksporcie; wartość jest też
  w Effect Controls i w MCP (`bend`). Shift przy przeciąganiu krawędzi przejścia przenosi ruch
  na drugą krawędź od chwili wciśnięcia, a puszczony zostawia ją tam, gdzie doszła.
- Podgląd trymowania: przy trymowaniu, ripple, roll, slip, slide i krawędziach przejść
  Program pokazuje klatkę w punkcie przeciąganego uchwytu, przy roll, slip, slide i
  przejściach dwa obrazy obok siebie. Po puszczeniu wraca do głowicy. Oba przełączniki są w
  menu Widok.

## 0.19.19 (2026-11-05)

- Odtwarzanie z przewidywaniem klatek: Program liczy z wyprzedzeniem, które klatki
  źródła pokaże w najbliższych sekundach (Time Remap, rewers, nesty, interpolacja, J/K/L i
  shuttle do 50x) i dekoduje je według GOP, kilkoma dekoderami naraz (także na drugiej
  karcie graficznej), każdą na swój czas.
  Obraz idzie za dźwiękiem: spóźniona klatka nie zatrzymuje go na długo, a szybki shuttle
  pokazuje klatki kluczowe. `hve play --rate` mierzy dowolną prędkość, `--legacy` starą drogę.

## 0.19.18 (2026-11-05)

- Layouty pracy: oprócz dotychczasowego układu wybierasz w Preferencjach (i przełączasz w
  locie) układ z klawiszami, gestami i panelami znanymi z innych programów: Premier (Premiere
  Pro), Leonardo (strona Edit w DaVinci Resolve, ze stronami Media i Edit), LasVegas (VEGAS
  Pro), Edison (EDIUS), Mozart (Media Composer), Cupertino (Final Cut Pro) i Studio (Pro
  Tools). Każdy layout ma własną mapę klawiszy do edycji w edytorze skrótów, własne narzędzia
  i przestrzenie robocze, a projekt zostaje ten sam: zmiana layoutu nie zmienia osi czasu.
- Zmienne wtapianie maski jak w After Effects: narzędzie Wtapianie maski pod G na
  monitorze Program dodaje punkt kliknięciem w ścieżkę i od razu ustawia jego promień na
  zewnątrz albo do środka (jeden krok cofania), Shift trzyma punkt w miejscu, Alt i
  przeciągnięcie w bok zmienia napięcie, Ctrl i klik albo Delete usuwa punkt. Granica
  wtapiania jest przerywaną linią, przy przeciąganym punkcie widać promień. Punkt na
  środku prostego boku działa teraz dokładnie tam, granice wewnętrzna i zewnętrzna
  przechodzą płynnie przez ścieżkę, punkt przeciągnięty na ścieżkę ściąga do niej
  wtapianie (punkt o promieniu 0 z kliknięcia bez przeciągania nadal nic nie zmienia, więc
  starsze projekty wyglądają tak samo), Hold, kąt narożnika i takie ściągnięcie wychodzą
  w renderze ostro, a nowe i usuwane punkty trafiają do wszystkich klatek ścieżki, także
  o innej liczbie wierzchołków, w tym samym miejscu na ścieżce. Effect Controls pokazuje liczbę
  punktów z resetem, MCP `add_mask` i `set_mask` przyjmują `feather_points`. W layoutach,
  w których G, Q albo V znaczą coś innego (Mozart, Edison, LasVegas, Studio, Leonardo,
  Cupertino), litera zostaje przy layoucie, dopóki nie wybierzesz narzędzia maski.
- Shuttle monitorów: szare etykiety na końcach paska pokazują zakres (−8.00× i +8.00×), a rolka
  nad paskiem zmienia go co 0.1× (z Shift co 1×) od 1.00× do 50.00×. Kreski idą za zakresem.
  Rolka działa także w trakcie trzymania gałki, gdziekolwiek jest kursor, a prędkość od razu
  idzie za gałką w nowym zakresie. Zakres zostaje w preferencjach użytkownika, nie w projekcie,
  i jest ten sam we wszystkich layoutach. Na wąskim monitorze etykiety się skracają albo
  chowają, pełny zakres jest w podpowiedzi. Ctrl z rolką dalej powiększa. Powyżej 20× obraz
  idzie w pełnej prędkości, a dźwięk taśmy płynnie cichnie i wraca poniżej 20×. J i L nie
  zwalniają już szybszego przewijania z paska.
- Effect Controls: widoczny nagłówek kolumn Właściwość i Wartość z dzielnikiem, który
  się przeciąga, a wartości wszystkich wierszy (liczby, pary X i Y, kolory, listy, pola wyboru,
  kąty, tekst) zaczynają się na dzielniku z jednostką zaraz za liczbą. Efekty, grupy parametrów
  i wartości zaznacza się kliknięciem, Ctrl, Shift albo prostokątem, kopiuje Ctrl+C, wkleja
  Ctrl+V (także na kilka zaznaczonych klipów naraz, z kluczami w tym samym czasie od początku
  klipu) i usuwa Delete, także z menu kontekstowego.
- Podgląd szybciej: przełącznik „Bez interpolacji klatek w podglądzie” w pasku Programu i
  w menu Widok. Program, przewijanie i odtwarzanie pokazują wtedy klatkę źródła bez mieszania
  i Pixel Motion, a eksport i klatki dla agentów zostają jak w projekcie. Na Programie widać
  odznakę.
- Render podglądu In do Out (menu Sekwencja; Premier `Enter`, Cupertino, Leonardo i Mozart
  `Ctrl+Alt+R`, LasVegas `Shift+M`, Edison `Alt+Shift+Q`, Studio `Alt+Shift+R`): klatki
  zakresu liczą się w tle jak w eksporcie i potem grają płynnie, także z Pixel Motion i Time
  Remap. Pasek renderu na osi pokazuje je na zielono, a pamięć ma limit RAM i dysku, wiek i
  przycisk Wyczyść w Preferencjach.
- Praca w tle w pasku stanu: wskaźnik z listą zadań, postępem, anulowaniem i licznikami Pixel
  Motion.
- Materiał 10-bitowy SDR (DJI, iPhone HEVC) bez efektów koloru dekoduje się przy odtwarzaniu
  lżej; ze scopes, podziałem przed i po, LUT albo korekcją koloru zostaje pełna głębia, eksport
  bez zmian.
- Eksport nie zapisuje już czarnej klatki, gdy dekoder nie zdąży: klatka, która się spóźnia,
  dostaje nowy dekoder na procesorze i więcej czasu, a jeśli i tak nie przyjdzie, eksport staje
  z komunikatem, który plik i która klatka zawiodły. Tak samo warstwa web, która się nie
  renderuje, i media offline. Eksport 4K HEVC 10-bit nie dekoduje już dalej, niż mieści
  pamięć klatek (wcześniej przepychał potrzebne klatki z pamięci i szukał ich od nowa), a
  klatki robione przez Pixel Motion nie są dekodowane drugi raz w rozmiarze warstwy. Na czas
  eksportu prerender Pixel Motion w edytorze czeka, żeby nie zabierał GPU eksportowi.
  Eksport ma własne dekodery, których podgląd nie zabiera, a po eksporcie się zamykają;
  anulowanie działa od razu także wtedy, gdy eksport czeka na spóźnioną klatkę.
- Layout Studio dla pracy jak w Pro Tools: tryby edycji Shuffle, Slip, Spot i Grid (F1 do F4),
  narzędzia Grabber, Trim, Selector i Pencil, nudge, presety zoomu i Commands Focus. Ścieżka
  audio pokazuje klipy, pas automatyki głośności albo panoramy lub pasy ujęć, w których
  kliknięcie gra ujęcie, a przeciągnięcie kompuje fragment. Tryby automatyki Touch, Latch,
  Write i Trim zapisują ruch tłumika jako jeden krok cofania. Mikser dostał w Studio wysyłki,
  VCA, panner obiektu i odsłuch binauralny. Nowe panele ADR (cue ze znaczników, trzy beepy,
  streamer na obrazie, nagrywanie cue w pętli z ocenianymi ujęciami) i Foley (arkusz cue,
  ścieżki na kategorie, nagrywanie przebiegów).
- Dwuklik na sekwencji w panelu Projekt otwiera jej oś czasu we wszystkich layoutach: zakładka,
  która ją pokazuje, wychodzi na wierzch (także z innego okna), a gdy jej nie ma, nowa staje
  obok pozostałych zakładek osi czasu. Dwuklik na neście otwiera go tak samo w zakładce osi
  czasu, Alt+dwuklik wchodzi w niego w miejscu jak dotąd. Dwuklik w środek klipu otwiera go
  także wtedy, gdy trafia w linię krycia albo przychodzi zaraz po kliknięciu, które klip
  zaznaczyło.
- Wymiana z programami audio: import i eksport AAF dla Pro Tools (klipy z zapasem, gain
  klipu, zanikania i przenikania, automatyka głośności i panoramy ścieżek, markery), projektów
  REAPER `.rpp` (ścieżki, elementy, zanikania, obwiednie głośności i panoramy, markery i
  regiony, tempo i metrum, elementy MIDI) oraz plików MIDI `.mid` jako sekwencji ze ścieżkami
  MIDI i mapą tempa. Każdy import cofa jedno Ctrl+Z.
- Czas muzyczny na osi: przełącznik Takty zamienia linijkę na takty i miary, pokazuje pas
  tempa z punktami, rampami i zmianami metrum oraz siatkę, do której przyciągają gesty (takty,
  miary, podziały do 1/32 i triole). Każda zmiana tempa to jedno Ctrl+Z. Ścieżka audio może
  podążać za tempem i zachować wysokość dźwięku: klipy rozciąga Signalsmith Stretch, a eksport
  brzmi tak samo jak odtwarzanie. Klip MIDI albo audio można powtórzyć jako pattern na taktach.
- Nagrywanie wielościeżkowe: nowy panel Nagrywanie. Uzbrajasz dowolnie wiele ścieżek audio,
  każdą z jej wejściem (kanał albo para) z jednego lub kilku urządzeń WASAPI, i nagrywasz je
  naraz. Punch-in i punch-out między punktami In i Out z rozbiegiem, nagrywanie w pętli, w
  którym każde okrążenie jest ujęciem tego samego klipu do przełączania w panelu, odsłuch
  wejścia przez mikser ścieżki z jej efektami. Nagranie trafia na próbkę, na której zostało
  zagrane: opóźnienia mierzone przez sterownik, deklarowane i ręczne przesunięcie w
  Preferencjach. Cały przebieg to jedno Ctrl+Z. ASIO czeka na umowę licencyjną ze Steinbergiem.
- MIDI: ścieżki MIDI grają przez instrumenty VST3 i CLAP co do próbki, a eksport brzmi tak
  samo jak odtwarzanie. Nowy panel Edytor MIDI z piano roll (rysowanie, przesuwanie, długość,
  dynamika, kwantyzacja z siłą i swingiem) i edytorem krokowym perkusji; każdy gest to jedno
  Ctrl+Z. Pliki MIDI (format 0 i 1) z mapą tempa, wejścia urządzeń MIDI i wejście sidechain
  dla wtyczek.
- Miks obiektowy: ścieżka audio może być obiektem z pozycją w pokoju albo azymutem, elewacją
  i odległością, z automatyką. Mikser renderuje obiekty metodą ITU-R BS.2127 do stereo, 5.1,
  7.1, 7.1.2, 7.1.4 i 9.1.6, a odtwarzanie brzmi tak samo jak eksport.
- Odsłuch słuchawkowy: szersza sekwencja może grać binauralnie na wyjściu stereo (model głowy,
  bez zewnętrznych danych HRTF).
- ADM BWF: zapis i odczyt plików BW64 z metadanymi ADM (bed i obiekty z ruchem), formatu,
  który przyjmuje Dolby Atmos Renderer, Pro Tools i Resolve Fairlight. Import rozpoznaje
  kanały bedu po głośnikach, więc bed w kolejności BS.2051 i na dowolnych torach trafia na
  właściwe kanały. Na razie z poziomu biblioteki, polecenia w menu przyjdą osobno.
- Głośność do emisji: presety ATSC A/85 (-24 LKFS, -2 dBTP) i Netflix (-27 LKFS mierzone na
  samym dialogu, -2 dBTP) obok EBU R128 i platform. Pomiar w mikserze pokazuje głośność
  dialogu i jego udział w programie oraz werdykt, czy mix spełnia wybraną normę. Dialog
  wykrywa lokalny detektor mowy, więc wynik jest zgodny z metodą, nie certyfikowany.
- Mikser gra wysyłki do szyn aux (przed i za tłumikiem, z poziomem i panoramą w automatyce),
  tłumiki VCA i sidechain: kompresor na muzyce może ściszać ją pod dialogiem. Każda gałąź
  trzyma opóźnienie wtyczek co do próbki, a odtwarzanie brzmi tak samo jak eksport.
- Automatyka tłumika w trybach Touch, Latch, Write i Trim: cały przejazd to jedna zmiana w
  historii, którą cofa jedno Ctrl+Z.
- Bounce ścieżki do pliku WAV i zamrażanie ścieżki: zamrożona ścieżka gra z pliku, póki się nie
  zmieni.
- Szyny do 16 kanałów: 7.1.2, 7.1.4 i 9.1.6 grają pełne, z downmixem do 7.1, 5.1 i stereo.

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
