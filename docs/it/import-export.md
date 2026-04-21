---
title: Importazione ed esportazione
section: guide
order: 8
locale: it
---

Eseguite il backup delle configurazioni delle icone o trasferitele su un altro Mac.

## Cosa viene esportato

Un file di esportazione (JSON) include:
- **Alias delle app** — le mappature personalizzate dei nomi di ricerca
- **Riferimenti alle icone nella cache** — quali app hanno icone personalizzate e i relativi file nella cache

## Esportazione

### Dall'interfaccia grafica

Andate in **Settings** > **Advanced** > **Configuration** e fate clic su **Export**.

### Dal CLI

```bash
iconchanger export ~/Desktop/my-icons.json
```

## Importazione

### Dall'interfaccia grafica

Andate in **Settings** > **Advanced** > **Configuration** e fate clic su **Import**.

### Dal CLI

```bash
iconchanger import ~/Desktop/my-icons.json
```

::: tip
L'importazione **aggiunge** solo nuovi elementi. Non sostituisce né rimuove mai gli alias o le icone nella cache esistenti.
:::

## Validazione

Prima di importare, è possibile validare un file di configurazione:

```bash
iconchanger validate ~/Desktop/my-icons.json
```

Questa operazione verifica la struttura del file senza apportare alcuna modifica.

## Automazione con dotfiles

È possibile automatizzare la configurazione di IconChanger come parte dei propri dotfiles:

```bash
#!/bin/bash
DMG_URL="https://github.com/Bengerthelorf/macIconChanger/releases/latest/download/IconChanger.dmg"
DMG_PATH="/tmp/IconChanger.dmg"

# Installare l'app
curl -L "$DMG_URL" -o "$DMG_PATH"
hdiutil attach "$DMG_PATH" -mountpoint /Volumes/IconChanger
cp -R /Volumes/IconChanger/IconChanger.app /Applications/
hdiutil detach /Volumes/IconChanger

# Installare il CLI (dal bundle dell'app)
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger

# Importare la configurazione delle icone
iconchanger import ~/dotfiles/iconchanger/config.json
```