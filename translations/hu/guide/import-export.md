# Importálás és exportálás

Készíts biztonsági mentést az ikonkonfigurációidról, vagy vidd át őket egy másik Mac-re.

## Mi kerül exportálásra

Az exportfájl (JSON) tartalma:
- **Alkalmazás-álnevek** — az egyedi keresésnevek hozzárendelései
- **Gyorsítótárazott ikon-hivatkozások** — mely alkalmazásoknak van egyedi ikonjuk, és a gyorsítótárazott ikonfájlok

## Exportálás

### A grafikus felületről

Navigálj a **Settings** > **Advanced** > **Configuration** menüpontra, és kattints az **Export** gombra.

### A parancssorból

```bash
iconchanger export ~/Desktop/my-icons.json
```

## Importálás

### A grafikus felületről

Navigálj a **Settings** > **Advanced** > **Configuration** menüpontra, és kattints az **Import** gombra.

### A parancssorból

```bash
iconchanger import ~/Desktop/my-icons.json
```

::: tip
Az importálás csak **hozzáad** új elemeket. Soha nem cseréli le és nem törli a meglévő álneveket vagy gyorsítótárazott ikonokat.
:::

## Ellenőrzés

Importálás előtt ellenőrizheted a konfigurációs fájlt:

```bash
iconchanger validate ~/Desktop/my-icons.json
```

Ez ellenőrzi a fájlszerkezetet anélkül, hogy bármit módosítana.

## Automatizálás dotfiles segítségével

Az IconChanger beállítását automatizálhatod a dotfiles részeként:

```bash
#!/bin/bash
DMG_URL="https://github.com/Bengerthelorf/macIconChanger/releases/latest/download/IconChanger.dmg"
DMG_PATH="/tmp/IconChanger.dmg"

# Az alkalmazás telepítése
curl -L "$DMG_URL" -o "$DMG_PATH"
hdiutil attach "$DMG_PATH" -mountpoint /Volumes/IconChanger
cp -R /Volumes/IconChanger/IconChanger.app /Applications/
hdiutil detach /Volumes/IconChanger

# CLI telepítése (az alkalmazáscsomagból)
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger

# Ikonkonfiguráció importálása
iconchanger import ~/dotfiles/iconchanger/config.json
```
