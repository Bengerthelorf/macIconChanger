---
title: Import & Export
section: guide
order: 8
locale: de
---

Sichern Sie Ihre Symbol-Konfigurationen oder übertragen Sie sie auf einen anderen Mac.

## Was wird exportiert

Eine Exportdatei (JSON) enthält:
- **App-Aliasse** — Ihre benutzerdefinierten Suchnamenzuordnungen
- **Zwischengespeicherte Symbolreferenzen** — welche Apps benutzerdefinierte Symbole haben und die zugehörigen zwischengespeicherten Symboldateien

## Exportieren

### Über die GUI

Gehen Sie zu **Einstellungen** > **Advanced** > **Configuration** und klicken Sie auf **Export**.

### Über das CLI

```bash
iconchanger export ~/Desktop/my-icons.json
```

## Importieren

### Über die GUI

Gehen Sie zu **Einstellungen** > **Advanced** > **Configuration** und klicken Sie auf **Import**.

### Über das CLI

```bash
iconchanger import ~/Desktop/my-icons.json
```

::: tip
Der Import **fügt** nur neue Einträge hinzu. Er ersetzt oder entfernt niemals Ihre bestehenden Aliasse oder zwischengespeicherten Symbole.
:::

## Validierung

Vor dem Import können Sie eine Konfigurationsdatei validieren:

```bash
iconchanger validate ~/Desktop/my-icons.json
```

Dies überprüft die Dateistruktur, ohne Änderungen vorzunehmen.

## Automatisierung mit Dotfiles

Sie können die IconChanger-Einrichtung als Teil Ihrer Dotfiles automatisieren:

```bash
#!/bin/bash
DMG_URL="https://github.com/Bengerthelorf/macIconChanger/releases/latest/download/IconChanger.dmg"
DMG_PATH="/tmp/IconChanger.dmg"

# App installieren
curl -L "$DMG_URL" -o "$DMG_PATH"
hdiutil attach "$DMG_PATH" -mountpoint /Volumes/IconChanger
cp -R /Volumes/IconChanger/IconChanger.app /Applications/
hdiutil detach /Volumes/IconChanger

# CLI installieren (aus dem App-Bundle)
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger

# Symbol-Konfiguration importieren
iconchanger import ~/dotfiles/iconchanger/config.json
```