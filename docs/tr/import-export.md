---
title: İçeri ve Dışarı Aktarma
section: guide
order: 8
locale: tr
---

Simge yapılandırmalarınızı yedekleyin veya başka bir Mac'e aktarın.

## Nelerin Dışarı Aktarıldığı

Dışarı aktarma dosyası (JSON) şunları içerir:
- **Uygulama takma adları** — özel arama adı eşlemeleriniz
- **Önbelleğe alınan simge referansları** — hangi uygulamaların özel simgelere sahip olduğu ve önbelleğe alınan simge dosyaları

## Dışarı Aktarma

### GUI'den

**Settings** > **Advanced** > **Configuration** bölümüne gidin ve **Export** düğmesine tıklayın.

### CLI'den

```bash
iconchanger export ~/Desktop/my-icons.json
```

## İçeri Aktarma

### GUI'den

**Settings** > **Advanced** > **Configuration** bölümüne gidin ve **Import** düğmesine tıklayın.

### CLI'den

```bash
iconchanger import ~/Desktop/my-icons.json
```

::: tip
İçeri aktarma yalnızca yeni öğeler **ekler**. Mevcut takma adlarınızı veya önbelleğe alınan simgelerinizi asla değiştirmez veya silmez.
:::

## Doğrulama

İçeri aktarmadan önce bir yapılandırma dosyasını doğrulayabilirsiniz:

```bash
iconchanger validate ~/Desktop/my-icons.json
```

Bu, herhangi bir değişiklik yapmadan dosya yapısını kontrol eder.

## Dotfiles ile Otomasyon

IconChanger kurulumunu dotfiles'ınızın bir parçası olarak otomatikleştirebilirsiniz:

```bash
#!/bin/bash
DMG_URL="https://github.com/Bengerthelorf/macIconChanger/releases/latest/download/IconChanger.dmg"
DMG_PATH="/tmp/IconChanger.dmg"

# Uygulamayı kur
curl -L "$DMG_URL" -o "$DMG_PATH"
hdiutil attach "$DMG_PATH" -mountpoint /Volumes/IconChanger
cp -R /Volumes/IconChanger/IconChanger.app /Applications/
hdiutil detach /Volumes/IconChanger

# CLI'yi kur (uygulama paketinden)
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger

# Simge yapılandırmanızı içeri aktarın
iconchanger import ~/dotfiles/iconchanger/config.json
```