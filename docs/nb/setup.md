---
title: Første oppsett
section: guide
order: 2
locale: nb
---

IconChanger trenger administratorrettigheter for å endre appikoner. Ved første oppstart tilbyr appen å sette dette opp automatisk.

## Automatisk oppsett (anbefalt)

1. Start IconChanger.
2. Klikk på **Setup**-knappen når du blir bedt om det.
3. Skriv inn administratorpassordet ditt.

Appen vil installere et hjelpeskript i `/usr/local/lib/iconchanger/` (eid av `root:wheel`) og konfigurere en avgrenset sudoers-regel slik at det kan kjøres uten passordforespørsel hver gang.

## Sikkerhet

IconChanger bruker flere sikkerhetstiltak for å beskytte hjelpepipelinen:

- **Root-eid hjelpekatalog** — Hjelpefilene ligger i `/usr/local/lib/iconchanger/` med `root:wheel`-eierskap, som forhindrer uprivilegerte endringer.
- **SHA-256 integritetsverifisering** — Hjelpeskriptet verifiseres mot en kjent hash før hver kjøring.
- **Avgrenset sudoers-regel** — Sudoers-oppføringen gir kun passordløs tilgang til det spesifikke hjelpeskriptet, ikke vilkårlige kommandoer.
- **Revisjonslogging** — Alle ikonoperasjoner logges med tidsstempler for sporbarhet.

## Manuelt oppsett

Hvis automatisk oppsett mislykkes, kan du konfigurere det manuelt:

1. Åpne Terminal.
2. Kjør:

```bash
sudo visudo -f /etc/sudoers.d/iconchanger
```

3. Legg til følgende linje:

```
ALL ALL=(ALL) NOPASSWD: /usr/local/lib/iconchanger/helper.sh
```

## Verifisere oppsettet

Etter oppsett skal appen vise applisten i sidefeltet. Hvis du ser oppsettskjermen igjen, kan det hende konfigurasjonen ikke ble brukt riktig.

Du kan verifisere oppsettet fra menylinjen: klikk på **...**-menyen og velg **Check Setup Status**.

## Begrensninger

Applikasjoner beskyttet av macOS System Integrity Protection (SIP) kan ikke få ikonene sine endret. Dette er en macOS-begrensning og kan ikke omgås.

Vanlige SIP-beskyttede apper inkluderer:
- Finder
- Safari (på enkelte macOS-versjoner)
- Andre systemapplikasjoner i `/System/Applications/`