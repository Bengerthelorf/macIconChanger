# API-avain

API-avain [macosicons.com](https://macosicons.com/)-sivustolta vaaditaan kuvakkeiden hakemiseen verkosta. Ilman sitä voit silti käyttää paikallisia kuvatiedostoja.

## API-avaimen hankkiminen

1. Käy osoitteessa [macosicons.com](https://macosicons.com/) ja luo tili.
2. Pyydä API-avain tiliasetuksistasi.
3. Kopioi avain.

![API-avaimen hankkiminen](/images/api-key.png)

## Avaimen syöttäminen

1. Avaa IconChanger.
2. Siirry kohtaan **Settings** > **Advanced**.
3. Liitä API-avaimesi **API Key** -kenttään.
4. Napsauta **Test Connection** varmistaaksesi, että se toimii.

![API-avaimen asetukset](/images/api-key-settings.png)

## Käyttö ilman API-avainta

Voit silti vaihtaa sovellusten kuvakkeita ilman API-avainta:

- Käyttämällä paikallisia kuvatiedostoja (napsauta **Choose from the Local** tai vedä ja pudota kuva)
- Käyttämällä sovelluksen sisällä olevia kuvakkeita (näytetään "Local"-osiossa)

## Edistyneet API-asetukset

Kohdassa **Settings** > **Advanced** > **API Settings** voit hienosäätää API:n toimintaa:

| Asetus | Oletus | Kuvaus |
|---|---|---|
| **Retry Count** | 0 (ei uudelleenyritystä) | Kuinka monta kertaa epäonnistunutta pyyntöä yritetään uudelleen (0–3) |
| **Timeout** | 15 sekuntia | Aikakatkaisu yksittäistä pyyntöä kohden |
| **Monthly Limit** | 50 | API-kyselyiden enimmäismäärä kuukaudessa |

**Monthly Usage** -laskuri näyttää nykyisen käyttösi. Se nollautuu automaattisesti jokaisen kuukauden 1. päivänä, tai voit nollata sen manuaalisesti.

### Kuvakehaun välimuisti

Ota käyttöön **Cache API Results** tallentaaksesi hakutulokset levylle. Välimuistissa olevat tulokset säilyvät sovelluksen uudelleenkäynnistyksen jälkeen, mikä vähentää API:n käyttöä. Käytä päivityspainiketta kuvakkeita selatessasi saadaksesi tuoreet tulokset.

## Vianmääritys

Jos API-testi epäonnistuu:
- Tarkista, että avaimesi on oikein (ei ylimääräisiä välilyöntejä)
- Tarkista internetyhteytesi
- macosicons.com-rajapinta saattaa olla tilapäisesti poissa käytöstä
