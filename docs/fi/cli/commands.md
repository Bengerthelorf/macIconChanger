# Komentojen viite

## Yleiskatsaus

```
iconchanger <komento> [valinnat]
```

## Komennot

### `status`

Näytä nykyisen konfiguraation tila.

```bash
iconchanger status
```

Näyttää:
- Määritettyjen sovellusaliaksien lukumäärän
- Välimuistissa olevien kuvakkeiden lukumäärän
- Apuskriptin tilan

---

### `list`

Listaa kaikki aliakset ja välimuistissa olevat kuvakkeet.

```bash
iconchanger list
```

Näyttää taulukon kaikista määritetyistä aliaksista ja kaikista välimuistissa olevista kuvakemerkinnöistä.

---

### `set-icon`

Aseta mukautettu kuvake sovellukselle.

```bash
iconchanger set-icon <sovellus-polku> <kuva-polku>
```

**Argumentit:**
- `sovellus-polku` — Polku sovellukseen (esim. `/Applications/Safari.app`)
- `kuva-polku` — Polku kuvakekuvaan (PNG, JPEG, ICNS jne.)

**Esimerkkejä:**

```bash
# Aseta mukautettu Safari-kuvake
iconchanger set-icon /Applications/Safari.app ~/icons/safari.png

# Suhteelliset polut toimivat myös
iconchanger set-icon /Applications/Slack.app ./slack-icon.icns
```

---

### `remove-icon`

Poista mukautettu kuvake ja palauta alkuperäinen.

```bash
iconchanger remove-icon <sovellus-polku>
```

**Esimerkki:**

```bash
iconchanger remove-icon /Applications/Safari.app
```

---

### `restore`

Palauta kaikki välimuistissa olevat mukautetut kuvakkeet. Hyödyllinen järjestelmäpäivityksen jälkeen tai kun sovellukset palauttavat oletuskuvakkeensa.

```bash
iconchanger restore [valinnat]
```

**Valinnat:**
- `--dry-run` — Esikatsele, mitä palautettaisiin, tekemättä muutoksia
- `--verbose` — Näytä yksityiskohtainen tuloste jokaiselle kuvakkeelle
- `--force` — Palauta, vaikka kuvake näyttäisi muuttumattomalta

**Esimerkkejä:**

```bash
# Palauta kaikki välimuistissa olevat kuvakkeet
iconchanger restore

# Esikatsele, mitä tapahtuisi
iconchanger restore --dry-run --verbose

# Pakota kaikkien palautus
iconchanger restore --force
```

---

### `export`

Vie aliakset ja välimuistissa olevat kuvakeasetukset JSON-tiedostoon.

```bash
iconchanger export <tulostiedosto-polku>
```

**Esimerkki:**

```bash
iconchanger export ~/Desktop/my-icons.json
```

---

### `import`

Tuo konfiguraatiotiedosto.

```bash
iconchanger import <syötetiedosto-polku>
```

Tuonti vain lisää uusia kohteita — se ei koskaan korvaa tai poista olemassa olevia merkintöjä.

**Esimerkki:**

```bash
iconchanger import ~/Desktop/my-icons.json
```

---

### `validate`

Tarkista konfiguraatiotiedosto ennen tuontia.

```bash
iconchanger validate <tiedosto-polku>
```

Tarkistaa JSON-rakenteen, pakolliset kentät ja tietojen eheyden tekemättä muutoksia.

**Esimerkki:**

```bash
iconchanger validate ~/Desktop/my-icons.json
```

---

### `escape-jail`

Vapaudu macOS Tahoen squircle-vankilasta asettamalla sovelluksen oma sisäinen kuvake mukautetuksi kuvakkeeksi. Mukautetut kuvakkeet ohittavat squircle-pakon ja säilyttävät alkuperäisen kuvakkeen muodon.

```bash
iconchanger escape-jail [sovellus-polku] [valinnat]
```

**Argumentit:**
- `sovellus-polku` — (Valinnainen) Polku tiettyyn `.app`-pakettiin. Jos jätetään pois, käsitellään kaikki sovellukset kansiossa `/Applications`.

**Valinnat:**
- `--dry-run` — Esikatsele, mitä tehtäisiin, tekemättä muutoksia
- `--verbose` — Näytä yksityiskohtainen tuloste

**Esimerkkejä:**

```bash
# Vapauta kaikki sovellukset /Applications-kansiossa
iconchanger escape-jail

# Esikatsele, mitä tapahtuisi
iconchanger escape-jail --dry-run --verbose

# Vapauta tietty sovellus
iconchanger escape-jail /Applications/Safari.app
```

::: warning
Mukautetut kuvakkeet eivät tue macOS Tahoen Clear-, Tinted- tai Dark-kuvaketiloja. Ne pysyvät staattisina bittikarttakuvina.
:::

---

### `completions`

Luo komentotulkin täydennysskriptit sarkaimen täydennystä varten.

```bash
iconchanger completions <komentotulkki>
```

**Argumentit:**
- `komentotulkki` — Komentotulkin tyyppi: `zsh`, `bash` tai `fish`

**Esimerkkejä:**

```bash
# Zsh (lisää tiedostoon ~/.zshrc)
source <(iconchanger completions zsh)

# Bash (lisää tiedostoon ~/.bashrc)
source <(iconchanger completions bash)

# Fish
iconchanger completions fish > ~/.config/fish/completions/iconchanger.fish
```
