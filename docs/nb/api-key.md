---
title: API-nøkkel
section: guide
order: 7
locale: nb
---

En API-nøkkel fra [macosicons.com](https://macosicons.com/) er nødvendig for å søke etter ikoner på nettet. Uten den kan du fortsatt bruke lokale bildefiler.

## Skaffe en API-nøkkel

1. Gå til [macosicons.com](https://macosicons.com/) og opprett en konto.
2. Be om en API-nøkkel fra kontoinnstillingene dine.
3. Kopier nøkkelen.

![Slik skaffer du en API-nøkkel](/images/api-key.png)

## Legge inn nøkkelen

1. Åpne IconChanger.
2. Gå til **Settings** > **Advanced**.
3. Lim inn API-nøkkelen i **API Key**-feltet.
4. Klikk **Test Connection** for å verifisere at den fungerer.

![API-nøkkelinnstillinger](/images/api-key-settings.png)

## Bruke uten API-nøkkel

Du kan fortsatt endre appikoner uten en API-nøkkel ved å:

- Bruke lokale bildefiler (klikk **Choose from the Local** eller dra og slipp et bilde)
- Bruke ikoner som følger med i selve appen (vist i "Local"-seksjonen)

## Avanserte API-innstillinger

Under **Settings** > **Advanced** > **API Settings** kan du finjustere API-atferden:

| Innstilling | Standard | Beskrivelse |
|---|---|---|
| **Retry Count** | 0 (ingen nytt forsøk) | Antall ganger en mislykket forespørsel skal prøves på nytt (0–3) |
| **Timeout** | 15 sekunder | Tidsavbrudd for hvert enkelt forsøk |
| **Monthly Limit** | 50 | Maksimalt antall API-forespørsler per måned |

Telleren **Monthly Usage** viser ditt nåværende forbruk. Den tilbakestilles automatisk den 1. i hver måned, eller du kan tilbakestille den manuelt.

### Buffer for ikonsøk

Aktiver **Cache API Results** for å lagre søkeresultater på disk. Bufrede resultater beholdes etter omstart av appen, noe som reduserer API-bruken. Bruk oppdateringsknappen når du blar gjennom ikoner for å hente ferske resultater.

## Feilsøking

Hvis API-testen mislykkes:
- Sjekk at nøkkelen er korrekt (ingen ekstra mellomrom)
- Verifiser internettforbindelsen din
- macosicons.com-API-et kan være midlertidig utilgjengelig