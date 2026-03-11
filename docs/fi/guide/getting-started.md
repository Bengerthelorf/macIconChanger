# Pikaopas

## Vaatimukset

- macOS 13.0 (Ventura) tai uudempi
- Ylläpitäjän oikeudet (alkumääritystä ja kuvakkeiden vaihtamista varten)

## Asennus

### Homebrew (suositeltu)

```bash
brew install Bengerthelorf/tap/iconchanger
```

### Manuaalinen lataus

1. Lataa uusin DMG [GitHub Releases](https://github.com/Bengerthelorf/macIconChanger/releases/latest) -sivulta.
2. Avaa DMG ja vedä **IconChanger** Ohjelmat-kansioon.
3. Käynnistä IconChanger.

## Ensimmäinen käynnistys

Ensimmäisellä käynnistyskerralla IconChanger pyytää sinua suorittamaan kertaluonteisen käyttöoikeuksien määrityksen. Tämä vaaditaan, jotta sovellus voi vaihtaa sovellusten kuvakkeita.

![Ensimmäisen käynnistyksen määritysnäyttö](/images/setup-prompt.png)

Napsauta määrityspainiketta ja anna ylläpitäjän salasanasi. IconChanger määrittää tarvittavat käyttöoikeudet automaattisesti (sudoers-sääntö apuskriptiä varten).

::: tip
Jos automaattinen määritys epäonnistuu, katso [Alkumääritys](./setup) manuaalisia ohjeita varten.
:::

## Ensimmäisen kuvakkeen vaihtaminen

1. Valitse sovellus sivupalkista.
2. Selaa kuvakkeita [macOSicons.com](https://macosicons.com/)-sivustolta tai valitse paikallinen kuvatiedosto.
3. Napsauta kuvaketta ottaaksesi sen käyttöön.

![Pääkäyttöliittymä](/images/main-interface.png)

Siinä kaikki! Sovelluksen kuvake vaihtuu välittömästi.

## Seuraavat vaiheet

- [Määritä API-avain](./api-key) verkkokuvakehakua varten
- [Tutustu sovellusten aliaksiin](./aliases) parempien hakutulosten saamiseksi
- [Määritä taustapalvelu](./background-service) automaattista kuvakkeiden palautusta varten
- [Asenna komentoriviliittymä](/fi/cli/) komentoriviä varten
