# Cambiare le icone

## Utilizzo dell'interfaccia grafica

### Ricerca online

1. Selezionate un'app dalla barra laterale.
2. Sfogliate le icone da [macOSicons.com](https://macosicons.com/) nell'area principale.
3. Utilizzate il menu a tendina **Style** per filtrare per stile (ad es. Liquid Glass).
4. Fate clic su un'icona per applicarla.

![Ricerca delle icone](/images/search-icons.png)

### Scegliere un file locale

Fate clic su **Choose from the Local** (oppure premete <kbd>Cmd</kbd>+<kbd>O</kbd>) per aprire il selettore di file. Formati supportati: PNG, JPEG, ICNS, TIFF, HEIC, WebP, BMP, GIF, SVG.

### Drag & Drop

Trascinate un file immagine dal Finder direttamente sull'area dell'icona dell'app. Apparirà un'evidenziazione blu per confermare la zona di rilascio.

![Drag and drop](/images/drag-drop.png)

### Ripristinare l'icona predefinita

Per ripristinare l'icona originale di un'app:
- Fate clic sul pulsante **Restore Default** (oppure premete <kbd>Cmd</kbd>+<kbd>Delete</kbd>)
- Oppure fate clic con il tasto destro sull'app nella barra laterale e selezionate **Restore Default Icon**

## Escape Squircle Jail (macOS Tahoe)

macOS 26 Tahoe costringe tutte le icone delle app in una forma squircle (quadrato arrotondato). Le app con icone non conformi vengono rimpicciolite e posizionate su uno sfondo grigio a forma di squircle.

IconChanger può risolvere questo problema riapplicando l'icona originale inclusa nell'app come icona personalizzata, aggirando così l'imposizione dello squircle da parte di macOS.

### Per singola app

Fate clic con il tasto destro su un'app nella barra laterale e selezionate **Escape Squircle Jail**.

### Per tutte le app contemporaneamente

Fate clic sul menu **...** nella barra degli strumenti e selezionate **Escape Squircle Jail (All Apps)**. Questa operazione elabora tutte le app che non hanno già icone personalizzate.

::: tip
Le icone personalizzate impostate in questo modo **non** supportano le modalità Clear, Tinted o Dark delle icone di macOS Tahoe — rimangono statiche. Si tratta di una limitazione del sistema.
:::

::: info
Il servizio in background riapplicherà automaticamente le icone dopo gli aggiornamenti delle app, mantenendole fuori dallo squircle jail.
:::

## Icone delle cartelle

Potete anche personalizzare le icone delle cartelle. Aggiungete cartelle tramite **Settings** > **Application** > **Application Folders**, oppure fate clic sul pulsante **+** nella sezione cartelle della barra laterale.

Una volta aggiunta una cartella, questa appare nella barra laterale come le app. Potete cercare icone, trascinare immagini o scegliere file locali — lo stesso flusso di lavoro utilizzato per cambiare le icone delle app.

::: tip
Nomi di cartelle come "go" o "Downloads" potrebbero non restituire buoni risultati di ricerca su macOSicons.com. Utilizzate gli [alias](./aliases) per impostare un nome più adatto alla ricerca (ad es., impostare l'alias di "Documents" su "folder").
:::

## Cache delle icone

Quando applicate un'icona personalizzata, questa viene automaticamente memorizzata nella cache. Ciò significa che:
- Le icone personalizzate possono essere ripristinate dopo gli aggiornamenti delle app
- Il servizio in background può riapplicarle a intervalli regolari
- È possibile esportare e importare le configurazioni delle icone

Gestite le icone nella cache in **Settings** > **Icon Cache**.

## Scorciatoie da tastiera

| Scorciatoia | Azione |
|---|---|
| <kbd>Cmd</kbd>+<kbd>O</kbd> | Scegliere un file icona locale |
| <kbd>Cmd</kbd>+<kbd>Delete</kbd> | Ripristinare l'icona predefinita |
| <kbd>Cmd</kbd>+<kbd>R</kbd> | Aggiornare la visualizzazione delle icone |

## Suggerimenti

- Se non vengono trovate icone per un'app, provate a [impostare un alias](./aliases) con un nome più semplice.
- Il contatore (ad es. "12/15") mostra quante icone sono state caricate con successo rispetto al totale trovato.
- Le icone sono ordinate per popolarità (numero di download) per impostazione predefinita.
