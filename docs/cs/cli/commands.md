---
title: Reference příkazů
section: cli
locale: cs
---

## Přehled

```
iconchanger <příkaz> [možnosti]
```

## Příkazy

### `status`

Zobrazí aktuální stav konfigurace.

```bash
iconchanger status
```

Zobrazí:
- Počet nakonfigurovaných aliasů aplikací
- Počet ikon v mezipaměti
- Stav pomocného skriptu

---

### `list`

Vypíše všechny aliasy a ikony v mezipaměti.

```bash
iconchanger list
```

Zobrazí tabulku se všemi nakonfigurovanými aliasy a všemi záznamy ikon v mezipaměti.

---

### `set-icon`

Nastaví vlastní ikonu pro aplikaci.

```bash
iconchanger set-icon <cesta-k-aplikaci> <cesta-k-obrázku>
```

**Argumenty:**
- `cesta-k-aplikaci` — Cesta k aplikaci (např. `/Applications/Safari.app`)
- `cesta-k-obrázku` — Cesta k souboru s ikonou (PNG, JPEG, ICNS atd.)

**Příklady:**

```bash
# Nastavení vlastní ikony pro Safari
iconchanger set-icon /Applications/Safari.app ~/icons/safari.png

# Fungují i relativní cesty
iconchanger set-icon /Applications/Slack.app ./slack-icon.icns
```

---

### `remove-icon`

Odstraní vlastní ikonu a obnoví původní.

```bash
iconchanger remove-icon <cesta-k-aplikaci>
```

**Příklad:**

```bash
iconchanger remove-icon /Applications/Safari.app
```

---

### `restore`

Obnoví všechny vlastní ikony z mezipaměti. Užitečné po aktualizaci systému nebo když si aplikace resetují své ikony.

```bash
iconchanger restore [možnosti]
```

**Možnosti:**
- `--dry-run` — Náhled toho, co by bylo obnoveno, bez provádění změn
- `--verbose` — Podrobný výstup pro každou ikonu
- `--force` — Obnovit i v případě, že se ikona zdá nezměněná

**Příklady:**

```bash
# Obnovení všech ikon z mezipaměti
iconchanger restore

# Náhled toho, co by se stalo
iconchanger restore --dry-run --verbose

# Vynucená obnova všeho
iconchanger restore --force
```

---

### `export`

Exportuje aliasy a konfiguraci ikon z mezipaměti do souboru JSON.

```bash
iconchanger export <výstupní-cesta>
```

**Příklad:**

```bash
iconchanger export ~/Desktop/my-icons.json
```

---

### `import`

Importuje konfigurační soubor.

```bash
iconchanger import <vstupní-cesta>
```

Import pouze přidává nové položky — nikdy nenahrazuje ani neodstraňuje stávající záznamy.

**Příklad:**

```bash
iconchanger import ~/Desktop/my-icons.json
```

---

### `validate`

Ověří konfigurační soubor před importem.

```bash
iconchanger validate <cesta-k-souboru>
```

Zkontroluje strukturu JSON, povinná pole a integritu dat bez provádění změn.

**Příklad:**

```bash
iconchanger validate ~/Desktop/my-icons.json
```

---

### `escape-jail`

Útěk ze squircle vězení macOS Tahoe opětovným aplikováním přibalených ikon jako vlastních ikon. Vlastní ikony obcházejí vynucování tvaru squircle a zachovávají původní tvar ikony.

```bash
iconchanger escape-jail [cesta-k-aplikaci] [možnosti]
```

**Argumenty:**
- `cesta-k-aplikaci` — (Volitelné) Cesta ke konkrétnímu balíčku `.app`. Pokud je vynecháno, zpracují se všechny aplikace v `/Applications`.

**Možnosti:**
- `--dry-run` — Náhled toho, co by se provedlo, bez provádění změn
- `--verbose` — Podrobný výstup

**Příklady:**

```bash
# Útěk z vězení pro všechny aplikace v /Applications
iconchanger escape-jail

# Náhled toho, co by se stalo
iconchanger escape-jail --dry-run --verbose

# Útěk z vězení pro konkrétní aplikaci
iconchanger escape-jail /Applications/Safari.app
```

::: warning
Vlastní ikony nepodporují režimy Clear, Tinted ani Dark ikon v macOS Tahoe. Zůstávají jako statické bitmapy.
:::

---

### `completions`

Generuje skripty pro automatické doplňování v shellu.

```bash
iconchanger completions <shell>
```

**Argumenty:**
- `shell` — Typ shellu: `zsh`, `bash` nebo `fish`

**Příklady:**

```bash
# Zsh (přidejte do ~/.zshrc)
source <(iconchanger completions zsh)

# Bash (přidejte do ~/.bashrc)
source <(iconchanger completions bash)

# Fish
iconchanger completions fish > ~/.config/fish/completions/iconchanger.fish
```