# API-sleutel

Een API-sleutel van [macosicons.com](https://macosicons.com/) is vereist om online naar pictogrammen te zoeken. Zonder deze sleutel kun je nog steeds lokale afbeeldingsbestanden gebruiken.

## Een API-sleutel verkrijgen

1. Ga naar [macosicons.com](https://macosicons.com/) en maak een account aan.
2. Vraag een API-sleutel aan via je accountinstellingen.
3. Kopieer de sleutel.

![Een API-sleutel verkrijgen](/images/api-key.png)

## De sleutel invoeren

1. Open IconChanger.
2. Ga naar **Settings** > **Advanced**.
3. Plak je API-sleutel in het veld **API Key**.
4. Klik op **Test Connection** om te controleren of het werkt.

![API-sleutelinstellingen](/images/api-key-settings.png)

## Gebruik zonder API-sleutel

Je kunt ook zonder API-sleutel apppictogrammen wijzigen door:

- Lokale afbeeldingsbestanden te gebruiken (klik op **Choose from the Local** of sleep een afbeelding)
- Pictogrammen te gebruiken die in de app zelf zijn meegeleverd (te zien in het gedeelte "Local")

## Geavanceerde API-instellingen

In **Settings** > **Advanced** > **API Settings** kun je het API-gedrag fijnafstemmen:

| Instelling | Standaard | Beschrijving |
|---|---|---|
| **Retry Count** | 0 (geen nieuwe poging) | Aantal keren dat een mislukt verzoek opnieuw wordt geprobeerd (0–3) |
| **Timeout** | 15 seconden | Timeout per verzoek |
| **Monthly Limit** | 50 | Maximaal aantal API-query's per maand |

De teller **Monthly Usage** toont je huidige gebruik. Deze wordt automatisch op de 1e van elke maand gereset, of je kunt hem handmatig resetten.

### Cache voor pictogramzoekopdrachten

Schakel **Cache API Results** in om zoekresultaten op schijf op te slaan. Gecachete resultaten blijven bewaard na het herstarten van de app, waardoor het API-gebruik wordt verminderd. Gebruik de vernieuwknop bij het bladeren door pictogrammen om actuele resultaten op te halen.

## Probleemoplossing

Als de API-test mislukt:
- Controleer of je sleutel correct is (geen extra spaties)
- Controleer je internetverbinding
- De macosicons.com API kan tijdelijk niet beschikbaar zijn
