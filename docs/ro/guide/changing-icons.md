# Schimbarea pictogramelor

## Folosind interfata grafica

### Cautare online

1. Selecteaza o aplicatie din bara laterala.
2. Exploreaza pictogramele de pe [macOSicons.com](https://macosicons.com/) in zona principala.
3. Foloseste meniul derulant **Style** pentru a filtra dupa stil (de ex., Liquid Glass).
4. Apasa pe o pictograma pentru a o aplica.

![Cautarea pictogramelor](/images/search-icons.png)

### Alegerea unui fisier local

Apasa **Choose from the Local** (sau apasa <kbd>Cmd</kbd>+<kbd>O</kbd>) pentru a deschide selectorul de fisiere. Formate acceptate: PNG, JPEG, ICNS, TIFF, HEIC, WebP, BMP, GIF, SVG.

### Trage si plaseaza

Trage un fisier imagine din Finder direct in zona de pictograma a aplicatiei. Va aparea o evidentiare albastra pentru a confirma zona de plasare.

![Trage si plaseaza](/images/drag-drop.png)

### Restaurarea pictogramei implicite

Pentru a restaura pictograma originala a unei aplicatii:
- Apasa butonul **Restore Default** (sau apasa <kbd>Cmd</kbd>+<kbd>Delete</kbd>)
- Sau apasa click dreapta pe aplicatie in bara laterala si selecteaza **Restore Default Icon**

## Eliberare din captivitatea Squircle (macOS Tahoe)

macOS 26 Tahoe forteaza toate pictogramele aplicatiilor intr-o forma de squircle (patrat rotunjit). Aplicatiile cu pictograme neconforme sunt micsorate si plasate pe un fundal gri de squircle.

IconChanger poate rezolva aceasta problema reaplicand pictograma inclusa in aplicatie ca pictograma personalizata, ocolind astfel impunerea formei squircle de catre macOS.

### Per aplicatie

Apasa click dreapta pe o aplicatie in bara laterala si selecteaza **Escape Squircle Jail**.

### Toate aplicatiile deodata

Apasa meniul **⋯** din bara de instrumente si selecteaza **Escape Squircle Jail (All Apps)**. Aceasta proceseaza toate aplicatiile care nu au deja pictograme personalizate.

::: tip
Pictogramele personalizate setate in acest mod **nu** accepta modurile de pictograme Clear, Tinted sau Dark din macOS Tahoe — ele raman statice. Aceasta este o limitare a sistemului.
:::

::: info
Serviciul in fundal va reaplica automat pictogramele dupa actualizarile aplicatiilor, mentinandu-le in afara captivitati squircle.
:::

## Memorarea in cache a pictogramelor

Cand aplici o pictograma personalizata, aceasta este memorata automat in cache. Asta inseamna ca:
- Pictogramele personalizate pot fi restaurate dupa actualizarile aplicatiilor
- Serviciul in fundal le poate reaplica conform unui program
- Poti exporta si importa configuratiile de pictograme

Gestioneaza pictogramele din cache in **Settings** > **Icon Cache**.

## Scurtaturi de tastatura

| Scurtatura | Actiune |
|---|---|
| <kbd>Cmd</kbd>+<kbd>O</kbd> | Alege un fisier de pictograma local |
| <kbd>Cmd</kbd>+<kbd>Delete</kbd> | Restaureaza pictograma implicita |
| <kbd>Cmd</kbd>+<kbd>R</kbd> | Reimprosapateaza afisarea pictogramei |

## Sfaturi

- Daca nu sunt gasite pictograme pentru o aplicatie, incearca sa [setezi un alias](./aliases) cu un nume mai simplu.
- Contorul (de ex., "12/15") arata cate pictograme au fost incarcate cu succes din totalul gasit.
- Pictogramele sunt sortate implicit dupa popularitate (numar de descarcari).
