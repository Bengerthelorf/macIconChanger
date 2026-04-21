---
title: Installazione del CLI
section: cli
locale: it
---

IconChanger include un'interfaccia a riga di comando per lo scripting e l'automazione.

## Installazione dall'app

1. Aprite IconChanger > **Settings** > **Advanced**.
2. Nella sezione **Command Line Tool**, fate clic su **Install**.
3. Inserite la password di amministratore.

Il comando `iconchanger` è ora disponibile nel vostro terminale.

## Installazione manuale

Se preferite installare manualmente (ad es. in uno script dotfiles):

```bash
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger
```

## Verifica dell'installazione

```bash
iconchanger --version
```

## Disinstallazione

Dall'app: **Settings** > **Advanced** > **Uninstall**.

Oppure manualmente:

```bash
sudo rm /usr/local/bin/iconchanger
```

## Prossimi passi

Consultate il [Riferimento dei comandi](./commands) per tutti i comandi disponibili.