---
title: CLI-installasjon
section: cli
locale: nb
---

IconChanger inkluderer et kommandolinjegrensesnitt for skripting og automatisering.

## Installer fra appen

1. Åpne IconChanger > **Settings** > **Advanced**.
2. Under **Command Line Tool**, klikk **Install**.
3. Skriv inn administratorpassordet ditt.

`iconchanger`-kommandoen er nå tilgjengelig i terminalen din.

## Manuell installasjon

Hvis du foretrekker å installere manuelt (f.eks. i et dotfiles-skript):

```bash
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger
```

## Verifiser installasjonen

```bash
iconchanger --version
```

## Avinstaller

Fra appen: **Settings** > **Advanced** > **Uninstall**.

Eller manuelt:

```bash
sudo rm /usr/local/bin/iconchanger
```

## Neste steg

Se [Kommandoreferanse](./commands) for alle tilgjengelige kommandoer.