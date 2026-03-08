# IconChanger

[English](./README.md) | [中文版](./README-zh.md)

Une application macOS pour personnaliser les icônes de vos applications, avec une interface graphique et un outil en ligne de commande.

![aperçu](./Github/Github-Iconchanger.jpeg)

## Fonctionnalités

- **Icônes personnalisées** — Changez l'icône de n'importe quelle application via l'interface ou le terminal
- **Cache d'icônes** — Met automatiquement en cache les icônes personnalisées pour une restauration facile
- **Service en arrière-plan** — Restauration planifiée et détection des mises à jour pour conserver vos icônes
- **Lancement au démarrage** — Démarrage automatique avec comportement configurable (ouvrir la fenêtre ou rester caché)
- **Alias d'applications** — Associez des noms de recherche alternatifs pour de meilleurs résultats
- **Import/Export** — Sauvegardez, partagez et restaurez vos configurations d'icônes
- **Outil CLI** — Interface en ligne de commande complète avec 8 commandes
- **Localisation** — Disponible en 30 langues

## Installation

### Application

1. Téléchargez le dernier DMG depuis [Releases](https://github.com/Bengerthelorf/macIconChanger/releases/latest).
2. Glissez IconChanger dans votre dossier Applications.
3. Lancez et suivez la configuration initiale (accorde les permissions pour changer les icônes).

### Outil CLI

1. Ouvrez IconChanger → `Réglages` → `Avancé`.
2. Cliquez sur **Installer** sous Outil de ligne de commande (mot de passe admin requis).
3. La commande `iconchanger` est maintenant disponible dans votre terminal.

## Utilisation

### Changer les icônes (GUI)

1. Sélectionnez une application dans la barre latérale.
2. Recherchez des icônes ou choisissez une image locale.
3. Cliquez pour appliquer.

### Changer les icônes (CLI)

```bash
# Définir une icône personnalisée
iconchanger set-icon /Applications/Safari.app ~/icons/safari.png

# Supprimer une icône personnalisée (restaurer l'original)
iconchanger remove-icon /Applications/Safari.app

# Restaurer toutes les icônes en cache (ex: après une mise à jour système)
iconchanger restore

# Aperçu de la restauration
iconchanger restore --dry-run --verbose
```

### Alias d'applications

Si la recherche d'icônes ne donne aucun résultat pour une application :

1. Clic droit sur l'app dans la barre latérale → **Définir l'alias**.
2. Entrez un nom adapté à la recherche (ex: `Adobe Illustrator 2023` → `Illustrator`).

### Gestion de la configuration

```bash
# Exporter la configuration (alias + icônes en cache)
iconchanger export ~/Desktop/my-icons.json

# Importer une configuration
iconchanger import ~/Desktop/my-icons.json

# Valider un fichier de configuration avant l'import
iconchanger validate ~/Desktop/my-icons.json

# Vérifier l'état de la configuration
iconchanger status

# Lister tous les alias et icônes en cache
iconchanger list
```

### Service en arrière-plan

Configurez dans `Réglages` → `Arrière-plan` :

- **Exécuter en arrière-plan** — L'app reste active après fermeture de la fenêtre
- **Restauration planifiée** — Restaure automatiquement les icônes à intervalles définis
- **Restauration lors des mises à jour** — Détecte les mises à jour et réapplique les icônes
- **Afficher dans la barre des menus / le Dock** — Choisissez la visibilité en arrière-plan
- **Lancement au démarrage** — Démarrage automatique avec comportement configurable

## Configuration initiale

Au premier lancement, IconChanger vous propose de configurer les permissions. Cliquez sur le bouton et entrez votre mot de passe admin (configure automatiquement la règle sudoers).

Pour une configuration manuelle, ajoutez via `sudo visudo` :

```
ALL ALL=(ALL) NOPASSWD: /Users/<votre-nom-utilisateur>/.iconchanger/helper.sh
```

## Clé API

Une clé API de [macosicons.com](https://macosicons.com/) est nécessaire pour rechercher des icônes en ligne.

1. Visitez [macosicons.com](https://macosicons.com/) et créez un compte.
2. Demandez une clé API.
3. Entrez-la dans `Réglages` → `Avancé` → `Clé API`.

Vous pouvez aussi utiliser des fichiers d'icônes locaux sans clé API.

![Comment obtenir une clé API](./Github/Api.png)

## Automatisation avec dotfiles

```bash
#!/bin/bash
DMG_URL="https://github.com/Bengerthelorf/macIconChanger/releases/latest/download/IconChanger.dmg"
DMG_PATH="/tmp/IconChanger.dmg"

# Installer l'application
curl -L "$DMG_URL" -o "$DMG_PATH"
hdiutil attach "$DMG_PATH" -mountpoint /Volumes/IconChanger
cp -R /Volumes/IconChanger/IconChanger.app /Applications/
hdiutil detach /Volumes/IconChanger

# Installer le CLI (depuis le bundle de l'app)
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger

# Importer votre configuration d'icônes
iconchanger import ~/dotfiles/iconchanger/config.json
```

## Configuration requise

- macOS 13.0 ou ultérieur
- Privilèges administrateur (pour la configuration initiale et les changements d'icônes)

## Limitations

Les applications système protégées par SIP (System Integrity Protection) ne peuvent pas voir leurs icônes modifiées. C'est une restriction de macOS.

## Contribuer

1. Forkez le projet.
2. Clonez et ouvrez dans Xcode 15+.
3. Commencez à contribuer !

Signalez les bugs via [GitHub Issues](https://github.com/Bengerthelorf/macIconChanger/issues).

## Remerciements

- [underthestars-zhy/IconChanger](https://github.com/underthestars-zhy/IconChanger) — Projet original
- [lcandy2](https://github.com/lcandy2) — Fork avec interface de réglages, système d'alias et gestion des permissions ; ce projet est basé sur son travail
- [macOSicons.com](https://macosicons.com/#/) — Base de données d'icônes
- [fileicon](https://github.com/mklement0/fileicon) — Outil de manipulation d'icônes
- [Atom](https://github.com/atomtoto) — Contributeur

## Licence

Licence MIT. Voir [LICENSE](LICENSE) pour les détails.

## Historique des étoiles

[![Star History Chart](https://api.star-history.com/svg?repos=Bengerthelorf/macIconChanger&type=Timeline)](https://www.star-history.com/#Bengerthelorf/macIconChanger&Timeline)
