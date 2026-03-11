# CLI-installatie

IconChanger bevat een opdrachtregelinterface voor scripting en automatisering.

## Installeren vanuit de app

1. Open IconChanger > **Settings** > **Advanced**.
2. Klik onder **Command Line Tool** op **Install**.
3. Voer je beheerderswachtwoord in.

De opdracht `iconchanger` is nu beschikbaar in je terminal.

## Handmatig installeren

Als je liever handmatig installeert (bijv. in een dotfiles-script):

```bash
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger
```

## Installatie verifiëren

```bash
iconchanger --version
```

## Verwijderen

Via de app: **Settings** > **Advanced** > **Uninstall**.

Of handmatig:

```bash
sudo rm /usr/local/bin/iconchanger
```

## Volgende stappen

Zie de [Opdrachtreferentie](/nl/cli/commands) voor alle beschikbare opdrachten.
