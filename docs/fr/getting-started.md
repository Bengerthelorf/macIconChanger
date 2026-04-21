---
title: Demarrage rapide
section: guide
order: 1
locale: fr
---

## Configuration requise

- macOS 13.0 (Ventura) ou version ulterieure
- Privileges d'administrateur (pour la configuration initiale et le changement d'icones)

## Installation

### Homebrew (recommande)

```bash
brew install Bengerthelorf/tap/iconchanger
```

### Telechargement manuel

1. Telechargez le dernier DMG depuis les [Releases GitHub](https://github.com/Bengerthelorf/macIconChanger/releases/latest).
2. Ouvrez le DMG et glissez **IconChanger** dans votre dossier Applications.
3. Lancez IconChanger.

## Premier lancement

Lors du premier lancement, IconChanger vous invitera a effectuer une configuration unique des permissions. Cette etape est necessaire pour que l'application puisse modifier les icones des applications.

![Ecran de configuration au premier lancement](/images/setup-prompt.png)

Cliquez sur le bouton de configuration et saisissez votre mot de passe administrateur. IconChanger configurera automatiquement les permissions necessaires (une regle sudoers pour le script auxiliaire).

::: tip
Si la configuration automatique echoue, consultez la page [Configuration initiale](./setup) pour les instructions manuelles.
:::

## Changer votre premiere icone

1. Selectionnez une application dans la barre laterale.
2. Parcourez les icones de [macOSicons.com](https://macosicons.com/) ou choisissez un fichier image local.
3. Cliquez sur une icone pour l'appliquer.

![Interface principale](/images/main-interface.png)

C'est tout ! L'icone de l'application sera changee immediatement.

## Etapes suivantes

- [Configurer une cle API](./api-key) pour la recherche d'icones en ligne
- [En savoir plus sur les alias d'applications](./aliases) pour de meilleurs resultats de recherche
- [Configurer le service d'arriere-plan](./background-service) pour la restauration automatique des icones
- [Installer l'outil CLI](/fr/cli/) pour l'acces en ligne de commande