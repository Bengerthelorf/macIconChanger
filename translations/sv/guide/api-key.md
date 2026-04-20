# API-nyckel

En API-nyckel från [macosicons.com](https://macosicons.com/) krävs för att söka efter ikoner online. Utan den kan du fortfarande använda lokala bildfiler.

## Skaffa en API-nyckel

1. Besök [macosicons.com](https://macosicons.com/) och skapa ett konto.
2. Begär en API-nyckel från dina kontoinställningar.
3. Kopiera nyckeln.

![Hur man skaffar en API-nyckel](/images/api-key.png)

## Ange nyckeln

1. Öppna IconChanger.
2. Gå till **Settings** > **Advanced**.
3. Klistra in din API-nyckel i fältet **API Key**.
4. Klicka på **Test Connection** för att verifiera att den fungerar.

![API-nyckelinställningar](/images/api-key-settings.png)

## Användning utan API-nyckel

Du kan fortfarande byta appikoner utan en API-nyckel genom att:

- Använda lokala bildfiler (klicka på **Choose from the Local** eller dra och släpp en bild)
- Använda ikoner som följer med appen (visas under avsnittet "Local")

## Avancerade API-inställningar

Under **Settings** > **Advanced** > **API Settings** kan du finjustera API-beteendet:

| Inställning | Standard | Beskrivning |
|---|---|---|
| **Retry Count** | 0 (inget nytt försök) | Antal gånger ett misslyckat anrop ska försökas på nytt (0–3) |
| **Timeout** | 15 sekunder | Tidsgräns för varje enskilt anropsförsök |
| **Monthly Limit** | 50 | Maximalt antal API-förfrågningar per månad |

Räknaren **Monthly Usage** visar din aktuella användning. Den återställs automatiskt den 1:a varje månad, eller så kan du återställa den manuellt.

### Cache för ikonsökning

Aktivera **Cache API Results** för att spara sökresultat till disk. Cachade resultat bevaras över omstarter av appen, vilket minskar API-användningen. Använd uppdateringsknappen när du bläddrar bland ikoner för att hämta färska resultat.

## Felsökning

Om API-testet misslyckas:
- Kontrollera att din nyckel är korrekt (inga extra mellanslag)
- Verifiera din internetanslutning
- API:et på macosicons.com kan vara tillfälligt otillgängligt
