# Monetizasyon Rehberi: AdMob + Premium (IAP)

Uygulamada iki gelir kanalı hazır ve kodludur:

| Kanal | Ne zaman gelir üretir | Nerede görünür |
|---|---|---|
| AdMob banner | Ana ekran + bulmaca-sonu ekranı altı | Ücretsiz kullanıcılar |
| AdMob geçiş (interstitial) | Her 3 çözümden sonra, en az 120 sn arayla | Ücretsiz kullanıcılar |
| AdMob ödüllü (rewarded) | Kullanıcı "+3 ipucu" için kendi isteğiyle izler | Ücretsiz kullanıcılar |
| Premium (tek seferlik IAP) | `premium_unlock` satın alımı (~$4.99) | Reklamları kaldırır, sınırsız ipucu, 2 bonus paket |

Tasarım ilkesi: **çözüm ekranında asla reklam yok.** Bu, "saygılı ücretsiz
oyun" konumlandırmasının temelidir; yorumlara ve kalıcılığa doğrudan yansır.

---

## A) AdMob kurulumu (~20 dakika)

1. https://admob.google.com → Google hesabınızla başvurun (hesap onayı
   1 gün sürebilir; ödeme bilgilerini sonra da girebilirsiniz).
2. **Apps → Add app** → *Android* → "Is the app listed on a supported app
   store?" → **No** (henüz yayınlanmadı; yayından sonra mağaza kaydıyla
   eşlersiniz) → adı `Quotecrack` koyun.
3. Oluşan **App ID**'yi not edin: `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY`
   (~ işaretli olan App ID'dir).
4. **Ad units → Add ad unit** ile sırasıyla 3 birim oluşturun:
   - **Banner** → adı `home_banner`
   - **Interstitial** → adı `between_puzzles`
   - **Rewarded** → adı `hint_reward` (ödül: 3 / hint yazabilirsiniz;
     uygulama kendi değerini kullanır)
   Her birinin **Ad unit ID**'sini not edin (`ca-app-pub-…/…`, / işaretli).

### ID'leri yapıştıracağınız YALNIZCA İKİ dosya

**1. `lib/config/monetization_config.dart`**, şu üç satırı kendi ad-unit
ID'lerinizle değiştirin:

```dart
static const String _bannerProd = 'ca-app-pub-SIZINKI/banner';
static const String _interstitialProd = 'ca-app-pub-SIZINKI/interstitial';
static const String _rewardedProd = 'ca-app-pub-SIZINKI/rewarded';
```

**2. `android/app/build.gradle.kts`**, `admobAppId` satırındaki test
değerini kendi **App ID**'nizle (~ işaretli) değiştirin:

```kotlin
manifestPlaceholders["admobAppId"] = "ca-app-pub-SIZINKI~UYGULAMAID"
```

Değiştirip push'layın; Actions yeni AAB üretir. **Debug APK her zaman test
reklamı gösterir** (kod `kDebugMode`'a bakar), bu yüzden telefonda test
ederken gerçek ID'lere tıklamanız diye bir risk yoktur.

> ⚠️ Kendi reklamlarınıza ASLA kendiniz tıklamayın; AdMob hesabı kapatır.
> Yayın sonrası ilk saatlerde "Ad serving limited" görmek normaldir;
> AdMob uygulamayı doğruladıkça açılır (günler-haftalar).

### "Hiç reklam görmüyorum" (bu bir bug DEĞİL)

Yeni yayımlanan, AdMob'un henüz onaylamadığı bir uygulamada banner da,
"+3 ipucu" ödüllü reklamı da bir süre **boş döner** ("no fill"). Sebepleri:

- **Onay bekleme:** AdMob yeni uygulamayı/ad-unit'leri doğrulayana kadar
  reklam doldurmaz. Bu genelde birkaç gün, bazen 1-2 hafta sürer. AdMob →
  uygulamanız → durum "Ready/Getting ready" olunca akış kendiliğinden başlar.
- **Henüz gerçek ID girmediyseniz:** yukarıdaki iki dosyada hâlâ test ID'leri
  varsa, **release** derlemesi (kDebugMode=false) gerçek ID arar ve test
  reklamı GÖSTERMEZ; sonuç yine boş ekran olur.
- **Test etmek için:** **debug APK** her zaman Google'ın test reklamını
  gösterir. Banner'ı, geçiş reklamını ve "+3 ipucu" ödüllü akışını telefonda
  doğrulamak için debug APK kullanın; orada reklam GÖRÜNÜR.

Kodda hata yok: reklam dolmazsa uygulama çökmez, sessizce reklamsız çalışır.
v1.1.5'ten beri "+3 ipucu"na basıldığında reklam hazır değilse kullanıcıya
"şu an video yok, birazdan tekrar deneyin" mesajı gösterilir (eskiden hiçbir
şey olmuyordu, bu yüzden bozuk gibi hissettiriyordu).

#### İpucu/ödüllü reklam: ödül yalnız izlenen reklamla (gelir zırhı)

"+3 ipucu" butonu **yalnızca ödüllü bir reklam gerçekten yüklüyken** etkin olur
(`AdsService.rewardedAvailable` reaktif sinyali). Reklam yoksa — çevrimdışı,
no-fill ya da henüz yüklenmemiş — buton **gri/pasif** görünür. Sonuç:

- **Reklam izlenmeden ASLA ödül verilmez.** Jeton yalnız `onUserEarnedReward`
  tetiklendiğinde (reklam gerçekten tamamlandığında) eklenir.
- **Çevrimdışı suistimal yok.** İnternet kapalıyken reklam yüklenemez → buton
  pasif kalır; kimse interneti kapatıp bedava ipucu alamaz.
- **Bedava yedek (fallback) yol KALDIRILDI.** `AppConfig.grantHintsWithoutAd`
  artık `false` ve hiçbir bedava-jeton dalı yoktur; bir koruma testi
  (`test/logic/economy_test.dart`) bunu CI'da kilitler.

Not: Release derlemeleri (kapalı test dahil) **gerçek** reklam birimi ID'lerini
kullanır; test/sahte reklam yalnız debug derlemede görünür. Kapalı testte AdMob
gerçek reklam sunmaya başlayana kadar buton pasif görünebilir — bu, ekonomiyi
koruyan bilinçli davranıştır.

### app-ads.txt (OPSİYONEL: yayından sonra, geliri %5-15 artırabilir)

Gizlilik politikası için ek bir şey yapmanıza gerek YOK, o, bu reponun
Pages sitesinde otomatik yayında:
`https://tahir94510.github.io/quotecrack/privacy.html`

`app-ads.txt` ise bazı programatik reklam alıcılarının aradığı bir
doğrulama dosyasıdır ve spec gereği alan adının KÖKÜNDE durmak zorundadır
(`tahir94510.github.io/app-ads.txt`). Proje sayfası alt dizin olduğu için
bunun tek yolu, `tahir94510.github.io` adlı ayrı bir "kullanıcı sitesi"
reposudur. Bu dosya OLMADAN da AdMob'un kendi talebi reklam göstermeye
devam eder, yani uygulamayı yayınlamak için gerekmez; gelir oturduktan
sonra 5 dakikalık iyileştirme olarak yapın:

1. GitHub → sağ üst **+** → **New repository** → ad alanına TAM OLARAK
   `tahir94510.github.io` yazın → Public → **Create repository**.
2. **creating a new file** → dosya adı `app-ads.txt` → içerik TEK satır
   (yayıncı kimliğiniz yerleştirilmiş, kopyala-yapıştır hazır):

   ```
   google.com, pub-6486621084238367, DIRECT, f08c47fec0942fa0
   ```

   → **Commit changes**.
3. Play Console mağaza kaydındaki **Website** alanına
   `https://tahir94510.github.io` yazın.
4. 1+ gün sonra AdMob → Apps → app-ads.txt durumunu kontrol edin.

## A2) Mediation: AdMob'a ek reklam ağları (bidding) — kod HAZIR

Uygulama, AdMob'un **bidding mediation**'ı için üç ek ağın resmî Flutter
adaptörleriyle gelir (pubspec: `gma_mediation_applovin`, `gma_mediation_unity`,
`gma_mediation_pangle`). Bidding = her gösterim için ağlar gerçek zamanlı
açık artırmada yarışır; şelale (waterfall) sıralaması ve elle eCPM yönetimi
YOKTUR. Google'ın 2026 tavsiyesi de budur.

**Neden bu üçü?** Bireysel geliştirici hesabıyla sürtünmesiz açılırlar ve
oyun kitlesinde en güçlü talebe sahiptirler:

| Ağ | Güçlü olduğu yer | Hesap |
|---|---|---|
| AppLovin | Geçiş + ödüllü (oyun demandı lideri) | applovin.com |
| Unity Ads | Ödüllü + geçiş (oyun reklamcılığı merkezi) | cloud.unity.com |
| Pangle (TikTok) | Ödüllü + geçiş, TR dahil global | pangleglobal.com |

(Meta Audience Network banner/geçişte çok güçlüdür ama **işletme doğrulaması**
ister; ileride doğrulamayı tamamlarsanız `gma_mediation_meta` paketi tek
satırla eklenir + aşağıdaki aynı konsol adımları uygulanır.)

**Formata bağlama:** ÜÇ formata da (banner/geçiş/ödüllü) üç ağın hepsini
bidder olarak ekleyin. Açık artırma, hangi ağın hangi formatta güçlü olduğunu
gösterim başına kendisi çözer — elle format ayrımı yapmayın.

Adaptörler siz konsol kurulumunu yapana kadar **zararsızca pasiftir**:
uygulama bugünkü gibi yalnız AdMob'la çalışır. Kurulum bittiği anda (yeni
sürüm gerekmeden*) açık artırma devreye girer. (*AppLovin hariç: SDK anahtarı
derlemeye girdiği için bir sürüm güncellemesi gerekir — aşağıda.)

### Konsol kurulumu, sırasıyla (~20 dk/ağ)

1. **Ağ hesapları:** üç ağda da yayıncı hesabı açın (yukarıdaki tablo).
   Her birinde uygulamayı kaydedin — paket adı: `io.github.tahir94510.quotecrack`.
   - AppLovin: kayıt sonrası **Account → Keys → SDK Key**'i kopyalayın.
   - Unity: bir "Project" oluşturun → **Game ID** (Android) not edin.
   - Pangle: uygulama ekleyin → **App ID** not edin; her format için bir
     "Ad Placement" oluşturun (tip: Banner/Interstitial/Rewarded, bidding).
2. **AppLovin SDK anahtarını koda girin** (tek satır):
   `android/app/build.gradle.kts` → `manifestPlaceholders["applovinSdkKey"] = "ANAHTARINIZ"`.
   Boş kaldığı sürece AppLovin adaptörü pasiftir, diğer her şey çalışır.
3. **AdMob → Mediation → Create mediation group** — üç grup açın:
   - `android_banner` (format: Banner, platform: Android) → ad unit: `home_banner`
   - `android_interstitial` (Interstitial) → ad unit: `between_puzzles`
   - `android_rewarded` (Rewarded) → ad unit: `hint_reward`
   Her grupta **Add bidding ad source** → AppLovin / Unity Ads / Pangle'ı
   ekleyin → her ağ için çıkan **ortaklık sözleşmesini** onaylayın →
   istenen kimlikleri eşleyin (Unity: Game ID; Pangle: App ID + Placement;
   AppLovin: hesap bağlantısı yeterli).
4. **GDPR ortak listesi:** AdMob → Privacy & messaging → GDPR mesajınız →
   **Review your ad partners** → AppLovin, Unity Ads ve Pangle'ı işaretleyin →
   mesajı yeniden **Publish** edin. (Uygulamadaki UMP/TCF akışı hazır; ek kod
   gerekmez — SDK'lar TCF onay dizesini kendileri okur.)
5. **Play Console → App content → Data safety:** üç ağın topladığı veriyi
   beyana ekleyin. Hazır beyan tabloları:
   - AppLovin: https://developers.applovin.com/en/max/android/overview/data-and-user-privacy/
   - Unity: https://docs.unity.com/ads/en-us/manual/GoogleDataSafety
   - Pangle: https://www.pangleglobal.com/help/doc/google-play-data-safety
   (Genelde: cihaz/reklam kimliği, kaba konum (IP), etkileşim verisi —
   "Advertising or marketing" amacıyla, üçüncü tarafla paylaşılan.)
6. **app-ads.txt satırları:** `pages/app-ads.txt` içindeki şablon satırların
   yer tutucularını her ağın panelinde gösterilen KENDİ yayıncı kimliğinizle
   doldurun ve dosyayı `tahir94510.github.io` kullanıcı-sitesi reposuna
   kopyalayın (kurulum §app-ads.txt'de anlatıldı).
7. **Doğrulama:** debug APK → Ayarlar → **Ad Inspector (debug)** → her
   adaptörün "initialized" göründüğünü ve test isteklerinde bidder'ların
   yarıştığını kontrol edin. (Adaptör durumu release'te de loglanır ama
   Ad Inspector en net araçtır.)

> Notlar: (1) Yeni eklenen ağların doldurma oranı ilk günlerde düşük olur —
> ağlar uygulamayı incelerken normaldir. (2) AdMob raporlarında mediation
> geliri "Bidding" satırlarında ayrışır. (3) Adaptörler ~3-4 MB APK boyutu
> ekler; bidding'in gelir artışı bunun karşılığıdır. (4) `google_mobile_ads`
> ^8'e sabitli — gerekçe pubspec'te; Unity adaptörü ^9 çıkınca birlikte
> yükseltilir.

## B) Premium IAP kurulumu (~10 dakika)

Play Console → uygulamanız → **Monetize → Products → In-app products**:

1. **Create product**.
2. **Product ID:** `premium_unlock`  ← BİREBİR böyle olmalı
   (kod `lib/config/monetization_config.dart` içinde bunu arar).
3. **Name:** `Quotecrack Premium`
4. **Description:** `Remove all ads, unlock unlimited hints, and enjoy
   exclusive bonus puzzle packs. One purchase, yours forever.`
   > Ucu açık tutuldu (paket adı/sayısı yazmıyor): ileride premium paket
   > ekleyince bu açıklamayı güncellemek zorunda kalmazsınız.
5. **Price:** $4.99 (Google diğer para birimlerine kendisi çevirir;
   isterseniz ülke ülke düzeltebilirsiniz).
6. **Activate** edin.

> Not: IAP ürünleri ancak en az bir AAB **kapalı test kanalına yüklendikten
> sonra** oluşturulabilir; "ürün ekleyemiyorum" görürseniz önce
> YAYINLAMA_REHBERI §7'yi tamamlayın.

### Satın almayı ücretsiz test etme (license tester)

Play Console (uygulama değil, konsol ana sayfası) → **Settings → License
testing** → kendi Gmail'inizi ekleyin. Bu hesap, kapalı testteki uygulamada
**ödeme yapmadan** satın alma akışını uçtan uca test edebilir (kart ekranı
"test card" der). Şunları doğrulayın:

- [ ] Paywall fiyatı mağazadan geliyor (yüklenirken "Loading price…" yazar).
- [ ] Satın alınca reklamlar anında kayboluyor, ipuçları sınırsız oluyor,
      Klasikler paketi açılıyor.
- [ ] Uygulamayı silip yeniden kurunca **Settings → Restore purchases**
      premium'u geri getiriyor.

## C) Gelir beklentisi (dürüst rakamlar)

Kelime bulmaca kitlesi (ABD ağırlıklı, yaşı yüksekçe) mobil oyun
ortalamasının ÜZERİNDE eCPM getirir, ancak ilk aylar trafik azdır:

- Banner eCPM tipik: $0.3-1.5 · Geçiş reklamı: $8-20 · Ödüllü: $10-25
- Kaba senaryo: günde 300 aktif kullanıcı × ort. 2 geçiş reklamı ≈
  600 gösterim × $12 eCPM ≈ **~$7/gün** + banner + ödüllü + ara sıra
  premium satışı. 1.000+ günlük kullanıcıda bu doğrusal büyür.
- İlk 2-3 ay düşük olur; mağaza sıralamasına girdikçe organik trafik
  bileşik artar. Paylaşım virali (günlük bulmaca sonucu) ve puanlar
  (in-app review akışı entegre) bu eğriyi hızlandırır.

Ayarlanabilir her şey `lib/config/app_config.dart` içindedir (geçiş reklamı
sıklığı, ipucu jetonları, vb.), agresifleştirmeden önce yorumlara etkisini
izleyin.
