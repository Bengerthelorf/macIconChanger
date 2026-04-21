---
title: Import og eksport
section: guide
order: 8
locale: nb
---

Sikkerhetskopier ikonkonfigurasjonene dine eller overfør dem til en annen Mac.

## Hva som eksporteres

En eksportfil (JSON) inkluderer:
- **App-aliaser** -- dine egendefinerte søkenavntilordninger
- **Bufrede ikonreferanser** -- hvilke apper som har egendefinerte ikoner og de bufrede ikonfilene

## Eksportere

### Fra brukergrensesnittet

Gå til **Settings** > **Advanced** > **Configuration**, og klikk **Export**.

### Fra CLI-et

```bash
iconchanger export ~/Desktop/my-icons.json
```

## Importere

### Fra brukergrensesnittet

Gå til **Settings** > **Advanced** > **Configuration**, og klikk **Import**.

### Fra CLI-et

```bash
iconchanger import ~/Desktop/my-icons.json
```

::: tip
Import **legger kun til** nye elementer. Den erstatter eller fjerner aldri eksisterende aliaser eller bufrede ikoner.
:::

## Validering

Før import kan du validere en konfigurasjonsfil:

```bash
iconchanger validate ~/Desktop/my-icons.json
```

Dette sjekker filstrukturen uten å gjøre noen endringer.

## Automatisering med dotfiles

Du kan automatisere IconChanger-oppsettet som en del av dine dotfiles:

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

# Importer ikonkonfigurasjonen din
iconchanger import ~/dotfiles/iconchanger/config.json
```