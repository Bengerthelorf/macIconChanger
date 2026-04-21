---
title: Alkumääritys
section: guide
order: 2
locale: fi
---

IconChanger tarvitsee ylläpitäjän oikeudet sovellusten kuvakkeiden vaihtamiseen. Ensimmäisellä käynnistyskerralla sovellus tarjoaa mahdollisuuden määrittää tämän automaattisesti.

## Automaattinen määritys (suositeltu)

1. Käynnistä IconChanger.
2. Napsauta **Setup**-painiketta pyydettäessä.
3. Anna ylläpitäjän salasanasi.

Sovellus asentaa apuskriptin polkuun `/usr/local/lib/iconchanger/` (omistaja `root:wheel`) ja määrittää rajatun sudoers-säännön, jotta skripti voidaan suorittaa ilman salasanakyselyä joka kerralla.

## Tietoturva

IconChanger käyttää useita turvatoimia apuputken suojaamiseksi:

- **Rootin omistama apuhakemisto** — Aputiedostot sijaitsevat polussa `/usr/local/lib/iconchanger/` ja ne ovat `root:wheel`-omistuksessa, mikä estää oikeudettomien käyttäjien muokkaukset.
- **SHA-256-eheyden tarkistus** — Apuskripti tarkistetaan tunnettua tiivistettä vasten ennen jokaista suoritusta.
- **Rajattu sudoers-sääntö** — Sudoers-merkintä myöntää salasanattoman pääsyn vain tiettyyn apuskriptiin, ei mielivaltaisiin komentoihin.
- **Tarkastusloki** — Kaikki kuvakeoperaatiot kirjataan aikaleimoilla jäljitettävyyttä varten.

## Manuaalinen määritys

Jos automaattinen määritys epäonnistuu, voit tehdä sen manuaalisesti:

1. Avaa Pääte.
2. Suorita:

```bash
sudo visudo -f /etc/sudoers.d/iconchanger
```

3. Lisää seuraava rivi:

```
ALL ALL=(ALL) NOPASSWD: /usr/local/lib/iconchanger/helper.sh
```

## Määrityksen tarkistaminen

Määrityksen jälkeen sovelluksen pitäisi näyttää sovellusluettelo sivupalkissa. Jos näet määrityskehotteen uudelleen, asetuksia ei ehkä ole otettu käyttöön oikein.

Voit tarkistaa määrityksen tilarivin kautta: napsauta **...**-valikkoa ja valitse **Check Setup Status**.

## Rajoitukset

Sovelluksia, jotka ovat macOS:n järjestelmän eheyssuojauksen (SIP) suojaamia, ei voida vaihtaa. Tämä on macOS:n rajoitus, jota ei voida ohittaa.

Yleisiä SIP-suojattuja sovelluksia ovat:
- Finder
- Safari (joissain macOS-versioissa)
- Muut järjestelmäsovellukset kansiossa `/System/Applications/`