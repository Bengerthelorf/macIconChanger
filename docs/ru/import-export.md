---
title: Импорт и экспорт
section: guide
order: 8
locale: ru
---

Создавайте резервные копии конфигураций иконок или переносите их на другой Mac.

## Что экспортируется

Файл экспорта (JSON) включает:
- **Псевдонимы приложений** — ваши пользовательские сопоставления имён для поиска
- **Ссылки на кэшированные иконки** — какие приложения имеют пользовательские иконки и файлы кэшированных иконок

## Экспорт

### Через графический интерфейс

Перейдите в **Settings** > **Advanced** > **Configuration** и нажмите **Export**.

### Через CLI

```bash
iconchanger export ~/Desktop/my-icons.json
```

## Импорт

### Через графический интерфейс

Перейдите в **Settings** > **Advanced** > **Configuration** и нажмите **Import**.

### Через CLI

```bash
iconchanger import ~/Desktop/my-icons.json
```

::: tip
Импорт только **добавляет** новые элементы. Он никогда не заменяет и не удаляет существующие псевдонимы или кэшированные иконки.
:::

## Валидация

Перед импортом можно проверить файл конфигурации:

```bash
iconchanger validate ~/Desktop/my-icons.json
```

Это проверит структуру файла, не внося никаких изменений.

## Автоматизация с помощью dotfiles

Вы можете автоматизировать настройку IconChanger в рамках ваших dotfiles:

```bash
#!/bin/bash
DMG_URL="https://github.com/Bengerthelorf/macIconChanger/releases/latest/download/IconChanger.dmg"
DMG_PATH="/tmp/IconChanger.dmg"

# Установка приложения
curl -L "$DMG_URL" -o "$DMG_PATH"
hdiutil attach "$DMG_PATH" -mountpoint /Volumes/IconChanger
cp -R /Volumes/IconChanger/IconChanger.app /Applications/
hdiutil detach /Volumes/IconChanger

# Установка CLI (из пакета приложения)
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger

# Импорт конфигурации иконок
iconchanger import ~/dotfiles/iconchanger/config.json
```