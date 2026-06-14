# Monetizasyon Rehberi — AdMob + Premium (IAP)

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
   Her birinin **Ad unit ID**'sini not edin (`ca-app-pub-…/…` — / işaretli).

### ID'leri yapıştıracağınız YALNIZCA İKİ dosya

**1. `lib/config/monetization_config.dart`** — şu üç satırı kendi ad-unit
ID'lerinizle değiştirin:

```dart
static const String _bannerProd = 'ca-app-pub-SIZINKI/banner';
static const String _interstitialProd = 'ca-app-pub-SIZINKI/interstitial';
static const String _rewardedProd = 'ca-app-pub-SIZINKI/rewarded';
```

**2. `android/app/build.gradle.kts`** — `admobAppId` satırındaki test
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

### app-ads.txt (OPSİYONEL — yayından sonra, geliri %5-15 artırabilir)

Gizlilik politikası için ek bir şey yapmanıza gerek YOK — o, bu reponun
Pages sitesinde otomatik yayında:
`https://tahir94510.github.io/jubilant-robot/privacy.html`

`app-ads.txt` ise bazı programatik reklam alıcılarının aradığı bir
doğrulama dosyasıdır ve spec gereği alan adının KÖKÜNDE durmak zorundadır
(`tahir94510.github.io/app-ads.txt`). Proje sayfası alt dizin olduğu için
bunun tek yolu, `tahir94510.github.io` adlı ayrı bir "kullanıcı sitesi"
reposudur. Bu dosya OLMADAN da AdMob'un kendi talebi reklam göstermeye
devam eder — yani uygulamayı yayınlamak için gerekmez; gelir oturduktan
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
      Shakespeare/Stoic paketleri açılıyor.
- [ ] Uygulamayı silip yeniden kurunca **Settings → Restore purchases**
      premium'u geri getiriyor.

## C) Gelir beklentisi (dürüst rakamlar)

Kelime bulmaca kitlesi (ABD ağırlıklı, yaşı yüksekçe) mobil oyun
ortalamasının ÜZERİNDE eCPM getirir, ancak ilk aylar trafik azdır:

- Banner eCPM tipik: $0.3–1.5 · Geçiş reklamı: $8–20 · Ödüllü: $10–25
- Kaba senaryo: günde 300 aktif kullanıcı × ort. 2 geçiş reklamı ≈
  600 gösterim × $12 eCPM ≈ **~$7/gün** + banner + ödüllü + ara sıra
  premium satışı. 1.000+ günlük kullanıcıda bu doğrusal büyür.
- İlk 2-3 ay düşük olur; mağaza sıralamasına girdikçe organik trafik
  bileşik artar. Paylaşım virali (günlük bulmaca sonucu) ve puanlar
  (in-app review akışı entegre) bu eğriyi hızlandırır.

Ayarlanabilir her şey `lib/config/app_config.dart` içindedir (geçiş reklamı
sıklığı, ipucu jetonları, vb.) — agresifleştirmeden önce yorumlara etkisini
izleyin.
