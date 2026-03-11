# Hurtig start

## Krav

- macOS 13.0 (Ventura) eller nyere
- Administratorrettigheder (til førstegangsopsætning og ikonskift)

## Installation

### Homebrew (anbefalet)

```bash
brew install Bengerthelorf/tap/iconchanger
```

### Manuel download

1. Download den seneste DMG fra [GitHub Releases](https://github.com/Bengerthelorf/macIconChanger/releases/latest).
2. Åbn DMG-filen, og træk **IconChanger** ind i din Programmer-mappe.
3. Start IconChanger.

## Første opstart

Ved første opstart vil IconChanger bede dig om at gennemføre en engangsopsætning af tilladelser. Dette er nødvendigt, for at appen kan ændre applikationsikoner.

![Opsætningsskærm ved første opstart](/images/setup-prompt.png)

Klik på opsætningsknappen, og indtast din administratoradgangskode. IconChanger konfigurerer automatisk de nødvendige tilladelser (en sudoers-regel til hjælpescriptet).

::: tip
Hvis den automatiske opsætning fejler, se [Førstegangsopsætning](./setup) for manuelle instruktioner.
:::

## Skift dit første ikon

1. Vælg en applikation fra sidebjælken.
2. Gennemse ikoner fra [macOSicons.com](https://macosicons.com/) eller vælg en lokal billedfil.
3. Klik på et ikon for at anvende det.

![Hovedgrænseflade](/images/main-interface.png)

Det er det hele! Appikonet ændres med det samme.

## Næste skridt

- [Opsæt en API-nøgle](./api-key) til online ikonsøgning
- [Lær om app-aliasser](./aliases) for bedre søgeresultater
- [Konfigurer baggrundstjenesten](./background-service) til automatisk ikongendannelse
- [Installer CLI-værktøjet](/da/cli/) til kommandolinjeadgang
