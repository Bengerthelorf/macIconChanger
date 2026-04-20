# Kunci API

Kunci API dari [macosicons.com](https://macosicons.com/) diperlukan untuk mencari ikon dalam talian. Tanpanya, anda masih boleh menggunakan fail imej tempatan.

## Mendapatkan Kunci API

1. Layari [macosicons.com](https://macosicons.com/) dan buat akaun.
2. Minta kunci API dari tetapan akaun anda.
3. Salin kunci tersebut.

![Cara mendapatkan kunci API](/images/api-key.png)

## Memasukkan Kunci

1. Buka IconChanger.
2. Pergi ke **Settings** > **Advanced**.
3. Tampal kunci API anda dalam medan **API Key**.
4. Klik **Test Connection** untuk mengesahkan ia berfungsi.

![Tetapan kunci API](/images/api-key-settings.png)

## Menggunakan Tanpa Kunci API

Anda masih boleh menukar ikon aplikasi tanpa kunci API dengan:

- Menggunakan fail imej tempatan (klik **Choose from the Local** atau seret & lepas imej)
- Menggunakan ikon yang dibundel dalam aplikasi itu sendiri (ditunjukkan dalam bahagian "Local")

## Tetapan API Lanjutan

Di **Settings** > **Advanced** > **API Settings**, anda boleh melaraskan tingkah laku API:

| Tetapan | Lalai | Penerangan |
|---|---|---|
| **Retry Count** | 0 (tiada cubaan semula) | Berapa kali mencuba semula permintaan yang gagal (0–3) |
| **Timeout** | 15 saat | Had masa untuk setiap percubaan permintaan |
| **Monthly Limit** | 50 | Pertanyaan API maksimum sebulan |

Pembilang **Monthly Usage** menunjukkan penggunaan semasa anda. Ia ditetapkan semula secara automatik pada hari pertama setiap bulan, atau anda boleh menetapkannya semula secara manual.

### Cache Carian Ikon

Aktifkan **Cache API Results** untuk menyimpan hasil carian ke cakera. Hasil cache kekal selepas aplikasi dimulakan semula, mengurangkan penggunaan API. Gunakan butang muat semula semasa menyemak imbas ikon untuk mendapatkan hasil terkini.

## Penyelesaian Masalah

Jika ujian API gagal:
- Pastikan kunci anda betul (tiada ruang tambahan)
- Sahkan sambungan internet anda
- API macosicons.com mungkin tidak tersedia buat sementara waktu
