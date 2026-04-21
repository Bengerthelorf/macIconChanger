---
title: Szybki start
section: guide
order: 1
locale: pl
---

## Wymagania

- macOS 13.0 (Ventura) lub nowszy
- Uprawnienia administratora (do wstępnej konfiguracji i zmiany ikon)

## Instalacja

### Homebrew (zalecane)

```bash
brew install Bengerthelorf/tap/iconchanger
```

### Pobieranie ręczne

1. Pobierz najnowszy plik DMG z [GitHub Releases](https://github.com/Bengerthelorf/macIconChanger/releases/latest).
2. Otwórz plik DMG i przeciągnij **IconChanger** do folderu Aplikacje.
3. Uruchom IconChanger.

## Pierwsze uruchomienie

Przy pierwszym uruchomieniu IconChanger poprosi o jednorazową konfigurację uprawnień. Jest to wymagane, aby aplikacja mogła zmieniać ikony aplikacji.

![Ekran konfiguracji przy pierwszym uruchomieniu](/images/setup-prompt.png)

Kliknij przycisk konfiguracji i wprowadź hasło administratora. IconChanger automatycznie skonfiguruje niezbędne uprawnienia (reguła sudoers dla skryptu pomocniczego).

::: tip
Jeśli automatyczna konfiguracja się nie powiedzie, zapoznaj się z [Wstępną konfiguracją](./setup), aby uzyskać instrukcje ręcznej konfiguracji.
:::

## Zmiana pierwszej ikony

1. Wybierz aplikację z paska bocznego.
2. Przeglądaj ikony z [macOSicons.com](https://macosicons.com/) lub wybierz lokalny plik obrazu.
3. Kliknij ikonę, aby ją zastosować.

![Główny interfejs](/images/main-interface.png)

To wszystko! Ikona aplikacji zostanie zmieniona natychmiast.

## Następne kroki

- [Skonfiguruj klucz API](./api-key) do wyszukiwania ikon online
- [Dowiedz się o aliasach aplikacji](./aliases), aby uzyskać lepsze wyniki wyszukiwania
- [Skonfiguruj usługę w tle](./background-service) do automatycznego przywracania ikon
- [Zainstaluj narzędzie CLI](/pl/cli/) do obsługi z wiersza poleceń