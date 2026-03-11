# Taustapalvelu

Taustapalvelu pitää mukautetut kuvakkeesi ennallaan, myös sovellusten päivitysten tai järjestelmämuutosten jälkeen.

## Käyttöönotto

Siirry kohtaan **Settings** > **Background** ja kytke **Run in Background** päälle.

Kun toiminto on käytössä, IconChanger jatkaa toimintaansa ikkunan sulkemisen jälkeen. Voit käyttää sitä valikkoriviltä tai Dockista.

## Ominaisuudet

### Ajastettu palautus

Palauta kaikki välimuistissa olevat mukautetut kuvakkeet automaattisesti säännöllisin väliajoin.

- Kytke **Restore Icons on Schedule** päälle
- Valitse aikaväli: joka tunti, 3 tuntia, 6 tuntia, 12 tuntia, päivittäin tai mukautettu aikaväli
- Asetukset näyttävät, milloin edellinen ja seuraava palautus tapahtuu

### Sovellusten päivitysten tunnistus

Tunnista, milloin sovelluksia päivitetään, ja aseta niiden mukautetut kuvakkeet automaattisesti uudelleen.

- Kytke **Restore Icons When Apps Update** päälle
- Aseta, kuinka usein päivityksiä tarkistetaan (5 minuutista 2 tuntiin tai mukautettu)

### Sovelluksen näkyvyys

Hallitse, missä IconChanger näkyy toimiessaan taustalla:

- **Show in Menu Bar** — lisää kuvakkeen valikkoriviin
- **Show in Dock** — pitää sovelluksen Dockissa

Vähintään yhden näistä on oltava käytössä.

### Käynnistys kirjautuessa

Käynnistä IconChanger automaattisesti, kun kirjaudut Maciisi.

- **Open Main Window** — käynnistää normaalisti pääikkunan kanssa
- **Start Hidden** — käynnistää hiljaisesti taustalla (vaatii "Run in Background" -asetuksen olevan käytössä)

::: info
"Start Hidden" vaikuttaa vain kirjautumisen yhteydessä tapahtuvaan käynnistykseen. Sovelluksen avaaminen manuaalisesti näyttää aina pääikkunan.
:::

## Palvelun tila

Kun taustapalvelu on aktiivinen, asetussivulla näytetään:
- **Service Status** — onko palvelu käynnissä
- **Cached Icons** — kuinka monta kuvaketta on valmiina palautettavaksi
