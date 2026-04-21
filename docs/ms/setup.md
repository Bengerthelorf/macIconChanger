---
title: Persediaan Awal
section: guide
order: 2
locale: ms
---

IconChanger memerlukan keistimewaan pentadbir untuk menukar ikon aplikasi. Pada pelancaran pertama, aplikasi menawarkan untuk menyediakannya secara automatik.

## Persediaan Automatik (Disyorkan)

1. Lancarkan IconChanger.
2. Klik butang **Setup** apabila diminta.
3. Masukkan kata laluan pentadbir anda.

Aplikasi akan memasang skrip pembantu ke `/usr/local/lib/iconchanger/` (dimiliki oleh `root:wheel`) dan mengkonfigurasi peraturan sudoers terhad supaya ia boleh dijalankan tanpa permintaan kata laluan setiap kali.

## Keselamatan

IconChanger menggunakan beberapa langkah keselamatan untuk melindungi saluran paip pembantu:

- **Direktori pembantu milik root** — Fail pembantu berada di `/usr/local/lib/iconchanger/` dengan pemilikan `root:wheel`, menghalang pengubahsuaian tanpa kebenaran.
- **Pengesahan integriti SHA-256** — Skrip pembantu disahkan terhadap hash yang diketahui sebelum setiap pelaksanaan.
- **Peraturan sudoers terhad** — Entri sudoers hanya memberikan akses tanpa kata laluan kepada skrip pembantu tertentu, bukan arahan sewenang-wenangnya.
- **Log audit** — Semua operasi ikon direkodkan dengan cap masa untuk kebolehkesanan.

## Persediaan Manual

Jika persediaan automatik gagal, anda boleh mengkonfigurasinya secara manual:

1. Buka Terminal.
2. Jalankan:

```bash
sudo visudo -f /etc/sudoers.d/iconchanger
```

3. Tambahkan baris berikut:

```
ALL ALL=(ALL) NOPASSWD: /usr/local/lib/iconchanger/helper.sh
```

## Mengesahkan Persediaan

Selepas persediaan, aplikasi sepatutnya menunjukkan senarai aplikasi di bar sisi. Jika anda melihat permintaan persediaan semula, konfigurasi mungkin tidak digunakan dengan betul.

Anda boleh mengesahkan persediaan dari bar menu: klik menu **...** dan pilih **Check Setup Status**.

## Had

Aplikasi yang dilindungi oleh macOS System Integrity Protection (SIP) tidak boleh ditukar ikonnya. Ini adalah sekatan macOS dan tidak boleh dipintas.

Aplikasi yang dilindungi SIP yang biasa termasuk:
- Finder
- Safari (pada sesetengah versi macOS)
- Aplikasi sistem lain dalam `/System/Applications/`