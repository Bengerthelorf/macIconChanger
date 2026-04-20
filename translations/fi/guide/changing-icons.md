# Kuvakkeiden vaihtaminen

## Käyttöliittymän käyttö

### Verkkohaku

1. Valitse sovellus sivupalkista.
2. Selaa kuvakkeita [macOSicons.com](https://macosicons.com/)-sivustolta pääalueella.
3. Käytä **Style**-pudotusvalikkoa suodattaaksesi tyylin mukaan (esim. Liquid Glass).
4. Napsauta kuvaketta ottaaksesi sen käyttöön.

![Kuvakkeiden hakeminen](/images/search-icons.png)

### Paikallisen tiedoston valitseminen

Napsauta **Choose from the Local** (tai paina <kbd>Cmd</kbd>+<kbd>O</kbd>) avataksesi tiedostovalitsimen. Tuetut muodot: PNG, JPEG, ICNS, TIFF, HEIC, WebP, BMP, GIF, SVG.

### Vedä ja pudota

Vedä kuvatiedosto Finderista suoraan sovelluksen kuvakealueelle. Sininen korostus ilmestyy vahvistamaan pudotusalueen.

![Vedä ja pudota](/images/drag-drop.png)

### Oletuskuvakkeen palauttaminen

Sovelluksen alkuperäisen kuvakkeen palauttaminen:
- Napsauta **Restore Default** -painiketta (tai paina <kbd>Cmd</kbd>+<kbd>Delete</kbd>)
- Tai napsauta sovellusta sivupalkissa hiiren oikealla painikkeella ja valitse **Restore Default Icon**

## Squircle-vankilasta vapautuminen (macOS Tahoe)

macOS 26 Tahoe pakottaa kaikki sovellusten kuvakkeet squircle-muotoon (pyöristetty neliö). Sovellukset, joiden kuvakkeet eivät ole yhteensopivia, pienennetään ja asetetaan harmaalle squircle-taustalle.

IconChanger voi korjata tämän asettamalla sovelluksen oman sisäisen kuvakkeen mukautetuksi kuvakkeeksi, mikä ohittaa macOS:n squircle-pakon.

### Yksittäinen sovellus

Napsauta sovellusta sivupalkissa hiiren oikealla painikkeella ja valitse **Escape Squircle Jail**.

### Kaikki sovellukset kerralla

Napsauta työkalupalkin **...** -valikkoa ja valitse **Escape Squircle Jail (All Apps)**. Tämä käsittelee kaikki sovellukset, joilla ei vielä ole mukautettuja kuvakkeita.

::: tip
Tällä tavalla asetetut mukautetut kuvakkeet **eivät** tue macOS Tahoen Clear-, Tinted- tai Dark-kuvaketiloja — ne pysyvät staattisina. Tämä on järjestelmän rajoitus.
:::

::: info
Taustapalvelusi asettaa kuvakkeet automaattisesti uudelleen sovellusten päivitysten jälkeen, pitäen ne poissa squircle-vankilasta.
:::

## Kansioiden kuvakkeet

Voit myös mukauttaa kansioiden kuvakkeita. Lisää kansioita kohdasta **Settings** > **Application** > **Application Folders** tai napsauta **+**-painiketta sivupalkin kansioosiossa.

Kun kansio on lisätty, se näkyy sivupalkissa kuten sovellukset. Voit etsiä kuvakkeita, vetää ja pudottaa kuvia tai valita paikallisia tiedostoja — sama työnkulku kuin sovellusten kuvakkeiden vaihtamisessa.

::: tip
Kansioiden nimet kuten "go" tai "Downloads" eivät välttämättä anna hyviä hakutuloksia macOSicons.com-sivustolla. Käytä [aliaksia](./aliases) asettaaksesi hakuystävällisemmän nimen (esim. aseta "Documents"-kansion aliakseksi "folder").
:::

## Kuvakkeiden välimuisti

Kun otat mukautetun kuvakkeen käyttöön, se tallennetaan automaattisesti välimuistiin. Tämä tarkoittaa:
- Mukautetut kuvakkeesi voidaan palauttaa sovellusten päivitysten jälkeen
- Taustapalvelu voi asettaa ne uudelleen aikataulun mukaan
- Voit viedä ja tuoda kuvakeasetukset

Hallinnoi välimuistissa olevia kuvakkeita kohdassa **Settings** > **Icon Cache**.

## Pikanäppäimet

| Pikanäppäin | Toiminto |
|---|---|
| <kbd>Cmd</kbd>+<kbd>O</kbd> | Valitse paikallinen kuvaketiedosto |
| <kbd>Cmd</kbd>+<kbd>Delete</kbd> | Palauta oletuskuvake |
| <kbd>Cmd</kbd>+<kbd>R</kbd> | Päivitä kuvakenäkymä |

## Vinkkejä

- Jos sovellukselle ei löydy kuvakkeita, kokeile [aliaksen asettamista](./aliases) yksinkertaisemmalla nimellä.
- Laskuri (esim. "12/15") näyttää, kuinka monta kuvaketta ladattiin onnistuneesti löydetyistä.
- Kuvakkeet lajitellaan oletuksena suosion (latausmäärän) mukaan.
