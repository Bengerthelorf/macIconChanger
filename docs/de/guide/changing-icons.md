# Symbole ändern

## Die GUI verwenden

### Online suchen

1. Wählen Sie eine App in der Seitenleiste aus.
2. Durchsuchen Sie die Symbole von [macOSicons.com](https://macosicons.com/) im Hauptbereich.
3. Verwenden Sie das Dropdown-Menü **Style**, um nach Stil zu filtern (z. B. Liquid Glass).
4. Klicken Sie auf ein Symbol, um es anzuwenden.

![Nach Symbolen suchen](/images/search-icons.png)

### Lokale Datei auswählen

Klicken Sie auf **Choose from the Local** (oder drücken Sie <kbd>Cmd</kbd>+<kbd>O</kbd>), um einen Dateiauswahldialog zu öffnen. Unterstützte Formate: PNG, JPEG, ICNS, TIFF, HEIC, WebP, BMP, GIF, SVG.

### Drag & Drop

Ziehen Sie eine Bilddatei aus dem Finder direkt auf den Symbolbereich der App. Eine blaue Hervorhebung zeigt die Ablagezone an.

![Drag & Drop](/images/drag-drop.png)

### Standardsymbol wiederherstellen

So stellen Sie das Originalsymbol einer App wieder her:
- Klicken Sie auf die Schaltfläche **Restore Default** (oder drücken Sie <kbd>Cmd</kbd>+<kbd>Delete</kbd>)
- Oder klicken Sie mit der rechten Maustaste auf die App in der Seitenleiste und wählen Sie **Restore Default Icon**

## Squircle-Zwang aufheben (macOS Tahoe)

macOS 26 Tahoe erzwingt bei allen App-Symbolen eine Squircle-Form (abgerundetes Quadrat). Apps mit nicht konformen Symbolen werden verkleinert und auf einem grauen Squircle-Hintergrund platziert.

IconChanger kann dies beheben, indem es das mitgelieferte App-Symbol als benutzerdefiniertes Symbol neu anwendet, wodurch die Squircle-Erzwingung von macOS umgangen wird.

### Einzelne App

Klicken Sie mit der rechten Maustaste auf eine App in der Seitenleiste und wählen Sie **Escape Squircle Jail**.

### Alle Apps auf einmal

Klicken Sie auf das Menü **⋯** in der Symbolleiste und wählen Sie **Escape Squircle Jail (All Apps)**. Dies verarbeitet alle Apps, die noch kein benutzerdefiniertes Symbol haben.

::: tip
Benutzerdefinierte Symbole, die auf diese Weise gesetzt werden, unterstützen **nicht** die Modi Clear, Tinted oder Dark von macOS Tahoe — sie bleiben statisch. Dies ist eine Systemeinschränkung.
:::

::: info
Ihr Hintergrunddienst wendet Symbole nach App-Updates automatisch erneut an und hält sie vom Squircle-Zwang frei.
:::

## Ordnersymbole

Sie können auch Ordnersymbole anpassen. Fügen Sie Ordner über **Einstellungen** > **Application** > **Application Folders** hinzu, oder klicken Sie auf die Schaltfläche **+** im Ordnerbereich der Seitenleiste.

Sobald ein Ordner hinzugefügt wurde, erscheint er in der Seitenleiste wie eine App. Sie können nach Symbolen suchen, Bilder per Drag & Drop hinzufügen oder lokale Dateien auswählen — der gleiche Workflow wie beim Ändern von App-Symbolen.

::: tip
Ordnernamen wie „go" oder „Downloads" liefern auf macOSicons.com möglicherweise keine guten Suchergebnisse. Verwenden Sie [Aliasse](./aliases), um einen suchfreundlicheren Namen festzulegen (z. B. „Documents" als Alias „folder" festlegen).
:::

## Symbol-Caching

Wenn Sie ein benutzerdefiniertes Symbol anwenden, wird es automatisch zwischengespeichert. Das bedeutet:
- Ihre benutzerdefinierten Symbole können nach App-Updates wiederhergestellt werden
- Der Hintergrunddienst kann sie planmäßig erneut anwenden
- Sie können Ihre Symbol-Konfigurationen exportieren und importieren

Verwalten Sie zwischengespeicherte Symbole unter **Einstellungen** > **Icon Cache**.

## Tastenkürzel

| Tastenkürzel | Aktion |
|---|---|
| <kbd>Cmd</kbd>+<kbd>O</kbd> | Lokale Symboldatei auswählen |
| <kbd>Cmd</kbd>+<kbd>Delete</kbd> | Standardsymbol wiederherstellen |
| <kbd>Cmd</kbd>+<kbd>R</kbd> | Symbolanzeige aktualisieren |

## Tipps

- Wenn keine Symbole für eine App gefunden werden, versuchen Sie, [einen Alias festzulegen](./aliases) mit einem einfacheren Namen.
- Der Zähler (z. B. "12/15") zeigt an, wie viele Symbole von der Gesamtzahl erfolgreich geladen wurden.
- Symbole werden standardmäßig nach Beliebtheit (Downloadanzahl) sortiert.
