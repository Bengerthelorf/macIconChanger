# Alkumääritys

IconChanger tarvitsee ylläpitäjän oikeudet sovellusten kuvakkeiden vaihtamiseen. Ensimmäisellä käynnistyskerralla sovellus tarjoaa mahdollisuuden määrittää tämän automaattisesti.

## Automaattinen määritys (suositeltu)

1. Käynnistä IconChanger.
2. Napsauta **Setup**-painiketta pyydettäessä.
3. Anna ylläpitäjän salasanasi.

Sovellus luo apuskriptin polkuun `~/.iconchanger/helper.sh` ja määrittää sudoers-säännön, jotta skripti voidaan suorittaa ilman salasanakyselyä joka kerralla.

## Manuaalinen määritys

Jos automaattinen määritys epäonnistuu, voit tehdä sen manuaalisesti:

1. Avaa Pääte.
2. Suorita:

```bash
sudo visudo
```

3. Lisää seuraava rivi loppuun:

```
ALL ALL=(ALL) NOPASSWD: /Users/<käyttäjänimesi>/.iconchanger/helper.sh
```

Korvaa `<käyttäjänimesi>` todellisella macOS-käyttäjänimelläsi.

## Määrityksen tarkistaminen

Määrityksen jälkeen sovelluksen pitäisi näyttää sovellusluettelo sivupalkissa. Jos näet määrityskehotteen uudelleen, asetuksia ei ehkä ole otettu käyttöön oikein.

Voit tarkistaa määrityksen tilarivin kautta: napsauta **...**-valikkoa ja valitse **Check Setup Status**.

## Rajoitukset

Sovelluksia, jotka ovat macOS:n järjestelmän eheyssuojauksen (SIP) suojaamia, ei voida vaihtaa. Tämä on macOS:n rajoitus, jota ei voida ohittaa.

Yleisiä SIP-suojattuja sovelluksia ovat:
- Finder
- Safari (joissain macOS-versioissa)
- Muut järjestelmäsovellukset kansiossa `/System/Applications/`
