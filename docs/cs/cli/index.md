# Instalace CLI

IconChanger obsahuje rozhraní příkazového řádku pro skriptování a automatizaci.

## Instalace z aplikace

1. Otevřete IconChanger > **Settings** > **Advanced**.
2. V části **Command Line Tool** klikněte na **Install**.
3. Zadejte heslo správce.

Příkaz `iconchanger` je nyní dostupný ve vašem terminálu.

## Ruční instalace

Pokud preferujete ruční instalaci (např. v rámci dotfiles skriptu):

```bash
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger
```

## Ověření instalace

```bash
iconchanger --version
```

## Odinstalace

Z aplikace: **Settings** > **Advanced** > **Uninstall**.

Nebo ručně:

```bash
sudo rm /usr/local/bin/iconchanger
```

## Další kroky

Podívejte se na [Referenci příkazů](./commands) pro přehled všech dostupných příkazů.
