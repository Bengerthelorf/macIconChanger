# Parancsreferencia

## Áttekintés

```
iconchanger <parancs> [opciók]
```

## Parancsok

### `status`

Az aktuális konfigurációs állapot megjelenítése.

```bash
iconchanger status
```

Megjelenítés:
- A konfigurált alkalmazás-álnevek száma
- A gyorsítótárazott ikonok száma
- A segédszkript állapota

---

### `list`

Az összes álnév és gyorsítótárazott ikon listázása.

```bash
iconchanger list
```

Táblázatos formában megjeleníti az összes konfigurált álnevet és gyorsítótárazott ikonbejegyzést.

---

### `set-icon`

Egyedi ikon beállítása egy alkalmazáshoz.

```bash
iconchanger set-icon <alkalmazás-útvonal> <kép-útvonal>
```

**Argumentumok:**
- `alkalmazás-útvonal` — Az alkalmazás elérési útja (pl. `/Applications/Safari.app`)
- `kép-útvonal` — Az ikonfájl elérési útja (PNG, JPEG, ICNS stb.)

**Példák:**

```bash
# Egyedi Safari ikon beállítása
iconchanger set-icon /Applications/Safari.app ~/icons/safari.png

# Relatív útvonalak is működnek
iconchanger set-icon /Applications/Slack.app ./slack-icon.icns
```

---

### `remove-icon`

Egyedi ikon eltávolítása és az eredeti visszaállítása.

```bash
iconchanger remove-icon <alkalmazás-útvonal>
```

**Példa:**

```bash
iconchanger remove-icon /Applications/Safari.app
```

---

### `restore`

Az összes gyorsítótárazott egyedi ikon visszaállítása. Hasznos rendszerfrissítés után vagy amikor az alkalmazások visszaállítják az ikonjaikat.

```bash
iconchanger restore [opciók]
```

**Opciók:**
- `--dry-run` — Előnézet: mi történne a módosítások végrehajtása nélkül
- `--verbose` — Részletes kimenet minden ikonhoz
- `--force` — Visszaállítás akkor is, ha az ikon változatlannak tűnik

**Példák:**

```bash
# Az összes gyorsítótárazott ikon visszaállítása
iconchanger restore

# Előnézet a történtekről
iconchanger restore --dry-run --verbose

# Minden kényszerített visszaállítása
iconchanger restore --force
```

---

### `export`

Álnevek és gyorsítótárazott ikonkonfiguráció exportálása JSON fájlba.

```bash
iconchanger export <kimeneti-útvonal>
```

**Példa:**

```bash
iconchanger export ~/Desktop/my-icons.json
```

---

### `import`

Konfigurációs fájl importálása.

```bash
iconchanger import <bemeneti-útvonal>
```

Az importálás csak új elemeket ad hozzá — soha nem cseréli le és nem törli a meglévő bejegyzéseket.

**Példa:**

```bash
iconchanger import ~/Desktop/my-icons.json
```

---

### `validate`

Konfigurációs fájl ellenőrzése importálás előtt.

```bash
iconchanger validate <fájl-útvonal>
```

Ellenőrzi a JSON struktúrát, a kötelező mezőket és az adatok integritását anélkül, hogy bármit módosítana.

**Példa:**

```bash
iconchanger validate ~/Desktop/my-icons.json
```

---

### `escape-jail`

Kilépés a macOS Tahoe squircle börtönéből a beépített ikonok egyedi ikonként való újraalkalmazásával. Az egyedi ikonok megkerülik a squircle-kényszerítést, megőrizve az eredeti ikon alakját.

```bash
iconchanger escape-jail [alkalmazás-útvonal] [opciók]
```

**Argumentumok:**
- `alkalmazás-útvonal` — (Opcionális) Egy adott `.app` csomag elérési útja. Ha nincs megadva, az `/Applications` mappában lévő összes alkalmazást feldolgozza.

**Opciók:**
- `--dry-run` — Előnézet a módosítások végrehajtása nélkül
- `--verbose` — Részletes kimenet

**Példák:**

```bash
# Kilépés a börtönből az /Applications összes alkalmazásánál
iconchanger escape-jail

# Előnézet a történtekről
iconchanger escape-jail --dry-run --verbose

# Kilépés a börtönből egy adott alkalmazásnál
iconchanger escape-jail /Applications/Safari.app
```

::: warning
Az egyedi ikonok nem támogatják a macOS Tahoe Clear, Tinted vagy Dark ikon üzemmódjait. Statikus bittérképként jelennek meg.
:::

---

### `completions`

Shell-kiegészítő szkriptek generálása a tabulátoros kiegészítéshez.

```bash
iconchanger completions <shell>
```

**Argumentumok:**
- `shell` — Shell típus: `zsh`, `bash` vagy `fish`

**Példák:**

```bash
# Zsh (add hozzá a ~/.zshrc fájlhoz)
source <(iconchanger completions zsh)

# Bash (add hozzá a ~/.bashrc fájlhoz)
source <(iconchanger completions bash)

# Fish
iconchanger completions fish > ~/.config/fish/completions/iconchanger.fish
```
