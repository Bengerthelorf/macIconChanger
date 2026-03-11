# Pengaturan Awal

IconChanger memerlukan hak akses administrator untuk mengubah ikon aplikasi. Pada peluncuran pertama, aplikasi menawarkan untuk mengatur ini secara otomatis.

## Pengaturan Otomatis (Direkomendasikan)

1. Jalankan IconChanger.
2. Klik tombol **Setup** saat diminta.
3. Masukkan kata sandi administrator Anda.

Aplikasi akan membuat skrip helper di `~/.iconchanger/helper.sh` dan mengonfigurasi aturan sudoers agar dapat berjalan tanpa meminta kata sandi setiap kali.

## Pengaturan Manual

Jika pengaturan otomatis gagal, Anda dapat mengonfigurasinya secara manual:

1. Buka Terminal.
2. Jalankan:

```bash
sudo visudo
```

3. Tambahkan baris berikut di bagian akhir:

```
ALL ALL=(ALL) NOPASSWD: /Users/<nama-pengguna-anda>/.iconchanger/helper.sh
```

Ganti `<nama-pengguna-anda>` dengan nama pengguna macOS Anda yang sebenarnya.

## Memverifikasi Pengaturan

Setelah pengaturan, aplikasi seharusnya menampilkan daftar aplikasi di sidebar. Jika Anda melihat permintaan pengaturan lagi, konfigurasi mungkin belum diterapkan dengan benar.

Anda dapat memverifikasi pengaturan dari menu bar: klik menu **...** dan pilih **Check Setup Status**.

## Keterbatasan

Aplikasi yang dilindungi oleh System Integrity Protection (SIP) macOS tidak dapat diubah ikonnya. Ini adalah batasan macOS dan tidak dapat dilewati.

Aplikasi yang umum dilindungi SIP meliputi:
- Finder
- Safari (pada beberapa versi macOS)
- Aplikasi sistem lainnya di `/System/Applications/`
