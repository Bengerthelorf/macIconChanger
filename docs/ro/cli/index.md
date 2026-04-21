---
title: Instalarea CLI
section: cli
locale: ro
---

IconChanger include o interfata prin linia de comanda pentru scripturi si automatizare.

## Instalare din aplicatie

1. Deschide IconChanger > **Settings** > **Advanced**.
2. Sub **Command Line Tool**, apasa **Install**.
3. Introdu parola de administrator.

Comanda `iconchanger` este acum disponibila in terminal.

## Instalare manuala

Daca preferi sa instalezi manual (de ex., intr-un script dotfiles):

```bash
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger
```

## Verificarea instalarii

```bash
iconchanger --version
```

## Dezinstalare

Din aplicatie: **Settings** > **Advanced** > **Uninstall**.

Sau manual:

```bash
sudo rm /usr/local/bin/iconchanger
```

## Pasii urmatori

Consulta [Referinta comenzilor](./commands) pentru toate comenzile disponibile.