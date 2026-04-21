---
title: Встановлення CLI
section: cli
locale: uk
---

IconChanger включає інтерфейс командного рядка для створення скриптів та автоматизації.

## Встановлення з програми

1. Відкрийте IconChanger > **Settings** > **Advanced**.
2. У розділі **Command Line Tool** натисніть **Install**.
3. Введіть пароль адміністратора.

Команда `iconchanger` тепер доступна у вашому терміналі.

## Встановлення вручну

Якщо ви бажаєте встановити вручну (наприклад, у скрипті dotfiles):

```bash
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger
```

## Перевірка встановлення

```bash
iconchanger --version
```

## Видалення

З програми: **Settings** > **Advanced** > **Uninstall**.

Або вручну:

```bash
sudo rm /usr/local/bin/iconchanger
```

## Наступні кроки

Див. [Довідник команд](./commands) для всіх доступних команд.