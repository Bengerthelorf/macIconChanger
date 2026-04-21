---
title: Instalacion del CLI
section: cli
locale: es
---

IconChanger incluye una interfaz de linea de comandos para scripting y automatizacion.

## Instalar desde la aplicacion

1. Abra IconChanger > **Settings** > **Advanced**.
2. En **Command Line Tool**, haga clic en **Install**.
3. Introduzca su contrasena de administrador.

El comando `iconchanger` estara ahora disponible en su terminal.

## Instalar manualmente

Si prefiere instalarlo manualmente (por ejemplo, en un script de dotfiles):

```bash
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger
```

## Verificar la instalacion

```bash
iconchanger --version
```

## Desinstalar

Desde la aplicacion: **Settings** > **Advanced** > **Uninstall**.

O manualmente:

```bash
sudo rm /usr/local/bin/iconchanger
```

## Siguientes pasos

Consulte la [Referencia de comandos](./commands) para ver todos los comandos disponibles.