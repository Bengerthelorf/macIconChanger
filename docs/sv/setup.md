---
title: Initial konfiguration
section: guide
order: 2
locale: sv
---

IconChanger behöver administratörsbehörighet för att byta appikoner. Vid första uppstarten erbjuder appen att konfigurera detta automatiskt.

## Automatisk konfiguration (rekommenderat)

1. Starta IconChanger.
2. Klicka på knappen **Setup** när du uppmanas.
3. Ange ditt administratörslösenord.

Appen installerar ett hjälpskript i `/usr/local/lib/iconchanger/` (ägt av `root:wheel`) och konfigurerar en avgränsad sudoers-regel så att det kan köras utan lösenordsfråga varje gång.

## Säkerhet

IconChanger använder flera säkerhetsåtgärder för att skydda hjälppipelinen:

- **Root-ägd hjälpkatalog** — Hjälpfilerna finns i `/usr/local/lib/iconchanger/` med `root:wheel`-ägande, vilket förhindrar oprivilegierade ändringar.
- **SHA-256 integritetsverifiering** — Hjälpskriptet verifieras mot en känd hash före varje körning.
- **Avgränsad sudoers-regel** — Sudoers-posten ger bara lösenordsfri åtkomst till det specifika hjälpskriptet, inte godtyckliga kommandon.
- **Granskningsloggning** — Alla ikonoperationer loggas med tidsstämplar för spårbarhet.

## Manuell konfiguration

Om den automatiska konfigurationen misslyckas kan du konfigurera det manuellt:

1. Öppna Terminal.
2. Kör:

```bash
sudo visudo -f /etc/sudoers.d/iconchanger
```

3. Lägg till följande rad:

```
ALL ALL=(ALL) NOPASSWD: /usr/local/lib/iconchanger/helper.sh
```

## Verifiera konfigurationen

Efter konfigurationen bör appen visa applistan i sidofältet. Om du ser konfigurationsprompten igen kan det vara så att inställningarna inte tillämpades korrekt.

Du kan verifiera konfigurationen från menyraden: klicka på menyn **...** och välj **Check Setup Status**.

## Begränsningar

Appar som skyddas av macOS System Integrity Protection (SIP) kan inte få sina ikoner ändrade. Detta är en begränsning i macOS och kan inte kringgås.

Vanliga SIP-skyddade appar inkluderar:
- Finder
- Safari (i vissa macOS-versioner)
- Övriga systemappar i `/System/Applications/`