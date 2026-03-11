# Import a export

Zálohujte si konfigurace ikon nebo je přeneste na jiný Mac.

## Co se exportuje

Exportní soubor (JSON) obsahuje:
- **Aliasy aplikací** — vaše vlastní mapování vyhledávacích názvů
- **Reference ikon v mezipaměti** — které aplikace mají vlastní ikony a soubory ikon v mezipaměti

## Export

### Z grafického rozhraní

Přejděte do **Settings** > **Advanced** > **Configuration** a klikněte na **Export**.

### Z příkazového řádku

```bash
iconchanger export ~/Desktop/my-icons.json
```

## Import

### Z grafického rozhraní

Přejděte do **Settings** > **Advanced** > **Configuration** a klikněte na **Import**.

### Z příkazového řádku

```bash
iconchanger import ~/Desktop/my-icons.json
```

::: tip
Import pouze **přidává** nové položky. Nikdy nenahrazuje ani neodstraňuje vaše stávající aliasy nebo ikony v mezipaměti.
:::

## Validace

Před importem můžete konfigurační soubor ověřit:

```bash
iconchanger validate ~/Desktop/my-icons.json
```

Tím se zkontroluje struktura souboru bez provádění jakýchkoliv změn.

## Automatizace pomocí dotfiles

Nastavení IconChanger můžete automatizovat jako součást svých dotfiles:

```bash
#!/bin/bash
DMG_URL="https://github.com/Bengerthelorf/macIconChanger/releases/latest/download/IconChanger.dmg"
DMG_PATH="/tmp/IconChanger.dmg"

# Instalace aplikace
curl -L "$DMG_URL" -o "$DMG_PATH"
hdiutil attach "$DMG_PATH" -mountpoint /Volumes/IconChanger
cp -R /Volumes/IconChanger/IconChanger.app /Applications/
hdiutil detach /Volumes/IconChanger

# Instalace CLI (z balíčku aplikace)
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger

# Import konfigurace ikon
iconchanger import ~/dotfiles/iconchanger/config.json
```
