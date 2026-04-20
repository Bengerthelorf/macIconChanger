# Bakgrunnstjeneste

Bakgrunnstjenesten holder dine egendefinerte ikoner intakte, selv etter appoppdateringer eller systemendringer.

## Aktivering

Gå til **Settings** > **Background** og slå på **Run in Background**.

Når dette er aktivert, fortsetter IconChanger å kjøre etter at du lukker vinduet. Du kan nå den fra menylinjen eller Dock.

## Funksjoner

### Planlagt gjenoppretting

Gjenopprett alle bufrede egendefinerte ikoner automatisk med jevne mellomrom.

- Slå på **Restore Icons on Schedule**
- Velg et intervall: hver time, 3 timer, 6 timer, 12 timer, daglig, eller et egendefinert intervall
- Innstillingene viser når siste og neste gjenoppretting vil skje

### Oppdage appoppdateringer

Oppdage når apper oppdateres og automatisk bruke de egendefinerte ikonene på nytt.

- Slå på **Restore Icons When Apps Update**
- Angi hvor ofte det skal sjekkes for oppdateringer (hvert 5. minutt til annenhver time, eller egendefinert)

### App-synlighet

Kontroller hvor IconChanger vises når den kjører i bakgrunnen:

- **Show in Menu Bar** -- legger til et ikon i menylinjen
- **Show in Dock** -- beholder appen i Dock

Minst ett av disse må være aktivert.

### Start ved innlogging

Start IconChanger automatisk når du logger inn på Mac-en.

- **Open Main Window** -- starter normalt med hovedvinduet
- **Start Hidden** -- starter stille i bakgrunnen (krever at «Run in Background» er aktivert)

::: info
«Start Hidden» påvirker bare oppstart ved innlogging. Å åpne appen manuelt vil alltid vise hovedvinduet.
:::

## Tjenestestatus

Når bakgrunnstjenesten er aktiv, viser innstillingssiden:
- **Service Status** -- om tjenesten kjører
- **Cached Icons** -- hvor mange ikoner som er klare for gjenoppretting
