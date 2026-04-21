---
title: Bakgrundstjänst
section: guide
order: 6
locale: sv
---

Bakgrundstjänsten håller dina anpassade ikoner intakta, även efter appuppdateringar eller systemändringar.

## Aktivering

Gå till **Settings** > **Background** och aktivera **Run in Background**.

När detta är aktiverat fortsätter IconChanger att köras efter att du stänger fönstret. Du kan komma åt appen från menyraden eller Dock.

## Funktioner

### Schemalagd återställning

Återställ automatiskt alla cachade anpassade ikoner med jämna mellanrum.

- Aktivera **Restore Icons on Schedule**
- Välj ett intervall: varje timme, var 3:e timme, var 6:e timme, var 12:e timme, dagligen eller ett anpassat intervall
- Inställningarna visar när den senaste och nästa återställningen sker

### Detektering av appuppdateringar

Upptäck när appar uppdateras och tillämpa automatiskt deras anpassade ikoner på nytt.

- Aktivera **Restore Icons When Apps Update**
- Ställ in hur ofta uppdateringar ska kontrolleras (var 5:e minut till varannan timme, eller anpassat)

### Appsynlighet

Kontrollera var IconChanger visas när den körs i bakgrunden:

- **Show in Menu Bar** — lägger till en ikon i menyraden
- **Show in Dock** — behåller appen i Dock

Minst ett av dessa alternativ måste vara aktiverat.

### Starta vid inloggning

Starta IconChanger automatiskt när du loggar in på din Mac.

- **Open Main Window** — startar normalt med huvudfönstret
- **Start Hidden** — startar tyst i bakgrunden (kräver att "Run in Background" är aktiverat)

::: info
"Start Hidden" påverkar bara start vid inloggning. Att öppna appen manuellt visar alltid huvudfönstret.
:::

## Tjänstestatus

När bakgrundstjänsten är aktiv visar inställningssidan:
- **Service Status** — om tjänsten körs
- **Cached Icons** — hur många ikoner som är redo för återställning