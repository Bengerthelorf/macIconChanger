# Snabbstart

## Krav

- macOS 13.0 (Ventura) eller senare
- Administratörsbehörighet (för initial konfiguration och byte av ikoner)

## Installation

### Homebrew (rekommenderat)

```bash
brew install Bengerthelorf/tap/iconchanger
```

### Manuell nedladdning

1. Ladda ner den senaste DMG-filen från [GitHub Releases](https://github.com/Bengerthelorf/macIconChanger/releases/latest).
2. Öppna DMG-filen och dra **IconChanger** till din Programmapp.
3. Starta IconChanger.

## Första uppstarten

Vid första uppstarten kommer IconChanger att be dig genomföra en engångskonfiguration av behörigheter. Detta krävs för att appen ska kunna byta appikoner.

![Konfigurationsskärm vid första uppstart](/images/setup-prompt.png)

Klicka på konfigurationsknappen och ange ditt administratörslösenord. IconChanger konfigurerar automatiskt de nödvändiga behörigheterna (en sudoers-regel för hjälpskriptet).

::: tip
Om den automatiska konfigurationen misslyckas, se [Initial konfiguration](./setup) för manuella instruktioner.
:::

## Byt din första ikon

1. Välj en app i sidofältet.
2. Bläddra bland ikoner från [macOSicons.com](https://macosicons.com/) eller välj en lokal bildfil.
3. Klicka på en ikon för att tillämpa den.

![Huvudgränssnitt](/images/main-interface.png)

Klart! Appikonen byts omedelbart.

## Nästa steg

- [Konfigurera en API-nyckel](./api-key) för ikonssökning online
- [Lär dig om appalias](./aliases) för bättre sökresultat
- [Konfigurera bakgrundstjänsten](./background-service) för automatisk ikonåterställning
- [Installera CLI-verktyget](/sv/cli/) för åtkomst via kommandoraden
