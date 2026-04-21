---
title: Kommandoreferens
section: cli
locale: sv
---

## Översikt

```
iconchanger <kommando> [alternativ]
```

## Kommandon

### `status`

Visa aktuell konfigurationsstatus.

```bash
iconchanger status
```

Visar:
- Antal konfigurerade appalias
- Antal cachade ikoner
- Status för hjälpskriptet

---

### `list`

Lista alla alias och cachade ikoner.

```bash
iconchanger list
```

Visar en tabell över alla konfigurerade alias och alla cachade ikonposter.

---

### `set-icon`

Ange en anpassad ikon för en app.

```bash
iconchanger set-icon <app-sökväg> <bild-sökväg>
```

**Argument:**
- `app-sökväg` — Sökväg till appen (t.ex. `/Applications/Safari.app`)
- `bild-sökväg` — Sökväg till ikonbilden (PNG, JPEG, ICNS osv.)

**Exempel:**

```bash
# Ange en anpassad Safari-ikon
iconchanger set-icon /Applications/Safari.app ~/icons/safari.png

# Relativa sökvägar fungerar också
iconchanger set-icon /Applications/Slack.app ./slack-icon.icns
```

---

### `remove-icon`

Ta bort en anpassad ikon och återställ originalet.

```bash
iconchanger remove-icon <app-sökväg>
```

**Exempel:**

```bash
iconchanger remove-icon /Applications/Safari.app
```

---

### `restore`

Återställ alla cachade anpassade ikoner. Användbart efter en systemuppdatering eller när appar har återställt sina ikoner.

```bash
iconchanger restore [alternativ]
```

**Alternativ:**
- `--dry-run` — Förhandsgranska vad som skulle återställas utan att göra ändringar
- `--verbose` — Visa detaljerad utdata för varje ikon
- `--force` — Återställ även om ikonen verkar oförändrad

**Exempel:**

```bash
# Återställ alla cachade ikoner
iconchanger restore

# Förhandsgranska vad som skulle hända
iconchanger restore --dry-run --verbose

# Tvinga återställning av allt
iconchanger restore --force
```

---

### `export`

Exportera alias och cachad ikonkonfiguration till en JSON-fil.

```bash
iconchanger export <utdata-sökväg>
```

**Exempel:**

```bash
iconchanger export ~/Desktop/my-icons.json
```

---

### `import`

Importera en konfigurationsfil.

```bash
iconchanger import <indata-sökväg>
```

Import lägger bara till nya poster — den ersätter eller tar aldrig bort befintliga poster.

**Exempel:**

```bash
iconchanger import ~/Desktop/my-icons.json
```

---

### `validate`

Validera en konfigurationsfil innan import.

```bash
iconchanger validate <fil-sökväg>
```

Kontrollerar JSON-struktur, obligatoriska fält och dataintegritet utan att göra ändringar.

**Exempel:**

```bash
iconchanger validate ~/Desktop/my-icons.json
```

---

### `escape-jail`

Bryt ut ur macOS Tahoes squircle-fängelse genom att tillämpa medföljande ikoner som anpassade ikoner. Anpassade ikoner kringgår squircle-tvånget och bevarar den ursprungliga ikonformen.

```bash
iconchanger escape-jail [app-sökväg] [alternativ]
```

**Argument:**
- `app-sökväg` — (Valfritt) Sökväg till ett specifikt `.app`-paket. Om det utelämnas behandlas alla appar i `/Applications`.

**Alternativ:**
- `--dry-run` — Förhandsgranska vad som skulle göras utan att göra ändringar
- `--verbose` — Visa detaljerad utdata

**Exempel:**

```bash
# Bryt ut alla appar i /Applications ur squircle-fängelset
iconchanger escape-jail

# Förhandsgranska vad som skulle hända
iconchanger escape-jail --dry-run --verbose

# Bryt ut en specifik app
iconchanger escape-jail /Applications/Safari.app
```

::: warning
Anpassade ikoner stöder inte macOS Tahoes ikonlägen Clear, Tinted eller Dark. De förblir som statiska bitmappar.
:::

---

### `completions`

Generera skalskript för tabbkomplettering.

```bash
iconchanger completions <skal>
```

**Argument:**
- `skal` — Skaltyp: `zsh`, `bash` eller `fish`

**Exempel:**

```bash
# Zsh (lägg till i ~/.zshrc)
source <(iconchanger completions zsh)

# Bash (lägg till i ~/.bashrc)
source <(iconchanger completions bash)

# Fish
iconchanger completions fish > ~/.config/fish/completions/iconchanger.fish
```