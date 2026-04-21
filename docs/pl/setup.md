---
title: Wstępna konfiguracja
section: guide
order: 2
locale: pl
---

IconChanger wymaga uprawnień administratora do zmiany ikon aplikacji. Przy pierwszym uruchomieniu aplikacja oferuje automatyczną konfigurację.

## Automatyczna konfiguracja (zalecana)

1. Uruchom IconChanger.
2. Kliknij przycisk **Setup**, gdy zostaniesz o to poproszony.
3. Wprowadź hasło administratora.

Aplikacja zainstaluje skrypt pomocniczy w `/usr/local/lib/iconchanger/` (właściciel `root:wheel`) i skonfiguruje ograniczoną regułę sudoers, aby mógł on działać bez pytania o hasło za każdym razem.

## Bezpieczeństwo

IconChanger stosuje kilka środków bezpieczeństwa w celu ochrony pipeline'u pomocniczego:

- **Katalog pomocniczy należący do roota** — Pliki pomocnicze znajdują się w `/usr/local/lib/iconchanger/` z własnością `root:wheel`, co uniemożliwia nieuprawnione modyfikacje.
- **Weryfikacja integralności SHA-256** — Skrypt pomocniczy jest weryfikowany na podstawie znanego hasha przed każdym uruchomieniem.
- **Ograniczona reguła sudoers** — Wpis sudoers przyznaje dostęp bez hasła tylko do konkretnego skryptu pomocniczego, a nie do dowolnych poleceń.
- **Dziennik audytu** — Wszystkie operacje na ikonach są rejestrowane ze znacznikami czasu w celu zapewnienia identyfikowalności.

## Ręczna konfiguracja

Jeśli automatyczna konfiguracja się nie powiedzie, możesz skonfigurować ją ręcznie:

1. Otwórz Terminal.
2. Uruchom:

```bash
sudo visudo -f /etc/sudoers.d/iconchanger
```

3. Dodaj następującą linię:

```
ALL ALL=(ALL) NOPASSWD: /usr/local/lib/iconchanger/helper.sh
```

## Weryfikacja konfiguracji

Po konfiguracji aplikacja powinna wyświetlić listę aplikacji na pasku bocznym. Jeśli ponownie widzisz monit o konfigurację, konfiguracja mogła nie zostać zastosowana prawidłowo.

Możesz zweryfikować konfigurację z paska menu: kliknij menu **...** i wybierz **Check Setup Status**.

## Ograniczenia

Aplikacje chronione przez System Integrity Protection (SIP) macOS nie mogą mieć zmienionych ikon. Jest to ograniczenie systemu macOS i nie można go obejść.

Popularne aplikacje chronione przez SIP:
- Finder
- Safari (w niektórych wersjach macOS)
- Inne aplikacje systemowe w `/System/Applications/`