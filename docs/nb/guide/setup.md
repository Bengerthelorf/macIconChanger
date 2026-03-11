# Første oppsett

IconChanger trenger administratorrettigheter for å endre appikoner. Ved første oppstart tilbyr appen å sette dette opp automatisk.

## Automatisk oppsett (anbefalt)

1. Start IconChanger.
2. Klikk på **Setup**-knappen når du blir bedt om det.
3. Skriv inn administratorpassordet ditt.

Appen vil opprette et hjelpeskript på `~/.iconchanger/helper.sh` og konfigurere en sudoers-regel slik at det kan kjøres uten passordforespørsel hver gang.

## Manuelt oppsett

Hvis automatisk oppsett mislykkes, kan du konfigurere det manuelt:

1. Åpne Terminal.
2. Kjør:

```bash
sudo visudo
```

3. Legg til følgende linje på slutten:

```
ALL ALL=(ALL) NOPASSWD: /Users/<ditt-brukernavn>/.iconchanger/helper.sh
```

Erstatt `<ditt-brukernavn>` med ditt faktiske macOS-brukernavn.

## Verifisere oppsettet

Etter oppsett skal appen vise applisten i sidefeltet. Hvis du ser oppsettskjermen igjen, kan det hende konfigurasjonen ikke ble brukt riktig.

Du kan verifisere oppsettet fra menylinjen: klikk på **...**-menyen og velg **Check Setup Status**.

## Begrensninger

Applikasjoner beskyttet av macOS System Integrity Protection (SIP) kan ikke få ikonene sine endret. Dette er en macOS-begrensning og kan ikke omgås.

Vanlige SIP-beskyttede apper inkluderer:
- Finder
- Safari (på enkelte macOS-versjoner)
- Andre systemapplikasjoner i `/System/Applications/`
