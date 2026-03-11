# Configurazione iniziale

IconChanger necessita di privilegi di amministratore per modificare le icone delle applicazioni. Al primo avvio, l'app propone di eseguire la configurazione automaticamente.

## Configurazione automatica (consigliata)

1. Avviate IconChanger.
2. Fate clic sul pulsante **Setup** quando richiesto.
3. Inserite la password di amministratore.

L'app creerà uno script helper in `~/.iconchanger/helper.sh` e configurerà una regola sudoers in modo che possa essere eseguito senza richiedere la password ogni volta.

## Configurazione manuale

Se la configurazione automatica non riesce, è possibile procedere manualmente:

1. Aprite Terminal.
2. Eseguite:

```bash
sudo visudo
```

3. Aggiungete la seguente riga alla fine:

```
ALL ALL=(ALL) NOPASSWD: /Users/<nome-utente>/.iconchanger/helper.sh
```

Sostituite `<nome-utente>` con il vostro nome utente macOS effettivo.

## Verifica della configurazione

Dopo la configurazione, l'app dovrebbe mostrare l'elenco delle applicazioni nella barra laterale. Se viene visualizzata nuovamente la schermata di configurazione, la configurazione potrebbe non essere stata applicata correttamente.

È possibile verificare la configurazione dalla barra dei menu: fate clic sul menu **...** e selezionate **Check Setup Status**.

## Limitazioni

Le applicazioni protette dalla System Integrity Protection (SIP) di macOS non possono avere le proprie icone modificate. Si tratta di una restrizione di macOS che non può essere aggirata.

Le app comunemente protette da SIP includono:
- Finder
- Safari (su alcune versioni di macOS)
- Altre applicazioni di sistema in `/System/Applications/`
