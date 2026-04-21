---
title: Rujukan Perintah
section: cli
locale: ms
---

## Gambaran Keseluruhan

```
iconchanger <command> [options]
```

## Perintah

### `status`

Tunjukkan status konfigurasi semasa.

```bash
iconchanger status
```

Memaparkan:
- Bilangan alias aplikasi yang dikonfigurasi
- Bilangan ikon yang dicache
- Status skrip pembantu

---

### `list`

Senaraikan semua alias dan ikon yang dicache.

```bash
iconchanger list
```

Menunjukkan jadual semua alias yang dikonfigurasi dan semua entri ikon yang dicache.

---

### `set-icon`

Tetapkan ikon tersuai untuk aplikasi.

```bash
iconchanger set-icon <app-path> <image-path>
```

**Argumen:**
- `app-path` — Laluan ke aplikasi (contohnya, `/Applications/Safari.app`)
- `image-path` — Laluan ke imej ikon (PNG, JPEG, ICNS, dll.)

**Contoh:**

```bash
# Tetapkan ikon Safari tersuai
iconchanger set-icon /Applications/Safari.app ~/icons/safari.png

# Laluan relatif juga berfungsi
iconchanger set-icon /Applications/Slack.app ./slack-icon.icns
```

---

### `remove-icon`

Buang ikon tersuai dan pulihkan ikon asal.

```bash
iconchanger remove-icon <app-path>
```

**Contoh:**

```bash
iconchanger remove-icon /Applications/Safari.app
```

---

### `restore`

Pulihkan semua ikon tersuai yang dicache. Berguna selepas kemas kini sistem atau apabila aplikasi menetapkan semula ikon mereka.

```bash
iconchanger restore [options]
```

**Pilihan:**
- `--dry-run` — Pratonton apa yang akan dipulihkan tanpa membuat perubahan
- `--verbose` — Tunjukkan output terperinci untuk setiap ikon
- `--force` — Pulihkan walaupun ikon kelihatan tidak berubah

**Contoh:**

```bash
# Pulihkan semua ikon yang dicache
iconchanger restore

# Pratonton apa yang akan berlaku
iconchanger restore --dry-run --verbose

# Paksa pulihkan semuanya
iconchanger restore --force
```

---

### `export`

Eksport alias dan konfigurasi ikon yang dicache ke fail JSON.

```bash
iconchanger export <output-path>
```

**Contoh:**

```bash
iconchanger export ~/Desktop/my-icons.json
```

---

### `import`

Import fail konfigurasi.

```bash
iconchanger import <input-path>
```

Import hanya menambah item baharu — ia tidak pernah menggantikan atau membuang entri sedia ada.

**Contoh:**

```bash
iconchanger import ~/Desktop/my-icons.json
```

---

### `validate`

Sahkan fail konfigurasi sebelum mengimport.

```bash
iconchanger validate <file-path>
```

Menyemak struktur JSON, medan yang diperlukan, dan integriti data tanpa membuat perubahan.

**Contoh:**

```bash
iconchanger validate ~/Desktop/my-icons.json
```

---

### `escape-jail`

Lepaskan diri dari squircle jail macOS Tahoe dengan menggunakan semula ikon yang dibundel sebagai ikon tersuai. Ikon tersuai memintas penguatkuasaan squircle, mengekalkan bentuk ikon asal.

```bash
iconchanger escape-jail [app-path] [options]
```

**Argumen:**
- `app-path` — (Pilihan) Laluan ke bundel `.app` tertentu. Jika ditinggalkan, memproses semua aplikasi dalam `/Applications`.

**Pilihan:**
- `--dry-run` — Pratonton apa yang akan dilakukan tanpa membuat perubahan
- `--verbose` — Tunjukkan output terperinci

**Contoh:**

```bash
# Lepaskan jail untuk semua aplikasi dalam /Applications
iconchanger escape-jail

# Pratonton apa yang akan berlaku
iconchanger escape-jail --dry-run --verbose

# Lepaskan jail untuk aplikasi tertentu
iconchanger escape-jail /Applications/Safari.app
```

::: warning
Ikon tersuai tidak menyokong mod ikon Clear, Tinted, atau Dark macOS Tahoe. Ia kekal sebagai bitmap statik.
:::

---

### `completions`

Jana skrip pelengkapan shell untuk pelengkapan tab.

```bash
iconchanger completions <shell>
```

**Argumen:**
- `shell` — Jenis shell: `zsh`, `bash`, atau `fish`

**Contoh:**

```bash
# Zsh (tambah ke ~/.zshrc)
source <(iconchanger completions zsh)

# Bash (tambah ke ~/.bashrc)
source <(iconchanger completions bash)

# Fish
iconchanger completions fish > ~/.config/fish/completions/iconchanger.fish
```