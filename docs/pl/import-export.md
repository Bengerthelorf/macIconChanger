---
title: Import i eksport
section: guide
order: 8
locale: pl
---

Twórz kopie zapasowe konfiguracji ikon lub przenoś je na innego Maca.

## Co jest eksportowane

Plik eksportu (JSON) zawiera:
- **Aliasy aplikacji** — niestandardowe mapowania nazw wyszukiwania
- **Odniesienia do zapisanych ikon** — które aplikacje mają niestandardowe ikony i pliki zapisanych ikon

## Eksportowanie

### Z interfejsu graficznego

Przejdź do **Settings** > **Advanced** > **Configuration** i kliknij **Export**.

### Z wiersza poleceń

```bash
iconchanger export ~/Desktop/my-icons.json
```

## Importowanie

### Z interfejsu graficznego

Przejdź do **Settings** > **Advanced** > **Configuration** i kliknij **Import**.

### Z wiersza poleceń

```bash
iconchanger import ~/Desktop/my-icons.json
```

::: tip
Import jedynie **dodaje** nowe elementy. Nigdy nie zastępuje ani nie usuwa istniejących aliasów lub zapisanych ikon.
:::

## Walidacja

Przed importem możesz zwalidować plik konfiguracyjny:

```bash
iconchanger validate ~/Desktop/my-icons.json
```

Sprawdza to strukturę pliku bez wprowadzania żadnych zmian.

## Automatyzacja z dotfiles

Możesz zautomatyzować konfigurację IconChanger jako część swoich dotfiles:

```bash
#!/bin/bash
DMG_URL="https://github.com/Bengerthelorf/macIconChanger/releases/latest/download/IconChanger.dmg"
DMG_PATH="/tmp/IconChanger.dmg"

# Zainstaluj aplikację
curl -L "$DMG_URL" -o "$DMG_PATH"
hdiutil attach "$DMG_PATH" -mountpoint /Volumes/IconChanger
cp -R /Volumes/IconChanger/IconChanger.app /Applications/
hdiutil detach /Volumes/IconChanger

# Zainstaluj CLI (z pakietu aplikacji)
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger

# Importuj konfigurację ikon
iconchanger import ~/dotfiles/iconchanger/config.json
```