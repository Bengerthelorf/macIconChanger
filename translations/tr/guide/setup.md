# İlk Kurulum

IconChanger, uygulama simgelerini değiştirmek için yönetici ayrıcalıklarına ihtiyaç duyar. İlk açılışta uygulama, bunu otomatik olarak ayarlamayı teklif eder.

## Otomatik Kurulum (Önerilen)

1. IconChanger uygulamasını başlatın.
2. İstendiğinde **Setup** düğmesine tıklayın.
3. Yönetici parolanızı girin.

Uygulama, `/usr/local/lib/iconchanger/` konumuna (`root:wheel` sahipliğinde) bir yardımcı betik yükleyecek ve her seferinde parola sormadan çalışabilmesi için kapsamlı bir sudoers kuralı yapılandıracaktır.

## Güvenlik

IconChanger, yardımcı boru hattını korumak için çeşitli güvenlik önlemleri kullanır:

- **Root sahipliğindeki yardımcı dizin** — Yardımcı dosyalar `/usr/local/lib/iconchanger/` konumunda `root:wheel` sahipliğiyle bulunur ve yetkisiz değişiklikleri önler.
- **SHA-256 bütünlük doğrulaması** — Yardımcı betik, her çalıştırmadan önce bilinen bir hash değerine karşı doğrulanır.
- **Kapsamlı sudoers kuralı** — Sudoers girişi yalnızca belirli yardımcı betiğe parolasız erişim verir, rastgele komutlara değil.
- **Denetim günlüğü** — Tüm simge işlemleri izlenebilirlik için zaman damgalarıyla kaydedilir.

## Manuel Kurulum

Otomatik kurulum başarısız olursa, manuel olarak yapılandırabilirsiniz:

1. Terminal uygulamasını açın.
2. Şu komutu çalıştırın:

```bash
sudo visudo -f /etc/sudoers.d/iconchanger
```

3. Aşağıdaki satırı ekleyin:

```
ALL ALL=(ALL) NOPASSWD: /usr/local/lib/iconchanger/helper.sh
```

## Kurulumu Doğrulama

Kurulumdan sonra uygulama, kenar çubuğunda uygulama listesini göstermelidir. Kurulum istemini tekrar görüyorsanız, yapılandırma doğru şekilde uygulanmamış olabilir.

Kurulumu menü çubuğundan doğrulayabilirsiniz: **...** menüsüne tıklayın ve **Check Setup Status** seçeneğini seçin.

## Sınırlamalar

macOS Sistem Bütünlüğü Koruması (SIP) tarafından korunan uygulamaların simgeleri değiştirilemez. Bu bir macOS kısıtlamasıdır ve atlanamaz.

Yaygın SIP korumalı uygulamalar:
- Finder
- Safari (bazı macOS sürümlerinde)
- `/System/Applications/` içindeki diğer sistem uygulamaları
