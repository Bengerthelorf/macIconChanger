# Riferimento dei comandi

## Panoramica

```
iconchanger <comando> [opzioni]
```

## Comandi

### `status`

Mostra lo stato della configurazione corrente.

```bash
iconchanger status
```

Visualizza:
- Numero di alias delle app configurati
- Numero di icone nella cache
- Stato dello script helper

---

### `list`

Elenca tutti gli alias e le icone nella cache.

```bash
iconchanger list
```

Mostra una tabella di tutti gli alias configurati e di tutte le voci delle icone nella cache.

---

### `set-icon`

Imposta un'icona personalizzata per un'applicazione.

```bash
iconchanger set-icon <percorso-app> <percorso-immagine>
```

**Argomenti:**
- `percorso-app` — Percorso dell'applicazione (ad es. `/Applications/Safari.app`)
- `percorso-immagine` — Percorso del file immagine dell'icona (PNG, JPEG, ICNS, ecc.)

**Esempi:**

```bash
# Impostare un'icona personalizzata per Safari
iconchanger set-icon /Applications/Safari.app ~/icons/safari.png

# Funzionano anche i percorsi relativi
iconchanger set-icon /Applications/Slack.app ./slack-icon.icns
```

---

### `remove-icon`

Rimuove un'icona personalizzata e ripristina quella originale.

```bash
iconchanger remove-icon <percorso-app>
```

**Esempio:**

```bash
iconchanger remove-icon /Applications/Safari.app
```

---

### `restore`

Ripristina tutte le icone personalizzate nella cache. Utile dopo un aggiornamento del sistema o quando le app ripristinano le proprie icone.

```bash
iconchanger restore [opzioni]
```

**Opzioni:**
- `--dry-run` — Anteprima di ciò che verrebbe ripristinato senza apportare modifiche
- `--verbose` — Mostra un output dettagliato per ogni icona
- `--force` — Ripristina anche se l'icona sembra invariata

**Esempi:**

```bash
# Ripristinare tutte le icone nella cache
iconchanger restore

# Anteprima di ciò che accadrebbe
iconchanger restore --dry-run --verbose

# Forzare il ripristino di tutto
iconchanger restore --force
```

---

### `export`

Esporta gli alias e la configurazione delle icone nella cache in un file JSON.

```bash
iconchanger export <percorso-output>
```

**Esempio:**

```bash
iconchanger export ~/Desktop/my-icons.json
```

---

### `import`

Importa un file di configurazione.

```bash
iconchanger import <percorso-input>
```

L'importazione aggiunge solo nuovi elementi — non sostituisce né rimuove mai le voci esistenti.

**Esempio:**

```bash
iconchanger import ~/Desktop/my-icons.json
```

---

### `validate`

Valida un file di configurazione prima dell'importazione.

```bash
iconchanger validate <percorso-file>
```

Verifica la struttura JSON, i campi obbligatori e l'integrità dei dati senza apportare modifiche.

**Esempio:**

```bash
iconchanger validate ~/Desktop/my-icons.json
```

---

### `escape-jail`

Evade dallo squircle jail di macOS Tahoe riapplicando le icone incluse nelle app come icone personalizzate. Le icone personalizzate aggirano l'imposizione dello squircle, preservando la forma originale dell'icona.

```bash
iconchanger escape-jail [percorso-app] [opzioni]
```

**Argomenti:**
- `percorso-app` — (Facoltativo) Percorso di uno specifico bundle `.app`. Se omesso, elabora tutte le app in `/Applications`.

**Opzioni:**
- `--dry-run` — Anteprima di ciò che verrebbe fatto senza apportare modifiche
- `--verbose` — Mostra un output dettagliato

**Esempi:**

```bash
# Evadere dallo jail per tutte le app in /Applications
iconchanger escape-jail

# Anteprima di ciò che accadrebbe
iconchanger escape-jail --dry-run --verbose

# Evadere dallo jail per una specifica app
iconchanger escape-jail /Applications/Safari.app
```

::: warning
Le icone personalizzate non supportano le modalità Clear, Tinted o Dark delle icone di macOS Tahoe. Rimangono come bitmap statiche.
:::

---

### `completions`

Genera script di completamento per la shell per il completamento con il tasto Tab.

```bash
iconchanger completions <shell>
```

**Argomenti:**
- `shell` — Tipo di shell: `zsh`, `bash` o `fish`

**Esempi:**

```bash
# Zsh (aggiungere a ~/.zshrc)
source <(iconchanger completions zsh)

# Bash (aggiungere a ~/.bashrc)
source <(iconchanger completions bash)

# Fish
iconchanger completions fish > ~/.config/fish/completions/iconchanger.fish
```
