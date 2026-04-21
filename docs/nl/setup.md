---
title: Eerste configuratie
section: guide
order: 2
locale: nl
---

IconChanger heeft beheerdersbevoegdheden nodig om apppictogrammen te wijzigen. Bij de eerste keer opstarten biedt de app aan dit automatisch in te stellen.

## Automatische configuratie (aanbevolen)

1. Start IconChanger.
2. Klik op de knop **Setup** wanneer daarom wordt gevraagd.
3. Voer je beheerderswachtwoord in.

De app installeert een hulpscript in `/usr/local/lib/iconchanger/` (eigendom van `root:wheel`) en configureert een afgebakende sudoers-regel zodat het zonder wachtwoordprompt kan worden uitgevoerd.

## Beveiliging

IconChanger gebruikt meerdere beveiligingsmaatregelen om de hulppipeline te beschermen:

- **Root-eigendom hulpmap** — De hulpbestanden bevinden zich in `/usr/local/lib/iconchanger/` met `root:wheel`-eigendom, waardoor onbevoegde wijzigingen worden voorkomen.
- **SHA-256 integriteitsverificatie** — Het hulpscript wordt voor elke uitvoering geverifieerd aan de hand van een bekende hash.
- **Afgebakende sudoers-regel** — De sudoers-vermelding verleent alleen wachtwoordloze toegang tot het specifieke hulpscript, niet tot willekeurige commando's.
- **Auditlogboek** — Alle pictogramoperaties worden geregistreerd met tijdstempels voor traceerbaarheid.

## Handmatige configuratie

Als de automatische configuratie mislukt, kun je het handmatig instellen:

1. Open Terminal.
2. Voer uit:

```bash
sudo visudo -f /etc/sudoers.d/iconchanger
```

3. Voeg de volgende regel toe:

```
ALL ALL=(ALL) NOPASSWD: /usr/local/lib/iconchanger/helper.sh
```

## Configuratie verifiëren

Na de configuratie zou de app de lijst met apps in de zijbalk moeten tonen. Als je het configuratiescherm opnieuw ziet, is de configuratie mogelijk niet correct toegepast.

Je kunt de configuratie verifiëren via de menubalk: klik op het menu **...** en selecteer **Check Setup Status**.

## Beperkingen

Apps die worden beschermd door macOS System Integrity Protection (SIP) kunnen geen gewijzigde pictogrammen krijgen. Dit is een macOS-beperking en kan niet worden omzeild.

Veelvoorkomende door SIP beschermde apps zijn onder andere:
- Finder
- Safari (op sommige macOS-versies)
- Andere systeemapps in `/System/Applications/`