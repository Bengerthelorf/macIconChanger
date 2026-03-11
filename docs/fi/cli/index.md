# Komentoriviliittymän asennus

IconChanger sisältää komentoriviliittymän skriptausta ja automaatiota varten.

## Asennus sovelluksesta

1. Avaa IconChanger > **Settings** > **Advanced**.
2. Kohdassa **Command Line Tool** napsauta **Install**.
3. Anna ylläpitäjän salasanasi.

`iconchanger`-komento on nyt käytettävissä päätteessäsi.

## Manuaalinen asennus

Jos haluat asentaa manuaalisesti (esim. dotfiles-skriptissä):

```bash
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger
```

## Asennuksen tarkistaminen

```bash
iconchanger --version
```

## Asennuksen poisto

Sovelluksesta: **Settings** > **Advanced** > **Uninstall**.

Tai manuaalisesti:

```bash
sudo rm /usr/local/bin/iconchanger
```

## Seuraavat vaiheet

Katso [Komentojen viite](./commands) kaikista käytettävissä olevista komennoista.
