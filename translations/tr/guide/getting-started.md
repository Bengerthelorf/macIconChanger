# Hızlı Başlangıç

## Gereksinimler

- macOS 13.0 (Ventura) veya üstü
- Yönetici ayrıcalıkları (ilk kurulum ve simge değiştirme için)

## Kurulum

### Homebrew (Önerilen)

```bash
brew install Bengerthelorf/tap/iconchanger
```

### Manuel İndirme

1. En son DMG dosyasını [GitHub Releases](https://github.com/Bengerthelorf/macIconChanger/releases/latest) sayfasından indirin.
2. DMG dosyasını açın ve **IconChanger** uygulamasını Uygulamalar klasörüne sürükleyin.
3. IconChanger uygulamasını başlatın.

## İlk Açılış

İlk açılışta IconChanger, tek seferlik bir izin kurulumunu tamamlamanızı isteyecektir. Bu, uygulamanın uygulama simgelerini değiştirebilmesi için gereklidir.

![İlk açılış kurulum ekranı](/images/setup-prompt.png)

Kurulum düğmesine tıklayın ve yönetici parolanızı girin. IconChanger gerekli izinleri (yardımcı betik için bir sudoers kuralı) otomatik olarak yapılandıracaktır.

::: tip
Otomatik kurulum başarısız olursa, manuel talimatlar için [İlk Kurulum](./setup) sayfasına bakın.
:::

## İlk Simgenizi Değiştirme

1. Kenar çubuğundan bir uygulama seçin.
2. [macOSicons.com](https://macosicons.com/) üzerinden simgelere göz atın veya yerel bir görsel dosyası seçin.
3. Uygulamak için bir simgeye tıklayın.

![Ana arayüz](/images/main-interface.png)

Hepsi bu kadar! Uygulama simgesi anında değiştirilecektir.

## Sonraki Adımlar

- Çevrimiçi simge araması için [API anahtarı ayarlayın](./api-key)
- Daha iyi arama sonuçları için [uygulama takma adlarını öğrenin](./aliases)
- Otomatik simge geri yükleme için [arka plan hizmetini yapılandırın](./background-service)
- Komut satırı erişimi için [CLI aracını kurun](/tr/cli/)
