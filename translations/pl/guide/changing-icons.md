# Zmiana ikon

## Korzystanie z interfejsu graficznego

### Wyszukiwanie online

1. Wybierz aplikację z paska bocznego.
2. Przeglądaj ikony z [macOSicons.com](https://macosicons.com/) w głównym obszarze.
3. Użyj listy rozwijanej **Style**, aby filtrować według stylu (np. Liquid Glass).
4. Kliknij ikonę, aby ją zastosować.

![Wyszukiwanie ikon](/images/search-icons.png)

### Wybór pliku lokalnego

Kliknij **Choose from the Local** (lub naciśnij <kbd>Cmd</kbd>+<kbd>O</kbd>), aby otworzyć okno wyboru pliku. Obsługiwane formaty: PNG, JPEG, ICNS, TIFF, HEIC, WebP, BMP, GIF, SVG.

### Przeciągnij i upuść

Przeciągnij plik obrazu z Findera bezpośrednio na obszar ikony aplikacji. Niebieskie podświetlenie potwierdzi strefę upuszczania.

![Przeciągnij i upuść](/images/drag-drop.png)

### Przywracanie domyślnej ikony

Aby przywrócić oryginalną ikonę aplikacji:
- Kliknij przycisk **Restore Default** (lub naciśnij <kbd>Cmd</kbd>+<kbd>Delete</kbd>)
- Lub kliknij prawym przyciskiem myszy aplikację na pasku bocznym i wybierz **Restore Default Icon**

## Ucieczka z więzienia squircle (macOS Tahoe)

macOS 26 Tahoe wymusza na wszystkich ikonach aplikacji kształt squircle (zaokrąglony kwadrat). Aplikacje z niekompatybilnymi ikonami są zmniejszane i umieszczane na szarym tle w kształcie squircle.

IconChanger może to naprawić, ponownie stosując wbudowaną ikonę aplikacji jako ikonę niestandardową, co omija wymuszanie squircle przez macOS.

### Dla pojedynczej aplikacji

Kliknij prawym przyciskiem myszy aplikację na pasku bocznym i wybierz **Escape Squircle Jail**.

### Dla wszystkich aplikacji naraz

Kliknij menu **⋯** na pasku narzędzi i wybierz **Escape Squircle Jail (All Apps)**. Spowoduje to przetworzenie wszystkich aplikacji, które nie mają jeszcze niestandardowych ikon.

::: tip
Ikony niestandardowe ustawione w ten sposób **nie** obsługują trybów ikon Clear, Tinted ani Dark w macOS Tahoe — pozostają statyczne. Jest to ograniczenie systemowe.
:::

::: info
Usługa w tle automatycznie ponownie zastosuje ikony po aktualizacjach aplikacji, chroniąc je przed więzieniem squircle.
:::

## Ikony folderów

Możesz również dostosowywać ikony folderów. Dodaj foldery poprzez **Settings** > **Application** > **Application Folders** lub kliknij przycisk **+** w sekcji folderów na pasku bocznym.

Po dodaniu folder pojawia się na pasku bocznym tak jak aplikacje. Możesz wyszukiwać ikony, przeciągać i upuszczać obrazy lub wybierać pliki lokalne — ten sam przepływ pracy, co przy zmianie ikon aplikacji.

::: tip
Nazwy folderów takie jak „go" czy „Downloads" mogą nie dawać dobrych wyników wyszukiwania na macOSicons.com. Użyj [aliasów](./aliases), aby ustawić bardziej przyjazną dla wyszukiwania nazwę (np. alias „Documents" na „folder").
:::

## Pamięć podręczna ikon

Po zastosowaniu niestandardowej ikony jest ona automatycznie zapisywana w pamięci podręcznej. Oznacza to, że:
- Niestandardowe ikony mogą być przywrócone po aktualizacjach aplikacji
- Usługa w tle może je ponownie zastosować według harmonogramu
- Możesz eksportować i importować konfiguracje ikon

Zarządzaj zapisanymi ikonami w **Settings** > **Icon Cache**.

## Skróty klawiszowe

| Skrót | Akcja |
|---|---|
| <kbd>Cmd</kbd>+<kbd>O</kbd> | Wybierz lokalny plik ikony |
| <kbd>Cmd</kbd>+<kbd>Delete</kbd> | Przywróć domyślną ikonę |
| <kbd>Cmd</kbd>+<kbd>R</kbd> | Odśwież wyświetlanie ikon |

## Wskazówki

- Jeśli nie znaleziono ikon dla aplikacji, spróbuj [ustawić alias](./aliases) z prostszą nazwą.
- Licznik (np. "12/15") pokazuje, ile ikon zostało pomyślnie załadowanych z całkowitej liczby znalezionych.
- Ikony są domyślnie sortowane według popularności (liczby pobrań).
