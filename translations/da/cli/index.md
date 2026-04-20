# CLI-installation

IconChanger inkluderer en kommandolinjegrænseflade til scripting og automatisering.

## Installer fra appen

1. Åbn IconChanger > **Settings** > **Advanced**.
2. Under **Command Line Tool** klik på **Install**.
3. Indtast din administratoradgangskode.

Kommandoen `iconchanger` er nu tilgængelig i din terminal.

## Installer manuelt

Hvis du foretrækker at installere manuelt (f.eks. i et dotfiles-script):

```bash
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger
```

## Bekræft installationen

```bash
iconchanger --version
```

## Afinstaller

Fra appen: **Settings** > **Advanced** > **Uninstall**.

Eller manuelt:

```bash
sudo rm /usr/local/bin/iconchanger
```

## Næste skridt

Se [Kommandoreferencer](./commands) for alle tilgængelige kommandoer.
