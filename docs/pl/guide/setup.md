# Wstępna konfiguracja

IconChanger wymaga uprawnień administratora do zmiany ikon aplikacji. Przy pierwszym uruchomieniu aplikacja oferuje automatyczną konfigurację.

## Automatyczna konfiguracja (zalecana)

1. Uruchom IconChanger.
2. Kliknij przycisk **Setup**, gdy zostaniesz o to poproszony.
3. Wprowadź hasło administratora.

Aplikacja utworzy skrypt pomocniczy w `~/.iconchanger/helper.sh` i skonfiguruje regułę sudoers, aby mógł on działać bez pytania o hasło za każdym razem.

## Ręczna konfiguracja

Jeśli automatyczna konfiguracja się nie powiedzie, możesz skonfigurować ją ręcznie:

1. Otwórz Terminal.
2. Uruchom:

```bash
sudo visudo
```

3. Dodaj następującą linię na końcu:

```
ALL ALL=(ALL) NOPASSWD: /Users/<twoja-nazwa-uzytkownika>/.iconchanger/helper.sh
```

Zastąp `<twoja-nazwa-uzytkownika>` swoją rzeczywistą nazwą użytkownika macOS.

## Weryfikacja konfiguracji

Po konfiguracji aplikacja powinna wyświetlić listę aplikacji na pasku bocznym. Jeśli ponownie widzisz monit o konfigurację, konfiguracja mogła nie zostać zastosowana prawidłowo.

Możesz zweryfikować konfigurację z paska menu: kliknij menu **...** i wybierz **Check Setup Status**.

## Ograniczenia

Aplikacje chronione przez System Integrity Protection (SIP) macOS nie mogą mieć zmienionych ikon. Jest to ograniczenie systemu macOS i nie można go obejść.

Popularne aplikacje chronione przez SIP:
- Finder
- Safari (w niektórych wersjach macOS)
- Inne aplikacje systemowe w `/System/Applications/`
