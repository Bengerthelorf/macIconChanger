---
title: API klíč
section: guide
order: 7
locale: cs
---

Pro online vyhledávání ikon je vyžadován API klíč z [macosicons.com](https://macosicons.com/). Bez něj můžete stále používat lokální soubory s obrázky.

## Získání API klíče

1. Navštivte [macosicons.com](https://macosicons.com/) a vytvořte si účet.
2. V nastavení účtu si vyžádejte API klíč.
3. Zkopírujte klíč.

![Jak získat API klíč](/images/api-key.png)

## Zadání klíče

1. Otevřete IconChanger.
2. Přejděte do **Settings** > **Advanced**.
3. Vložte API klíč do pole **API Key**.
4. Klikněte na **Test Connection** pro ověření funkčnosti.

![Nastavení API klíče](/images/api-key-settings.png)

## Použití bez API klíče

Ikony aplikací můžete měnit i bez API klíče:

- Pomocí lokálních souborů s obrázky (klikněte na **Choose from the Local** nebo přetáhněte obrázek myší)
- Pomocí ikon přibalených v samotné aplikaci (zobrazené v sekci „Local")

## Pokročilé nastavení API

V **Settings** > **Advanced** > **API Settings** můžete doladit chování API:

| Nastavení | Výchozí | Popis |
|---|---|---|
| **Retry Count** | 0 (bez opakování) | Kolikrát se má opakovat neúspěšný požadavek (0–3) |
| **Timeout** | 15 sekund | Časový limit pro každý jednotlivý pokus |
| **Monthly Limit** | 50 | Maximální počet API dotazů za měsíc |

Počítadlo **Monthly Usage** zobrazuje vaše aktuální využití. Automaticky se resetuje 1. den každého měsíce, nebo ho můžete resetovat ručně.

### Mezipaměť vyhledávání ikon

Zapněte **Cache API Results** pro ukládání výsledků vyhledávání na disk. Výsledky v mezipaměti přetrvávají i po restartu aplikace, čímž se snižuje využití API. Při procházení ikon použijte tlačítko obnovení pro získání aktuálních výsledků.

## Řešení problémů

Pokud test API selže:
- Zkontrolujte, zda je klíč správný (bez přebytečných mezer)
- Ověřte připojení k internetu
- API služba macosicons.com může být dočasně nedostupná