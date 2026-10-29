# Zmiany

Notatki o wersjach są po polsku. / Release notes are written in Polish.

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
