---
title: Import & Eksport
section: guide
order: 8
locale: ms
---

Sandarkan konfigurasi ikon anda atau pindahkan ke Mac lain.

## Apa yang Dieksport

Fail eksport (JSON) merangkumi:
- **Alias aplikasi** — pemetaan nama carian tersuai anda
- **Rujukan ikon yang dicache** — aplikasi mana yang mempunyai ikon tersuai dan fail ikon yang dicache

## Mengeksport

### Dari GUI

Pergi ke **Settings** > **Advanced** > **Configuration**, dan klik **Export**.

### Dari CLI

```bash
iconchanger export ~/Desktop/my-icons.json
```

## Mengimport

### Dari GUI

Pergi ke **Settings** > **Advanced** > **Configuration**, dan klik **Import**.

### Dari CLI

```bash
iconchanger import ~/Desktop/my-icons.json
```

::: tip
Import hanya **menambah** item baharu. Ia tidak pernah menggantikan atau membuang alias atau ikon yang dicache sedia ada anda.
:::

## Mengesahkan

Sebelum mengimport, anda boleh mengesahkan fail konfigurasi:

```bash
iconchanger validate ~/Desktop/my-icons.json
```

Ini menyemak struktur fail tanpa membuat sebarang perubahan.

## Automasi dengan Dotfiles

Anda boleh mengautomasikan persediaan IconChanger sebagai sebahagian daripada dotfiles anda:

```bash
#!/bin/bash
DMG_URL="https://github.com/Bengerthelorf/macIconChanger/releases/latest/download/IconChanger.dmg"
DMG_PATH="/tmp/IconChanger.dmg"

# Pasang aplikasi
curl -L "$DMG_URL" -o "$DMG_PATH"
hdiutil attach "$DMG_PATH" -mountpoint /Volumes/IconChanger
cp -R /Volumes/IconChanger/IconChanger.app /Applications/
hdiutil detach /Volumes/IconChanger

# Pasang CLI (dari bundel aplikasi)
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger

# Import konfigurasi ikon anda
iconchanger import ~/dotfiles/iconchanger/config.json
```