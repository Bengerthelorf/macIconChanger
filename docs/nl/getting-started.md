---
title: Snel aan de slag
section: guide
order: 1
locale: nl
---

## Vereisten

- macOS 13.0 (Ventura) of nieuwer
- Beheerdersbevoegdheden (voor de eerste configuratie en het wijzigen van pictogrammen)

## Installatie

### Homebrew (aanbevolen)

```bash
brew install Bengerthelorf/tap/iconchanger
```

### Handmatige download

1. Download de nieuwste DMG van [GitHub Releases](https://github.com/Bengerthelorf/macIconChanger/releases/latest).
2. Open de DMG en sleep **IconChanger** naar je map Programma's.
3. Start IconChanger.

## Eerste keer opstarten

Bij de eerste keer opstarten vraagt IconChanger je om een eenmalige machtigingsconfiguratie te voltooien. Dit is nodig om de app pictogrammen van apps te laten wijzigen.

![Eerste configuratiescherm](/images/setup-prompt.png)

Klik op de configuratieknop en voer je beheerderswachtwoord in. IconChanger configureert automatisch de benodigde machtigingen (een sudoers-regel voor het hulpscript).

::: tip
Als de automatische configuratie mislukt, zie [Eerste configuratie](/nl/guide/setup) voor handmatige instructies.
:::

## Je eerste pictogram wijzigen

1. Selecteer een app in de zijbalk.
2. Blader door pictogrammen van [macOSicons.com](https://macosicons.com/) of kies een lokaal afbeeldingsbestand.
3. Klik op een pictogram om het toe te passen.

![Hoofdscherm](/images/main-interface.png)

Dat is alles! Het apppictogram wordt direct gewijzigd.

## Volgende stappen

- [Een API-sleutel instellen](/nl/guide/api-key) voor online pictogrammen zoeken
- [Meer over app-aliassen](/nl/guide/aliases) voor betere zoekresultaten
- [De achtergronddienst configureren](/nl/guide/background-service) voor automatisch pictogramherstel
- [De CLI-tool installeren](/nl/cli/) voor toegang via de opdrachtregel