# Počáteční nastavení

IconChanger potřebuje oprávnění správce ke změně ikon aplikací. Při prvním spuštění aplikace nabídne automatické nastavení.

## Automatické nastavení (doporučeno)

1. Spusťte IconChanger.
2. Klikněte na tlačítko **Setup** po zobrazení výzvy.
3. Zadejte heslo správce.

Aplikace vytvoří pomocný skript v `~/.iconchanger/helper.sh` a nakonfiguruje pravidlo sudoers, aby se při každé změně nemusel zadávat heslo.

## Ruční nastavení

Pokud automatické nastavení selže, můžete ho provést ručně:

1. Otevřete Terminal.
2. Spusťte:

```bash
sudo visudo
```

3. Na konec přidejte následující řádek:

```
ALL ALL=(ALL) NOPASSWD: /Users/<vaše-uživatelské-jméno>/.iconchanger/helper.sh
```

Nahraďte `<vaše-uživatelské-jméno>` svým skutečným uživatelským jménem v macOS.

## Ověření nastavení

Po nastavení by aplikace měla zobrazit seznam aplikací v postranním panelu. Pokud se znovu zobrazí výzva k nastavení, konfigurace pravděpodobně nebyla správně aplikována.

Nastavení můžete ověřit z panelu nabídek: klikněte na nabídku **...** a vyberte **Check Setup Status**.

## Omezení

Aplikacím chráněným ochranou integrity systému macOS (SIP) nelze měnit ikony. Jedná se o omezení systému macOS, které nelze obejít.

Běžné aplikace chráněné SIP:
- Finder
- Safari (v některých verzích macOS)
- Další systémové aplikace v `/System/Applications/`
