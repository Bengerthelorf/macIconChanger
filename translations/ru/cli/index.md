# Установка CLI

IconChanger включает интерфейс командной строки для автоматизации и скриптов.

## Установка из приложения

1. Откройте IconChanger > **Settings** > **Advanced**.
2. В разделе **Command Line Tool** нажмите **Install**.
3. Введите пароль администратора.

Команда `iconchanger` теперь доступна в вашем терминале.

## Ручная установка

Если вы предпочитаете установить вручную (например, в скрипте dotfiles):

```bash
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger
```

## Проверка установки

```bash
iconchanger --version
```

## Удаление

Из приложения: **Settings** > **Advanced** > **Uninstall**.

Или вручную:

```bash
sudo rm /usr/local/bin/iconchanger
```

## Дальнейшие шаги

См. [Справочник по командам](./commands) для просмотра всех доступных команд.
