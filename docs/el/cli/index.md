---
title: Εγκατάσταση CLI
section: cli
locale: el
---

Το IconChanger περιλαμβάνει μια διεπαφή γραμμής εντολών για δέσμες ενεργειών και αυτοματοποίηση.

## Εγκατάσταση από την εφαρμογή

1. Ανοίξτε το IconChanger > **Settings** > **Advanced**.
2. Στην ενότητα **Command Line Tool**, κάντε κλικ στο **Install**.
3. Εισαγάγετε τον κωδικό διαχειριστή σας.

Η εντολή `iconchanger` είναι πλέον διαθέσιμη στο τερματικό σας.

## Χειροκίνητη εγκατάσταση

Αν προτιμάτε χειροκίνητη εγκατάσταση (π.χ. σε σενάριο dotfiles):

```bash
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger
```

## Επαλήθευση εγκατάστασης

```bash
iconchanger --version
```

## Απεγκατάσταση

Από την εφαρμογή: **Settings** > **Advanced** > **Uninstall**.

Ή χειροκίνητα:

```bash
sudo rm /usr/local/bin/iconchanger
```

## Επόμενα βήματα

Δείτε την [Αναφορά εντολών](./commands) για όλες τις διαθέσιμες εντολές.