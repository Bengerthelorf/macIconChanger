---
title: Імпорт та експорт
section: guide
order: 8
locale: uk
---

Створюйте резервні копії конфігурацій іконок або переносіть їх на інший Mac.

## Що експортується

Файл експорту (JSON) містить:
- **Псевдоніми програм** — ваші власні зв'язки пошукових назв
- **Посилання на кешовані іконки** — які програми мають власні іконки та файли кешованих іконок

## Експорт

### Через графічний інтерфейс

Перейдіть до **Settings** > **Advanced** > **Configuration** та натисніть **Export**.

### Через CLI

```bash
iconchanger export ~/Desktop/my-icons.json
```

## Імпорт

### Через графічний інтерфейс

Перейдіть до **Settings** > **Advanced** > **Configuration** та натисніть **Import**.

### Через CLI

```bash
iconchanger import ~/Desktop/my-icons.json
```

::: tip
Імпорт лише **додає** нові елементи. Він ніколи не замінює та не видаляє ваші наявні псевдоніми або кешовані іконки.
:::

## Валідація

Перед імпортом ви можете перевірити файл конфігурації:

```bash
iconchanger validate ~/Desktop/my-icons.json
```

Це перевіряє структуру файлу без внесення будь-яких змін.

## Автоматизація з dotfiles

Ви можете автоматизувати налаштування IconChanger як частину ваших dotfiles:

```bash
#!/bin/bash
DMG_URL="https://github.com/Bengerthelorf/macIconChanger/releases/latest/download/IconChanger.dmg"
DMG_PATH="/tmp/IconChanger.dmg"

# Встановлення програми
curl -L "$DMG_URL" -o "$DMG_PATH"
hdiutil attach "$DMG_PATH" -mountpoint /Volumes/IconChanger
cp -R /Volumes/IconChanger/IconChanger.app /Applications/
hdiutil detach /Volumes/IconChanger

# Встановлення CLI (з пакету програми)
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger

# Імпорт конфігурації іконок
iconchanger import ~/dotfiles/iconchanger/config.json
```