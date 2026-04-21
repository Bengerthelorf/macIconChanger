---
title: Impor & Ekspor
section: guide
order: 8
locale: id
---

Cadangkan konfigurasi ikon Anda atau transfer ke Mac lain.

## Apa yang Diekspor

File ekspor (JSON) mencakup:
- **Alias aplikasi** — pemetaan nama pencarian kustom Anda
- **Referensi ikon yang di-cache** — aplikasi mana yang memiliki ikon kustom beserta file ikon yang di-cache

## Mengekspor

### Dari GUI

Buka **Settings** > **Advanced** > **Configuration**, dan klik **Export**.

### Dari CLI

```bash
iconchanger export ~/Desktop/my-icons.json
```

## Mengimpor

### Dari GUI

Buka **Settings** > **Advanced** > **Configuration**, dan klik **Import**.

### Dari CLI

```bash
iconchanger import ~/Desktop/my-icons.json
```

::: tip
Impor hanya **menambahkan** item baru. Impor tidak pernah mengganti atau menghapus alias atau ikon yang di-cache yang sudah ada.
:::

## Validasi

Sebelum mengimpor, Anda dapat memvalidasi file konfigurasi:

```bash
iconchanger validate ~/Desktop/my-icons.json
```

Ini memeriksa struktur file tanpa melakukan perubahan apa pun.

## Otomatisasi dengan Dotfiles

Anda dapat mengotomatisasi pengaturan IconChanger sebagai bagian dari dotfiles Anda:

```bash
#!/bin/bash
DMG_URL="https://github.com/Bengerthelorf/macIconChanger/releases/latest/download/IconChanger.dmg"
DMG_PATH="/tmp/IconChanger.dmg"

# Instal aplikasi
curl -L "$DMG_URL" -o "$DMG_PATH"
hdiutil attach "$DMG_PATH" -mountpoint /Volumes/IconChanger
cp -R /Volumes/IconChanger/IconChanger.app /Applications/
hdiutil detach /Volumes/IconChanger

# Instal CLI (dari bundle aplikasi)
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger

# Impor konfigurasi ikon Anda
iconchanger import ~/dotfiles/iconchanger/config.json
```