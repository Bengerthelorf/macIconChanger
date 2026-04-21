---
title: Komut Referansı
section: cli
locale: tr
---

## Genel Bakış

```
iconchanger <komut> [seçenekler]
```

## Komutlar

### `status`

Mevcut yapılandırma durumunu gösterir.

```bash
iconchanger status
```

Görüntülenen bilgiler:
- Yapılandırılan uygulama takma adlarının sayısı
- Önbelleğe alınan simge sayısı
- Yardımcı betik durumu

---

### `list`

Tüm takma adları ve önbelleğe alınan simgeleri listeler.

```bash
iconchanger list
```

Yapılandırılan tüm takma adların ve önbelleğe alınan simge girişlerinin bir tablosunu gösterir.

---

### `set-icon`

Bir uygulama için özel simge ayarlar.

```bash
iconchanger set-icon <uygulama-yolu> <görsel-yolu>
```

**Argümanlar:**
- `uygulama-yolu` — Uygulamanın yolu (ör. `/Applications/Safari.app`)
- `görsel-yolu` — Simge görselinin yolu (PNG, JPEG, ICNS vb.)

**Örnekler:**

```bash
# Safari için özel simge ayarla
iconchanger set-icon /Applications/Safari.app ~/icons/safari.png

# Göreceli yollar da çalışır
iconchanger set-icon /Applications/Slack.app ./slack-icon.icns
```

---

### `remove-icon`

Özel simgeyi kaldırır ve orijinalini geri yükler.

```bash
iconchanger remove-icon <uygulama-yolu>
```

**Örnek:**

```bash
iconchanger remove-icon /Applications/Safari.app
```

---

### `restore`

Önbelleğe alınan tüm özel simgeleri geri yükler. Sistem güncellemesinden sonra veya uygulamalar simgelerini sıfırladığında kullanışlıdır.

```bash
iconchanger restore [seçenekler]
```

**Seçenekler:**
- `--dry-run` — Değişiklik yapmadan nelerin geri yükleneceğini önizler
- `--verbose` — Her simge için ayrıntılı çıktı gösterir
- `--force` — Simge değişmemiş görünse bile geri yükleme yapar

**Örnekler:**

```bash
# Önbelleğe alınan tüm simgeleri geri yükle
iconchanger restore

# Ne olacağını önizle
iconchanger restore --dry-run --verbose

# Her şeyi zorla geri yükle
iconchanger restore --force
```

---

### `export`

Takma adları ve önbelleğe alınan simge yapılandırmasını bir JSON dosyasına dışarı aktarır.

```bash
iconchanger export <çıktı-yolu>
```

**Örnek:**

```bash
iconchanger export ~/Desktop/my-icons.json
```

---

### `import`

Bir yapılandırma dosyasını içeri aktarır.

```bash
iconchanger import <girdi-yolu>
```

İçeri aktarma yalnızca yeni öğeler ekler — mevcut girişleri asla değiştirmez veya silmez.

**Örnek:**

```bash
iconchanger import ~/Desktop/my-icons.json
```

---

### `validate`

İçeri aktarmadan önce bir yapılandırma dosyasını doğrular.

```bash
iconchanger validate <dosya-yolu>
```

Herhangi bir değişiklik yapmadan JSON yapısını, gerekli alanları ve veri bütünlüğünü kontrol eder.

**Örnek:**

```bash
iconchanger validate ~/Desktop/my-icons.json
```

---

### `escape-jail`

Paketlenmiş simgeleri özel simge olarak yeniden uygulayarak macOS Tahoe'nun squircle hapishanesinden kaçış sağlar. Özel simgeler squircle zorunluluğunu atlayarak orijinal simge şeklini korur.

```bash
iconchanger escape-jail [uygulama-yolu] [seçenekler]
```

**Argümanlar:**
- `uygulama-yolu` — (İsteğe bağlı) Belirli bir `.app` paketinin yolu. Belirtilmezse `/Applications` içindeki tüm uygulamaları işler.

**Seçenekler:**
- `--dry-run` — Değişiklik yapmadan nelerin yapılacağını önizler
- `--verbose` — Ayrıntılı çıktı gösterir

**Örnekler:**

```bash
# /Applications içindeki tüm uygulamalar için squircle hapishaneden kaçış
iconchanger escape-jail

# Ne olacağını önizle
iconchanger escape-jail --dry-run --verbose

# Belirli bir uygulama için squircle hapishaneden kaçış
iconchanger escape-jail /Applications/Safari.app
```

::: warning
Özel simgeler, macOS Tahoe'nun Clear, Tinted veya Dark simge modlarını desteklemez. Statik bitmap olarak kalırlar.
:::

---

### `completions`

Sekme tamamlama için kabuk tamamlama betikleri oluşturur.

```bash
iconchanger completions <kabuk>
```

**Argümanlar:**
- `kabuk` — Kabuk türü: `zsh`, `bash` veya `fish`

**Örnekler:**

```bash
# Zsh (~/.zshrc dosyasına ekleyin)
source <(iconchanger completions zsh)

# Bash (~/.bashrc dosyasına ekleyin)
source <(iconchanger completions bash)

# Fish
iconchanger completions fish > ~/.config/fish/completions/iconchanger.fish
```