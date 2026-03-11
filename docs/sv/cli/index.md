# CLI-installation

IconChanger inkluderar ett kommandoradsgränssnitt för skript och automatisering.

## Installera från appen

1. Öppna IconChanger > **Settings** > **Advanced**.
2. Under **Command Line Tool**, klicka på **Install**.
3. Ange ditt administratörslösenord.

Kommandot `iconchanger` är nu tillgängligt i din terminal.

## Installera manuellt

Om du föredrar att installera manuellt (t.ex. i ett dotfiles-skript):

```bash
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger
```

## Verifiera installationen

```bash
iconchanger --version
```

## Avinstallera

Från appen: **Settings** > **Advanced** > **Uninstall**.

Eller manuellt:

```bash
sudo rm /usr/local/bin/iconchanger
```

## Nästa steg

Se [Kommandoreferens](./commands) för alla tillgängliga kommandon.
