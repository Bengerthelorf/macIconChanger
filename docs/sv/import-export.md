---
title: Import och export
section: guide
order: 8
locale: sv
---

Säkerhetskopiera dina ikonkonfigurationer eller överför dem till en annan Mac.

## Vad som exporteras

En exportfil (JSON) innehåller:
- **Appalias** — dina anpassade söknamnsmappningar
- **Cachade ikonreferenser** — vilka appar som har anpassade ikoner och de cachade ikonfilerna

## Exportera

### Från GUI:t

Gå till **Settings** > **Advanced** > **Configuration** och klicka på **Export**.

### Från CLI:t

```bash
iconchanger export ~/Desktop/my-icons.json
```

## Importera

### Från GUI:t

Gå till **Settings** > **Advanced** > **Configuration** och klicka på **Import**.

### Från CLI:t

```bash
iconchanger import ~/Desktop/my-icons.json
```

::: tip
Import lägger bara **till** nya poster. Den ersätter eller tar aldrig bort dina befintliga alias eller cachade ikoner.
:::

## Validering

Innan du importerar kan du validera en konfigurationsfil:

```bash
iconchanger validate ~/Desktop/my-icons.json
```

Detta kontrollerar filstrukturen utan att göra några ändringar.

## Automatisering med dotfiles

Du kan automatisera konfigurationen av IconChanger som en del av dina dotfiles:

```bash
#!/bin/bash
DMG_URL="https://github.com/Bengerthelorf/macIconChanger/releases/latest/download/IconChanger.dmg"
DMG_PATH="/tmp/IconChanger.dmg"

# Installera appen
curl -L "$DMG_URL" -o "$DMG_PATH"
hdiutil attach "$DMG_PATH" -mountpoint /Volumes/IconChanger
cp -R /Volumes/IconChanger/IconChanger.app /Applications/
hdiutil detach /Volumes/IconChanger

# Installera CLI (från appaketet)
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger

# Importera din ikonkonfiguration
iconchanger import ~/dotfiles/iconchanger/config.json
```