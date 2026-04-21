---
title: Rychlý start
section: guide
order: 1
locale: cs
---

## Požadavky

- macOS 13.0 (Ventura) nebo novější
- Oprávnění správce (pro počáteční nastavení a změnu ikon)

## Instalace

### Homebrew (doporučeno)

```bash
brew install Bengerthelorf/tap/iconchanger
```

### Ruční stažení

1. Stáhněte si nejnovější DMG z [GitHub Releases](https://github.com/Bengerthelorf/macIconChanger/releases/latest).
2. Otevřete DMG a přetáhněte **IconChanger** do složky Aplikace.
3. Spusťte IconChanger.

## První spuštění

Při prvním spuštění vás IconChanger vyzve k jednorázovému nastavení oprávnění. To je nezbytné, aby aplikace mohla měnit ikony aplikací.

![Obrazovka nastavení při prvním spuštění](/images/setup-prompt.png)

Klikněte na tlačítko nastavení a zadejte heslo správce. IconChanger automaticky nakonfiguruje potřebná oprávnění (pravidlo sudoers pro pomocný skript).

::: tip
Pokud automatické nastavení selže, podívejte se na [Počáteční nastavení](./setup) pro ruční postup.
:::

## Změna první ikony

1. Vyberte aplikaci z postranního panelu.
2. Procházejte ikony z [macOSicons.com](https://macosicons.com/) nebo zvolte lokální soubor s obrázkem.
3. Klikněte na ikonu pro její aplikování.

![Hlavní rozhraní](/images/main-interface.png)

To je vše! Ikona aplikace se změní okamžitě.

## Další kroky

- [Nastavte si API klíč](./api-key) pro online vyhledávání ikon
- [Zjistěte více o aliasech aplikací](./aliases) pro lepší výsledky vyhledávání
- [Nakonfigurujte službu na pozadí](./background-service) pro automatickou obnovu ikon
- [Nainstalujte nástroj CLI](/cs/cli/) pro přístup z příkazového řádku