---
title: Hintergrunddienst
section: guide
order: 6
locale: de
---

Der Hintergrunddienst sorgt dafür, dass Ihre benutzerdefinierten Symbole erhalten bleiben, auch nach App-Updates oder Systemänderungen.

## Aktivierung

Gehen Sie zu **Einstellungen** > **Background** und aktivieren Sie **Run in Background**.

Wenn aktiviert, läuft IconChanger weiter, nachdem Sie das Fenster geschlossen haben. Sie können über die Menüleiste oder das Dock darauf zugreifen.

## Funktionen

### Geplante Wiederherstellung

Alle zwischengespeicherten benutzerdefinierten Symbole automatisch in regelmäßigen Abständen wiederherstellen.

- Aktivieren Sie **Restore Icons on Schedule**
- Wählen Sie ein Intervall: stündlich, alle 3 Stunden, 6 Stunden, 12 Stunden, täglich oder ein benutzerdefiniertes Intervall
- Die Einstellungen zeigen an, wann die letzte und nächste Wiederherstellung stattfindet

### App-Update-Erkennung

Erkennt, wenn Apps aktualisiert werden, und wendet deren benutzerdefinierte Symbole automatisch erneut an.

- Aktivieren Sie **Restore Icons When Apps Update**
- Legen Sie fest, wie oft auf Updates geprüft wird (alle 5 Minuten bis alle 2 Stunden, oder benutzerdefiniert)

### App-Sichtbarkeit

Steuern Sie, wo IconChanger angezeigt wird, wenn es im Hintergrund läuft:

- **Show in Menu Bar** — fügt ein Symbol zur Menüleiste hinzu
- **Show in Dock** — behält die App im Dock

Mindestens eine dieser Optionen muss aktiviert sein.

### Beim Anmelden starten

Starten Sie IconChanger automatisch, wenn Sie sich an Ihrem Mac anmelden.

- **Open Main Window** — startet normal mit dem Hauptfenster
- **Start Hidden** — startet unauffällig im Hintergrund (erfordert, dass "Run in Background" aktiviert ist)

::: info
"Start Hidden" wirkt sich nur auf den Start bei der Anmeldung aus. Das manuelle Öffnen der App zeigt immer das Hauptfenster.
:::

## Dienststatus

Wenn der Hintergrunddienst aktiv ist, zeigt die Einstellungsseite:
- **Service Status** — ob der Dienst ausgeführt wird
- **Cached Icons** — wie viele Symbole zur Wiederherstellung bereit sind