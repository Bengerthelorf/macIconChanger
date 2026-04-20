# Importeren & exporteren

Maak een back-up van je pictogramconfiguraties of zet ze over naar een andere Mac.

## Wat wordt er geëxporteerd

Een exportbestand (JSON) bevat:
- **App-aliassen** — je aangepaste zoeknaamkoppelingen
- **Gecachete pictogramverwijzingen** — welke apps aangepaste pictogrammen hebben en de bijbehorende gecachete pictogrambestanden

## Exporteren

### Via de GUI

Ga naar **Settings** > **Advanced** > **Configuration** en klik op **Export**.

### Via de CLI

```bash
iconchanger export ~/Desktop/my-icons.json
```

## Importeren

### Via de GUI

Ga naar **Settings** > **Advanced** > **Configuration** en klik op **Import**.

### Via de CLI

```bash
iconchanger import ~/Desktop/my-icons.json
```

::: tip
Importeren **voegt** alleen nieuwe items toe. Het vervangt of verwijdert nooit je bestaande aliassen of gecachete pictogrammen.
:::

## Valideren

Voordat je importeert, kun je een configuratiebestand valideren:

```bash
iconchanger validate ~/Desktop/my-icons.json
```

Dit controleert de bestandsstructuur zonder wijzigingen aan te brengen.

## Automatisering met dotfiles

Je kunt de configuratie van IconChanger automatiseren als onderdeel van je dotfiles:

```bash
#!/bin/bash
DMG_URL="https://github.com/Bengerthelorf/macIconChanger/releases/latest/download/IconChanger.dmg"
DMG_PATH="/tmp/IconChanger.dmg"

# De app installeren
curl -L "$DMG_URL" -o "$DMG_PATH"
hdiutil attach "$DMG_PATH" -mountpoint /Volumes/IconChanger
cp -R /Volumes/IconChanger/IconChanger.app /Applications/
hdiutil detach /Volumes/IconChanger

# CLI installeren (vanuit de app-bundel)
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger

# Je pictogramconfiguratie importeren
iconchanger import ~/dotfiles/iconchanger/config.json
```
