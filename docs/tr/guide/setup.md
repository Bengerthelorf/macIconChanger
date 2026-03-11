# İlk Kurulum

IconChanger, uygulama simgelerini değiştirmek için yönetici ayrıcalıklarına ihtiyaç duyar. İlk açılışta uygulama, bunu otomatik olarak ayarlamayı teklif eder.

## Otomatik Kurulum (Önerilen)

1. IconChanger uygulamasını başlatın.
2. İstendiğinde **Setup** düğmesine tıklayın.
3. Yönetici parolanızı girin.

Uygulama, `~/.iconchanger/helper.sh` konumunda bir yardımcı betik oluşturacak ve her seferinde parola sormadan çalışabilmesi için bir sudoers kuralı yapılandıracaktır.

## Manuel Kurulum

Otomatik kurulum başarısız olursa, manuel olarak yapılandırabilirsiniz:

1. Terminal uygulamasını açın.
2. Şu komutu çalıştırın:

```bash
sudo visudo
```

3. Dosyanın sonuna aşağıdaki satırı ekleyin:

```
ALL ALL=(ALL) NOPASSWD: /Users/<kullanici-adiniz>/.iconchanger/helper.sh
```

`<kullanici-adiniz>` kısmını gerçek macOS kullanıcı adınızla değiştirin.

## Kurulumu Doğrulama

Kurulumdan sonra uygulama, kenar çubuğunda uygulama listesini göstermelidir. Kurulum istemini tekrar görüyorsanız, yapılandırma doğru şekilde uygulanmamış olabilir.

Kurulumu menü çubuğundan doğrulayabilirsiniz: **...** menüsüne tıklayın ve **Check Setup Status** seçeneğini seçin.

## Sınırlamalar

macOS Sistem Bütünlüğü Koruması (SIP) tarafından korunan uygulamaların simgeleri değiştirilemez. Bu bir macOS kısıtlamasıdır ve atlanamaz.

Yaygın SIP korumalı uygulamalar:
- Finder
- Safari (bazı macOS sürümlerinde)
- `/System/Applications/` içindeki diğer sistem uygulamaları
