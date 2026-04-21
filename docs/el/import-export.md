---
title: Εισαγωγή & Εξαγωγή
section: guide
order: 8
locale: el
---

Δημιουργήστε αντίγραφα ασφαλείας των ρυθμίσεων εικονιδίων σας ή μεταφέρετέ τες σε άλλο Mac.

## Τι εξάγεται

Ένα αρχείο εξαγωγής (JSON) περιλαμβάνει:
- **Ψευδώνυμα εφαρμογών** — τις προσαρμοσμένες αντιστοιχίσεις ονομάτων αναζήτησης
- **Αναφορές αποθηκευμένων εικονιδίων** — ποιες εφαρμογές έχουν προσαρμοσμένα εικονίδια και τα αποθηκευμένα αρχεία εικονιδίων

## Εξαγωγή

### Από τη γραφική διεπαφή

Μεταβείτε στις **Settings** > **Advanced** > **Configuration** και κάντε κλικ στο **Export**.

### Από το CLI

```bash
iconchanger export ~/Desktop/my-icons.json
```

## Εισαγωγή

### Από τη γραφική διεπαφή

Μεταβείτε στις **Settings** > **Advanced** > **Configuration** και κάντε κλικ στο **Import**.

### Από το CLI

```bash
iconchanger import ~/Desktop/my-icons.json
```

::: tip
Η εισαγωγή **προσθέτει** μόνο νέα στοιχεία. Δεν αντικαθιστά και δεν αφαιρεί ποτέ τα υπάρχοντα ψευδώνυμα ή αποθηκευμένα εικονίδια.
:::

## Επικύρωση

Πριν την εισαγωγή, μπορείτε να επικυρώσετε ένα αρχείο διαμόρφωσης:

```bash
iconchanger validate ~/Desktop/my-icons.json
```

Αυτό ελέγχει τη δομή του αρχείου χωρίς να κάνει αλλαγές.

## Αυτοματοποίηση με dotfiles

Μπορείτε να αυτοματοποιήσετε τη ρύθμιση του IconChanger ως μέρος των dotfiles σας:

```bash
#!/bin/bash
DMG_URL="https://github.com/Bengerthelorf/macIconChanger/releases/latest/download/IconChanger.dmg"
DMG_PATH="/tmp/IconChanger.dmg"

# Install the app
curl -L "$DMG_URL" -o "$DMG_PATH"
hdiutil attach "$DMG_PATH" -mountpoint /Volumes/IconChanger
cp -R /Volumes/IconChanger/IconChanger.app /Applications/
hdiutil detach /Volumes/IconChanger

# Install CLI (from the app bundle)
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger

# Import your icon configuration
iconchanger import ~/dotfiles/iconchanger/config.json
```