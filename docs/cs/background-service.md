---
title: Služba na pozadí
section: guide
order: 6
locale: cs
---

Služba na pozadí udržuje vaše vlastní ikony nedotčené, a to i po aktualizacích aplikací nebo změnách systému.

## Aktivace

Přejděte do **Settings** > **Background** a zapněte přepínač **Run in Background**.

Když je služba aktivní, IconChanger pokračuje v běhu i po zavření okna. Přístup k němu získáte z panelu nabídek nebo Docku.

## Funkce

### Plánovaná obnova

Automatická obnova všech vlastních ikon uložených v mezipaměti v pravidelných intervalech.

- Zapněte přepínač **Restore Icons on Schedule**
- Vyberte interval: každou hodinu, 3 hodiny, 6 hodin, 12 hodin, denně nebo vlastní interval
- V nastavení se zobrazuje, kdy proběhla poslední obnova a kdy bude příští

### Detekce aktualizací aplikací

Detekce aktualizací aplikací a automatické opětovné aplikování jejich vlastních ikon.

- Zapněte přepínač **Restore Icons When Apps Update**
- Nastavte, jak často se mají kontrolovat aktualizace (každých 5 minut až každé 2 hodiny nebo vlastní interval)

### Viditelnost aplikace

Nastavení, kde se IconChanger zobrazuje při běhu na pozadí:

- **Show in Menu Bar** — přidá ikonu do panelu nabídek
- **Show in Dock** — ponechá aplikaci v Docku

Alespoň jedna z těchto možností musí být zapnutá.

### Spuštění při přihlášení

Automatické spuštění IconChanger při přihlášení k Macu.

- **Open Main Window** — normální spuštění s hlavním oknem
- **Start Hidden** — tiché spuštění na pozadí (vyžaduje zapnuté „Run in Background")

::: info
„Start Hidden" ovlivňuje pouze spuštění při přihlášení. Ruční otevření aplikace vždy zobrazí hlavní okno.
:::

## Stav služby

Když je služba na pozadí aktivní, na stránce nastavení se zobrazuje:
- **Service Status** — zda služba běží
- **Cached Icons** — kolik ikon je připraveno k obnově