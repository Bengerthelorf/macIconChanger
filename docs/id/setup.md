---
title: Pengaturan Awal
section: guide
order: 2
locale: id
---

IconChanger memerlukan hak akses administrator untuk mengubah ikon aplikasi. Pada peluncuran pertama, aplikasi menawarkan untuk mengatur ini secara otomatis.

## Pengaturan Otomatis (Direkomendasikan)

1. Jalankan IconChanger.
2. Klik tombol **Setup** saat diminta.
3. Masukkan kata sandi administrator Anda.

Aplikasi akan menginstal skrip helper ke `/usr/local/lib/iconchanger/` (dimiliki oleh `root:wheel`) dan mengonfigurasi aturan sudoers terbatas agar dapat berjalan tanpa meminta kata sandi setiap kali.

## Keamanan

IconChanger menggunakan beberapa langkah keamanan untuk melindungi pipeline helper:

- **Direktori helper milik root** — File helper berada di `/usr/local/lib/iconchanger/` dengan kepemilikan `root:wheel`, mencegah modifikasi yang tidak berwenang.
- **Verifikasi integritas SHA-256** — Skrip helper diverifikasi terhadap hash yang diketahui sebelum setiap eksekusi.
- **Aturan sudoers terbatas** — Entri sudoers hanya memberikan akses tanpa kata sandi ke skrip helper tertentu, bukan perintah sembarang.
- **Pencatatan audit** — Semua operasi ikon dicatat dengan stempel waktu untuk ketertelusuran.

## Pengaturan Manual

Jika pengaturan otomatis gagal, Anda dapat mengonfigurasinya secara manual:

1. Buka Terminal.
2. Jalankan:

```bash
sudo visudo -f /etc/sudoers.d/iconchanger
```

3. Tambahkan baris berikut:

```
ALL ALL=(ALL) NOPASSWD: /usr/local/lib/iconchanger/helper.sh
```

## Memverifikasi Pengaturan

Setelah pengaturan, aplikasi seharusnya menampilkan daftar aplikasi di sidebar. Jika Anda melihat permintaan pengaturan lagi, konfigurasi mungkin belum diterapkan dengan benar.

Anda dapat memverifikasi pengaturan dari menu bar: klik menu **...** dan pilih **Check Setup Status**.

## Keterbatasan

Aplikasi yang dilindungi oleh System Integrity Protection (SIP) macOS tidak dapat diubah ikonnya. Ini adalah batasan macOS dan tidak dapat dilewati.

Aplikasi yang umum dilindungi SIP meliputi:
- Finder
- Safari (pada beberapa versi macOS)
- Aplikasi sistem lainnya di `/System/Applications/`