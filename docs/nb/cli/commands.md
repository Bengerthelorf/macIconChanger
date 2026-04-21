---
title: Kommandoreferanse
section: cli
locale: nb
---

## Oversikt

```
iconchanger <kommando> [alternativer]
```

## Kommandoer

### `status`

Vis gjeldende konfigurasjonsstatus.

```bash
iconchanger status
```

Viser:
- Antall konfigurerte app-aliaser
- Antall bufrede ikoner
- Status for hjelpeskriptet

---

### `list`

List alle aliaser og bufrede ikoner.

```bash
iconchanger list
```

Viser en tabell over alle konfigurerte aliaser og alle bufrede ikonoppføringer.

---

### `set-icon`

Sett et egendefinert ikon for en applikasjon.

```bash
iconchanger set-icon <app-sti> <bilde-sti>
```

**Argumenter:**
- `app-sti` -- Sti til applikasjonen (f.eks. `/Applications/Safari.app`)
- `bilde-sti` -- Sti til ikonbildet (PNG, JPEG, ICNS, osv.)

**Eksempler:**

```bash
# Sett et egendefinert Safari-ikon
iconchanger set-icon /Applications/Safari.app ~/icons/safari.png

# Relative stier fungerer også
iconchanger set-icon /Applications/Slack.app ./slack-icon.icns
```

---

### `remove-icon`

Fjern et egendefinert ikon og gjenopprett originalen.

```bash
iconchanger remove-icon <app-sti>
```

**Eksempel:**

```bash
iconchanger remove-icon /Applications/Safari.app
```

---

### `restore`

Gjenopprett alle bufrede egendefinerte ikoner. Nyttig etter en systemoppdatering eller når apper tilbakestiller ikonene sine.

```bash
iconchanger restore [alternativer]
```

**Alternativer:**
- `--dry-run` -- Forhåndsvis hva som ville bli gjenopprettet uten å gjøre endringer
- `--verbose` -- Vis detaljert utdata for hvert ikon
- `--force` -- Gjenopprett selv om ikonet ser ut til å være uendret

**Eksempler:**

```bash
# Gjenopprett alle bufrede ikoner
iconchanger restore

# Forhåndsvis hva som ville skje
iconchanger restore --dry-run --verbose

# Tving gjenoppretting av alt
iconchanger restore --force
```

---

### `export`

Eksporter aliaser og bufret ikonkonfigurasjon til en JSON-fil.

```bash
iconchanger export <utdata-sti>
```

**Eksempel:**

```bash
iconchanger export ~/Desktop/my-icons.json
```

---

### `import`

Importer en konfigurasjonsfil.

```bash
iconchanger import <inndata-sti>
```

Import legger kun til nye elementer -- den erstatter eller fjerner aldri eksisterende oppføringer.

**Eksempel:**

```bash
iconchanger import ~/Desktop/my-icons.json
```

---

### `validate`

Valider en konfigurasjonsfil før import.

```bash
iconchanger validate <fil-sti>
```

Sjekker JSON-struktur, påkrevde felter og dataintegritet uten å gjøre endringer.

**Eksempel:**

```bash
iconchanger validate ~/Desktop/my-icons.json
```

---

### `escape-jail`

Unnslippe macOS Tahoe sin squircle jail ved å bruke medfølgende ikoner som egendefinerte ikoner. Egendefinerte ikoner omgår squircle-tvangen og bevarer den opprinnelige ikonformen.

```bash
iconchanger escape-jail [app-sti] [alternativer]
```

**Argumenter:**
- `app-sti` -- (Valgfritt) Sti til en spesifikk `.app`-pakke. Hvis utelatt, behandles alle apper i `/Applications`.

**Alternativer:**
- `--dry-run` -- Forhåndsvis hva som ville bli gjort uten å gjøre endringer
- `--verbose` -- Vis detaljert utdata

**Eksempler:**

```bash
# Unnslippe jail for alle apper i /Applications
iconchanger escape-jail

# Forhåndsvis hva som ville skje
iconchanger escape-jail --dry-run --verbose

# Unnslippe jail for en spesifikk app
iconchanger escape-jail /Applications/Safari.app
```

::: warning
Egendefinerte ikoner støtter ikke macOS Tahoe sine Clear-, Tinted- eller Dark-ikonmoduser. De forblir som statiske punktgrafikk.
:::

---

### `completions`

Generer skallkompletteringsskript for tabulatorfullføring.

```bash
iconchanger completions <skall>
```

**Argumenter:**
- `skall` -- Skalltype: `zsh`, `bash` eller `fish`

**Eksempler:**

```bash
# Zsh (legg til i ~/.zshrc)
source <(iconchanger completions zsh)

# Bash (legg til i ~/.bashrc)
source <(iconchanger completions bash)

# Fish
iconchanger completions fish > ~/.config/fish/completions/iconchanger.fish
```