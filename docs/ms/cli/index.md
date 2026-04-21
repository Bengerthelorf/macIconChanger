---
title: Pemasangan CLI
section: cli
locale: ms
---

IconChanger menyertakan antara muka baris perintah untuk skrip dan automasi.

## Pasang dari Aplikasi

1. Buka IconChanger > **Settings** > **Advanced**.
2. Di bawah **Command Line Tool**, klik **Install**.
3. Masukkan kata laluan pentadbir anda.

Perintah `iconchanger` kini tersedia dalam terminal anda.

## Pasang Secara Manual

Jika anda lebih suka memasang secara manual (contohnya, dalam skrip dotfiles):

```bash
sudo cp /Applications/IconChanger.app/Contents/Resources/IconChangerCLI /usr/local/bin/iconchanger
sudo chmod +x /usr/local/bin/iconchanger
```

## Mengesahkan Pemasangan

```bash
iconchanger --version
```

## Nyahpasang

Dari aplikasi: **Settings** > **Advanced** > **Uninstall**.

Atau secara manual:

```bash
sudo rm /usr/local/bin/iconchanger
```

## Langkah Seterusnya

Lihat [Rujukan Perintah](./commands) untuk semua perintah yang tersedia.