# Pictogrammen wijzigen

## Via de GUI

### Online zoeken

1. Selecteer een app in de zijbalk.
2. Blader door de pictogrammen van [macOSicons.com](https://macosicons.com/) in het hoofdgedeelte.
3. Gebruik het dropdown-menu **Style** om te filteren op stijl (bijv. Liquid Glass).
4. Klik op een pictogram om het toe te passen.

![Pictogrammen zoeken](/images/search-icons.png)

### Een lokaal bestand kiezen

Klik op **Choose from the Local** (of druk op <kbd>Cmd</kbd>+<kbd>O</kbd>) om een bestandskiezer te openen. Ondersteunde formaten: PNG, JPEG, ICNS, TIFF, HEIC, WebP, BMP, GIF, SVG.

### Drag & drop

Sleep een afbeeldingsbestand vanuit Finder rechtstreeks naar het pictogramgebied van de app. Er verschijnt een blauwe markering om de dropzone te bevestigen.

![Drag & drop](/images/drag-drop.png)

### Standaardpictogram herstellen

Om het originele pictogram van een app te herstellen:
- Klik op de knop **Restore Default** (of druk op <kbd>Cmd</kbd>+<kbd>Delete</kbd>)
- Of klik met de rechtermuisknop op de app in de zijbalk en selecteer **Restore Default Icon**

## Escape Squircle Jail (macOS Tahoe)

macOS 26 Tahoe dwingt alle apppictogrammen in een squircle-vorm (afgerond vierkant). Apps met afwijkende pictogrammen worden verkleind en op een grijze squircle-achtergrond geplaatst.

IconChanger kan dit oplossen door het eigen meegeleverde pictogram van een app opnieuw toe te passen als aangepast pictogram, waardoor de squircle-verplichting van macOS wordt omzeild.

### Per app

Klik met de rechtermuisknop op een app in de zijbalk en selecteer **Escape Squircle Jail**.

### Alle apps tegelijk

Klik op het menu **⋯** in de werkbalk en selecteer **Escape Squircle Jail (All Apps)**. Dit verwerkt alle apps die nog geen aangepast pictogram hebben.

::: tip
Aangepaste pictogrammen die op deze manier zijn ingesteld, ondersteunen **niet** de Clear-, Tinted- of Dark-pictogrammodi van macOS Tahoe — ze blijven statisch. Dit is een systeembeperking.
:::

::: info
Je achtergronddienst past pictogrammen automatisch opnieuw toe na app-updates, zodat ze buiten de squircle jail blijven.
:::

## Pictogramcache

Wanneer je een aangepast pictogram toepast, wordt het automatisch gecachet. Dit betekent:
- Je aangepaste pictogrammen kunnen worden hersteld na app-updates
- De achtergronddienst kan ze volgens een schema opnieuw toepassen
- Je kunt je pictogramconfiguraties exporteren en importeren

Beheer gecachete pictogrammen in **Settings** > **Icon Cache**.

## Sneltoetsen

| Sneltoets | Actie |
|---|---|
| <kbd>Cmd</kbd>+<kbd>O</kbd> | Een lokaal pictogrambestand kiezen |
| <kbd>Cmd</kbd>+<kbd>Delete</kbd> | Standaardpictogram herstellen |
| <kbd>Cmd</kbd>+<kbd>R</kbd> | Pictogramweergave vernieuwen |

## Tips

- Als er geen pictogrammen worden gevonden voor een app, probeer dan [een alias in te stellen](/nl/guide/aliases) met een eenvoudigere naam.
- De teller (bijv. "12/15") toont hoeveel pictogrammen succesvol zijn geladen van het totaal aantal gevonden.
- Pictogrammen worden standaard gesorteerd op populariteit (aantal downloads).
