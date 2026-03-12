# Změna ikon

## Použití grafického rozhraní

### Online vyhledávání

1. Vyberte aplikaci z postranního panelu.
2. Procházejte ikony z [macOSicons.com](https://macosicons.com/) v hlavní oblasti.
3. Pomocí rozbalovací nabídky **Style** filtrujte podle stylu (např. Liquid Glass).
4. Klikněte na ikonu pro její aplikování.

![Vyhledávání ikon](/images/search-icons.png)

### Výběr lokálního souboru

Klikněte na **Choose from the Local** (nebo stiskněte <kbd>Cmd</kbd>+<kbd>O</kbd>) pro otevření dialogu výběru souboru. Podporované formáty: PNG, JPEG, ICNS, TIFF, HEIC, WebP, BMP, GIF, SVG.

### Přetažení myší

Přetáhněte soubor s obrázkem z Finderu přímo na oblast ikony aplikace. Modrým zvýrazněním se potvrdí cílová zóna pro přetažení.

![Přetažení myší](/images/drag-drop.png)

### Obnovení výchozí ikony

Pro obnovení původní ikony aplikace:
- Klikněte na tlačítko **Restore Default** (nebo stiskněte <kbd>Cmd</kbd>+<kbd>Delete</kbd>)
- Nebo klikněte pravým tlačítkem na aplikaci v postranním panelu a vyberte **Restore Default Icon**

## Útěk ze squircle vězení (macOS Tahoe)

macOS 26 Tahoe nutí všechny ikony aplikací do tvaru squircle (zaoblený čtverec). Aplikace s neodpovídajícími ikonami jsou zmenšeny a umístěny na šedém squircle pozadí.

IconChanger to může opravit opětovným aplikováním vlastní přibalené ikony aplikace jako vlastní ikony, čímž obejde vynucování tvaru squircle systémem macOS.

### Jednotlivá aplikace

Klikněte pravým tlačítkem na aplikaci v postranním panelu a vyberte **Escape Squircle Jail**.

### Všechny aplikace najednou

Klikněte na nabídku **⋯** v panelu nástrojů a vyberte **Escape Squircle Jail (All Apps)**. Zpracují se všechny aplikace, které ještě nemají vlastní ikony.

::: tip
Vlastní ikony nastavené tímto způsobem **nepodporují** režimy Clear, Tinted ani Dark ikon v macOS Tahoe — zůstávají statické. Jedná se o systémové omezení.
:::

::: info
Služba na pozadí automaticky znovu aplikuje ikony po aktualizacích aplikací a udrží je mimo squircle vězení.
:::

## Ikony složek

Můžete také přizpůsobit ikony složek. Přidejte složky přes **Settings** > **Application** > **Application Folders**, nebo klikněte na tlačítko **+** v sekci složek postranního panelu.

Po přidání se složka zobrazí v postranním panelu stejně jako aplikace. Můžete vyhledávat ikony, přetahovat obrázky nebo vybírat lokální soubory — stejný postup jako při změně ikon aplikací.

::: tip
Názvy složek jako „go" nebo „Downloads" nemusí na macOSicons.com vracet dobré výsledky vyhledávání. Použijte [aliasy](./aliases) pro nastavení vyhledávacího názvu (např. nastavte alias „Documents" na „folder").
:::

## Ukládání ikon do mezipaměti

Při aplikování vlastní ikony se tato automaticky uloží do mezipaměti. To znamená:
- Vaše vlastní ikony mohou být obnoveny po aktualizacích aplikací
- Služba na pozadí je může znovu aplikovat podle plánu
- Konfigurace ikon můžete exportovat a importovat

Ikony v mezipaměti spravujte v **Settings** > **Icon Cache**.

## Klávesové zkratky

| Zkratka | Akce |
|---|---|
| <kbd>Cmd</kbd>+<kbd>O</kbd> | Výběr lokálního souboru s ikonou |
| <kbd>Cmd</kbd>+<kbd>Delete</kbd> | Obnovení výchozí ikony |
| <kbd>Cmd</kbd>+<kbd>R</kbd> | Obnovení zobrazení ikon |

## Tipy

- Pokud se pro aplikaci nenajdou žádné ikony, zkuste [nastavit alias](./aliases) s jednodušším názvem.
- Počítadlo (např. „12/15") ukazuje, kolik ikon se úspěšně načetlo z celkového počtu nalezených.
- Ikony jsou ve výchozím nastavení řazeny podle popularity (počtu stažení).
