# CLI telepítés

Az IconChanger tartalmaz egy parancssori felületet szkripteléshez és automatizáláshoz.

## Telepítés az alkalmazásból

1. Nyisd meg az IconChanger > **Settings** > **Advanced** menüpontot.
2. A **Command Line Tool** alatt kattints az **Install** gombra.
3. Add meg a rendszergazdai jelszavadat.

Az `iconchanger` parancs mostantól elérhető a terminálban.

## Kézi telepítés

Ha inkább kézzel szeretnéd telepíteni (pl. egy dotfiles szkriptben):

```bash
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger
```

## Telepítés ellenőrzése

```bash
iconchanger --version
```

## Eltávolítás

Az alkalmazásból: **Settings** > **Advanced** > **Uninstall**.

Vagy kézzel:

```bash
sudo rm /usr/local/bin/iconchanger
```

## Következő lépések

Az összes elérhető parancsért lásd a [Parancsreferencia](./commands) oldalt.
