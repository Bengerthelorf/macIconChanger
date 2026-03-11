# Referinta comenzilor

## Prezentare generala

```
iconchanger <comanda> [optiuni]
```

## Comenzi

### `status`

Afiseaza starea curenta a configurarii.

```bash
iconchanger status
```

Afiseaza:
- Numarul de aliasuri configurate pentru aplicatii
- Numarul de pictograme din cache
- Starea scriptului ajutator

---

### `list`

Listeaza toate aliasurile si pictogramele din cache.

```bash
iconchanger list
```

Afiseaza un tabel cu toate aliasurile configurate si toate intrarile de pictograme din cache.

---

### `set-icon`

Seteaza o pictograma personalizata pentru o aplicatie.

```bash
iconchanger set-icon <cale-aplicatie> <cale-imagine>
```

**Argumente:**
- `cale-aplicatie` — Calea catre aplicatie (de ex., `/Applications/Safari.app`)
- `cale-imagine` — Calea catre imaginea pictogramei (PNG, JPEG, ICNS, etc.)

**Exemple:**

```bash
# Seteaza o pictograma personalizata pentru Safari
iconchanger set-icon /Applications/Safari.app ~/icons/safari.png

# Caile relative functioneaza de asemenea
iconchanger set-icon /Applications/Slack.app ./slack-icon.icns
```

---

### `remove-icon`

Elimina o pictograma personalizata si restaureaza pictograma originala.

```bash
iconchanger remove-icon <cale-aplicatie>
```

**Exemplu:**

```bash
iconchanger remove-icon /Applications/Safari.app
```

---

### `restore`

Restaureaza toate pictogramele personalizate din cache. Util dupa o actualizare de sistem sau cand aplicatiile isi reseteaza pictogramele.

```bash
iconchanger restore [optiuni]
```

**Optiuni:**
- `--dry-run` — Previzualizeaza ce ar fi restaurat fara a face modificari
- `--verbose` — Afiseaza informatii detaliate pentru fiecare pictograma
- `--force` — Restaureaza chiar daca pictograma pare neschimbata

**Exemple:**

```bash
# Restaureaza toate pictogramele din cache
iconchanger restore

# Previzualizeaza ce s-ar intampla
iconchanger restore --dry-run --verbose

# Forteaza restaurarea tuturor
iconchanger restore --force
```

---

### `export`

Exporta aliasurile si configuratia pictogramelor din cache intr-un fisier JSON.

```bash
iconchanger export <cale-fisier-iesire>
```

**Exemplu:**

```bash
iconchanger export ~/Desktop/my-icons.json
```

---

### `import`

Importa un fisier de configurare.

```bash
iconchanger import <cale-fisier-intrare>
```

Importul doar adauga elemente noi — nu inlocuieste si nu sterge intrarile existente.

**Exemplu:**

```bash
iconchanger import ~/Desktop/my-icons.json
```

---

### `validate`

Valideaza un fisier de configurare inainte de import.

```bash
iconchanger validate <cale-fisier>
```

Verifica structura JSON, campurile obligatorii si integritatea datelor fara a face modificari.

**Exemplu:**

```bash
iconchanger validate ~/Desktop/my-icons.json
```

---

### `escape-jail`

Elibereaza aplicatiile din captivitatea squircle din macOS Tahoe reaplicand pictogramele incluse ca pictograme personalizate. Pictogramele personalizate ocolesc impunerea formei squircle, pastrand forma originala a pictogramei.

```bash
iconchanger escape-jail [cale-aplicatie] [optiuni]
```

**Argumente:**
- `cale-aplicatie` — (Optional) Calea catre un pachet `.app` specific. Daca este omis, proceseaza toate aplicatiile din `/Applications`.

**Optiuni:**
- `--dry-run` — Previzualizeaza ce s-ar face fara a efectua modificari
- `--verbose` — Afiseaza informatii detaliate

**Exemple:**

```bash
# Elibereaza din captivitate toate aplicatiile din /Applications
iconchanger escape-jail

# Previzualizeaza ce s-ar intampla
iconchanger escape-jail --dry-run --verbose

# Elibereaza din captivitate o aplicatie specifica
iconchanger escape-jail /Applications/Safari.app
```

::: warning
Pictogramele personalizate nu accepta modurile de pictograme Clear, Tinted sau Dark din macOS Tahoe. Ele raman ca imagini bitmap statice.
:::

---

### `completions`

Genereaza scripturi de completare automata pentru terminal.

```bash
iconchanger completions <shell>
```

**Argumente:**
- `shell` — Tipul de shell: `zsh`, `bash` sau `fish`

**Exemple:**

```bash
# Zsh (adauga in ~/.zshrc)
source <(iconchanger completions zsh)

# Bash (adauga in ~/.bashrc)
source <(iconchanger completions bash)

# Fish
iconchanger completions fish > ~/.config/fish/completions/iconchanger.fish
```
