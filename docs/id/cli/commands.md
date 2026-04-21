---
title: Referensi Perintah
section: cli
locale: id
---

## Ringkasan

```
iconchanger <command> [options]
```

## Perintah

### `status`

Menampilkan status konfigurasi saat ini.

```bash
iconchanger status
```

Menampilkan:
- Jumlah alias aplikasi yang dikonfigurasi
- Jumlah ikon yang di-cache
- Status skrip helper

---

### `list`

Menampilkan daftar semua alias dan ikon yang di-cache.

```bash
iconchanger list
```

Menampilkan tabel semua alias yang dikonfigurasi dan semua entri ikon yang di-cache.

---

### `set-icon`

Mengatur ikon kustom untuk suatu aplikasi.

```bash
iconchanger set-icon <app-path> <image-path>
```

**Argumen:**
- `app-path` — Path ke aplikasi (misalnya, `/Applications/Safari.app`)
- `image-path` — Path ke gambar ikon (PNG, JPEG, ICNS, dll.)

**Contoh:**

```bash
# Mengatur ikon kustom Safari
iconchanger set-icon /Applications/Safari.app ~/icons/safari.png

# Path relatif juga bisa digunakan
iconchanger set-icon /Applications/Slack.app ./slack-icon.icns
```

---

### `remove-icon`

Menghapus ikon kustom dan memulihkan ikon asli.

```bash
iconchanger remove-icon <app-path>
```

**Contoh:**

```bash
iconchanger remove-icon /Applications/Safari.app
```

---

### `restore`

Memulihkan semua ikon kustom yang di-cache. Berguna setelah pembaruan sistem atau saat aplikasi mengatur ulang ikonnya.

```bash
iconchanger restore [options]
```

**Opsi:**
- `--dry-run` — Pratinjau apa yang akan dipulihkan tanpa melakukan perubahan
- `--verbose` — Menampilkan output detail untuk setiap ikon
- `--force` — Memulihkan meskipun ikon tampak tidak berubah

**Contoh:**

```bash
# Memulihkan semua ikon yang di-cache
iconchanger restore

# Pratinjau apa yang akan terjadi
iconchanger restore --dry-run --verbose

# Paksa pulihkan semuanya
iconchanger restore --force
```

---

### `export`

Mengekspor alias dan konfigurasi ikon yang di-cache ke file JSON.

```bash
iconchanger export <output-path>
```

**Contoh:**

```bash
iconchanger export ~/Desktop/my-icons.json
```

---

### `import`

Mengimpor file konfigurasi.

```bash
iconchanger import <input-path>
```

Impor hanya menambahkan item baru — tidak pernah mengganti atau menghapus entri yang sudah ada.

**Contoh:**

```bash
iconchanger import ~/Desktop/my-icons.json
```

---

### `validate`

Memvalidasi file konfigurasi sebelum mengimpor.

```bash
iconchanger validate <file-path>
```

Memeriksa struktur JSON, field yang diperlukan, dan integritas data tanpa melakukan perubahan.

**Contoh:**

```bash
iconchanger validate ~/Desktop/my-icons.json
```

---

### `escape-jail`

Keluar dari squircle jail macOS Tahoe dengan menerapkan ulang ikon bawaan sebagai ikon kustom. Ikon kustom melewati penerapan squircle, mempertahankan bentuk ikon asli.

```bash
iconchanger escape-jail [app-path] [options]
```

**Argumen:**
- `app-path` — (Opsional) Path ke bundle `.app` tertentu. Jika tidak disebutkan, memproses semua aplikasi di `/Applications`.

**Opsi:**
- `--dry-run` — Pratinjau apa yang akan dilakukan tanpa melakukan perubahan
- `--verbose` — Menampilkan output detail

**Contoh:**

```bash
# Escape jail untuk semua aplikasi di /Applications
iconchanger escape-jail

# Pratinjau apa yang akan terjadi
iconchanger escape-jail --dry-run --verbose

# Escape jail untuk aplikasi tertentu
iconchanger escape-jail /Applications/Safari.app
```

::: warning
Ikon kustom tidak mendukung mode ikon Clear, Tinted, atau Dark di macOS Tahoe. Ikon tetap berupa bitmap statis.
:::

---

### `completions`

Menghasilkan skrip penyelesaian shell untuk penyelesaian tab.

```bash
iconchanger completions <shell>
```

**Argumen:**
- `shell` — Jenis shell: `zsh`, `bash`, atau `fish`

**Contoh:**

```bash
# Zsh (tambahkan ke ~/.zshrc)
source <(iconchanger completions zsh)

# Bash (tambahkan ke ~/.bashrc)
source <(iconchanger completions bash)

# Fish
iconchanger completions fish > ~/.config/fish/completions/iconchanger.fish
```