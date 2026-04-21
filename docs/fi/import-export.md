---
title: Tuonti ja vienti
section: guide
order: 8
locale: fi
---

Varmuuskopioi kuvakeasetukset tai siirrä ne toiselle Macille.

## Mitä viedään

Vientitiedosto (JSON) sisältää:
- **Sovellusten aliakset** — mukautetut hakunimien yhdistämisesi
- **Välimuistissa olevat kuvakeviittaukset** — mitkä sovellukset käyttävät mukautettuja kuvakkeita ja välimuistissa olevat kuvaketiedostot

## Vienti

### Käyttöliittymästä

Siirry kohtaan **Settings** > **Advanced** > **Configuration** ja napsauta **Export**.

### Komentoriviltä

```bash
iconchanger export ~/Desktop/my-icons.json
```

## Tuonti

### Käyttöliittymästä

Siirry kohtaan **Settings** > **Advanced** > **Configuration** ja napsauta **Import**.

### Komentoriviltä

```bash
iconchanger import ~/Desktop/my-icons.json
```

::: tip
Tuonti vain **lisää** uusia kohteita. Se ei koskaan korvaa tai poista olemassa olevia aliaksia tai välimuistissa olevia kuvakkeita.
:::

## Tarkistaminen

Ennen tuontia voit tarkistaa konfiguraatiotiedoston:

```bash
iconchanger validate ~/Desktop/my-icons.json
```

Tämä tarkistaa tiedostorakenteen tekemättä muutoksia.

## Automaatio dotfiles-tiedostojen avulla

Voit automatisoida IconChanger-asennuksen osana dotfiles-tiedostojasi:

```bash
#!/bin/bash
DMG_URL="https://github.com/Bengerthelorf/macIconChanger/releases/latest/download/IconChanger.dmg"
DMG_PATH="/tmp/IconChanger.dmg"

# Asenna sovellus
curl -L "$DMG_URL" -o "$DMG_PATH"
hdiutil attach "$DMG_PATH" -mountpoint /Volumes/IconChanger
cp -R /Volumes/IconChanger/IconChanger.app /Applications/
hdiutil detach /Volumes/IconChanger

# Asenna komentoriviliittymä (sovelluksen paketista)
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger

# Tuo kuvakeasetukset
iconchanger import ~/dotfiles/iconchanger/config.json
```