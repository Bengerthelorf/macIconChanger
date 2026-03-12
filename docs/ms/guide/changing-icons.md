# Menukar Ikon

## Menggunakan GUI

### Carian Dalam Talian

1. Pilih aplikasi dari bar sisi.
2. Layari ikon dari [macOSicons.com](https://macosicons.com/) di kawasan utama.
3. Gunakan menu lungsur **Style** untuk menapis mengikut gaya (contohnya, Liquid Glass).
4. Klik ikon untuk menggunakannya.

![Mencari ikon](/images/search-icons.png)

### Pilih Fail Tempatan

Klik **Choose from the Local** (atau tekan <kbd>Cmd</kbd>+<kbd>O</kbd>) untuk membuka pemilih fail. Format yang disokong: PNG, JPEG, ICNS, TIFF, HEIC, WebP, BMP, GIF, SVG.

### Seret & Lepas

Seret fail imej dari Finder terus ke kawasan ikon aplikasi. Sorotan biru akan muncul untuk mengesahkan zon lepas.

![Seret dan lepas](/images/drag-drop.png)

### Pulihkan Ikon Asal

Untuk memulihkan ikon asal aplikasi:
- Klik butang **Restore Default** (atau tekan <kbd>Cmd</kbd>+<kbd>Delete</kbd>)
- Atau klik kanan aplikasi di bar sisi dan pilih **Restore Default Icon**

## Escape Squircle Jail (macOS Tahoe)

macOS 26 Tahoe memaksa semua ikon aplikasi ke dalam bentuk squircle (segi empat bulat). Aplikasi dengan ikon yang tidak mematuhi format ini akan dikecilkan dan diletakkan di atas latar belakang squircle kelabu.

IconChanger boleh membetulkan ini dengan menggunakan semula ikon asal aplikasi yang dibundel sebagai ikon tersuai, yang memintas penguatkuasaan squircle macOS.

### Setiap Aplikasi

Klik kanan aplikasi di bar sisi dan pilih **Escape Squircle Jail**.

### Semua Aplikasi Sekaligus

Klik menu **⋯** di bar alat dan pilih **Escape Squircle Jail (All Apps)**. Ini memproses semua aplikasi yang belum mempunyai ikon tersuai.

::: tip
Ikon tersuai yang ditetapkan dengan cara ini **tidak** menyokong mod ikon Clear, Tinted, atau Dark macOS Tahoe — ia kekal statik. Ini adalah had sistem.
:::

::: info
Perkhidmatan latar belakang anda akan menggunakan semula ikon secara automatik selepas kemas kini aplikasi, memastikan ia kekal di luar squircle jail.
:::

## Ikon Folder

Anda juga boleh menyesuaikan ikon folder. Tambah folder melalui **Settings** > **Application** > **Application Folders**, atau klik butang **+** di bahagian folder bar sisi.

Selepas folder ditambah, ia muncul di bar sisi seperti aplikasi. Anda boleh mencari ikon, seret dan lepas imej, atau pilih fail tempatan — aliran kerja yang sama seperti menukar ikon aplikasi.

::: tip
Nama folder seperti "go" atau "Downloads" mungkin tidak memberikan hasil carian yang baik dari macOSicons.com. Gunakan [alias](./aliases) untuk menetapkan nama yang lebih mesra carian (contohnya, tetapkan alias "Documents" kepada "folder").
:::

## Cache Ikon

Apabila anda menggunakan ikon tersuai, ia dicache secara automatik. Ini bermakna:
- Ikon tersuai anda boleh dipulihkan selepas kemas kini aplikasi
- Perkhidmatan latar belakang boleh menggunakannya semula mengikut jadual
- Anda boleh mengeksport dan mengimport konfigurasi ikon anda

Urus ikon yang dicache dalam **Settings** > **Icon Cache**.

## Pintasan Papan Kekunci

| Pintasan | Tindakan |
|---|---|
| <kbd>Cmd</kbd>+<kbd>O</kbd> | Pilih fail ikon tempatan |
| <kbd>Cmd</kbd>+<kbd>Delete</kbd> | Pulihkan ikon asal |
| <kbd>Cmd</kbd>+<kbd>R</kbd> | Muat semula paparan ikon |

## Petua

- Jika tiada ikon ditemui untuk aplikasi, cuba [tetapkan alias](./aliases) dengan nama yang lebih ringkas.
- Pembilang (contohnya, "12/15") menunjukkan berapa banyak ikon yang berjaya dimuat daripada jumlah keseluruhan yang ditemui.
- Ikon diisih mengikut populariti (bilangan muat turun) secara lalai.
