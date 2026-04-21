---
title: Instalacao da CLI
section: cli
locale: pt
---

O IconChanger inclui uma interface de linha de comando para scripts e automacao.

## Instalar pelo App

1. Abra IconChanger > **Settings** > **Advanced**.
2. Em **Command Line Tool**, clique em **Install**.
3. Insira sua senha de administrador.

O comando `iconchanger` agora esta disponivel no seu terminal.

## Instalar Manualmente

Se voce preferir instalar manualmente (ex.: em um script de dotfiles):

```bash
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger
```

## Verificar Instalacao

```bash
iconchanger --version
```

## Desinstalar

Pelo app: **Settings** > **Advanced** > **Uninstall**.

Ou manualmente:

```bash
sudo rm /usr/local/bin/iconchanger
```

## Proximos Passos

Consulte a [Referencia de Comandos](./commands) para todos os comandos disponiveis.