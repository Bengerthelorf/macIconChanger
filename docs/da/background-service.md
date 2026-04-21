---
title: Baggrundstjeneste
section: guide
order: 6
locale: da
---

Baggrundstjenesten holder dine brugerdefinerede ikoner intakte, selv efter appopdateringer eller systemændringer.

## Aktivering

Gå til **Settings** > **Background** og slå **Run in Background** til.

Når det er aktiveret, fortsætter IconChanger med at køre, efter du lukker vinduet. Du kan tilgå den fra menulinjen eller Dock.

## Funktioner

### Planlagt gendannelse

Gendan automatisk alle cachede brugerdefinerede ikoner med regelmæssige intervaller.

- Slå **Restore Icons on Schedule** til
- Vælg et interval: hver time, 3 timer, 6 timer, 12 timer, dagligt eller et brugerdefineret interval
- Indstillingerne viser, hvornår den sidste og næste gendannelse finder sted

### Registrering af appopdateringer

Registrer, når apps opdateres, og genanvend automatisk deres brugerdefinerede ikoner.

- Slå **Restore Icons When Apps Update** til
- Indstil, hvor ofte der skal tjekkes for opdateringer (hvert 5. minut til hver 2. time, eller brugerdefineret)

### Appsynlighed

Kontroller, hvor IconChanger vises, når den kører i baggrunden:

- **Show in Menu Bar** — tilføjer et ikon i menulinjen
- **Show in Dock** — beholder appen i Dock

Mindst én af disse skal være aktiveret.

### Start ved login

Start IconChanger automatisk, når du logger ind på din Mac.

- **Open Main Window** — starter normalt med hovedvinduet
- **Start Hidden** — starter lydløst i baggrunden (kræver at "Run in Background" er aktiveret)

::: info
"Start Hidden" påvirker kun opstart ved login. Manuel åbning af appen vil altid vise hovedvinduet.
:::

## Tjenestestatus

Når baggrundstjenesten er aktiv, viser indstillingssiden:
- **Service Status** — om tjenesten kører
- **Cached Icons** — hvor mange ikoner der er klar til gendannelse