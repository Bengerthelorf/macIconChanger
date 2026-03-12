# Kunci API

Kunci API dari [macosicons.com](https://macosicons.com/) diperlukan untuk mencari ikon secara online. Tanpa kunci API, Anda masih dapat menggunakan file gambar lokal.

## Mendapatkan Kunci API

1. Kunjungi [macosicons.com](https://macosicons.com/) dan buat akun.
2. Minta kunci API dari pengaturan akun Anda.
3. Salin kunci tersebut.

![Cara mendapatkan kunci API](/images/api-key.png)

## Memasukkan Kunci

1. Buka IconChanger.
2. Buka **Settings** > **Advanced**.
3. Tempelkan kunci API Anda di kolom **API Key**.
4. Klik **Test Connection** untuk memverifikasi bahwa kunci berfungsi.

![Pengaturan kunci API](/images/api-key-settings.png)

## Menggunakan Tanpa Kunci API

Anda masih dapat mengubah ikon aplikasi tanpa kunci API dengan cara:

- Menggunakan file gambar lokal (klik **Choose from the Local** atau seret & lepas gambar)
- Menggunakan ikon yang sudah termasuk dalam aplikasi itu sendiri (ditampilkan di bagian "Local")

## Pengaturan API Lanjutan

Di **Settings** > **Advanced** > **API Settings**, Anda dapat menyesuaikan perilaku API:

| Pengaturan | Default | Deskripsi |
|---|---|---|
| **Retry Count** | 0 (tanpa percobaan ulang) | Berapa kali mencoba ulang permintaan yang gagal (0–3) |
| **Timeout** | 15 detik | Batas waktu untuk setiap percobaan permintaan |
| **Monthly Limit** | 50 | Kueri API maksimum per bulan |

Penghitung **Monthly Usage** menampilkan penggunaan Anda saat ini. Penghitung ini direset otomatis pada tanggal 1 setiap bulan, atau Anda dapat meresetnya secara manual.

### Cache Pencarian Ikon

Aktifkan **Cache API Results** untuk menyimpan hasil pencarian ke disk. Hasil yang di-cache tetap tersimpan setelah aplikasi di-restart, sehingga mengurangi penggunaan API. Gunakan tombol segarkan saat menjelajahi ikon untuk mengambil hasil terbaru.

## Pemecahan Masalah

Jika pengujian API gagal:
- Pastikan kunci Anda benar (tanpa spasi tambahan)
- Periksa koneksi internet Anda
- API macosicons.com mungkin sedang tidak tersedia untuk sementara
