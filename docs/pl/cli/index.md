---
title: Instalacja CLI
section: cli
locale: pl
---

IconChanger zawiera interfejs wiersza poleceń do skryptowania i automatyzacji.

## Instalacja z aplikacji

1. Otwórz IconChanger > **Settings** > **Advanced**.
2. W sekcji **Command Line Tool** kliknij **Install**.
3. Wprowadź hasło administratora.

Polecenie `iconchanger` jest teraz dostępne w terminalu.

## Instalacja ręczna

Jeśli wolisz zainstalować ręcznie (np. w skrypcie dotfiles):

```bash
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger
```

## Weryfikacja instalacji

```bash
iconchanger --version
```

## Odinstalowanie

Z aplikacji: **Settings** > **Advanced** > **Uninstall**.

Lub ręcznie:

```bash
sudo rm /usr/local/bin/iconchanger
```

## Następne kroki

Zobacz [Referencję poleceń](./commands), aby poznać wszystkie dostępne polecenia.