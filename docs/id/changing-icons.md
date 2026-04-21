---
title: Mengubah Ikon
section: guide
order: 3
locale: id
---

## Menggunakan GUI

### Pencarian Online

1. Pilih aplikasi dari sidebar.
2. Telusuri ikon dari [macOSicons.com](https://macosicons.com/) di area utama.
3. Gunakan dropdown **Style** untuk memfilter berdasarkan gaya (misalnya, Liquid Glass).
4. Klik ikon untuk menerapkannya.

![Mencari ikon](/images/search-icons.png)

### Memilih File Lokal

Klik **Choose from the Local** (atau tekan <kbd>Cmd</kbd>+<kbd>O</kbd>) untuk membuka pemilih file. Format yang didukung: PNG, JPEG, ICNS, TIFF, HEIC, WebP, BMP, GIF, SVG.

### Seret & Lepas

Seret file gambar dari Finder langsung ke area ikon aplikasi. Sorotan biru akan muncul untuk mengonfirmasi zona lepas.

![Seret dan lepas](/images/drag-drop.png)

### Memulihkan Ikon Default

Untuk memulihkan ikon asli aplikasi:
- Klik tombol **Restore Default** (atau tekan <kbd>Cmd</kbd>+<kbd>Delete</kbd>)
- Atau klik kanan aplikasi di sidebar dan pilih **Restore Default Icon**

## Escape Squircle Jail (macOS Tahoe)

macOS 26 Tahoe memaksa semua ikon aplikasi ke dalam bentuk squircle (persegi membulat). Aplikasi dengan ikon yang tidak sesuai akan diperkecil dan ditempatkan di atas latar belakang squircle abu-abu.

IconChanger dapat memperbaiki ini dengan menerapkan ulang ikon bawaan aplikasi sebagai ikon kustom, yang melewati penerapan squircle oleh macOS.

### Per Aplikasi

Klik kanan aplikasi di sidebar dan pilih **Escape Squircle Jail**.

### Semua Aplikasi Sekaligus

Klik menu **⋯** di toolbar dan pilih **Escape Squircle Jail (All Apps)**. Ini memproses semua aplikasi yang belum memiliki ikon kustom.

::: tip
Ikon kustom yang diatur dengan cara ini **tidak** mendukung mode ikon Clear, Tinted, atau Dark di macOS Tahoe — ikon tetap statis. Ini adalah keterbatasan sistem.
:::

::: info
Layanan latar belakang Anda akan secara otomatis menerapkan ulang ikon setelah pembaruan aplikasi, menjaga ikon tetap keluar dari squircle jail.
:::

## Ikon Folder

Anda juga dapat menyesuaikan ikon folder. Tambahkan folder melalui **Settings** > **Application** > **Application Folders**, atau klik tombol **+** di bagian folder sidebar.

Setelah folder ditambahkan, folder tersebut muncul di sidebar seperti aplikasi. Anda dapat mencari ikon, menyeret & melepas gambar, atau memilih file lokal — alur kerja yang sama seperti mengubah ikon aplikasi.

::: tip
Nama folder seperti "go" atau "Downloads" mungkin tidak memberikan hasil pencarian yang baik dari macOSicons.com. Gunakan [alias](./aliases) untuk menetapkan nama yang lebih ramah pencarian (misalnya, atur alias "Documents" menjadi "folder").
:::

## Cache Ikon

Saat Anda menerapkan ikon kustom, ikon tersebut secara otomatis di-cache. Ini berarti:
- Ikon kustom Anda dapat dipulihkan setelah pembaruan aplikasi
- Layanan latar belakang dapat menerapkan ulang secara terjadwal
- Anda dapat mengekspor dan mengimpor konfigurasi ikon Anda

Kelola ikon yang di-cache di **Settings** > **Icon Cache**.

## Pintasan Keyboard

| Pintasan | Aksi |
|---|---|
| <kbd>Cmd</kbd>+<kbd>O</kbd> | Memilih file ikon lokal |
| <kbd>Cmd</kbd>+<kbd>Delete</kbd> | Memulihkan ikon default |
| <kbd>Cmd</kbd>+<kbd>R</kbd> | Menyegarkan tampilan ikon |

## Tips

- Jika tidak ada ikon yang ditemukan untuk suatu aplikasi, coba [atur alias](./aliases) dengan nama yang lebih sederhana.
- Penghitung (misalnya, "12/15") menunjukkan berapa banyak ikon yang berhasil dimuat dari total yang ditemukan.
- Ikon diurutkan berdasarkan popularitas (jumlah unduhan) secara default.