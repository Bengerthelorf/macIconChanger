# Configurazione iniziale

IconChanger necessita di privilegi di amministratore per modificare le icone delle applicazioni. Al primo avvio, l'app propone di eseguire la configurazione automaticamente.

## Configurazione automatica (consigliata)

1. Avviate IconChanger.
2. Fate clic sul pulsante **Setup** quando richiesto.
3. Inserite la password di amministratore.

L'app installerà uno script helper in `/usr/local/lib/iconchanger/` (di proprietà di `root:wheel`) e configurerà una regola sudoers limitata in modo che possa essere eseguito senza richiedere la password ogni volta.

## Sicurezza

IconChanger utilizza diverse misure di sicurezza per proteggere la pipeline helper:

- **Directory helper di proprietà di root** — I file helper si trovano in `/usr/local/lib/iconchanger/` con proprietà `root:wheel`, impedendo modifiche non privilegiate.
- **Verifica dell'integrità SHA-256** — Lo script helper viene verificato rispetto a un hash noto prima di ogni esecuzione.
- **Regola sudoers limitata** — La voce sudoers concede l'accesso senza password solo allo script helper specifico, non a comandi arbitrari.
- **Registrazione di audit** — Tutte le operazioni sulle icone vengono registrate con timestamp per la tracciabilità.

## Configurazione manuale

Se la configurazione automatica non riesce, è possibile procedere manualmente:

1. Aprite Terminal.
2. Eseguite:

```bash
sudo visudo -f /etc/sudoers.d/iconchanger
```

3. Aggiungete la seguente riga:

```
ALL ALL=(ALL) NOPASSWD: /usr/local/lib/iconchanger/helper.sh
```

## Verifica della configurazione

Dopo la configurazione, l'app dovrebbe mostrare l'elenco delle applicazioni nella barra laterale. Se viene visualizzata nuovamente la schermata di configurazione, la configurazione potrebbe non essere stata applicata correttamente.

È possibile verificare la configurazione dalla barra dei menu: fate clic sul menu **...** e selezionate **Check Setup Status**.

## Limitazioni

Le applicazioni protette dalla System Integrity Protection (SIP) di macOS non possono avere le proprie icone modificate. Si tratta di una restrizione di macOS che non può essere aggirata.

Le app comunemente protette da SIP includono:
- Finder
- Safari (su alcune versioni di macOS)
- Altre applicazioni di sistema in `/System/Applications/`
