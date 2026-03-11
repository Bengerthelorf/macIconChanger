# Skift ikoner

## Brug af den grafiske brugerflade

### Søg online

1. Vælg en app fra sidebjælken.
2. Gennemse ikonerne fra [macOSicons.com](https://macosicons.com/) i hovedområdet.
3. Brug rullelisten **Style** til at filtrere efter stil (f.eks. Liquid Glass).
4. Klik på et ikon for at anvende det.

![Søgning efter ikoner](/images/search-icons.png)

### Vælg en lokal fil

Klik på **Choose from the Local** (eller tryk <kbd>Cmd</kbd>+<kbd>O</kbd>) for at åbne en filvælger. Understøttede formater: PNG, JPEG, ICNS, TIFF, HEIC, WebP, BMP, GIF, SVG.

### Træk og slip

Træk en billedfil fra Finder direkte hen på appens ikonområde. En blå markering vises for at bekræfte slipzonen.

![Træk og slip](/images/drag-drop.png)

### Gendan standardikon

For at gendanne en apps originale ikon:
- Klik på knappen **Restore Default** (eller tryk <kbd>Cmd</kbd>+<kbd>Delete</kbd>)
- Eller højreklik på appen i sidebjælken og vælg **Restore Default Icon**

## Escape Squircle Jail (macOS Tahoe)

macOS 26 Tahoe tvinger alle appikoner ind i en squircle-form (afrundet firkant). Apps med ikke-konforme ikoner bliver formindsket og placeret på en grå squircle-baggrund.

IconChanger kan løse dette ved at genanvende en apps eget medfølgende ikon som et brugerdefineret ikon, hvilket omgår macOS' squircle-tvang.

### Per app

Højreklik på en app i sidebjælken og vælg **Escape Squircle Jail**.

### Alle apps på én gang

Klik på **⋯**-menuen i værktøjslinjen og vælg **Escape Squircle Jail (All Apps)**. Dette behandler alle apps, der ikke allerede har brugerdefinerede ikoner.

::: tip
Brugerdefinerede ikoner sat på denne måde understøtter **ikke** macOS Tahoes Clear-, Tinted- eller Dark-ikontilstande — de forbliver statiske. Dette er en systembegrænsning.
:::

::: info
Din baggrundstjeneste genanvender automatisk ikoner efter appopdateringer og holder dem ude af squircle jail.
:::

## Ikoncaching

Når du anvender et brugerdefineret ikon, caches det automatisk. Det betyder:
- Dine brugerdefinerede ikoner kan gendannes efter appopdateringer
- Baggrundstjenesten kan genanvende dem efter en tidsplan
- Du kan eksportere og importere dine ikonkonfigurationer

Administrer cachede ikoner under **Settings** > **Icon Cache**.

## Tastaturgenveje

| Genvej | Handling |
|---|---|
| <kbd>Cmd</kbd>+<kbd>O</kbd> | Vælg en lokal ikonfil |
| <kbd>Cmd</kbd>+<kbd>Delete</kbd> | Gendan standardikon |
| <kbd>Cmd</kbd>+<kbd>R</kbd> | Opdater ikonvisning |

## Tips

- Hvis der ikke findes ikoner til en app, prøv at [sætte et alias](./aliases) med et simplere navn.
- Tælleren (f.eks. "12/15") viser, hvor mange ikoner der er indlæst succesfuldt ud af det samlede antal fundet.
- Ikoner sorteres som standard efter popularitet (antal downloads).
