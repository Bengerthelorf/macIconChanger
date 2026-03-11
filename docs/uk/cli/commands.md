# Довідник команд

## Огляд

```
iconchanger <command> [options]
```

## Команди

### `status`

Показати поточний стан конфігурації.

```bash
iconchanger status
```

Відображає:
- Кількість налаштованих псевдонімів програм
- Кількість кешованих іконок
- Стан допоміжного скрипта

---

### `list`

Показати всі псевдоніми та кешовані іконки.

```bash
iconchanger list
```

Відображає таблицю всіх налаштованих псевдонімів та всіх записів кешованих іконок.

---

### `set-icon`

Встановити власну іконку для програми.

```bash
iconchanger set-icon <app-path> <image-path>
```

**Аргументи:**
- `app-path` — Шлях до програми (наприклад, `/Applications/Safari.app`)
- `image-path` — Шлях до зображення іконки (PNG, JPEG, ICNS тощо)

**Приклади:**

```bash
# Встановити власну іконку Safari
iconchanger set-icon /Applications/Safari.app ~/icons/safari.png

# Відносні шляхи також працюють
iconchanger set-icon /Applications/Slack.app ./slack-icon.icns
```

---

### `remove-icon`

Видалити власну іконку та відновити оригінальну.

```bash
iconchanger remove-icon <app-path>
```

**Приклад:**

```bash
iconchanger remove-icon /Applications/Safari.app
```

---

### `restore`

Відновити всі кешовані власні іконки. Корисно після оновлення системи або коли програми скидають свої іконки.

```bash
iconchanger restore [options]
```

**Параметри:**
- `--dry-run` — Попередній перегляд того, що буде відновлено, без внесення змін
- `--verbose` — Показати детальний вивід для кожної іконки
- `--force` — Відновити навіть якщо іконка виглядає незміненою

**Приклади:**

```bash
# Відновити всі кешовані іконки
iconchanger restore

# Попередній перегляд дій
iconchanger restore --dry-run --verbose

# Примусове відновлення всього
iconchanger restore --force
```

---

### `export`

Експортувати псевдоніми та конфігурацію кешованих іконок у JSON-файл.

```bash
iconchanger export <output-path>
```

**Приклад:**

```bash
iconchanger export ~/Desktop/my-icons.json
```

---

### `import`

Імпортувати файл конфігурації.

```bash
iconchanger import <input-path>
```

Імпорт лише додає нові елементи — він ніколи не замінює та не видаляє наявні записи.

**Приклад:**

```bash
iconchanger import ~/Desktop/my-icons.json
```

---

### `validate`

Перевірити файл конфігурації перед імпортом.

```bash
iconchanger validate <file-path>
```

Перевіряє структуру JSON, обов'язкові поля та цілісність даних без внесення змін.

**Приклад:**

```bash
iconchanger validate ~/Desktop/my-icons.json
```

---

### `escape-jail`

Вийти зі скверкл-в'язниці macOS Tahoe, повторно застосувавши вбудовані іконки як власні. Власні іконки обходять примусове застосування скверклів, зберігаючи оригінальну форму іконки.

```bash
iconchanger escape-jail [app-path] [options]
```

**Аргументи:**
- `app-path` — (Необов'язково) Шлях до конкретного пакету `.app`. Якщо не вказано, обробляє всі програми в `/Applications`.

**Параметри:**
- `--dry-run` — Попередній перегляд дій без внесення змін
- `--verbose` — Показати детальний вивід

**Приклади:**

```bash
# Вийти з в'язниці для всіх програм в /Applications
iconchanger escape-jail

# Попередній перегляд дій
iconchanger escape-jail --dry-run --verbose

# Вийти з в'язниці для конкретної програми
iconchanger escape-jail /Applications/Safari.app
```

::: warning
Власні іконки не підтримують режими Clear, Tinted або Dark іконок macOS Tahoe. Вони залишаються статичними растровими зображеннями.
:::

---

### `completions`

Згенерувати скрипти автодоповнення оболонки для tab-завершення.

```bash
iconchanger completions <shell>
```

**Аргументи:**
- `shell` — Тип оболонки: `zsh`, `bash` або `fish`

**Приклади:**

```bash
# Zsh (додайте до ~/.zshrc)
source <(iconchanger completions zsh)

# Bash (додайте до ~/.bashrc)
source <(iconchanger completions bash)

# Fish
iconchanger completions fish > ~/.config/fish/completions/iconchanger.fish
```
