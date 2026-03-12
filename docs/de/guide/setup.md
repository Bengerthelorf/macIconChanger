# Ersteinrichtung

IconChanger benötigt Administratorrechte, um Anwendungssymbole zu ändern. Beim ersten Start bietet die App an, dies automatisch einzurichten.

## Automatische Einrichtung (empfohlen)

1. Starten Sie IconChanger.
2. Klicken Sie auf die Schaltfläche **Setup**, wenn Sie dazu aufgefordert werden.
3. Geben Sie Ihr Administratorpasswort ein.

Die App installiert ein Hilfsskript unter `/usr/local/lib/iconchanger/` (Eigentümer: `root:wheel`) und konfiguriert eine eingeschränkte sudoers-Regel, damit es ohne wiederholte Passworteingabe ausgeführt werden kann.

## Sicherheit

IconChanger verwendet mehrere Sicherheitsmaßnahmen zum Schutz der Hilfspipeline:

- **Root-eigenes Hilfsverzeichnis** — Die Hilfsdateien befinden sich in `/usr/local/lib/iconchanger/` mit `root:wheel`-Eigentümerschaft, wodurch unprivilegierte Änderungen verhindert werden.
- **SHA-256-Integritätsprüfung** — Das Hilfsskript wird vor jeder Ausführung gegen einen bekannten Hash überprüft.
- **Eingeschränkte sudoers-Regel** — Der sudoers-Eintrag gewährt nur passwortlosen Zugriff auf das spezifische Hilfsskript, nicht auf beliebige Befehle.
- **Audit-Protokollierung** — Alle Symboloperationen werden mit Zeitstempeln für die Nachverfolgbarkeit protokolliert.

## Manuelle Einrichtung

Falls die automatische Einrichtung fehlschlägt, können Sie die Konfiguration manuell vornehmen:

1. Öffnen Sie das Terminal.
2. Führen Sie folgenden Befehl aus:

```bash
sudo visudo -f /etc/sudoers.d/iconchanger
```

3. Fügen Sie die folgende Zeile hinzu:

```
ALL ALL=(ALL) NOPASSWD: /usr/local/lib/iconchanger/helper.sh
```

## Einrichtung überprüfen

Nach der Einrichtung sollte die App die Anwendungsliste in der Seitenleiste anzeigen. Wenn Sie erneut zur Einrichtung aufgefordert werden, wurde die Konfiguration möglicherweise nicht korrekt angewendet.

Sie können die Einrichtung über die Menüleiste überprüfen: Klicken Sie auf das Menü **...** und wählen Sie **Check Setup Status**.

## Einschränkungen

Anwendungen, die durch den macOS-Systemintegritätsschutz (SIP) geschützt sind, können nicht geändert werden. Dies ist eine macOS-Einschränkung und kann nicht umgangen werden.

Häufige SIP-geschützte Apps:
- Finder
- Safari (bei einigen macOS-Versionen)
- Andere Systemanwendungen in `/System/Applications/`
