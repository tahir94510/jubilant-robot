# Yayınlama Rehberi — A'dan Z'ye Google Play

Bu rehber, hiç uygulama yayımlamamış biri için yazıldı. Sırayla uygulayın;
her bölüm bir öncekine dayanır. Toplam aktif eforunuz ~2-3 saattir, takvim
süresi ise kapalı test şartı nedeniyle ~3 haftadır.

---

## §1 — Google Play Developer hesabı ($25, tek seferlik)

1. https://play.google.com/console adresine gidin, Google hesabınızla girin.
2. **Hesap türü: Kişisel** seçin (şirketiniz yoksa).
3. $25 tek seferlik ücreti ödeyin (kredi kartı).
4. Kimlik doğrulamasını tamamlayın (kimlik/pasaport fotoğrafı istenir;
   onay genellikle 1-2 gün sürer).
5. **Önemli:** Kişisel hesaplarda Google, e-posta adresinizi ve ülkenizi
   mağaza profilinde herkese gösterir; buna uygun bir e-posta kullanın.

> 13 Kasım 2023 sonrası açılan kişisel hesaplar **§8'deki kapalı test
> şartına** tabidir. Hesabı NE KADAR ERKEN açarsanız o kadar iyi — kimlik
> onayı beklerken diğer adımları yapabilirsiniz.

## §2 — İmza anahtarı (keystore): Actions'ta tek tık

Play Store'a yüklenecek paketler sizin "yükleme anahtarınızla" imzalanmalı.
Bilgisayarınıza hiçbir şey kurmadan üretin:

1. GitHub'da repoya gidin → **Actions** sekmesi →
   soldan **"Generate signing keystore"** → sağda **Run workflow** →
   (varsayılan değerler iyidir) → **Run workflow**.
2. ~1 dakika sonra biten çalışmaya tıklayın → en altta **Artifacts** →
   **signing-keys**'i indirin ve zip'i açın.
3. İçindeki `OKUBENI.txt` dosyasında 4 değer yazar. Repo →
   **Settings → Secrets and variables → Actions → New repository secret**
   ile şu 4 secret'ı oluşturun (adlar birebir aynı olmalı):
   - `KEYSTORE_BASE64` → `keystore-base64.txt` dosyasının TÜM içeriği
   - `KEYSTORE_PASSWORD` → OKUBENI.txt'deki parola
   - `KEY_ALIAS` → OKUBENI.txt'deki alias (varsayılan `quotecrack`)
   - `KEY_PASSWORD` → OKUBENI.txt'deki anahtar parolası
4. `upload-keystore.jks` + parolaları kalıcı güvenli bir yere kaydedin
   (parola yöneticisi önerilir), sonra GitHub'daki artefaktı silin
   (çalışma sayfasında artefaktın yanındaki çöp kutusu).
5. Herhangi bir commit push'layın (veya Actions → CI → Re-run all jobs):
   artık her çalışmada **quotecrack-release-aab** artefaktı da üretilir.

## §3 — Play Console'da uygulamayı oluşturma

Play Console → **Create app**:
- **App name:** `Quotecrack: Cryptogram Puzzle`
- **Default language:** English (United States)
- **App or game:** Game · **Free or paid:** Free
- Beyanları işaretleyin, **Create app**.

## §4 — Mağaza kaydı (Store listing)

**Grow → Store presence → Main store listing** sayfasını
[STORE_LISTING.md](STORE_LISTING.md) dosyasındaki hazır İngilizce
metinlerle doldurun (kopyala-yapıştır):
- App name, Short description, Full description → hazır.
- **App icon (512×512):** `assets/icon/icon.png` dosyasını yükleyin
  (1024'ü kabul etmezse herhangi bir çevrimiçi araçla 512'ye küçültün;
  PNG kalır).
- **Feature graphic (1024×500):** `store_assets/feature_graphic.png`.
- **Phone screenshots (en az 2):** Telefonunuza debug APK'yı kurup
  şu ekranların görüntüsünü alın: ana ekran, bulmaca ekranı, bulmaca-sonu,
  paketler, istatistikler. (Telefonda ekran görüntüsü: Güç+Ses kısma.)
  Alternatif: web önizlemeyi telefon görünümünde açıp görüntü alın.

## §5 — Uygulama içeriği formları (App content)

Soldaki **Policy → App content** altında sırayla (hazır cevaplar):

1. **Privacy policy:** `https://tahir94510.github.io/jubilant-robot/privacy.html`
   > Bu adresin canlı olması için GitHub Pages'in açık olması gerekir
   > (tek seferlik: repoyu Public yapın + Settings → Pages → Source:
   > "GitHub Actions" — ayrıntı README'de). Linki forma yapıştırmadan önce
   > tarayıcıda açılıp açılmadığını kontrol edin.
2. **Ads:** *Yes, my app contains ads.* (AdMob kullanıyoruz.)
3. **App access:** *All functionality is available without special access*
   (giriş/hesap yok).
4. **Content ratings** anketi:
   - Category: **Game**. E-posta girin.
   - Şiddet/cinsellik/küfür/kumar/uyuşturucu sorularının tümü: **No**.
   - "Does the app share user location": **No**. "Digital purchases": **Yes**
     (premium IAP). Sonuç tipik olarak **Everyone / PEGI 3** çıkar.
5. **Target audience:** 13+ seçin (çocuklara yönelik DEĞİL deyin) —
   böylece "Families" ek politikalarına girmezsiniz.
6. **News app:** No. **COVID-19 app:** No.
7. **Data safety** formu — şunları beyan edin (AdMob nedeniyle):
   - *Does your app collect or share any of the required user data types?*
     → **Yes**.
   - **Device or other IDs → Device or other IDs:** Collected: Yes,
     Shared: Yes (üçüncü taraf reklam ortağı Google AdMob),
     Processed ephemerally: No, Required: Yes (ücretsiz sürümde reklam
     için), Purpose: **Advertising or marketing**.
   - **Location → Approximate location:** Collected: **Yes**, Shared: Yes,
     Purpose: Advertising or marketing. (AdMob IP'den kaba konum türetir;
     beyan etmek güvenli taraftır.)
   - Diğer tüm veri türleri: **Not collected**.
   - *Is all of the user data collected by your app encrypted in transit?*
     → **Yes**.
   - *Do you provide a way for users to request that their data is
     deleted?* → **Yes** (uygulamayı silmek tüm yerel veriyi siler;
     gizlilik politikası bunu açıklıyor).
   - **Advertising ID** formu (ayrı soru gelirse): Yes, advertising ID
     kullanılıyor → amaç: Advertising.
8. **Government apps / Financial features:** No / None.

## §6 — Ülkeler ve fiyat

- **Countries/regions:** All countries (veya en azından US, UK, CA, AU,
  IN, PH, ZA + Avrupa — İngilizce konuşan pazarlar kritik).
- Uygulama ücretsiz; premium IAP fiyatı §IAP'ta (MONETIZASYON.md).

## §7 — İlk paketi yükleme (kapalı test)

1. Sol menü → **Test and release → Testing → Closed testing** →
   **Create track** (adı "Alpha" kalabilir).
2. **Create new release** → "App integrity" adımında **Play App Signing**
   varsayılanını kabul edin (Google, imzalamayı sizin yükleme anahtarınız
   üstünden yönetir — anahtar kaybında kurtarma şansı sağlar).
3. GitHub Actions'tan indirdiğiniz `quotecrack-release-aab` zip'inden çıkan
   `app-release.aab` dosyasını sürükleyip bırakın.
4. Release notes: `First release — daily cryptogram puzzles.`
5. **Testers** sekmesi → **Create email list** → testçilerin Gmail
   adreslerini ekleyin → kaydedin. Oluşan **opt-in link**'i testçilere
   gönderin (linke girip "Become a tester" demeleri ve uygulamayı Play'den
   indirmeleri gerekir).
6. **Save → Review release → Start rollout to Closed testing.**
   İlk incelemesi birkaç gün sürebilir.

## §8 — 12 testçi × 14 gün şartı ve üretime geçiş

Kişisel hesabınız yeniyse Google şunu ister: kapalı testinizde **en az 12
testçi, kesintisiz son 14 gün boyunca** kayıtlı (opt-in) kalmalı.

**Testçi bulma stratejileri (ücretsiz):**
- Aile + arkadaşlar + iş arkadaşları (WhatsApp grubunuz yeter).
- Reddit: r/AndroidClosedTesting ve r/AppTesters — karşılıklı test
  toplulukları ("ben seninkini test ederim, sen benimkini").
- Testçilere mesaj şablonu: opt-in linki + "Play'den indirin, ARADA BİR
  açın ve 14 gün boyunca silmeyin" notu.
- Testçilerin *aktif kullanması* değil, kayıtlı kalması esastır; yine de
  arada açmaları olumlu sinyaldir.

14 gün dolunca: Play Console → **Apply for production** → kısa anketi
doldurun (uygulamanızı, test sürecini anlatın; 1-2 cümle yeterli).
Onay gelince:

1. **Production** track → Create new release → aynı (veya güncel) AAB →
   rollout %100.
2. İlk üretim incelemesi de birkaç gün sürebilir. Yayında! 🎉

## §9 — Yayın sonrası kontrol listesi

- [ ] MONETIZASYON.md'deki **gerçek AdMob ID'leri** yayın AAB'sine girdi mi?
- [ ] `premium_unlock` ürünü **Active** mi? Fiyat doğru mu?
- [ ] Mağaza sayfasındaki "developer website" alanına
      `https://tahir94510.github.io` yazıldı mı (app-ads.txt için)?
- [ ] `pages/app-ads.txt` içindeki satır gerçek pub-ID ile dolduruldu mu
      ve kullanıcı sitesi reposuna kondu mu? (MONETIZASYON.md §app-ads.txt)
- [ ] Uygulamayı Play'den kendiniz indirip: reklamların geldiğini, premium
      satın almanın çalıştığını (lisans testçisiyle ücretsiz test
      edebilirsiniz), bildirimin geldiğini doğrulayın.
- [ ] Yorumlara ilk haftalarda hızlı yanıt verin — sıralama sinyali.

## Sürüm güncelleme rutini

1. `pubspec.yaml` → `version: 1.0.1+2` (sondaki sayı her yüklemede +1).
2. Push → Actions'tan yeni `quotecrack-release-aab`.
3. Play Console → Production → New release → AAB'yi yükle → notlar → çık.
