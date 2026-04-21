---
title: Import si export
section: guide
order: 8
locale: ro
---

Salveaza configuratiile pictogramelor sau transfera-le pe alt Mac.

## Ce se exporta

Un fisier de export (JSON) include:
- **Aliasuri ale aplicatiilor** — asocierile tale personalizate de nume pentru cautare
- **Referinte la pictograme din cache** — care aplicatii au pictograme personalizate si fisierele de pictograme din cache

## Exportare

### Din interfata grafica

Mergi la **Settings** > **Advanced** > **Configuration** si apasa **Export**.

### Din CLI

```bash
iconchanger export ~/Desktop/my-icons.json
```

## Importare

### Din interfata grafica

Mergi la **Settings** > **Advanced** > **Configuration** si apasa **Import**.

### Din CLI

```bash
iconchanger import ~/Desktop/my-icons.json
```

::: tip
Importul doar **adauga** elemente noi. Nu inlocuieste si nu sterge aliasurile sau pictogramele din cache existente.
:::

## Validare

Inainte de import, poti valida un fisier de configurare:

```bash
iconchanger validate ~/Desktop/my-icons.json
```

Aceasta verifica structura fisierului fara a face modificari.

## Automatizare cu dotfiles

Poti automatiza configurarea IconChanger ca parte a dotfiles-urilor tale:

```bash
#!/bin/bash
DMG_URL="https://github.com/Bengerthelorf/macIconChanger/releases/latest/download/IconChanger.dmg"
DMG_PATH="/tmp/IconChanger.dmg"

# Instaleaza aplicatia
curl -L "$DMG_URL" -o "$DMG_PATH"
hdiutil attach "$DMG_PATH" -mountpoint /Volumes/IconChanger
cp -R /Volumes/IconChanger/IconChanger.app /Applications/
hdiutil detach /Volumes/IconChanger

# Instaleaza CLI (din pachetul aplicatiei)
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger

# Importa configuratia pictogramelor
iconchanger import ~/dotfiles/iconchanger/config.json
```