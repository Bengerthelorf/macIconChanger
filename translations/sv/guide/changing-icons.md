# Byta ikoner

## Använda GUI:t

### Sök online

1. Välj en app i sidofältet.
2. Bläddra bland ikonerna från [macOSicons.com](https://macosicons.com/) i huvudområdet.
3. Använd rullgardinsmenyn **Style** för att filtrera efter stil (t.ex. Liquid Glass).
4. Klicka på en ikon för att tillämpa den.

![Söka efter ikoner](/images/search-icons.png)

### Välj en lokal fil

Klicka på **Choose from the Local** (eller tryck <kbd>Cmd</kbd>+<kbd>O</kbd>) för att öppna en filväljare. Format som stöds: PNG, JPEG, ICNS, TIFF, HEIC, WebP, BMP, GIF, SVG.

### Dra och släpp

Dra en bildfil från Finder direkt till appens ikonområde. En blå markering visas för att bekräfta släppzonen.

![Dra och släpp](/images/drag-drop.png)

### Återställ standardikon

För att återställa en apps originalikon:
- Klicka på knappen **Restore Default** (eller tryck <kbd>Cmd</kbd>+<kbd>Delete</kbd>)
- Eller högerklicka på appen i sidofältet och välj **Restore Default Icon**

## Escape Squircle Jail (macOS Tahoe)

macOS 26 Tahoe tvingar alla appikoner till en squircle-form (rundad kvadrat). Appar med icke-konforma ikoner krymps och placeras på en grå squircle-bakgrund.

IconChanger kan åtgärda detta genom att tillämpa appens egna medföljande ikon som en anpassad ikon, vilket kringgår macOS squircle-tvång.

### Per app

Högerklicka på en app i sidofältet och välj **Escape Squircle Jail**.

### Alla appar samtidigt

Klicka på menyn **⋯** i verktygsfältet och välj **Escape Squircle Jail (All Apps)**. Detta behandlar alla appar som inte redan har anpassade ikoner.

::: tip
Anpassade ikoner som ställs in på detta sätt stöder **inte** macOS Tahoes ikonlägen Clear, Tinted eller Dark — de förblir statiska. Detta är en systembegränsning.
:::

::: info
Din bakgrundstjänst tillämpar automatiskt ikoner på nytt efter appuppdateringar, så att de hålls utanför squircle-fängelset.
:::

## Mappikoner

Du kan även anpassa mappikoner. Lägg till mappar via **Settings** > **Application** > **Application Folders**, eller klicka på knappen **+** i sidofältets mappsektion.

När en mapp har lagts till visas den i sidofältet precis som appar. Du kan söka efter ikoner, dra och släppa bilder eller välja lokala filer — samma arbetsflöde som för att ändra appikoner.

::: tip
Mappnamn som "go" eller "Downloads" kanske inte ger bra sökresultat från macOSicons.com. Använd [alias](./aliases) för att ange ett mer sökvänligt namn (t.ex. ange alias "Documents" till "folder").
:::

## Ikoncache

När du tillämpar en anpassad ikon cachas den automatiskt. Det innebär att:
- Dina anpassade ikoner kan återställas efter appuppdateringar
- Bakgrundstjänsten kan tillämpa dem på nytt enligt ett schema
- Du kan exportera och importera dina ikonkonfigurationer

Hantera cachade ikoner i **Settings** > **Icon Cache**.

## Tangentbordsgenvägar

| Genväg | Åtgärd |
|---|---|
| <kbd>Cmd</kbd>+<kbd>O</kbd> | Välj en lokal ikonfil |
| <kbd>Cmd</kbd>+<kbd>Delete</kbd> | Återställ standardikon |
| <kbd>Cmd</kbd>+<kbd>R</kbd> | Uppdatera ikonvisningen |

## Tips

- Om inga ikoner hittas för en app, prova att [ange ett alias](./aliases) med ett enklare namn.
- Räknaren (t.ex. "12/15") visar hur många ikoner som laddades framgångsrikt av det totala antalet hittade.
- Ikoner sorteras efter popularitet (antal nedladdningar) som standard.
