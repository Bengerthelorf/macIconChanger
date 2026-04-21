---
title: Instalasi CLI
section: cli
locale: id
---

IconChanger menyertakan antarmuka baris perintah untuk scripting dan otomatisasi.

## Instal dari Aplikasi

1. Buka IconChanger > **Settings** > **Advanced**.
2. Di bagian **Command Line Tool**, klik **Install**.
3. Masukkan kata sandi administrator Anda.

Perintah `iconchanger` sekarang tersedia di terminal Anda.

## Instal Manual

Jika Anda memilih untuk menginstal secara manual (misalnya, dalam skrip dotfiles):

```bash
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger
```

## Verifikasi Instalasi

```bash
iconchanger --version
```

## Menghapus Instalasi

Dari aplikasi: **Settings** > **Advanced** > **Uninstall**.

Atau secara manual:

```bash
sudo rm /usr/local/bin/iconchanger
```

## Langkah Selanjutnya

Lihat [Referensi Perintah](./commands) untuk semua perintah yang tersedia.