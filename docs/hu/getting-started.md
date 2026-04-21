---
title: Gyors kezdés
section: guide
order: 1
locale: hu
---

## Követelmények

- macOS 13.0 (Ventura) vagy újabb
- Rendszergazdai jogosultság (a kezdeti beállításhoz és az ikonok módosításához)

## Telepítés

### Homebrew (ajánlott)

```bash
brew install Bengerthelorf/tap/iconchanger
```

### Kézi letöltés

1. Töltsd le a legújabb DMG-t a [GitHub Releases](https://github.com/Bengerthelorf/macIconChanger/releases/latest) oldalról.
2. Nyisd meg a DMG-t, és húzd az **IconChanger** alkalmazást az Alkalmazások mappába.
3. Indítsd el az IconChanger alkalmazást.

## Első indítás

Az első indításkor az IconChanger felkér egy egyszeri jogosultságbeállítás elvégzésére. Erre azért van szükség, hogy az alkalmazás módosíthassa az alkalmazásikonokat.

![Első indítás beállítási képernyő](/images/setup-prompt.png)

Kattints a beállítás gombra, és add meg a rendszergazdai jelszavadat. Az IconChanger automatikusan konfigurálja a szükséges jogosultságokat (egy sudoers szabályt a segédszkripthez).

::: tip
Ha az automatikus beállítás sikertelen, a kézi utasításokért lásd a [Kezdeti beállítás](./setup) oldalt.
:::

## Az első ikon megváltoztatása

1. Válassz ki egy alkalmazást az oldalsávból.
2. Böngéssz az ikonok között a [macOSicons.com](https://macosicons.com/) oldalon, vagy válassz egy helyi képfájlt.
3. Kattints egy ikonra az alkalmazásához.

![Fő felület](/images/main-interface.png)

Ennyi az egész! Az alkalmazás ikonja azonnal megváltozik.

## Következő lépések

- [API-kulcs beállítása](./api-key) az online ikonkereséshez
- [Ismerkedés az alkalmazás-álnevekkel](./aliases) a jobb keresési eredményekért
- [A háttérszolgáltatás konfigurálása](./background-service) az automatikus ikon-visszaállításhoz
- [A parancssori eszköz telepítése](/hu/cli/) a parancssori hozzáféréshez