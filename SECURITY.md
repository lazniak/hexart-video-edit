# Bezpieczeństwo / Security

## Polski

Znalazłeś lukę w HEXART Video Edit? Nie zakładaj publicznego issue.

Zgłoś ją prywatnie: zakładka **Security** tego repozytorium, przycisk **Report a vulnerability** (prywatne zgłoszenie widzi tylko HEXART). Opisz, co się dzieje, jak to odtworzyć, jakiej wersji dotyczy (`hve.exe --version`) i jaki widzisz skutek. Nie dołączaj cudzych danych ani haseł.

Co robimy: potwierdzamy odbiór w ciągu 7 dni, sprawdzamy zgłoszenie i podajemy termin poprawki. Poprawkę publikujemy w nowym wydaniu i w [CHANGELOG.md](CHANGELOG.md), z podziękowaniem, jeśli chcesz być wymieniony.

Wspierana jest najnowsza wersja z [Releases](https://github.com/lazniak/hexart-video-edit/releases/latest).

Co leży po stronie programu: serwer MCP słucha tylko na 127.0.0.1 i wymaga tokenu. Jeśli widzisz sposób obejścia tego z innego komputera albo z innego procesu bez tokenu, to dokładnie taki błąd chcemy dostać.

## English

Found a vulnerability in HEXART Video Edit? Please do not open a public issue.

Report it privately: the **Security** tab of this repository, **Report a vulnerability** (a private report is visible to HEXART only). Describe what happens, how to reproduce it, which version it affects (`hve.exe --version`) and the impact. Do not attach other people's data or passwords.

What we do: we acknowledge within 7 days, look into it and give a date for the fix. The fix ships in a new release and in [CHANGELOG.md](CHANGELOG.md), with credit if you want to be named.

The latest version from [Releases](https://github.com/lazniak/hexart-video-edit/releases/latest) is the supported one.

On the program side: the MCP server listens on 127.0.0.1 only and requires a token. If you find a way around that from another machine or from a process without the token, that is exactly the bug we want to hear about.
