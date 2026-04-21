---
title: Počáteční nastavení
section: guide
order: 2
locale: cs
---

IconChanger potřebuje oprávnění správce ke změně ikon aplikací. Při prvním spuštění aplikace nabídne automatické nastavení.

## Automatické nastavení (doporučeno)

1. Spusťte IconChanger.
2. Klikněte na tlačítko **Setup** po zobrazení výzvy.
3. Zadejte heslo správce.

Aplikace nainstaluje pomocný skript do `/usr/local/lib/iconchanger/` (vlastník `root:wheel`) a nakonfiguruje omezené pravidlo sudoers, aby se při každé změně nemusel zadávat heslo.

## Zabezpečení

IconChanger používá několik bezpečnostních opatření k ochraně pomocného kanálu:

- **Adresář helperu vlastněný rootem** — Pomocné soubory se nacházejí v `/usr/local/lib/iconchanger/` s vlastnictvím `root:wheel`, což zabraňuje neoprávněným úpravám.
- **Ověření integrity SHA-256** — Pomocný skript je před každým spuštěním ověřen proti známému hashi.
- **Omezené pravidlo sudoers** — Záznam sudoers uděluje přístup bez hesla pouze ke konkrétnímu pomocnému skriptu, nikoli k libovolným příkazům.
- **Auditní protokol** — Všechny operace s ikonami jsou zaznamenány s časovými razítky pro sledovatelnost.

## Ruční nastavení

Pokud automatické nastavení selže, můžete ho provést ručně:

1. Otevřete Terminal.
2. Spusťte:

```bash
sudo visudo -f /etc/sudoers.d/iconchanger
```

3. Přidejte následující řádek:

```
ALL ALL=(ALL) NOPASSWD: /usr/local/lib/iconchanger/helper.sh
```

## Ověření nastavení

Po nastavení by aplikace měla zobrazit seznam aplikací v postranním panelu. Pokud se znovu zobrazí výzva k nastavení, konfigurace pravděpodobně nebyla správně aplikována.

Nastavení můžete ověřit z panelu nabídek: klikněte na nabídku **...** a vyberte **Check Setup Status**.

## Omezení

Aplikacím chráněným ochranou integrity systému macOS (SIP) nelze měnit ikony. Jedná se o omezení systému macOS, které nelze obejít.

Běžné aplikace chráněné SIP:
- Finder
- Safari (v některých verzích macOS)
- Další systémové aplikace v `/System/Applications/`