# Chiave API

Una chiave API di [macosicons.com](https://macosicons.com/) è necessaria per cercare icone online. Senza di essa, è comunque possibile utilizzare file immagine locali.

## Ottenere una chiave API

1. Visitate [macosicons.com](https://macosicons.com/) e create un account.
2. Richiedete una chiave API dalle impostazioni del vostro account.
3. Copiate la chiave.

![Come ottenere una chiave API](/images/api-key.png)

## Inserire la chiave

1. Aprite IconChanger.
2. Andate in **Settings** > **Advanced**.
3. Incollate la chiave API nel campo **API Key**.
4. Fate clic su **Test Connection** per verificarne il funzionamento.

![Impostazioni chiave API](/images/api-key-settings.png)

## Utilizzo senza chiave API

È comunque possibile cambiare le icone delle app senza una chiave API:

- Utilizzando file immagine locali (fate clic su **Choose from the Local** o trascinate un'immagine)
- Utilizzando le icone incluse nell'app stessa (mostrate nella sezione "Local")

## Impostazioni API avanzate

In **Settings** > **Advanced** > **API Settings**, potete regolare in modo preciso il comportamento dell'API:

| Impostazione | Predefinito | Descrizione |
|---|---|---|
| **Retry Count** | 0 (nessun nuovo tentativo) | Quante volte riprovare una richiesta non riuscita (0–3) |
| **Timeout** | 15 secondi | Timeout per ogni singolo tentativo di richiesta |
| **Monthly Limit** | 50 | Numero massimo di query API al mese |

Il contatore **Monthly Usage** mostra l'utilizzo corrente. Si azzera automaticamente il 1° di ogni mese, oppure potete azzerarlo manualmente.

### Cache di ricerca icone

Attivate **Cache API Results** per salvare i risultati di ricerca su disco. I risultati memorizzati nella cache persistono dopo il riavvio dell'app, riducendo l'utilizzo dell'API. Utilizzate il pulsante di aggiornamento durante la navigazione delle icone per ottenere risultati aggiornati.

## Risoluzione dei problemi

Se il test dell'API non riesce:
- Verificate che la chiave sia corretta (senza spazi aggiuntivi)
- Controllate la connessione a Internet
- L'API di macosicons.com potrebbe essere temporaneamente non disponibile
