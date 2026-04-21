---
title: Schnellstart
section: guide
order: 1
locale: de
---

## Voraussetzungen

- macOS 13.0 (Ventura) oder neuer
- Administratorrechte (für die Ersteinrichtung und das Ändern von Symbolen)

## Installation

### Homebrew (empfohlen)

```bash
brew install Bengerthelorf/tap/iconchanger
```

### Manueller Download

1. Laden Sie die neueste DMG-Datei von den [GitHub Releases](https://github.com/Bengerthelorf/macIconChanger/releases/latest) herunter.
2. Öffnen Sie die DMG-Datei und ziehen Sie **IconChanger** in Ihren Programme-Ordner.
3. Starten Sie IconChanger.

## Erster Start

Beim ersten Start fordert IconChanger Sie auf, eine einmalige Berechtigungseinrichtung durchzuführen. Diese ist erforderlich, damit die App Anwendungssymbole ändern kann.

![Einrichtungsbildschirm beim ersten Start](/images/setup-prompt.png)

Klicken Sie auf die Einrichten-Schaltfläche und geben Sie Ihr Administratorpasswort ein. IconChanger konfiguriert automatisch die erforderlichen Berechtigungen (eine sudoers-Regel für das Hilfsskript).

::: tip
Falls die automatische Einrichtung fehlschlägt, finden Sie unter [Ersteinrichtung](./setup) eine Anleitung zur manuellen Konfiguration.
:::

## Ihr erstes Symbol ändern

1. Wählen Sie eine Anwendung in der Seitenleiste aus.
2. Durchsuchen Sie Symbole auf [macOSicons.com](https://macosicons.com/) oder wählen Sie eine lokale Bilddatei.
3. Klicken Sie auf ein Symbol, um es anzuwenden.

![Hauptoberfläche](/images/main-interface.png)

Das war's! Das App-Symbol wird sofort geändert.

## Nächste Schritte

- [API-Schlüssel einrichten](./api-key) für die Online-Symbolsuche
- [Mehr über App-Aliasse erfahren](./aliases) für bessere Suchergebnisse
- [Hintergrunddienst konfigurieren](./background-service) für automatische Symbolwiederherstellung
- [CLI-Werkzeug installieren](/de/cli/) für Kommandozeilenzugriff