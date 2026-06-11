# Kalite Kontrol Sistemi — Quotecrack

Bu doküman "her şey kusursuz çalışıyor mu?" sorusunu somut, tekrarlanabilir
bir sisteme çevirir. Üç katman vardır: **(A)** her push'ta makinenin
otomatik kanıtladıkları, **(B)** her sürümden önce sizin cihazda yaptığınız
manuel tur, **(C)** yayın sonrası rutin. Sonda **(D)** hata bulunduğunda
izlenecek döngü vardır.

---

## A) Her push'ta OTOMATİK kanıtlananlar (CI)

GitHub Actions her push'ta şunları koşar; **tek bir adım bile kırmızıysa
hiçbir paket üretilmez** — yani elinizdeki her artefakt bu kontrollerden
geçmiş demektir:

| Kontrol | Kapsam |
|---|---|
| `dart format` | Kod stili sapması yok |
| `flutter analyze` | Sıfır hata, sıfır uyarı |
| **77 otomatik test** | Aşağıdaki döküm |
| `flutter build apk --debug` | Android derlemesi kanıtı |
| `flutter build appbundle/apk --release` | İmzalı mağaza paketleri kanıtı |
| `flutter build web` | Reklamsız stub yolunun derlendiği kanıtı |

**77 testin dökümü:**
- **Motor (24):** RNG golden vektörleri (günlük bulmaca her cihazda aynı
  kalır — değişirse test kırılır), 1000 tohumda derangement/bijeksiyon,
  şifre determinizmi, 2026+2028'in her günü için tekrarsız günlük seçim,
  zorluk monotonlukları.
- **Veri seti (7):** 461 söz; benzersiz kimlik, kopya metin yok, ASCII,
  20-180 harf, atıf alanları dolu, 11 paketin hepsi dolu, her zorluk
  kovasında ≥40 söz.
- **Mantık (16):** Seri artışı/sıfırlanması/gece yarısı sınırı, jeton
  kazan/harca/taban, premium sınırsızlığı ve kalıcılığı, interstisyel
  kadans+bekleme penceresi, başarımların eşikte tam bir kez açılması.
- **Ekran ve etkileşim (30):** Uçtan uca çözüm akışı, otomatik doldurma,
  çakışma vurgusu, klavye soluklaştırma, geri alma; ana ekran menüleri,
  11 paketin listelenip açılması, premium kilit→paywall ve premium→içerik
  yönlendirmeleri, istatistik/başarım ekranları, **ayarlardaki her kontrol**
  (tema, yazı boyutu, 4 anahtar, hatırlatma kur/iptal/izin-reddi, geri
  yükleme), öğretici akışı+atlama; tekrar-oynamanın jeton/reklam
  üretmediği; arka planda kronometrenin durduğu.

> Otomatikleştirilemeyenler (tasarımı gereği): gerçek reklam dolumu, gerçek
> satın alma, bildirimin fiziksel teslimi — bunlar B turunun işidir.

## B) Sürüm öncesi MANUEL tur (cihazda, ~15 dakika)

Her mağaza yüklemesinden önce `quotecrack-release-apk` artefaktını telefona
kurup şu listeyi işaretleyin:

> ⚠️ Release pakette GERÇEK reklam kimlikleri aktiftir. Reklamların
> *göründüğünü* doğrulayın ama **asla tıklamayın** (AdMob hesabı kapatır).
> Reklamla etkileşmeniz gerekiyorsa önce AdMob → Ayarlar → Test cihazları
> bölümünden cihazınızı ekleyin.

1. [ ] Temiz kurulum → öğretici açılıyor, "Try one" mini bulmacası
       çözülebiliyor, ana ekrana düşüyor.
2. [ ] Günlük bulmaca: çöz → tamamlama ekranı → **Share result** gerçek bir
       paylaşım sayfası açıyor; ana ekranda seri 🔥 1 oldu.
3. [ ] Paketlerden bir bulmaca çöz → "Next puzzle" sıradaki çözülmemişe
       geçiyor; çözülen karede ✓ görünüyor.
4. [ ] İpucu: jeton düşüyor, doğru harf açılıyor; jeton sayısı uygulamayı
       kapatıp açınca korunuyor.
5. [ ] "+3 izle" ödüllü reklamı oynatıyor ve 3 jeton ekliyor.
6. [ ] Banner yalnız ana ekran + tamamlama ekranında; **çözüm ekranında
       asla reklam yok**; 3 çözümde bir geçiş reklamı geliyor (120 sn
       arayla).
7. [ ] Premium (license tester hesabıyla, ücretsiz): satın al → reklamlar
       anında kayboluyor, ipuçları sınırsız, Shakespeare+Stoic açılıyor;
       uygulamayı silip kur → **Restore purchases** premium'u geri
       getiriyor.
8. [ ] Üç tema + yazı boyutu kaydırıcısı: bulmaca ekranı hepsiyle okunaklı.
9. [ ] Hatırlatma: yarına bir saat kur → bildirim geliyor (veya saati 2 dk
       sonrasına kurup bekle).
10. [ ] Uçak modu: oyun tamamen oynanabilir; reklam alanları sessizce boş.
11. [ ] Yarım bıraktığın bulmaca: uygulamayı tamamen kapatıp açınca aynı
        yerden devam ediyor (girilen harfler + süre).
12. [ ] Çözülmüş bulmacayı tekrar çöz → jeton ARTMIYOR (ekonomi koruması).

## C) Sürüm çıkarma rutini + yayın sonrası

**Sürüm çıkarma:** `pubspec.yaml` → `version: 1.0.1+2` (sondaki sayı her
yüklemede +1) ve `lib/config/app_config.dart` → `appVersion` aynı isimle
güncelle → push → CI yeşil → `quotecrack-release-aab` indir → B turu →
Play Console'a yükle.

**Yayın sonrası (haftalık 10 dakika):**
- Play Console → **Vitals**: çökme/ANR oranı (%1'in altı sağlıklı).
- Play Console → **Yorumlar**: ilk haftalarda hepsine yanıt verin
  (sıralama sinyali); tekrar eden şikayeti bana iletin.
- AdMob → kazanç + "Ad serving" durumu (yeni uygulamada ilk günlerde
  sınırlı dolum normaldir).
- Ayda bir: bana "bakım turu" deyin — bağımlılık güncellemeleri + KGP
  uyarısı veren eklentilerin (flutter_timezone, in_app_review, share_plus)
  yeni sürümlerini kontrol edip güncellerim.

## D) Hata bulununca döngü

1. Bana şunları yazın: hangi ekran, ne yaptınız, ne beklediniz, ne oldu
   (varsa ekran görüntüsü).
2. Ben düzeltirim ve **aynı hatayı sonsuza dek kilitleyen bir regresyon
   testi** eklerim (bu projede şimdiye dek yakalanan her hata böyle
   kilitlendi: premium algılama, jeton çiftleme, arka plan kronometresi).
3. CI yeşili + yeni artefakt → B turundan ilgili madde → yükleme.
