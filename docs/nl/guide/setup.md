# Eerste configuratie

IconChanger heeft beheerdersbevoegdheden nodig om apppictogrammen te wijzigen. Bij de eerste keer opstarten biedt de app aan dit automatisch in te stellen.

## Automatische configuratie (aanbevolen)

1. Start IconChanger.
2. Klik op de knop **Setup** wanneer daarom wordt gevraagd.
3. Voer je beheerderswachtwoord in.

De app maakt een hulpscript aan op `~/.iconchanger/helper.sh` en configureert een sudoers-regel zodat het zonder wachtwoordprompt kan worden uitgevoerd.

## Handmatige configuratie

Als de automatische configuratie mislukt, kun je het handmatig instellen:

1. Open Terminal.
2. Voer uit:

```bash
sudo visudo
```

3. Voeg de volgende regel toe aan het einde:

```
ALL ALL=(ALL) NOPASSWD: /Users/<jouw-gebruikersnaam>/.iconchanger/helper.sh
```

Vervang `<jouw-gebruikersnaam>` door je werkelijke macOS-gebruikersnaam.

## Configuratie verifiëren

Na de configuratie zou de app de lijst met apps in de zijbalk moeten tonen. Als je het configuratiescherm opnieuw ziet, is de configuratie mogelijk niet correct toegepast.

Je kunt de configuratie verifiëren via de menubalk: klik op het menu **...** en selecteer **Check Setup Status**.

## Beperkingen

Apps die worden beschermd door macOS System Integrity Protection (SIP) kunnen geen gewijzigde pictogrammen krijgen. Dit is een macOS-beperking en kan niet worden omzeild.

Veelvoorkomende door SIP beschermde apps zijn onder andere:
- Finder
- Safari (op sommige macOS-versies)
- Andere systeemapps in `/System/Applications/`
