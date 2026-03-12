# Førstegangsopsætning

IconChanger har brug for administratorrettigheder for at ændre applikationsikoner. Ved første opstart tilbyder appen at sætte dette op automatisk.

## Automatisk opsætning (anbefalet)

1. Start IconChanger.
2. Klik på **Setup**-knappen, når du bliver bedt om det.
3. Indtast din administratoradgangskode.

Appen installerer et hjælpescript i `/usr/local/lib/iconchanger/` (ejet af `root:wheel`) og konfigurerer en afgrænset sudoers-regel, så det kan køre uden adgangskodeprompt hver gang.

## Sikkerhed

IconChanger bruger flere sikkerhedsforanstaltninger til at beskytte hjælpepipelinen:

- **Root-ejet hjælpemappe** — Hjælpefilerne ligger i `/usr/local/lib/iconchanger/` med `root:wheel`-ejerskab, hvilket forhindrer uprivilegerede ændringer.
- **SHA-256 integritetsverificering** — Hjælpescriptet verificeres mod en kendt hash før hver kørsel.
- **Afgrænset sudoers-regel** — Sudoers-posten giver kun adgangskode-fri adgang til det specifikke hjælpescript, ikke vilkårlige kommandoer.
- **Revisionslogning** — Alle ikonoperationer logges med tidsstempler for sporbarhed.

## Manuel opsætning

Hvis den automatiske opsætning fejler, kan du konfigurere det manuelt:

1. Åbn Terminal.
2. Kør:

```bash
sudo visudo -f /etc/sudoers.d/iconchanger
```

3. Tilføj følgende linje:

```
ALL ALL=(ALL) NOPASSWD: /usr/local/lib/iconchanger/helper.sh
```

## Bekræft opsætningen

Efter opsætningen bør appen vise applikationslisten i sidebjælken. Hvis du ser opsætningsprompten igen, er konfigurationen muligvis ikke blevet anvendt korrekt.

Du kan bekræfte opsætningen fra menulinjen: klik på **...**-menuen og vælg **Check Setup Status**.

## Begrænsninger

Applikationer beskyttet af macOS System Integrity Protection (SIP) kan ikke få deres ikoner ændret. Dette er en macOS-begrænsning og kan ikke omgås.

Almindelige SIP-beskyttede apps inkluderer:
- Finder
- Safari (på visse macOS-versioner)
- Andre systemapplikationer i `/System/Applications/`
