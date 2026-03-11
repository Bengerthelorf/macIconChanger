# Servizio in background

Il servizio in background mantiene intatte le icone personalizzate, anche dopo aggiornamenti delle app o modifiche al sistema.

## Attivazione

Andate in **Settings** > **Background** e attivate **Run in Background**.

Quando attivato, IconChanger continua a funzionare dopo la chiusura della finestra. È possibile accedervi dalla barra dei menu o dal Dock.

## Funzionalità

### Ripristino programmato

Ripristina automaticamente tutte le icone personalizzate memorizzate nella cache a intervalli regolari.

- Attivate **Restore Icons on Schedule**
- Scegliete un intervallo: ogni ora, 3 ore, 6 ore, 12 ore, giornaliero o un intervallo personalizzato
- Le impostazioni mostrano quando è avvenuto l'ultimo ripristino e quando avverrà il prossimo

### Rilevamento aggiornamenti app

Rileva quando le app vengono aggiornate e riapplica automaticamente le icone personalizzate.

- Attivate **Restore Icons When Apps Update**
- Impostate la frequenza di controllo degli aggiornamenti (da ogni 5 minuti a ogni 2 ore, o personalizzata)

### Visibilità dell'app

Controllate dove IconChanger viene visualizzato quando è in esecuzione in background:

- **Show in Menu Bar** — aggiunge un'icona alla barra dei menu
- **Show in Dock** — mantiene l'app nel Dock

Almeno una di queste opzioni deve essere attivata.

### Avvio al login

Avviate IconChanger automaticamente quando effettuate l'accesso al Mac.

- **Open Main Window** — avvia normalmente con la finestra principale
- **Start Hidden** — avvia silenziosamente in background (richiede che "Run in Background" sia attivato)

::: info
"Start Hidden" riguarda solo l'avvio al login. L'apertura manuale dell'app mostrerà sempre la finestra principale.
:::

## Stato del servizio

Quando il servizio in background è attivo, la pagina delle impostazioni mostra:
- **Service Status** — se il servizio è in esecuzione
- **Cached Icons** — quante icone sono pronte per il ripristino
