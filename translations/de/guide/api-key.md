# API-Schlüssel

Ein API-Schlüssel von [macosicons.com](https://macosicons.com/) ist erforderlich, um online nach Symbolen zu suchen. Ohne ihn können Sie weiterhin lokale Bilddateien verwenden.

## API-Schlüssel erhalten

1. Besuchen Sie [macosicons.com](https://macosicons.com/) und erstellen Sie ein Konto.
2. Fordern Sie in Ihren Kontoeinstellungen einen API-Schlüssel an.
3. Kopieren Sie den Schlüssel.

![So erhalten Sie einen API-Schlüssel](/images/api-key.png)

## Schlüssel eingeben

1. Öffnen Sie IconChanger.
2. Gehen Sie zu **Einstellungen** > **Erweitert**.
3. Fügen Sie Ihren API-Schlüssel in das Feld **API Key** ein.
4. Klicken Sie auf **Test Connection**, um die Funktion zu überprüfen.

![API-Schlüssel-Einstellungen](/images/api-key-settings.png)

## Verwendung ohne API-Schlüssel

Sie können App-Symbole auch ohne API-Schlüssel ändern:

- Verwenden Sie lokale Bilddateien (klicken Sie auf **Choose from the Local** oder ziehen Sie ein Bild per Drag & Drop)
- Verwenden Sie Symbole, die in der App selbst enthalten sind (angezeigt im Bereich "Local")

## Erweiterte API-Einstellungen

Unter **Einstellungen** > **Erweitert** > **API-Einstellungen** können Sie das API-Verhalten feinabstimmen:

| Einstellung | Standard | Beschreibung |
|---|---|---|
| **Retry Count** | 0 (kein Wiederholungsversuch) | Anzahl der Wiederholungsversuche bei fehlgeschlagenen Anfragen (0–3) |
| **Timeout** | 15 Sekunden | Zeitlimit pro Anfrage |
| **Monthly Limit** | 50 | Maximale API-Abfragen pro Monat |

Der Zähler **Monthly Usage** zeigt Ihre aktuelle Nutzung an. Er wird automatisch am 1. jedes Monats zurückgesetzt, oder Sie können ihn manuell zurücksetzen.

### Symbolsuche-Cache

Aktivieren Sie **Cache API Results**, um Suchergebnisse auf der Festplatte zu speichern. Zwischengespeicherte Ergebnisse bleiben über App-Neustarts hinweg erhalten und reduzieren die API-Nutzung. Verwenden Sie die Aktualisierungsschaltfläche beim Durchsuchen von Symbolen, um aktuelle Ergebnisse abzurufen.

## Fehlerbehebung

Wenn der API-Test fehlschlägt:
- Überprüfen Sie, ob Ihr Schlüssel korrekt ist (keine zusätzlichen Leerzeichen)
- Überprüfen Sie Ihre Internetverbindung
- Die macosicons.com-API ist möglicherweise vorübergehend nicht verfügbar
