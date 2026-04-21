---
title: Changer les icones
section: guide
order: 3
locale: fr
---

## Utilisation de l'interface graphique

### Recherche en ligne

1. Selectionnez une application dans la barre laterale.
2. Parcourez les icones de [macOSicons.com](https://macosicons.com/) dans la zone principale.
3. Utilisez le menu deroulant **Style** pour filtrer par style (par ex. Liquid Glass).
4. Cliquez sur une icone pour l'appliquer.

![Recherche d'icones](/images/search-icons.png)

### Choisir un fichier local

Cliquez sur **Choose from the Local** (ou appuyez sur <kbd>Cmd</kbd>+<kbd>O</kbd>) pour ouvrir le selecteur de fichiers. Formats pris en charge : PNG, JPEG, ICNS, TIFF, HEIC, WebP, BMP, GIF, SVG.

### Glisser-deposer

Glissez un fichier image depuis le Finder directement sur la zone d'icone de l'application. Un surlignage bleu apparaitra pour confirmer la zone de depot.

![Glisser-deposer](/images/drag-drop.png)

### Restaurer l'icone par defaut

Pour restaurer l'icone d'origine d'une application :
- Cliquez sur le bouton **Restore Default** (ou appuyez sur <kbd>Cmd</kbd>+<kbd>Delete</kbd>)
- Ou faites un clic droit sur l'application dans la barre laterale et selectionnez **Restore Default Icon**

## Echapper au carcan du squircle (macOS Tahoe)

macOS 26 Tahoe impose a toutes les icones d'applications une forme de squircle (carre arrondi). Les applications dont les icones ne sont pas conformes sont reduites et placees sur un fond gris en forme de squircle.

IconChanger peut corriger cela en reappliquant l'icone d'origine de l'application en tant qu'icone personnalisee, ce qui contourne l'imposition du squircle par macOS.

### Par application

Faites un clic droit sur une application dans la barre laterale et selectionnez **Escape Squircle Jail**.

### Toutes les applications en une fois

Cliquez sur le menu **...** dans la barre d'outils et selectionnez **Escape Squircle Jail (All Apps)**. Cela traite toutes les applications qui n'ont pas deja d'icone personnalisee.

::: tip
Les icones personnalisees definies de cette maniere ne prennent **pas** en charge les modes d'icones Clear, Tinted ou Dark de macOS Tahoe — elles restent statiques. Il s'agit d'une limitation du systeme.
:::

::: info
Votre service d'arriere-plan reappliquera automatiquement les icones apres les mises a jour des applications, les maintenant hors du carcan du squircle.
:::

## Icones de dossiers

Vous pouvez egalement personnaliser les icones des dossiers. Ajoutez des dossiers via **Settings** > **Application** > **Application Folders**, ou cliquez sur le bouton **+** dans la section des dossiers de la barre laterale.

Une fois un dossier ajoute, il apparait dans la barre laterale comme les applications. Vous pouvez rechercher des icones, glisser-deposer des images ou choisir des fichiers locaux — le meme flux de travail que pour changer les icones d'applications.

::: tip
Les noms de dossiers comme « go » ou « Downloads » peuvent ne pas donner de bons resultats de recherche sur macOSicons.com. Utilisez les [alias](./aliases) pour definir un nom plus adapte a la recherche (par ex., definir l'alias de « Documents » en « folder »).
:::

## Mise en cache des icones

Lorsque vous appliquez une icone personnalisee, elle est automatiquement mise en cache. Cela signifie :
- Vos icones personnalisees peuvent etre restaurees apres les mises a jour des applications
- Le service d'arriere-plan peut les reappliquer selon un calendrier
- Vous pouvez exporter et importer vos configurations d'icones

Gerez les icones en cache dans **Settings** > **Icon Cache**.

## Raccourcis clavier

| Raccourci | Action |
|---|---|
| <kbd>Cmd</kbd>+<kbd>O</kbd> | Choisir un fichier d'icone local |
| <kbd>Cmd</kbd>+<kbd>Delete</kbd> | Restaurer l'icone par defaut |
| <kbd>Cmd</kbd>+<kbd>R</kbd> | Rafraichir l'affichage des icones |

## Conseils

- Si aucune icone n'est trouvee pour une application, essayez de [definir un alias](./aliases) avec un nom plus simple.
- Le compteur (par ex. "12/15") indique combien d'icones ont ete chargees avec succes sur le total trouve.
- Les icones sont triees par popularite (nombre de telechargements) par defaut.