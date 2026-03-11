# Førstegangsopsætning

IconChanger har brug for administratorrettigheder for at ændre applikationsikoner. Ved første opstart tilbyder appen at sætte dette op automatisk.

## Automatisk opsætning (anbefalet)

1. Start IconChanger.
2. Klik på **Setup**-knappen, når du bliver bedt om det.
3. Indtast din administratoradgangskode.

Appen opretter et hjælpescript på `~/.iconchanger/helper.sh` og konfigurerer en sudoers-regel, så det kan køre uden adgangskodeprompt hver gang.

## Manuel opsætning

Hvis den automatiske opsætning fejler, kan du konfigurere det manuelt:

1. Åbn Terminal.
2. Kør:

```bash
sudo visudo
```

3. Tilføj følgende linje til sidst:

```
ALL ALL=(ALL) NOPASSWD: /Users/<dit-brugernavn>/.iconchanger/helper.sh
```

Erstat `<dit-brugernavn>` med dit faktiske macOS-brugernavn.

## Bekræft opsætningen

Efter opsætningen bør appen vise applikationslisten i sidebjælken. Hvis du ser opsætningsprompten igen, er konfigurationen muligvis ikke blevet anvendt korrekt.

Du kan bekræfte opsætningen fra menulinjen: klik på **...**-menuen og vælg **Check Setup Status**.

## Begrænsninger

Applikationer beskyttet af macOS System Integrity Protection (SIP) kan ikke få deres ikoner ændret. Dette er en macOS-begrænsning og kan ikke omgås.

Almindelige SIP-beskyttede apps inkluderer:
- Finder
- Safari (på visse macOS-versioner)
- Andre systemapplikationer i `/System/Applications/`
