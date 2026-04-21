---
title: Kezdeti beállítás
section: guide
order: 2
locale: hu
---

Az IconChanger alkalmazásnak rendszergazdai jogosultságra van szüksége az alkalmazásikonok módosításához. Az első indításkor az alkalmazás felajánlja az automatikus beállítást.

## Automatikus beállítás (ajánlott)

1. Indítsd el az IconChanger alkalmazást.
2. Kattints a **Setup** gombra, amikor a rendszer kéri.
3. Add meg a rendszergazdai jelszavadat.

Az alkalmazás telepíti a segédszkriptet a `/usr/local/lib/iconchanger/` könyvtárba (`root:wheel` tulajdonban), és beállít egy korlátozott sudoers szabályt, hogy a továbbiakban jelszókérés nélkül fusson.

## Biztonság

Az IconChanger több biztonsági intézkedést alkalmaz a segédfolyamat védelmére:

- **Root tulajdonú segédkönyvtár** — A segédfájlok a `/usr/local/lib/iconchanger/` könyvtárban találhatók `root:wheel` tulajdonnal, megakadályozva a jogosulatlan módosításokat.
- **SHA-256 integritás-ellenőrzés** — A segédszkriptet minden futtatás előtt egy ismert hash alapján ellenőrzi a rendszer.
- **Korlátozott sudoers szabály** — A sudoers bejegyzés csak a meghatározott segédszkripthez ad jelszó nélküli hozzáférést, nem tetszőleges parancsokhoz.
- **Auditnapló** — Minden ikonművelet időbélyeggel kerül naplózásra a nyomon követhetőség érdekében.

## Kézi beállítás

Ha az automatikus beállítás sikertelen, kézzel is konfigurálhatod:

1. Nyisd meg a Terminal alkalmazást.
2. Futtasd a következő parancsot:

```bash
sudo visudo -f /etc/sudoers.d/iconchanger
```

3. Add hozzá a következő sort:

```
ALL ALL=(ALL) NOPASSWD: /usr/local/lib/iconchanger/helper.sh
```

## Beállítás ellenőrzése

A beállítás után az alkalmazásnak meg kell jelenítenie az alkalmazáslistát az oldalsávban. Ha újra megjelenik a beállítási képernyő, a konfiguráció nem lett megfelelően alkalmazva.

A beállítást a menüsorból is ellenőrizheted: kattints a **...** menüre, és válaszd a **Check Setup Status** lehetőséget.

## Korlátozások

A macOS rendszerintegritás-védelme (SIP) által védett alkalmazások ikonjai nem módosíthatók. Ez a macOS korlátozása, amelyet nem lehet megkerülni.

Gyakori SIP-védett alkalmazások:
- Finder
- Safari (egyes macOS verziókon)
- Egyéb rendszeralkalmazások a `/System/Applications/` mappában