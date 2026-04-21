---
title: Guida rapida
section: guide
order: 1
locale: it
---

## Requisiti

- macOS 13.0 (Ventura) o successivo
- Privilegi di amministratore (per la configurazione iniziale e la modifica delle icone)

## Installazione

### Homebrew (consigliato)

```bash
brew install Bengerthelorf/tap/iconchanger
```

### Download manuale

1. Scaricate l'ultimo DMG da [GitHub Releases](https://github.com/Bengerthelorf/macIconChanger/releases/latest).
2. Aprite il DMG e trascinate **IconChanger** nella cartella Applicazioni.
3. Avviate IconChanger.

## Primo avvio

Al primo avvio, IconChanger vi chiederà di completare una configurazione dei permessi una tantum. Questa operazione è necessaria affinché l'app possa modificare le icone delle applicazioni.

![Schermata di configurazione al primo avvio](/images/setup-prompt.png)

Fate clic sul pulsante di configurazione e inserite la password di amministratore. IconChanger configurerà automaticamente i permessi necessari (una regola sudoers per lo script helper).

::: tip
Se la configurazione automatica non riesce, consultate [Configurazione iniziale](./setup) per le istruzioni manuali.
:::

## Cambiare la prima icona

1. Selezionate un'applicazione dalla barra laterale.
2. Sfogliate le icone da [macOSicons.com](https://macosicons.com/) o scegliete un file immagine locale.
3. Fate clic su un'icona per applicarla.

![Interfaccia principale](/images/main-interface.png)

Ecco fatto! L'icona dell'app verrà cambiata immediatamente.

## Prossimi passi

- [Configurare una chiave API](./api-key) per la ricerca di icone online
- [Scoprite gli alias delle app](./aliases) per risultati di ricerca migliori
- [Configurate il servizio in background](./background-service) per il ripristino automatico delle icone
- [Installate lo strumento CLI](/it/cli/) per l'accesso da riga di comando