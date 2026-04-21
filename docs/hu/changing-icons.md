---
title: Ikonok módosítása
section: guide
order: 3
locale: hu
---

## A grafikus felület használata

### Online keresés

1. Válassz ki egy alkalmazást az oldalsávból.
2. Böngéssz az ikonok között a [macOSicons.com](https://macosicons.com/) oldalról a fő területen.
3. Használd a **Style** legördülő menüt a stílus szerinti szűréshez (pl. Liquid Glass).
4. Kattints egy ikonra az alkalmazásához.

![Ikonok keresése](/images/search-icons.png)

### Helyi fájl kiválasztása

Kattints a **Choose from the Local** gombra (vagy nyomd meg a <kbd>Cmd</kbd>+<kbd>O</kbd> billentyűkombinációt) a fájlválasztó megnyitásához. Támogatott formátumok: PNG, JPEG, ICNS, TIFF, HEIC, WebP, BMP, GIF, SVG.

### Fogd és vidd

Húzz egy képfájlt a Finderből közvetlenül az alkalmazás ikonterületére. Egy kék kiemelés jelzi a célzónát.

![Fogd és vidd](/images/drag-drop.png)

### Alapértelmezett ikon visszaállítása

Egy alkalmazás eredeti ikonjának visszaállításához:
- Kattints a **Restore Default** gombra (vagy nyomd meg a <kbd>Cmd</kbd>+<kbd>Delete</kbd> billentyűkombinációt)
- Vagy kattints jobb gombbal az alkalmazásra az oldalsávban, és válaszd a **Restore Default Icon** lehetőséget

## Kilépés a squircle börtönből (macOS Tahoe)

A macOS 26 Tahoe minden alkalmazásikont squircle (lekerekített négyzet) formába kényszerít. A nem megfelelő ikonokkal rendelkező alkalmazások ikonjai összezsugorodnak, és szürke squircle háttérre kerülnek.

Az IconChanger ezt úgy javítja, hogy az alkalmazás saját beépített ikonját egyedi ikonként alkalmazza újra, amivel megkerüli a macOS squircle-kényszerítését.

### Alkalmazásonként

Kattints jobb gombbal egy alkalmazásra az oldalsávban, és válaszd az **Escape Squircle Jail** lehetőséget.

### Összes alkalmazás egyszerre

Kattints az eszköztáron található **⋯** menüre, és válaszd az **Escape Squircle Jail (All Apps)** lehetőséget. Ez feldolgozza az összes alkalmazást, amelyeknek még nincs egyedi ikonjuk.

::: tip
Az így beállított egyedi ikonok **nem** támogatják a macOS Tahoe Clear, Tinted vagy Dark ikon üzemmódjait — statikusak maradnak. Ez a rendszer korlátozása.
:::

::: info
A háttérszolgáltatásod automatikusan újraalkalmazza az ikonokat az alkalmazásfrissítések után, így azok nem kerülnek vissza a squircle börtönbe.
:::

## Mappaikonok

Mappaikonokat is testreszabhatsz. Adj hozzá mappákat a **Settings** > **Application** > **Application Folders** menüpontban, vagy kattints a **+** gombra az oldalsáv mappaszekciójában.

Miután egy mappa hozzáadásra került, úgy jelenik meg az oldalsávban, mint az alkalmazások. Kereshetsz ikonokat, húzhatod és ejtheted a képeket, vagy választhatsz helyi fájlokat — ugyanaz a munkafolyamat, mint az alkalmazásikonok módosításánál.

::: tip
Az olyan mappanevek, mint a „go" vagy „Downloads", nem feltétlenül adnak jó keresési eredményeket a macOSicons.com oldalon. Használj [álneveket](./aliases) egy keresésbarátabb név beállításához (pl. a „Documents" álneve legyen „folder").
:::

## Ikon-gyorsítótárazás

Amikor egyedi ikont alkalmazol, az automatikusan gyorsítótárazásra kerül. Ez azt jelenti, hogy:
- Az egyedi ikonok az alkalmazásfrissítések után is visszaállíthatók
- A háttérszolgáltatás ütemezetten újraalkalmazza őket
- Exportálhatod és importálhatod az ikonkonfigurációidat

A gyorsítótárazott ikonokat a **Settings** > **Icon Cache** menüpontban kezelheted.

## Billentyűparancsok

| Billentyűparancs | Művelet |
|---|---|
| <kbd>Cmd</kbd>+<kbd>O</kbd> | Helyi ikonfájl kiválasztása |
| <kbd>Cmd</kbd>+<kbd>Delete</kbd> | Alapértelmezett ikon visszaállítása |
| <kbd>Cmd</kbd>+<kbd>R</kbd> | Ikonmegjelenítés frissítése |

## Tippek

- Ha nem találhatók ikonok egy alkalmazáshoz, próbálj meg [álnevet beállítani](./aliases) egyszerűbb névvel.
- A számláló (pl. „12/15") megmutatja, hány ikon töltődött be sikeresen a talált összesből.
- Az ikonok alapértelmezetten népszerűség (letöltések száma) szerint vannak rendezve.