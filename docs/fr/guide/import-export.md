# Import et export

Sauvegardez vos configurations d'icones ou transferez-les vers un autre Mac.

## Contenu de l'export

Un fichier d'export (JSON) comprend :
- **Alias d'applications** — vos associations de noms de recherche personnalises
- **References des icones en cache** — quelles applications ont des icones personnalisees et les fichiers d'icones en cache

## Exporter

### Depuis l'interface graphique

Allez dans **Settings** > **Advanced** > **Configuration**, et cliquez sur **Export**.

### Depuis le CLI

```bash
iconchanger export ~/Desktop/my-icons.json
```

## Importer

### Depuis l'interface graphique

Allez dans **Settings** > **Advanced** > **Configuration**, et cliquez sur **Import**.

### Depuis le CLI

```bash
iconchanger import ~/Desktop/my-icons.json
```

::: tip
L'import ne fait qu'**ajouter** de nouveaux elements. Il ne remplace ni ne supprime jamais vos alias ou icones en cache existants.
:::

## Validation

Avant d'importer, vous pouvez valider un fichier de configuration :

```bash
iconchanger validate ~/Desktop/my-icons.json
```

Cela verifie la structure du fichier sans effectuer aucune modification.

## Automatisation avec les dotfiles

Vous pouvez automatiser la configuration d'IconChanger dans le cadre de vos dotfiles :

```bash
#!/bin/bash
DMG_URL="https://github.com/Bengerthelorf/macIconChanger/releases/latest/download/IconChanger.dmg"
DMG_PATH="/tmp/IconChanger.dmg"

# Install the app
curl -L "$DMG_URL" -o "$DMG_PATH"
hdiutil attach "$DMG_PATH" -mountpoint /Volumes/IconChanger
cp -R /Volumes/IconChanger/IconChanger.app /Applications/
hdiutil detach /Volumes/IconChanger

# Install CLI (from the app bundle)
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger

# Import your icon configuration
iconchanger import ~/dotfiles/iconchanger/config.json
```
