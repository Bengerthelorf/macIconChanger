# API-kulcs

A [macosicons.com](https://macosicons.com/) oldalról származó API-kulcs szükséges az online ikonkereséshez. Enélkül is használhatsz helyi képfájlokat.

## API-kulcs beszerzése

1. Látogass el a [macosicons.com](https://macosicons.com/) oldalra, és hozz létre egy fiókot.
2. Igényelj API-kulcsot a fiókbeállításaidban.
3. Másold ki a kulcsot.

![API-kulcs beszerzése](/images/api-key.png)

## A kulcs megadása

1. Nyisd meg az IconChanger alkalmazást.
2. Navigálj a **Settings** > **Advanced** menüpontra.
3. Illeszd be az API-kulcsot az **API Key** mezőbe.
4. Kattints a **Test Connection** gombra a működés ellenőrzéséhez.

![API-kulcs beállítások](/images/api-key-settings.png)

## Használat API-kulcs nélkül

API-kulcs nélkül is módosíthatod az alkalmazásikonokat:

- Helyi képfájlok használatával (kattints a **Choose from the Local** gombra, vagy húzz be egy képet)
- Az alkalmazásba épített ikonok használatával (a „Local" részben láthatók)

## Speciális API-beállítások

A **Settings** > **Advanced** > **API Settings** menüben finomhangolhatod az API viselkedését:

| Beállítás | Alapértelmezett | Leírás |
|---|---|---|
| **Retry Count** | 0 (nincs újrapróbálkozás) | Hányszor próbálkozzon újra sikertelen kérés esetén (0–3) |
| **Timeout** | 15 másodperc | Időkorlát kérésenként |
| **Monthly Limit** | 50 | Maximális API-lekérdezések száma havonta |

A **Monthly Usage** számláló mutatja az aktuális használatot. Automatikusan nullázódik minden hónap 1-jén, vagy manuálisan is nullázhatod.

### Ikonkeresési gyorsítótár

Kapcsold be a **Cache API Results** lehetőséget, hogy a keresési eredmények lemezre mentődjenek. A gyorsítótárazott eredmények az alkalmazás újraindítása után is megmaradnak, csökkentve az API-használatot. Használd a frissítés gombot ikonok böngészésekor a legfrissebb eredmények lekéréséhez.

## Hibaelhárítás

Ha az API-teszt sikertelen:
- Ellenőrizd, hogy a kulcsod helyes-e (nincsenek felesleges szóközök)
- Ellenőrizd az internetkapcsolatot
- A macosicons.com API átmenetileg elérhetetlenné válhat
