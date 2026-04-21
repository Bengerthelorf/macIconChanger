---
title: Αναφορά εντολών
section: cli
locale: el
---

## Επισκόπηση

```
iconchanger <command> [options]
```

## Εντολές

### `status`

Εμφάνιση τρέχουσας κατάστασης διαμόρφωσης.

```bash
iconchanger status
```

Εμφανίζει:
- Αριθμό ρυθμισμένων ψευδωνύμων εφαρμογών
- Αριθμό αποθηκευμένων εικονιδίων
- Κατάσταση βοηθητικού σεναρίου

---

### `list`

Εμφάνιση όλων των ψευδωνύμων και αποθηκευμένων εικονιδίων.

```bash
iconchanger list
```

Εμφανίζει έναν πίνακα με όλα τα ρυθμισμένα ψευδώνυμα και όλες τις καταχωρήσεις αποθηκευμένων εικονιδίων.

---

### `set-icon`

Ορισμός προσαρμοσμένου εικονιδίου για μια εφαρμογή.

```bash
iconchanger set-icon <app-path> <image-path>
```

**Ορίσματα:**
- `app-path` — Διαδρομή προς την εφαρμογή (π.χ. `/Applications/Safari.app`)
- `image-path` — Διαδρομή προς την εικόνα εικονιδίου (PNG, JPEG, ICNS, κ.λπ.)

**Παραδείγματα:**

```bash
# Set a custom Safari icon
iconchanger set-icon /Applications/Safari.app ~/icons/safari.png

# Relative paths work too
iconchanger set-icon /Applications/Slack.app ./slack-icon.icns
```

---

### `remove-icon`

Αφαίρεση προσαρμοσμένου εικονιδίου και επαναφορά του αρχικού.

```bash
iconchanger remove-icon <app-path>
```

**Παράδειγμα:**

```bash
iconchanger remove-icon /Applications/Safari.app
```

---

### `restore`

Επαναφορά όλων των αποθηκευμένων προσαρμοσμένων εικονιδίων. Χρήσιμο μετά από ενημέρωση συστήματος ή όταν οι εφαρμογές επαναφέρουν τα εικονίδιά τους.

```bash
iconchanger restore [options]
```

**Επιλογές:**
- `--dry-run` — Προεπισκόπηση χωρίς να γίνουν αλλαγές
- `--verbose` — Εμφάνιση λεπτομερούς εξόδου για κάθε εικονίδιο
- `--force` — Επαναφορά ακόμα και αν το εικονίδιο φαίνεται αμετάβλητο

**Παραδείγματα:**

```bash
# Restore all cached icons
iconchanger restore

# Preview what would happen
iconchanger restore --dry-run --verbose

# Force restore everything
iconchanger restore --force
```

---

### `export`

Εξαγωγή ψευδωνύμων και διαμόρφωσης αποθηκευμένων εικονιδίων σε αρχείο JSON.

```bash
iconchanger export <output-path>
```

**Παράδειγμα:**

```bash
iconchanger export ~/Desktop/my-icons.json
```

---

### `import`

Εισαγωγή αρχείου διαμόρφωσης.

```bash
iconchanger import <input-path>
```

Η εισαγωγή προσθέτει μόνο νέα στοιχεία — δεν αντικαθιστά και δεν αφαιρεί ποτέ υπάρχουσες καταχωρήσεις.

**Παράδειγμα:**

```bash
iconchanger import ~/Desktop/my-icons.json
```

---

### `validate`

Επικύρωση αρχείου διαμόρφωσης πριν την εισαγωγή.

```bash
iconchanger validate <file-path>
```

Ελέγχει τη δομή JSON, τα απαιτούμενα πεδία και την ακεραιότητα δεδομένων χωρίς να κάνει αλλαγές.

**Παράδειγμα:**

```bash
iconchanger validate ~/Desktop/my-icons.json
```

---

### `escape-jail`

Απόδραση από τη φυλακή squircle του macOS Tahoe εφαρμόζοντας εκ νέου τα ενσωματωμένα εικονίδια ως προσαρμοσμένα. Τα προσαρμοσμένα εικονίδια παρακάμπτουν την επιβολή squircle, διατηρώντας το αρχικό σχήμα του εικονιδίου.

```bash
iconchanger escape-jail [app-path] [options]
```

**Ορίσματα:**
- `app-path` — (Προαιρετικό) Διαδρομή προς συγκεκριμένο πακέτο `.app`. Αν παραλειφθεί, επεξεργάζεται όλες τις εφαρμογές στο `/Applications`.

**Επιλογές:**
- `--dry-run` — Προεπισκόπηση χωρίς να γίνουν αλλαγές
- `--verbose` — Εμφάνιση λεπτομερούς εξόδου

**Παραδείγματα:**

```bash
# Escape jail for all apps in /Applications
iconchanger escape-jail

# Preview what would happen
iconchanger escape-jail --dry-run --verbose

# Escape jail for a specific app
iconchanger escape-jail /Applications/Safari.app
```

::: warning
Τα προσαρμοσμένα εικονίδια δεν υποστηρίζουν τις λειτουργίες Clear, Tinted ή Dark εικονιδίων του macOS Tahoe. Παραμένουν ως στατικά bitmaps.
:::

---

### `completions`

Δημιουργία σεναρίων αυτόματης συμπλήρωσης κελύφους για συμπλήρωση με tab.

```bash
iconchanger completions <shell>
```

**Ορίσματα:**
- `shell` — Τύπος κελύφους: `zsh`, `bash` ή `fish`

**Παραδείγματα:**

```bash
# Zsh (add to ~/.zshrc)
source <(iconchanger completions zsh)

# Bash (add to ~/.bashrc)
source <(iconchanger completions bash)

# Fish
iconchanger completions fish > ~/.config/fish/completions/iconchanger.fish
```