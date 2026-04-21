---
title: CLI-Installation
section: cli
locale: de
---

IconChanger enthält eine Kommandozeilen-Schnittstelle für Skripting und Automatisierung.

## Installation über die App

1. Öffnen Sie IconChanger > **Einstellungen** > **Advanced**.
2. Klicken Sie unter **Command Line Tool** auf **Install**.
3. Geben Sie Ihr Administratorpasswort ein.

Der Befehl `iconchanger` steht nun in Ihrem Terminal zur Verfügung.

## Manuelle Installation

Wenn Sie die manuelle Installation bevorzugen (z. B. in einem Dotfiles-Skript):

```bash
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger
```

## Installation überprüfen

```bash
iconchanger --version
```

## Deinstallation

Über die App: **Einstellungen** > **Advanced** > **Uninstall**.

Oder manuell:

```bash
sudo rm /usr/local/bin/iconchanger
```

## Nächste Schritte

Alle verfügbaren Befehle finden Sie in der [Befehlsreferenz](./commands).