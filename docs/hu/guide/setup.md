# Kezdeti beállítás

Az IconChanger alkalmazásnak rendszergazdai jogosultságra van szüksége az alkalmazásikonok módosításához. Az első indításkor az alkalmazás felajánlja az automatikus beállítást.

## Automatikus beállítás (ajánlott)

1. Indítsd el az IconChanger alkalmazást.
2. Kattints a **Setup** gombra, amikor a rendszer kéri.
3. Add meg a rendszergazdai jelszavadat.

Az alkalmazás létrehoz egy segédszkriptet a `~/.iconchanger/helper.sh` helyen, és beállít egy sudoers szabályt, hogy a továbbiakban jelszókérés nélkül fusson.

## Kézi beállítás

Ha az automatikus beállítás sikertelen, kézzel is konfigurálhatod:

1. Nyisd meg a Terminal alkalmazást.
2. Futtasd a következő parancsot:

```bash
sudo visudo
```

3. Add hozzá a következő sort a fájl végéhez:

```
ALL ALL=(ALL) NOPASSWD: /Users/<felhasználóneved>/.iconchanger/helper.sh
```

A `<felhasználóneved>` helyére írd a tényleges macOS felhasználónevedet.

## Beállítás ellenőrzése

A beállítás után az alkalmazásnak meg kell jelenítenie az alkalmazáslistát az oldalsávban. Ha újra megjelenik a beállítási képernyő, a konfiguráció nem lett megfelelően alkalmazva.

A beállítást a menüsorból is ellenőrizheted: kattints a **...** menüre, és válaszd a **Check Setup Status** lehetőséget.

## Korlátozások

A macOS rendszerintegritás-védelme (SIP) által védett alkalmazások ikonjai nem módosíthatók. Ez a macOS korlátozása, amelyet nem lehet megkerülni.

Gyakori SIP-védett alkalmazások:
- Finder
- Safari (egyes macOS verziókon)
- Egyéb rendszeralkalmazások a `/System/Applications/` mappában
