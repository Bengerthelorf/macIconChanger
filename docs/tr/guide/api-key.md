# API Anahtarı

Çevrimiçi simge araması yapabilmek için [macosicons.com](https://macosicons.com/) sitesinden bir API anahtarı gereklidir. API anahtarı olmadan yerel görsel dosyalarını kullanmaya devam edebilirsiniz.

## API Anahtarı Alma

1. [macosicons.com](https://macosicons.com/) adresini ziyaret edin ve bir hesap oluşturun.
2. Hesap ayarlarınızdan bir API anahtarı talep edin.
3. Anahtarı kopyalayın.

![API anahtarı nasıl alınır](/images/api-key.png)

## Anahtarı Girme

1. IconChanger uygulamasını açın.
2. **Settings** > **Advanced** bölümüne gidin.
3. API anahtarınızı **API Key** alanına yapıştırın.
4. Çalıştığını doğrulamak için **Test Connection** düğmesine tıklayın.

![API anahtarı ayarları](/images/api-key-settings.png)

## API Anahtarı Olmadan Kullanım

API anahtarı olmadan da uygulama simgelerini değiştirebilirsiniz:

- Yerel görsel dosyalarını kullanarak (**Choose from the Local** düğmesine tıklayın veya bir görseli sürükleyip bırakın)
- Uygulamanın kendi içinde bulunan simgeleri kullanarak ("Local" bölümünde gösterilir)

## Gelismis API Ayarlari

**Settings** > **Advanced** > **API Settings** bolumunde API davranisini ince ayar yapabilirsiniz:

| Ayar | Varsayilan | Aciklama |
|---|---|---|
| **Retry Count** | 0 (yeniden deneme yok) | Basarisiz isteklerin kac kez yeniden denenmesi gerektigi (0–3) |
| **Timeout** | 15 saniye | Her istek denemesi icin zaman asimi |
| **Monthly Limit** | 50 | Aylik maksimum API sorgusu |

**Monthly Usage** sayaci mevcut kullaniminizi gosterir. Her ayin 1'inde otomatik olarak sifirlanir veya manuel olarak sifirlayabilirsiniz.

### Simge Arama Onbellegi

Arama sonuclarini diske kaydetmek icin **Cache API Results** secenegini etkinlestirin. Onbellekteki sonuclar uygulama yeniden baslatildiktan sonra da korunur ve API kullanimini azaltir. Guncel sonuclar almak icin simgelere gozatarken yenileme dugmesini kullanin.

## Sorun Giderme

API testi başarısız olursa:
- Anahtarınızın doğru olduğundan emin olun (fazladan boşluk olmamalı)
- İnternet bağlantınızı kontrol edin
- macosicons.com API'si geçici olarak kullanılamıyor olabilir
