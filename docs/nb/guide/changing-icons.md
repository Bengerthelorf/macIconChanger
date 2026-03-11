# Endre ikoner

## Bruke brukergrensesnittet

### Søk på nettet

1. Velg en app fra sidefeltet.
2. Bla gjennom ikonene fra [macOSicons.com](https://macosicons.com/) i hovedområdet.
3. Bruk **Style**-rullegardinmenyen for å filtrere etter stil (f.eks. Liquid Glass).
4. Klikk på et ikon for å bruke det.

![Søke etter ikoner](/images/search-icons.png)

### Velg en lokal fil

Klikk **Choose from the Local** (eller trykk <kbd>Cmd</kbd>+<kbd>O</kbd>) for å åpne en filvelger. Støttede formater: PNG, JPEG, ICNS, TIFF, HEIC, WebP, BMP, GIF, SVG.

### Dra og slipp

Dra en bildefil fra Finder direkte til appens ikonområde. En blå markering vil vises for å bekrefte slippområdet.

![Dra og slipp](/images/drag-drop.png)

### Gjenopprett standardikon

For å gjenopprette en apps originalikon:
- Klikk **Restore Default**-knappen (eller trykk <kbd>Cmd</kbd>+<kbd>Delete</kbd>)
- Eller høyreklikk appen i sidefeltet og velg **Restore Default Icon**

## Unnslippe Squircle Jail (macOS Tahoe)

macOS 26 Tahoe tvinger alle appikoner inn i en squircle-form (avrundet firkant). Apper med ikoner som ikke samsvarer, blir krympet og plassert på en grå squircle-bakgrunn.

IconChanger kan fikse dette ved å bruke appens eget medfølgende ikon som et egendefinert ikon, noe som omgår macOS sin squircle-tvang.

### Per app

Høyreklikk en app i sidefeltet og velg **Escape Squircle Jail**.

### Alle apper samtidig

Klikk **⋯**-menyen i verktøylinjen og velg **Escape Squircle Jail (All Apps)**. Dette behandler alle apper som ikke allerede har egendefinerte ikoner.

::: tip
Egendefinerte ikoner satt på denne måten støtter **ikke** macOS Tahoe sine Clear-, Tinted- eller Dark-ikonmoduser -- de forblir statiske. Dette er en systembegrensning.
:::

::: info
Bakgrunnstjenesten din vil automatisk bruke ikoner på nytt etter appoppdateringer, og holder dem utenfor squircle jail.
:::

## Ikonbufring

Når du bruker et egendefinert ikon, blir det automatisk bufret. Dette betyr:
- Dine egendefinerte ikoner kan gjenopprettes etter appoppdateringer
- Bakgrunnstjenesten kan bruke dem på nytt etter en tidsplan
- Du kan eksportere og importere ikonkonfigurasjonene dine

Administrer bufrede ikoner i **Settings** > **Icon Cache**.

## Tastatursnarveier

| Snarvei | Handling |
|---|---|
| <kbd>Cmd</kbd>+<kbd>O</kbd> | Velg en lokal ikonfil |
| <kbd>Cmd</kbd>+<kbd>Delete</kbd> | Gjenopprett standardikon |
| <kbd>Cmd</kbd>+<kbd>R</kbd> | Oppdater ikonvisning |

## Tips

- Hvis ingen ikoner finnes for en app, prøv å [sette et alias](./aliases) med et enklere navn.
- Telleren (f.eks. «12/15») viser hvor mange ikoner som ble lastet inn, av totalt antall funnet.
- Ikoner sorteres etter popularitet (antall nedlastinger) som standard.
