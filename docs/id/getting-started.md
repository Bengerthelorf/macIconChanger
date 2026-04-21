---
title: Panduan Cepat
section: guide
order: 1
locale: id
---

## Persyaratan

- macOS 13.0 (Ventura) atau lebih baru
- Hak akses administrator (untuk pengaturan awal dan mengubah ikon)

## Instalasi

### Homebrew (Direkomendasikan)

```bash
brew install Bengerthelorf/tap/iconchanger
```

### Unduh Manual

1. Unduh DMG terbaru dari [GitHub Releases](https://github.com/Bengerthelorf/macIconChanger/releases/latest).
2. Buka DMG dan seret **IconChanger** ke folder Applications Anda.
3. Jalankan IconChanger.

## Peluncuran Pertama

Pada peluncuran pertama, IconChanger akan meminta Anda menyelesaikan pengaturan izin satu kali. Ini diperlukan agar aplikasi dapat mengubah ikon aplikasi.

![Layar pengaturan peluncuran pertama](/images/setup-prompt.png)

Klik tombol pengaturan dan masukkan kata sandi administrator Anda. IconChanger akan secara otomatis mengonfigurasi izin yang diperlukan (aturan sudoers untuk skrip helper).

::: tip
Jika pengaturan otomatis gagal, lihat [Pengaturan Awal](./setup) untuk instruksi manual.
:::

## Mengubah Ikon Pertama Anda

1. Pilih aplikasi dari sidebar.
2. Telusuri ikon dari [macOSicons.com](https://macosicons.com/) atau pilih file gambar lokal.
3. Klik ikon untuk menerapkannya.

![Antarmuka utama](/images/main-interface.png)

Selesai! Ikon aplikasi akan langsung berubah.

## Langkah Selanjutnya

- [Siapkan kunci API](./api-key) untuk pencarian ikon online
- [Pelajari tentang alias aplikasi](./aliases) untuk hasil pencarian yang lebih baik
- [Konfigurasikan layanan latar belakang](./background-service) untuk pemulihan ikon otomatis
- [Instal alat CLI](/id/cli/) untuk akses baris perintah