---
title: Import og eksport
section: guide
order: 8
locale: da
---

Sikkerhedskopier dine ikonkonfigurationer eller overfør dem til en anden Mac.

## Hvad der eksporteres

En eksportfil (JSON) inkluderer:
- **App-aliasser** — dine brugerdefinerede søgenavnstilknytninger
- **Cachede ikonreferencer** — hvilke apps der har brugerdefinerede ikoner og de cachede ikonfiler

## Eksportering

### Fra den grafiske brugerflade

Gå til **Settings** > **Advanced** > **Configuration**, og klik på **Export**.

### Fra CLI'en

```bash
iconchanger export ~/Desktop/my-icons.json
```

## Importering

### Fra den grafiske brugerflade

Gå til **Settings** > **Advanced** > **Configuration**, og klik på **Import**.

### Fra CLI'en

```bash
iconchanger import ~/Desktop/my-icons.json
```

::: tip
Import **tilføjer** kun nye elementer. Den erstatter eller fjerner aldrig dine eksisterende aliasser eller cachede ikoner.
:::

## Validering

Før import kan du validere en konfigurationsfil:

```bash
iconchanger validate ~/Desktop/my-icons.json
```

Dette tjekker filstrukturen uden at foretage ændringer.

## Automatisering med dotfiles

Du kan automatisere opsætningen af IconChanger som en del af dine dotfiles:

```bash
#!/bin/bash
DMG_URL="https://github.com/Bengerthelorf/macIconChanger/releases/latest/download/IconChanger.dmg"
DMG_PATH="/tmp/IconChanger.dmg"

# Installer appen
curl -L "$DMG_URL" -o "$DMG_PATH"
hdiutil attach "$DMG_PATH" -mountpoint /Volumes/IconChanger
cp -R /Volumes/IconChanger/IconChanger.app /Applications/
hdiutil detach /Volumes/IconChanger

# Installer CLI (fra app-pakken)
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger

# Importer din ikonkonfiguration
iconchanger import ~/dotfiles/iconchanger/config.json
```