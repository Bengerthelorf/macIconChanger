---
title: Hurtigstart
section: guide
order: 1
locale: nb
---

## Krav

- macOS 13.0 (Ventura) eller nyere
- Administratorrettigheter (for første oppsett og endring av ikoner)

## Installasjon

### Homebrew (anbefalt)

```bash
brew install Bengerthelorf/tap/iconchanger
```

### Manuell nedlasting

1. Last ned den nyeste DMG-filen fra [GitHub Releases](https://github.com/Bengerthelorf/macIconChanger/releases/latest).
2. Åpne DMG-filen og dra **IconChanger** til Programmer-mappen.
3. Start IconChanger.

## Første oppstart

Ved første oppstart vil IconChanger be deg om å fullføre et engangsoppsett av tillatelser. Dette er nødvendig for at appen skal kunne endre appikoner.

![Oppsettskjerm ved første oppstart](/images/setup-prompt.png)

Klikk på oppsettknappen og skriv inn administratorpassordet ditt. IconChanger vil automatisk konfigurere de nødvendige tillatelsene (en sudoers-regel for hjelpeskriptet).

::: tip
Hvis det automatiske oppsettet mislykkes, se [Første oppsett](./setup) for manuelle instruksjoner.
:::

## Endre ditt første ikon

1. Velg en applikasjon fra sidefeltet.
2. Bla gjennom ikoner fra [macOSicons.com](https://macosicons.com/) eller velg en lokal bildefil.
3. Klikk på et ikon for å bruke det.

![Hovedgrensesnitt](/images/main-interface.png)

Det er alt! Appikonet endres umiddelbart.

## Neste steg

- [Sett opp en API-nøkkel](./api-key) for ikonsøk på nettet
- [Lær om app-aliaser](./aliases) for bedre søkeresultater
- [Konfigurer bakgrunnstjenesten](./background-service) for automatisk gjenoppretting av ikoner
- [Installer CLI-verktøyet](/nb/cli/) for kommandolinjetilgang