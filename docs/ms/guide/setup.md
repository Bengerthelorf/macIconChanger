# Persediaan Awal

IconChanger memerlukan keistimewaan pentadbir untuk menukar ikon aplikasi. Pada pelancaran pertama, aplikasi menawarkan untuk menyediakannya secara automatik.

## Persediaan Automatik (Disyorkan)

1. Lancarkan IconChanger.
2. Klik butang **Setup** apabila diminta.
3. Masukkan kata laluan pentadbir anda.

Aplikasi akan mencipta skrip pembantu di `~/.iconchanger/helper.sh` dan mengkonfigurasi peraturan sudoers supaya ia boleh dijalankan tanpa permintaan kata laluan setiap kali.

## Persediaan Manual

Jika persediaan automatik gagal, anda boleh mengkonfigurasinya secara manual:

1. Buka Terminal.
2. Jalankan:

```bash
sudo visudo
```

3. Tambahkan baris berikut di bahagian akhir:

```
ALL ALL=(ALL) NOPASSWD: /Users/<nama-pengguna-anda>/.iconchanger/helper.sh
```

Gantikan `<nama-pengguna-anda>` dengan nama pengguna macOS sebenar anda.

## Mengesahkan Persediaan

Selepas persediaan, aplikasi sepatutnya menunjukkan senarai aplikasi di bar sisi. Jika anda melihat permintaan persediaan semula, konfigurasi mungkin tidak digunakan dengan betul.

Anda boleh mengesahkan persediaan dari bar menu: klik menu **...** dan pilih **Check Setup Status**.

## Had

Aplikasi yang dilindungi oleh macOS System Integrity Protection (SIP) tidak boleh ditukar ikonnya. Ini adalah sekatan macOS dan tidak boleh dipintas.

Aplikasi yang dilindungi SIP yang biasa termasuk:
- Finder
- Safari (pada sesetengah versi macOS)
- Aplikasi sistem lain dalam `/System/Applications/`
