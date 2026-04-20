# Simge Değiştirme

## GUI Kullanımı

### Çevrimiçi Arama

1. Kenar çubuğundan bir uygulama seçin.
2. Ana alanda [macOSicons.com](https://macosicons.com/) üzerindeki simgelere göz atın.
3. Stile göre filtrelemek için **Style** açılır menüsünü kullanın (ör. Liquid Glass).
4. Uygulamak için bir simgeye tıklayın.

![Simge arama](/images/search-icons.png)

### Yerel Dosya Seçme

Bir dosya seçici açmak için **Choose from the Local** düğmesine tıklayın (veya <kbd>Cmd</kbd>+<kbd>O</kbd> tuşlarına basın). Desteklenen formatlar: PNG, JPEG, ICNS, TIFF, HEIC, WebP, BMP, GIF, SVG.

### Sürükle ve Bırak

Finder'dan bir görsel dosyasını doğrudan uygulamanın simge alanına sürükleyin. Bırakma bölgesini onaylamak için mavi bir vurgu görünecektir.

![Sürükle ve bırak](/images/drag-drop.png)

### Varsayılan Simgeyi Geri Yükleme

Bir uygulamanın orijinal simgesini geri yüklemek için:
- **Restore Default** düğmesine tıklayın (veya <kbd>Cmd</kbd>+<kbd>Delete</kbd> tuşlarına basın)
- Veya kenar çubuğunda uygulamaya sağ tıklayıp **Restore Default Icon** seçeneğini seçin

## Squircle Hapisten Kaçış (macOS Tahoe)

macOS 26 Tahoe, tüm uygulama simgelerini squircle (yuvarlatılmış kare) şekline zorlar. Uyumlu olmayan simgelere sahip uygulamalar küçültülür ve gri bir squircle arka planına yerleştirilir.

IconChanger, uygulamanın kendi paketlenmiş simgesini özel simge olarak yeniden uygulayarak bunu düzeltebilir; bu, macOS'un squircle zorunluluğunu atlar.

### Tek Uygulama İçin

Kenar çubuğunda bir uygulamaya sağ tıklayın ve **Escape Squircle Jail** seçeneğini seçin.

### Tüm Uygulamalar İçin

Araç çubuğundaki **⋯** menüsüne tıklayın ve **Escape Squircle Jail (All Apps)** seçeneğini seçin. Bu, henüz özel simgesi olmayan tüm uygulamaları işler.

::: tip
Bu yöntemle ayarlanan özel simgeler, macOS Tahoe'nun Clear, Tinted veya Dark simge modlarını **desteklemez** — statik kalırlar. Bu bir sistem sınırlamasıdır.
:::

::: info
Arka plan hizmetiniz, uygulama güncellemelerinden sonra simgeleri otomatik olarak yeniden uygulayarak squircle hapisten çıkmış hallerini korur.
:::

## Klasör Simgeleri

Klasör simgelerini de özelleştirebilirsiniz. **Settings** > **Application** > **Application Folders** üzerinden klasör ekleyin veya kenar çubuğunun klasör bölümündeki **+** düğmesine tıklayın.

Bir klasör eklendikten sonra, uygulamalar gibi kenar çubuğunda görünür. Simge arayabilir, görsel sürükleyip bırakabilir veya yerel dosya seçebilirsiniz — uygulama simgelerini değiştirmekle aynı iş akışı.

::: tip
"go" veya "Downloads" gibi klasör adları macOSicons.com'da iyi arama sonuçları vermeyebilir. Daha arama dostu bir ad belirlemek için [takma adları](./aliases) kullanın (ör. "Documents" için takma adı "folder" olarak ayarlayın).
:::

## Simge Önbellekleme

Özel bir simge uyguladığınızda, otomatik olarak önbelleğe alınır. Bu şu anlama gelir:
- Özel simgeleriniz uygulama güncellemelerinden sonra geri yüklenebilir
- Arka plan hizmeti bunları belirli aralıklarla yeniden uygulayabilir
- Simge yapılandırmalarınızı dışarı ve içeri aktarabilirsiniz

Önbelleğe alınan simgeleri **Settings** > **Icon Cache** bölümünden yönetin.

## Klavye Kısayolları

| Kısayol | İşlem |
|---|---|
| <kbd>Cmd</kbd>+<kbd>O</kbd> | Yerel simge dosyası seçme |
| <kbd>Cmd</kbd>+<kbd>Delete</kbd> | Varsayılan simgeyi geri yükleme |
| <kbd>Cmd</kbd>+<kbd>R</kbd> | Simge görünümünü yenileme |

## İpuçları

- Bir uygulama için simge bulunamıyorsa, daha basit bir adla [takma ad ayarlamayı](./aliases) deneyin.
- Sayaç (ör. "12/15"), bulunan toplam simgeden kaçının başarıyla yüklendiğini gösterir.
- Simgeler varsayılan olarak popülerliğe (indirme sayısına) göre sıralanır.
