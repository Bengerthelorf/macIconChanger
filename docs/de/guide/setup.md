# Ersteinrichtung

IconChanger benötigt Administratorrechte, um Anwendungssymbole zu ändern. Beim ersten Start bietet die App an, dies automatisch einzurichten.

## Automatische Einrichtung (empfohlen)

1. Starten Sie IconChanger.
2. Klicken Sie auf die Schaltfläche **Setup**, wenn Sie dazu aufgefordert werden.
3. Geben Sie Ihr Administratorpasswort ein.

Die App erstellt ein Hilfsskript unter `~/.iconchanger/helper.sh` und konfiguriert eine sudoers-Regel, damit es ohne wiederholte Passworteingabe ausgeführt werden kann.

## Manuelle Einrichtung

Falls die automatische Einrichtung fehlschlägt, können Sie die Konfiguration manuell vornehmen:

1. Öffnen Sie das Terminal.
2. Führen Sie folgenden Befehl aus:

```bash
sudo visudo
```

3. Fügen Sie die folgende Zeile am Ende hinzu:

```
ALL ALL=(ALL) NOPASSWD: /Users/<ihr-benutzername>/.iconchanger/helper.sh
```

Ersetzen Sie `<ihr-benutzername>` durch Ihren tatsächlichen macOS-Benutzernamen.

## Einrichtung überprüfen

Nach der Einrichtung sollte die App die Anwendungsliste in der Seitenleiste anzeigen. Wenn Sie erneut zur Einrichtung aufgefordert werden, wurde die Konfiguration möglicherweise nicht korrekt angewendet.

Sie können die Einrichtung über die Menüleiste überprüfen: Klicken Sie auf das Menü **...** und wählen Sie **Check Setup Status**.

## Einschränkungen

Anwendungen, die durch den macOS-Systemintegritätsschutz (SIP) geschützt sind, können nicht geändert werden. Dies ist eine macOS-Einschränkung und kann nicht umgangen werden.

Häufige SIP-geschützte Apps:
- Finder
- Safari (bei einigen macOS-Versionen)
- Andere Systemanwendungen in `/System/Applications/`
