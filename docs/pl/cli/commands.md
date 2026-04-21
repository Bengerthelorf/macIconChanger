---
title: Referencja poleceń
section: cli
locale: pl
---

## Przegląd

```
iconchanger <polecenie> [opcje]
```

## Polecenia

### `status`

Wyświetl aktualny status konfiguracji.

```bash
iconchanger status
```

Wyświetla:
- Liczbę skonfigurowanych aliasów aplikacji
- Liczbę zapisanych ikon
- Status skryptu pomocniczego

---

### `list`

Wyświetl listę wszystkich aliasów i zapisanych ikon.

```bash
iconchanger list
```

Pokazuje tabelę wszystkich skonfigurowanych aliasów i wszystkich wpisów zapisanych ikon.

---

### `set-icon`

Ustaw niestandardową ikonę dla aplikacji.

```bash
iconchanger set-icon <ścieżka-aplikacji> <ścieżka-obrazu>
```

**Argumenty:**
- `ścieżka-aplikacji` — Ścieżka do aplikacji (np. `/Applications/Safari.app`)
- `ścieżka-obrazu` — Ścieżka do pliku ikony (PNG, JPEG, ICNS itp.)

**Przykłady:**

```bash
# Ustaw niestandardową ikonę Safari
iconchanger set-icon /Applications/Safari.app ~/icons/safari.png

# Ścieżki względne również działają
iconchanger set-icon /Applications/Slack.app ./slack-icon.icns
```

---

### `remove-icon`

Usuń niestandardową ikonę i przywróć oryginalną.

```bash
iconchanger remove-icon <ścieżka-aplikacji>
```

**Przykład:**

```bash
iconchanger remove-icon /Applications/Safari.app
```

---

### `restore`

Przywróć wszystkie zapisane niestandardowe ikony. Przydatne po aktualizacji systemu lub gdy aplikacje resetują swoje ikony.

```bash
iconchanger restore [opcje]
```

**Opcje:**
- `--dry-run` — Podgląd tego, co zostałoby przywrócone, bez wprowadzania zmian
- `--verbose` — Pokaż szczegółowe dane wyjściowe dla każdej ikony
- `--force` — Przywróć nawet jeśli ikona wydaje się niezmieniona

**Przykłady:**

```bash
# Przywróć wszystkie zapisane ikony
iconchanger restore

# Podgląd tego, co się stanie
iconchanger restore --dry-run --verbose

# Wymuś przywrócenie wszystkiego
iconchanger restore --force
```

---

### `export`

Eksportuj aliasy i konfigurację zapisanych ikon do pliku JSON.

```bash
iconchanger export <ścieżka-wyjściowa>
```

**Przykład:**

```bash
iconchanger export ~/Desktop/my-icons.json
```

---

### `import`

Importuj plik konfiguracyjny.

```bash
iconchanger import <ścieżka-wejściowa>
```

Import jedynie dodaje nowe elementy — nigdy nie zastępuje ani nie usuwa istniejących wpisów.

**Przykład:**

```bash
iconchanger import ~/Desktop/my-icons.json
```

---

### `validate`

Zwaliduj plik konfiguracyjny przed importem.

```bash
iconchanger validate <ścieżka-pliku>
```

Sprawdza strukturę JSON, wymagane pola i integralność danych bez wprowadzania zmian.

**Przykład:**

```bash
iconchanger validate ~/Desktop/my-icons.json
```

---

### `escape-jail`

Ucieknij z więzienia squircle macOS Tahoe, ponownie stosując wbudowane ikony jako ikony niestandardowe. Ikony niestandardowe omijają wymuszanie squircle, zachowując oryginalny kształt ikony.

```bash
iconchanger escape-jail [ścieżka-aplikacji] [opcje]
```

**Argumenty:**
- `ścieżka-aplikacji` — (Opcjonalnie) Ścieżka do konkretnego pakietu `.app`. Jeśli pominięta, przetwarza wszystkie aplikacje w `/Applications`.

**Opcje:**
- `--dry-run` — Podgląd tego, co zostałoby zrobione, bez wprowadzania zmian
- `--verbose` — Pokaż szczegółowe dane wyjściowe

**Przykłady:**

```bash
# Ucieknij z więzienia dla wszystkich aplikacji w /Applications
iconchanger escape-jail

# Podgląd tego, co się stanie
iconchanger escape-jail --dry-run --verbose

# Ucieknij z więzienia dla konkretnej aplikacji
iconchanger escape-jail /Applications/Safari.app
```

::: warning
Ikony niestandardowe nie obsługują trybów ikon Clear, Tinted ani Dark w macOS Tahoe. Pozostają jako statyczne bitmapy.
:::

---

### `completions`

Generuj skrypty uzupełniania powłoki dla uzupełniania tabulatorem.

```bash
iconchanger completions <powłoka>
```

**Argumenty:**
- `powłoka` — Typ powłoki: `zsh`, `bash` lub `fish`

**Przykłady:**

```bash
# Zsh (dodaj do ~/.zshrc)
source <(iconchanger completions zsh)

# Bash (dodaj do ~/.bashrc)
source <(iconchanger completions bash)

# Fish
iconchanger completions fish > ~/.config/fish/completions/iconchanger.fish
```