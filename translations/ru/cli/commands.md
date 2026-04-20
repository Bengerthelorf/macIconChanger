# Справочник по командам

## Обзор

```
iconchanger <command> [options]
```

## Команды

### `status`

Показать текущее состояние конфигурации.

```bash
iconchanger status
```

Отображает:
- Количество настроенных псевдонимов приложений
- Количество кэшированных иконок
- Статус вспомогательного скрипта

---

### `list`

Вывести список всех псевдонимов и кэшированных иконок.

```bash
iconchanger list
```

Показывает таблицу всех настроенных псевдонимов и всех записей кэшированных иконок.

---

### `set-icon`

Установить пользовательскую иконку для приложения.

```bash
iconchanger set-icon <app-path> <image-path>
```

**Аргументы:**
- `app-path` — путь к приложению (например, `/Applications/Safari.app`)
- `image-path` — путь к файлу иконки (PNG, JPEG, ICNS и т.д.)

**Примеры:**

```bash
# Установить пользовательскую иконку для Safari
iconchanger set-icon /Applications/Safari.app ~/icons/safari.png

# Относительные пути тоже работают
iconchanger set-icon /Applications/Slack.app ./slack-icon.icns
```

---

### `remove-icon`

Удалить пользовательскую иконку и восстановить оригинальную.

```bash
iconchanger remove-icon <app-path>
```

**Пример:**

```bash
iconchanger remove-icon /Applications/Safari.app
```

---

### `restore`

Восстановить все кэшированные пользовательские иконки. Полезно после обновления системы или когда приложения сбрасывают свои иконки.

```bash
iconchanger restore [options]
```

**Параметры:**
- `--dry-run` — предварительный просмотр того, что будет восстановлено, без внесения изменений
- `--verbose` — подробный вывод для каждой иконки
- `--force` — восстановить даже если иконка не изменилась

**Примеры:**

```bash
# Восстановить все кэшированные иконки
iconchanger restore

# Предварительный просмотр
iconchanger restore --dry-run --verbose

# Принудительное восстановление всех иконок
iconchanger restore --force
```

---

### `export`

Экспортировать псевдонимы и конфигурацию кэшированных иконок в файл JSON.

```bash
iconchanger export <output-path>
```

**Пример:**

```bash
iconchanger export ~/Desktop/my-icons.json
```

---

### `import`

Импортировать файл конфигурации.

```bash
iconchanger import <input-path>
```

Импорт только добавляет новые элементы — он никогда не заменяет и не удаляет существующие записи.

**Пример:**

```bash
iconchanger import ~/Desktop/my-icons.json
```

---

### `validate`

Проверить файл конфигурации перед импортом.

```bash
iconchanger validate <file-path>
```

Проверяет структуру JSON, обязательные поля и целостность данных без внесения изменений.

**Пример:**

```bash
iconchanger validate ~/Desktop/my-icons.json
```

---

### `escape-jail`

Выйти из squircle jail в macOS Tahoe путём повторного применения встроенных иконок как пользовательских. Пользовательские иконки обходят принудительное применение формы сквиркла, сохраняя оригинальную форму иконки.

```bash
iconchanger escape-jail [app-path] [options]
```

**Аргументы:**
- `app-path` — (необязательно) путь к конкретному пакету `.app`. Если не указан, обрабатываются все приложения в `/Applications`.

**Параметры:**
- `--dry-run` — предварительный просмотр без внесения изменений
- `--verbose` — подробный вывод

**Примеры:**

```bash
# Выйти из squircle jail для всех приложений в /Applications
iconchanger escape-jail

# Предварительный просмотр
iconchanger escape-jail --dry-run --verbose

# Выйти из squircle jail для конкретного приложения
iconchanger escape-jail /Applications/Safari.app
```

::: warning
Пользовательские иконки не поддерживают режимы иконок Clear, Tinted и Dark в macOS Tahoe. Они остаются статичными растровыми изображениями.
:::

---

### `completions`

Сгенерировать скрипты автодополнения для оболочки.

```bash
iconchanger completions <shell>
```

**Аргументы:**
- `shell` — тип оболочки: `zsh`, `bash` или `fish`

**Примеры:**

```bash
# Zsh (добавьте в ~/.zshrc)
source <(iconchanger completions zsh)

# Bash (добавьте в ~/.bashrc)
source <(iconchanger completions bash)

# Fish
iconchanger completions fish > ~/.config/fish/completions/iconchanger.fish
```
