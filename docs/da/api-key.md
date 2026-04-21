---
title: API-nøgle
section: guide
order: 7
locale: da
---

En API-nøgle fra [macosicons.com](https://macosicons.com/) er påkrævet for at søge efter ikoner online. Uden den kan du stadig bruge lokale billedfiler.

## Sådan får du en API-nøgle

1. Besøg [macosicons.com](https://macosicons.com/) og opret en konto.
2. Anmod om en API-nøgle fra dine kontoindstillinger.
3. Kopier nøglen.

![Sådan får du en API-nøgle](/images/api-key.png)

## Indtastning af nøglen

1. Åbn IconChanger.
2. Gå til **Settings** > **Advanced**.
3. Indsæt din API-nøgle i feltet **API Key**.
4. Klik på **Test Connection** for at bekræfte, at den virker.

![API-nøgle indstillinger](/images/api-key-settings.png)

## Brug uden API-nøgle

Du kan stadig skifte appikoner uden en API-nøgle ved at:

- Bruge lokale billedfiler (klik på **Choose from the Local** eller træk og slip et billede)
- Bruge ikoner, der er inkluderet i selve appen (vist i sektionen "Local")

## Avancerede API-indstillinger

Under **Settings** > **Advanced** > **API Settings** kan du finjustere API-adfærden:

| Indstilling | Standard | Beskrivelse |
|---|---|---|
| **Retry Count** | 0 (intet nyt forsøg) | Antal gange en mislykket anmodning skal prøves igen (0–3) |
| **Timeout** | 15 sekunder | Timeout for hvert enkelt forsøg |
| **Monthly Limit** | 50 | Maksimalt antal API-forespørgsler pr. måned |

Tælleren **Monthly Usage** viser dit aktuelle forbrug. Den nulstilles automatisk den 1. i hver måned, eller du kan nulstille den manuelt.

### Cache til ikonsøgning

Aktiver **Cache API Results** for at gemme søgeresultater på disken. Cachelagrede resultater bevares efter genstart af appen, hvilket reducerer API-forbruget. Brug opdateringsknappen, når du gennemser ikoner, for at hente nye resultater.

## Fejlfinding

Hvis API-testen fejler:
- Kontroller, at din nøgle er korrekt (ingen ekstra mellemrum)
- Bekræft din internetforbindelse
- macosicons.com-API'en kan være midlertidigt utilgængelig