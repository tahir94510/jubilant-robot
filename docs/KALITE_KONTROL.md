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
| **135 otomatik test** | Aşağıdaki döküm |
| `flutter build apk --debug` | Android derlemesi kanıtı |
| `flutter build appbundle/apk --release` | İmzalı mağaza paketleri kanıtı |
| `flutter build web` | Reklamsız stub yolunun derlendiği kanıtı |

**135 testin dökümü:**
- **Motor (23):** RNG golden vektörleri (günlük bulmaca her cihazda aynı
  kalır — değişirse test kırılır), 1000 tohumda derangement/bijeksiyon,
  şifre determinizmi, 2026+2028'in her günü için tekrarsız günlük seçim,
  zorluk monotonlukları.
- **Veri seti (9):** 510 söz; benzersiz kimlik, kopya metin yok, ASCII,
  20-180 harf, atıf alanları dolu ve "Unknown" yasak (halk malı sözler
  "Anonymous"/"Proverb"), 11 paketin hepsi dolu, her zorluk kovasında
  ≥40 söz; 7 ses varlığının (WAV) mevcut+RIFF imzalı olması ve müzik
  dosyasının boyut bütçesi.
- **Mantık (40):** Seri artışı/sıfırlanması/gece yarısı VE yıl sınırı
  (31 Ara → 1 Oca), jeton kazan/harca/taban, premium sınırsızlığı ve
  kalıcılığı, interstisyel kadans+bekleme penceresi, başarımların eşikte
  tam bir kez açılması; tahta sığdırma matematiği (15 harfli kelime 360dp
  ekrana sığar + 510 sözün TAMAMI 320dp tahtaya sığar garantisi); ipucu
  sayacının reveal başına +1 artıp uygulama yeniden açılınca korunması,
  çözülmüş bulmacanın temiz başlaması.
- **Ekran ve etkileşim (63):** Uçtan uca çözüm akışı, otomatik doldurma,
  çakışma vurgusu, klavye soluklaştırma, geri alma; ana ekran menüleri,
  11 paketin listelenip açılması, premium kilit→paywall ve premium→içerik
  yönlendirmeleri, istatistik/başarım ekranları, **ayarlardaki her kontrol**
  (tema kartları — dördü de etiketli ve 320dp+1.6x'te kırılmadan, yazı
  boyutu, 4 anahtar, hatırlatma kur/iptal/izin-reddi, geri yükleme),
  öğretici akışı+atlama; tekrar-oynamanın jeton/reklam üretmediği; arka
  planda kronometrenin durduğu; uzun kelimeli tahtanın dar ekranda
  taşmaması; tamamlama ekranında düğmelerin kaydırmasız erişilebilir
  kalması; ısı haritası geometrisi (16 hafta, Pazartesi hizası, ay
  başlığı); 0 jetonda ipucu düğmesinin kapanıp +3'ün kalması.

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
13. [ ] Ses efektleri: tuş tıkları + çözüm melodisi duyuluyor; Ayarlar →
        "Sound effects" kapatınca tam sessiz. ÖNEMLİ: oyun sesi MEDYA
        kanalında — ses açma/kısma tuşları "Medya" sesini ayarlar (zil/
        arama değil). Başka uygulamada çalan müziği/podcast'i KESMEZ.
14. [ ] Tema seçici: varsayılan "Auto" seçili ve cihaz temasını izliyor;
        dört kartın da etiketi tam okunuyor (320dp + büyük yazıda bile),
        dört seçenek de anında uygulanıyor.
15. [ ] Açılış: soğuk başlatmada markalı splash görünüyor (lacivert
        gradyan + logo; Android 12+'da daire içinde logo), splash →
        ilk kare geçişinde beyaz flaş YOK (koyu temada da dene).
16. [ ] Launcher ikonu ana ekranda net ve dolgun (Q? + alt çizgi); Android
        13+ temalı ikon modunda tek renkli varyant düzgün.
17. [ ] Hatırlatma bildirimi durum çubuğunda BEYAZ "Q" glifi olarak
        görünüyor (gri kare/leke değil).
18. [ ] Uzun kelimeli bulmaca (ör. "generalizations" içeren) 360dp ekranda
        taşma şeridi olmadan sığıyor; hücreler eşit boyda küçülüyor.
19. [ ] "— Anonymous" atıflı sözler düzgün görünüyor ("Unknown" kalmadı).
20. [ ] Müzik: açılışta sakin akor döngüsü (C-Am-F-G…) yumuşakça (fade-in)
        başlıyor; cızırtı/gürültü/patlama YOK, döngü başı-sonu sessizlikte
        birleştiği için tekrar dikişi duyulmuyor; SFX ile karışmıyor.
        Çözüm anında müzik kısılıp (duck) melodi bitince geri yükseliyor.
        Ayarlar → "Music" VEYA ana ekrandaki müzik ikonu kapatınca anında
        susuyor; arka plana alınca / tam ekran reklamda duruyor.
21. [ ] Kutlama: bulmaca çözülünce tahtada soldan sağa yeşil dalga +
        sonuç ekranında konfeti patlaması görünüyor; sistem "animasyonları
        kapat" erişilebilirlik ayarı açıkken ikisi de YOK (tasarım gereği).
22. [ ] Kelime cue'su: bir kelimenin son harfi doğru girilince normal tuş
        sesinden farklı, tek parlak çan duyuluyor.
23. [ ] Seri daveti: İLK günlük çözümün sonuç ekranında "Protect your
        streak" kartı görünüyor; "Remind me daily" bildirimi planlıyor,
        "Not now" sessizce kapatıyor — her iki durumda da kart bir daha
        ASLA görünmüyor (paket çözümlerinde hiç görünmez).
24. [ ] Hatırlatma dayanıklılığı: hatırlatma açıkken saati 2-3 dk sonraya
        kur, bildirimin GELDİĞİNİ gör; sonra cihazı yeniden başlat ve
        ertesi gün bildirimi yine geldiğini doğrula (boot receiver).
25. [ ] Ana ekran müzik ikonu: başlıktaki nota ikonuna dokununca müzik
        anında susuyor (ikon "müzik kapalı"ya dönüyor); tekrar dokununca
        geri geliyor — durumu Ayarlar → "Music" ile birebir aynı.
26. [ ] Öğretici geçişi: ilk açılışta "Try one — 30 seconds"a basınca TEK
        akıcı geçişle bulmacaya giriliyor (arada ana ekran flaşı YOK);
        bulmacadan geri basınca ana ekrana düşüyor.
27. [ ] Hatırlatma saati: "Reminder time"a basınca KLAVYE ile saat giriş
        ekranı açılıyor (kadran yok → üst üste binen nokta/sayı sorunu yok);
        kaydedilen saat listede güncelleniyor.
28. [ ] Okunabilirlik: üç temada da (özellikle SEPYA) alt başlıklar/atıflar
        ve tahtadaki küçük şifre harfi rahat okunuyor — soluk/kaybolmuş
        metin yok (WCAG AA kontrastı sağlandı).
29. [ ] Bildirim markası: günlük hatırlatma bildiriminde küçük ikon + uygulama
        adı lacivert tonda; bildirim panelini açınca uzun metin tam görünüyor.
30. [ ] İlk açılış İstatistik: hiç çözüm yokken üstte "start your stats"
        davet kartı çıkıyor (boş ızgara bozuk görünmüyor); ilk çözümden
        sonra kart kayboluyor.
31. [ ] Uygulama-içi logo: ana ekran/öğretici/paywall'daki Q? logosu
        launcher ikonuyla aynı oranda (Q dolgun, ? omuzda, alt çizgi).
32. [ ] Tablet/büyük ekran: içerik kenara yapışmadan ortalı ve max ~560dp
        ile sınırlı; hiçbir ekranda taşma yok (telefon görünümü değişmez).
33. [ ] Dayanıklılık: bir servis (reklam/bildirim/müzik) başlatılamasa bile
        uygulama AÇILIR ve oyun oynanır — anında kapanma YOK. (Release
        çökmesinin kesin nedeni için Play Console → Android vitals →
        Çökmeler stack trace'i en güvenilir kanıttır.)

## C) Sürüm çıkarma rutini + yayın sonrası

**Sürüm çıkarma:** `pubspec.yaml` → `version: 1.1.4+7` (sondaki sayı her
yüklemede +1) ve `lib/config/app_config.dart` → `appVersion` aynı isimle
güncelle → push → CI yeşil → `quotecrack-release-aab` indir → B turu →
Play Console'a yükle.

**İçerik güncellemeleri:** yeni söz/paket ekleme tarifi ve otomatik uyum
garantileri ayrı dokümanda: [ICERIK_EKLEME.md](ICERIK_EKLEME.md)
(önerilen kadans: çeyrekte +50 söz, Aralık'ta sezonluk paket).

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
