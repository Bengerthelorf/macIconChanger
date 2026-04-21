---
title: Befehlsreferenz
section: cli
locale: de
---

## Übersicht

```
iconchanger <command> [options]
```

## Befehle

### `status`

Aktuellen Konfigurationsstatus anzeigen.

```bash
iconchanger status
```

Zeigt an:
- Anzahl der konfigurierten App-Aliasse
- Anzahl der zwischengespeicherten Symbole
- Status des Hilfsskripts

---

### `list`

Alle Aliasse und zwischengespeicherten Symbole auflisten.

```bash
iconchanger list
```

Zeigt eine Tabelle aller konfigurierten Aliasse und aller zwischengespeicherten Symboleinträge.

---

### `set-icon`

Ein benutzerdefiniertes Symbol für eine Anwendung festlegen.

```bash
iconchanger set-icon <app-path> <image-path>
```

**Argumente:**
- `app-path` — Pfad zur Anwendung (z. B. `/Applications/Safari.app`)
- `image-path` — Pfad zum Symbolbild (PNG, JPEG, ICNS usw.)

**Beispiele:**

```bash
# Benutzerdefiniertes Safari-Symbol festlegen
iconchanger set-icon /Applications/Safari.app ~/icons/safari.png

# Relative Pfade funktionieren ebenfalls
iconchanger set-icon /Applications/Slack.app ./slack-icon.icns
```

---

### `remove-icon`

Ein benutzerdefiniertes Symbol entfernen und das Original wiederherstellen.

```bash
iconchanger remove-icon <app-path>
```

**Beispiel:**

```bash
iconchanger remove-icon /Applications/Safari.app
```

---

### `restore`

Alle zwischengespeicherten benutzerdefinierten Symbole wiederherstellen. Nützlich nach einem Systemupdate oder wenn Apps ihre Symbole zurückgesetzt haben.

```bash
iconchanger restore [options]
```

**Optionen:**
- `--dry-run` — Vorschau der Wiederherstellung ohne Änderungen vorzunehmen
- `--verbose` — Detaillierte Ausgabe für jedes Symbol anzeigen
- `--force` — Auch wiederherstellen, wenn das Symbol unverändert erscheint

**Beispiele:**

```bash
# Alle zwischengespeicherten Symbole wiederherstellen
iconchanger restore

# Vorschau anzeigen
iconchanger restore --dry-run --verbose

# Alles erzwungen wiederherstellen
iconchanger restore --force
```

---

### `export`

Aliasse und zwischengespeicherte Symbol-Konfiguration in eine JSON-Datei exportieren.

```bash
iconchanger export <output-path>
```

**Beispiel:**

```bash
iconchanger export ~/Desktop/my-icons.json
```

---

### `import`

Eine Konfigurationsdatei importieren.

```bash
iconchanger import <input-path>
```

Der Import fügt nur neue Einträge hinzu — er ersetzt oder entfernt niemals bestehende Einträge.

**Beispiel:**

```bash
iconchanger import ~/Desktop/my-icons.json
```

---

### `validate`

Eine Konfigurationsdatei vor dem Import validieren.

```bash
iconchanger validate <file-path>
```

Überprüft die JSON-Struktur, erforderliche Felder und Datenintegrität, ohne Änderungen vorzunehmen.

**Beispiel:**

```bash
iconchanger validate ~/Desktop/my-icons.json
```

---

### `escape-jail`

Den Squircle-Zwang von macOS Tahoe aufheben, indem mitgelieferte Symbole als benutzerdefinierte Symbole neu angewendet werden. Benutzerdefinierte Symbole umgehen die Squircle-Erzwingung und bewahren die ursprüngliche Symbolform.

```bash
iconchanger escape-jail [app-path] [options]
```

**Argumente:**
- `app-path` — (Optional) Pfad zu einem bestimmten `.app`-Bundle. Wird dieser weggelassen, werden alle Apps in `/Applications` verarbeitet.

**Optionen:**
- `--dry-run` — Vorschau ohne Änderungen vorzunehmen
- `--verbose` — Detaillierte Ausgabe anzeigen

**Beispiele:**

```bash
# Squircle-Zwang für alle Apps in /Applications aufheben
iconchanger escape-jail

# Vorschau anzeigen
iconchanger escape-jail --dry-run --verbose

# Squircle-Zwang für eine bestimmte App aufheben
iconchanger escape-jail /Applications/Safari.app
```

::: warning
Benutzerdefinierte Symbole unterstützen nicht die Modi Clear, Tinted oder Dark von macOS Tahoe. Sie bleiben als statische Bitmaps erhalten.
:::

---

### `completions`

Shell-Vervollständigungsskripte für Tab-Vervollständigung generieren.

```bash
iconchanger completions <shell>
```

**Argumente:**
- `shell` — Shell-Typ: `zsh`, `bash` oder `fish`

**Beispiele:**

```bash
# Zsh (in ~/.zshrc einfügen)
source <(iconchanger completions zsh)

# Bash (in ~/.bashrc einfügen)
source <(iconchanger completions bash)

# Fish
iconchanger completions fish > ~/.config/fish/completions/iconchanger.fish
```