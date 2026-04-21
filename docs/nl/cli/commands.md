---
title: Opdrachtreferentie
section: cli
locale: nl
---

## Overzicht

```
iconchanger <opdracht> [opties]
```

## Opdrachten

### `status`

Toon de huidige configuratiestatus.

```bash
iconchanger status
```

Toont:
- Aantal geconfigureerde app-aliassen
- Aantal gecachete pictogrammen
- Status van het hulpscript

---

### `list`

Toon alle aliassen en gecachete pictogrammen.

```bash
iconchanger list
```

Toont een tabel met alle geconfigureerde aliassen en alle gecachete pictogramvermeldingen.

---

### `set-icon`

Stel een aangepast pictogram in voor een app.

```bash
iconchanger set-icon <app-pad> <afbeelding-pad>
```

**Argumenten:**
- `app-pad` — Pad naar de app (bijv. `/Applications/Safari.app`)
- `afbeelding-pad` — Pad naar de pictogramafbeelding (PNG, JPEG, ICNS, etc.)

**Voorbeelden:**

```bash
# Een aangepast Safari-pictogram instellen
iconchanger set-icon /Applications/Safari.app ~/icons/safari.png

# Relatieve paden werken ook
iconchanger set-icon /Applications/Slack.app ./slack-icon.icns
```

---

### `remove-icon`

Verwijder een aangepast pictogram en herstel het origineel.

```bash
iconchanger remove-icon <app-pad>
```

**Voorbeeld:**

```bash
iconchanger remove-icon /Applications/Safari.app
```

---

### `restore`

Herstel alle gecachete aangepaste pictogrammen. Handig na een systeemupdate of wanneer apps hun pictogrammen hebben gereset.

```bash
iconchanger restore [opties]
```

**Opties:**
- `--dry-run` — Bekijk een voorbeeld van wat er zou worden hersteld zonder wijzigingen aan te brengen
- `--verbose` — Toon gedetailleerde uitvoer voor elk pictogram
- `--force` — Herstel ook als het pictogram ongewijzigd lijkt

**Voorbeelden:**

```bash
# Alle gecachete pictogrammen herstellen
iconchanger restore

# Bekijk wat er zou gebeuren
iconchanger restore --dry-run --verbose

# Geforceerd alles herstellen
iconchanger restore --force
```

---

### `export`

Exporteer aliassen en gecachete pictogramconfiguratie naar een JSON-bestand.

```bash
iconchanger export <uitvoer-pad>
```

**Voorbeeld:**

```bash
iconchanger export ~/Desktop/my-icons.json
```

---

### `import`

Importeer een configuratiebestand.

```bash
iconchanger import <invoer-pad>
```

Importeren voegt alleen nieuwe items toe — het vervangt of verwijdert nooit bestaande vermeldingen.

**Voorbeeld:**

```bash
iconchanger import ~/Desktop/my-icons.json
```

---

### `validate`

Valideer een configuratiebestand voordat je het importeert.

```bash
iconchanger validate <bestand-pad>
```

Controleert de JSON-structuur, vereiste velden en data-integriteit zonder wijzigingen aan te brengen.

**Voorbeeld:**

```bash
iconchanger validate ~/Desktop/my-icons.json
```

---

### `escape-jail`

Ontsnap aan de squircle jail van macOS Tahoe door meegeleverde pictogrammen opnieuw toe te passen als aangepaste pictogrammen. Aangepaste pictogrammen omzeilen de squircle-verplichting en behouden de originele pictogramvorm.

```bash
iconchanger escape-jail [app-pad] [opties]
```

**Argumenten:**
- `app-pad` — (Optioneel) Pad naar een specifieke `.app`-bundel. Indien weggelaten, worden alle apps in `/Applications` verwerkt.

**Opties:**
- `--dry-run` — Bekijk een voorbeeld van wat er zou worden gedaan zonder wijzigingen aan te brengen
- `--verbose` — Toon gedetailleerde uitvoer

**Voorbeelden:**

```bash
# Squircle jail ontsnappen voor alle apps in /Applications
iconchanger escape-jail

# Bekijk wat er zou gebeuren
iconchanger escape-jail --dry-run --verbose

# Squircle jail ontsnappen voor een specifieke app
iconchanger escape-jail /Applications/Safari.app
```

::: warning
Aangepaste pictogrammen ondersteunen niet de Clear-, Tinted- of Dark-pictogrammodi van macOS Tahoe. Ze blijven als statische bitmaps.
:::

---

### `completions`

Genereer shell-aanvulscripts voor tab-aanvulling.

```bash
iconchanger completions <shell>
```

**Argumenten:**
- `shell` — Shell-type: `zsh`, `bash` of `fish`

**Voorbeelden:**

```bash
# Zsh (toevoegen aan ~/.zshrc)
source <(iconchanger completions zsh)

# Bash (toevoegen aan ~/.bashrc)
source <(iconchanger completions bash)

# Fish
iconchanger completions fish > ~/.config/fish/completions/iconchanger.fish
```