---
title: Kommandoreference
section: cli
locale: da
---

## Oversigt

```
iconchanger <kommando> [indstillinger]
```

## Kommandoer

### `status`

Vis aktuel konfigurationsstatus.

```bash
iconchanger status
```

Viser:
- Antal konfigurerede app-aliasser
- Antal cachede ikoner
- Hjælpescriptets status

---

### `list`

Vis alle aliasser og cachede ikoner.

```bash
iconchanger list
```

Viser en tabel over alle konfigurerede aliasser og alle cachede ikonposter.

---

### `set-icon`

Indstil et brugerdefineret ikon for en applikation.

```bash
iconchanger set-icon <app-sti> <billed-sti>
```

**Argumenter:**
- `app-sti` — Sti til applikationen (f.eks. `/Applications/Safari.app`)
- `billed-sti` — Sti til ikonbilledet (PNG, JPEG, ICNS osv.)

**Eksempler:**

```bash
# Indstil et brugerdefineret Safari-ikon
iconchanger set-icon /Applications/Safari.app ~/icons/safari.png

# Relative stier virker også
iconchanger set-icon /Applications/Slack.app ./slack-icon.icns
```

---

### `remove-icon`

Fjern et brugerdefineret ikon og gendan det originale.

```bash
iconchanger remove-icon <app-sti>
```

**Eksempel:**

```bash
iconchanger remove-icon /Applications/Safari.app
```

---

### `restore`

Gendan alle cachede brugerdefinerede ikoner. Nyttigt efter en systemopdatering eller når apps nulstiller deres ikoner.

```bash
iconchanger restore [indstillinger]
```

**Indstillinger:**
- `--dry-run` — Forhåndsvis, hvad der ville blive gendannet, uden at foretage ændringer
- `--verbose` — Vis detaljeret output for hvert ikon
- `--force` — Gendan, selvom ikonet ser uændret ud

**Eksempler:**

```bash
# Gendan alle cachede ikoner
iconchanger restore

# Forhåndsvis, hvad der ville ske
iconchanger restore --dry-run --verbose

# Tving gendannelse af alt
iconchanger restore --force
```

---

### `export`

Eksporter aliasser og cachedet ikonkonfiguration til en JSON-fil.

```bash
iconchanger export <output-sti>
```

**Eksempel:**

```bash
iconchanger export ~/Desktop/my-icons.json
```

---

### `import`

Importer en konfigurationsfil.

```bash
iconchanger import <input-sti>
```

Import tilføjer kun nye elementer — den erstatter eller fjerner aldrig eksisterende poster.

**Eksempel:**

```bash
iconchanger import ~/Desktop/my-icons.json
```

---

### `validate`

Valider en konfigurationsfil før import.

```bash
iconchanger validate <fil-sti>
```

Tjekker JSON-struktur, påkrævede felter og dataintegritet uden at foretage ændringer.

**Eksempel:**

```bash
iconchanger validate ~/Desktop/my-icons.json
```

---

### `escape-jail`

Undslip macOS Tahoes squircle jail ved at genanvende medfølgende ikoner som brugerdefinerede ikoner. Brugerdefinerede ikoner omgår squircle-tvangen og bevarer den originale ikonform.

```bash
iconchanger escape-jail [app-sti] [indstillinger]
```

**Argumenter:**
- `app-sti` — (Valgfrit) Sti til en bestemt `.app`-pakke. Hvis den udelades, behandles alle apps i `/Applications`.

**Indstillinger:**
- `--dry-run` — Forhåndsvis, hvad der ville blive gjort, uden at foretage ændringer
- `--verbose` — Vis detaljeret output

**Eksempler:**

```bash
# Undslip jail for alle apps i /Applications
iconchanger escape-jail

# Forhåndsvis, hvad der ville ske
iconchanger escape-jail --dry-run --verbose

# Undslip jail for en bestemt app
iconchanger escape-jail /Applications/Safari.app
```

::: warning
Brugerdefinerede ikoner understøtter ikke macOS Tahoes Clear-, Tinted- eller Dark-ikontilstande. De forbliver som statiske bitmaps.
:::

---

### `completions`

Generer shell-fuldførelsesscripts til tabulatorfuldførelse.

```bash
iconchanger completions <shell>
```

**Argumenter:**
- `shell` — Shell-type: `zsh`, `bash` eller `fish`

**Eksempler:**

```bash
# Zsh (tilføj til ~/.zshrc)
source <(iconchanger completions zsh)

# Bash (tilføj til ~/.bashrc)
source <(iconchanger completions bash)

# Fish
iconchanger completions fish > ~/.config/fish/completions/iconchanger.fish
```