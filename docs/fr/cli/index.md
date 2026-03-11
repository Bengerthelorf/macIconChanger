# Installation du CLI

IconChanger inclut une interface en ligne de commande pour le scripting et l'automatisation.

## Installation depuis l'application

1. Ouvrez IconChanger > **Settings** > **Advanced**.
2. Sous **Command Line Tool**, cliquez sur **Install**.
3. Saisissez votre mot de passe administrateur.

La commande `iconchanger` est maintenant disponible dans votre terminal.

## Installation manuelle

Si vous preferez installer manuellement (par ex. dans un script de dotfiles) :

```bash
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger
```

## Verifier l'installation

```bash
iconchanger --version
```

## Desinstallation

Depuis l'application : **Settings** > **Advanced** > **Uninstall**.

Ou manuellement :

```bash
sudo rm /usr/local/bin/iconchanger
```

## Etapes suivantes

Consultez la [Reference des commandes](./commands) pour toutes les commandes disponibles.
