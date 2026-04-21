---
title: Ghid rapid
section: guide
order: 1
locale: ro
---

## Cerinte

- macOS 13.0 (Ventura) sau mai recent
- Privilegii de administrator (pentru configurarea initiala si schimbarea pictogramelor)

## Instalare

### Homebrew (recomandat)

```bash
brew install Bengerthelorf/tap/iconchanger
```

### Descarcare manuala

1. Descarca cel mai recent DMG de pe [GitHub Releases](https://github.com/Bengerthelorf/macIconChanger/releases/latest).
2. Deschide fisierul DMG si trage **IconChanger** in folderul Applications.
3. Lanseaza IconChanger.

## Prima lansare

La prima lansare, IconChanger te va solicita sa finalizezi o configurare unica a permisiunilor. Aceasta este necesara pentru ca aplicatia sa poata schimba pictogramele aplicatiilor.

![Ecranul de configurare la prima lansare](/images/setup-prompt.png)

Apasa butonul de configurare si introdu parola de administrator. IconChanger va configura automat permisiunile necesare (o regula sudoers pentru scriptul ajutator).

::: tip
Daca configurarea automata esueaza, consulta [Configurarea initiala](./setup) pentru instructiuni de configurare manuala.
:::

## Schimbarea primei pictograme

1. Selecteaza o aplicatie din bara laterala.
2. Exploreaza pictogramele de pe [macOSicons.com](https://macosicons.com/) sau alege un fisier imagine local.
3. Apasa pe o pictograma pentru a o aplica.

![Interfata principala](/images/main-interface.png)

Asta e tot! Pictograma aplicatiei va fi schimbata imediat.

## Pasii urmatori

- [Configureaza o cheie API](./api-key) pentru cautarea online a pictogramelor
- [Afla despre aliasurile aplicatiilor](./aliases) pentru rezultate mai bune la cautare
- [Configureaza serviciul in fundal](./background-service) pentru restaurarea automata a pictogramelor
- [Instaleaza instrumentul CLI](/ro/cli/) pentru acces prin linia de comanda