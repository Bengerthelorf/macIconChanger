# Mula Pantas

## Keperluan

- macOS 13.0 (Ventura) atau lebih baharu
- Keistimewaan pentadbir (untuk persediaan awal dan menukar ikon)

## Pemasangan

### Homebrew (Disyorkan)

```bash
brew install Bengerthelorf/tap/iconchanger
```

### Muat Turun Manual

1. Muat turun DMG terkini dari [GitHub Releases](https://github.com/Bengerthelorf/macIconChanger/releases/latest).
2. Buka DMG dan seret **IconChanger** ke dalam folder Applications anda.
3. Lancarkan IconChanger.

## Pelancaran Pertama

Pada pelancaran pertama, IconChanger akan meminta anda melengkapkan persediaan kebenaran sekali sahaja. Ini diperlukan supaya aplikasi boleh menukar ikon aplikasi.

![Skrin persediaan pelancaran pertama](/images/setup-prompt.png)

Klik butang persediaan dan masukkan kata laluan pentadbir anda. IconChanger akan mengkonfigurasi kebenaran yang diperlukan secara automatik (peraturan sudoers untuk skrip pembantu).

::: tip
Jika persediaan automatik gagal, lihat [Persediaan Awal](./setup) untuk arahan manual.
:::

## Menukar Ikon Pertama Anda

1. Pilih aplikasi dari bar sisi.
2. Layari ikon dari [macOSicons.com](https://macosicons.com/) atau pilih fail imej tempatan.
3. Klik pada ikon untuk menggunakannya.

![Antara muka utama](/images/main-interface.png)

Itu sahaja! Ikon aplikasi akan ditukar serta-merta.

## Langkah Seterusnya

- [Sediakan kunci API](./api-key) untuk carian ikon dalam talian
- [Ketahui tentang alias aplikasi](./aliases) untuk hasil carian yang lebih baik
- [Konfigurasikan perkhidmatan latar belakang](./background-service) untuk pemulihan ikon automatik
- [Pasang alat CLI](/ms/cli/) untuk akses baris perintah
