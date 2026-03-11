# Initial konfiguration

IconChanger behöver administratörsbehörighet för att byta appikoner. Vid första uppstarten erbjuder appen att konfigurera detta automatiskt.

## Automatisk konfiguration (rekommenderat)

1. Starta IconChanger.
2. Klicka på knappen **Setup** när du uppmanas.
3. Ange ditt administratörslösenord.

Appen skapar ett hjälpskript på `~/.iconchanger/helper.sh` och konfigurerar en sudoers-regel så att det kan köras utan lösenordsfråga varje gång.

## Manuell konfiguration

Om den automatiska konfigurationen misslyckas kan du konfigurera det manuellt:

1. Öppna Terminal.
2. Kör:

```bash
sudo visudo
```

3. Lägg till följande rad i slutet:

```
ALL ALL=(ALL) NOPASSWD: /Users/<ditt-användarnamn>/.iconchanger/helper.sh
```

Ersätt `<ditt-användarnamn>` med ditt faktiska macOS-användarnamn.

## Verifiera konfigurationen

Efter konfigurationen bör appen visa applistan i sidofältet. Om du ser konfigurationsprompten igen kan det vara så att inställningarna inte tillämpades korrekt.

Du kan verifiera konfigurationen från menyraden: klicka på menyn **...** och välj **Check Setup Status**.

## Begränsningar

Appar som skyddas av macOS System Integrity Protection (SIP) kan inte få sina ikoner ändrade. Detta är en begränsning i macOS och kan inte kringgås.

Vanliga SIP-skyddade appar inkluderar:
- Finder
- Safari (i vissa macOS-versioner)
- Övriga systemappar i `/System/Applications/`
