# Quotecrack: Cryptogram Puzzles

Ünlü sözleri harf-şifresi çözerek bulduğunuz, tamamen çevrimdışı çalışan bir
kelime bulmaca oyunu. **7 dilde** (İngilizce, Türkçe, İspanyolca, Almanca,
Fransızca, İtalyanca, Portekizce) tam yerelleştirilmiş arayüzle küresel
kitleye hitap eder; her cihaza (telefon/tablet/PC/TV) uyumludur ve Google
Play'de yayımlanmaya hazırdır.

**Play Store başlığı:** `Quotecrack: Cryptogram Puzzle`
**Paket kimliği:** `io.github.tahir94510.quotecrack`

---

## Hiçbir şey kurmadan nasıl önizlerim?

Bu repo her push'ta GitHub Actions ile derlenir. Üç önizleme yolunuz var:

1. **Tarayıcıda oyna (en kolay):**
   `https://tahir94510.github.io/jubilant-robot/app/`

   > ℹ️ **Kalıcı karar: bu repo public kalır.** Nedeni: (1) Play Console'un
   > zorunlu tuttuğu gizlilik politikası sayfası bu reponun Pages sitesinde
   > yaşıyor ve linkin asla ölmemesi gerekiyor; (2) LICENSE "tüm hakları
   > saklı", kod görünür ama kopyalanması/yayınlanması yasak; (3) imza
   > anahtarları ve hesap bilgileri repoda DEĞİL, şifreli Secrets kasasında.
   > Pages ilk kurulum: Settings → Pages → Source: "GitHub Actions"
   > (yapıldı). Pages kapatılırsa CI yine yeşil kalır, yalnız önizleme ve
   > gizlilik sayfası yayından düşer, bu yüzden kapatmayın.

   (Reklam/satın alma web'de bilerek kapalıdır, oyunun kendisini test
   edersiniz.)

2. **Telefonunuzda dene (gerçek deneyim):**
   GitHub → **Actions** → en üstteki yeşil çalışma → **Artifacts** →
   `quotecrack-debug-apk` dosyasını indirin, telefonunuza atıp kurun.
   ("Bilinmeyen kaynaklara izin ver" sorusuna onay vermeniz gerekir.
   Debug APK'da Google'ın TEST reklamları görünür, bu normaldir.)

3. **Play Store paketleri (yayın için):**
   İmza secret'ları eklendiğinden aynı Artifacts listesinde şunlar da
   oluşur:
   - `quotecrack-release-aab` → Play Console'a yüklenen dosya
   - `quotecrack-release-apk` → mağazaya gidecek paketin birebir aynısını
     telefonda son kez doğrulamak için (⚠️ gerçek reklamlar aktif,
     görüntüleyin ama TIKLAMAYIN)

> Sürüm öncesi/sonrası tüm kontroller tek yerde:
> [docs/KALITE_KONTROL.md](docs/KALITE_KONTROL.md), her push'ta CI'ın
> otomatik kanıtladıkları + 33 maddelik cihaz turu + yayın rutini.
> Düzenli yeni bulmaca ekleme sistemi:
> [docs/ICERIK_EKLEME.md](docs/ICERIK_EKLEME.md).

## Yayınlamak için yapmanız gerekenler (sırasıyla)

| # | Adım | Nerede anlatılıyor |
|---|------|--------------------|
| 1 | Google Play Developer hesabı açın ($25, tek seferlik) | [docs/YAYINLAMA_REHBERI.md](docs/YAYINLAMA_REHBERI.md) §1 |
| 2 | İmza anahtarı üretin (Actions'ta tek tık) + 4 secret ekleyin | [docs/YAYINLAMA_REHBERI.md](docs/YAYINLAMA_REHBERI.md) §2 |
| 3 | AdMob hesabı + 3 reklam birimi; ID'leri 2 dosyaya yapıştırın | [docs/MONETIZASYON.md](docs/MONETIZASYON.md) |
| 4 | Play Console'da uygulamayı oluşturun, hazır metinleri yapıştırın | [docs/YAYINLAMA_REHBERI.md](docs/YAYINLAMA_REHBERI.md) §3-7 + [docs/STORE_LISTING.md](docs/STORE_LISTING.md) |
| 5 | `premium_unlock` ürününü oluşturun ($4.99) | [docs/MONETIZASYON.md](docs/MONETIZASYON.md) §IAP |
| 6 | 12 testçi × 14 gün kapalı test → üretime geçiş | [docs/YAYINLAMA_REHBERI.md](docs/YAYINLAMA_REHBERI.md) §8 |

> **Gerçekçi takvim:** Google, 13 Kasım 2023'ten sonra açılan bireysel
> hesaplardan, üretime geçmeden önce **en az 12 testçinin kesintisiz 14 gün**
> uygulamayı kapalı testte kullanmasını ister (bu eşik Aralık 2024'te 20'den
> 12'ye düşürüldü; kuruluş hesapları muaftır). Yani "bugün yükle, yarın
> yayında" değil; **~3 hafta** planlayın. (Google kuralları güncelleyebilir;
> Play Console'daki güncel sayıyı teyit edin.) Testçi bulma stratejileri
> rehberde.

## Oyun ne içeriyor?

- **Günlük bulmaca:** Her dilin kendi günlük bulmacası var; aynı gün o dili
  oynayan herkese aynı söz düşer. Seri (streak), takvim ısı haritası ve sonuç
  paylaşımı var. **İstatistik, seri, paket ilerlemesi ve günlük geçmiş her dil
  için ayrı bir profilde tutulur**; premium, jeton ve ayarlar tüm dillerde
  ortaktır (premium bir kez alınır, her dilde açık olur).
- **Her dil kendi içerik evreni:** Dili değiştirince tüm katalog o kültürün
  özgün sözlerine döner. **Yedi dilin her biri 510 özgün, doğru atıflı yerel
  söz** içerir (atasözleri, bilgelik, nükte, edebiyat ve klasikler) — diller
  arası içerik paritesi sağlanmıştır. Her dil, dört zorluk basamağını, dört
  tematik paketi ve premium Klasikler paketini doldurur (`repository_load_test`
  ile güvence altında). Tamamı kamu malı ya da kültürel miras; telif riski sıfır.
- **Her dil için 10 paket:** 4 zorluk (Başlangıç'tan Uzman'a) + ücretsiz
  "Kısa & Öz" hızlı paketi + 4 tema (Atasözleri, Bilgelik, Nükte, Edebiyat) +
  1 premium Klasikler; hepsi o dile özgü ve zorluk algoritmasıyla otomatik
  derecelendirilmiş.
- **İpucu ekonomisi:** Başlangıçta 10 jeton, her çözümde +1, ödüllü
  reklamla +3, premium'da sınırsız.
- **24 başarım, istatistikler, 30 saniyelik etkileşimli öğretici.**
- **7 dilde tam yerelleştirme:** Arayüzün her ekranı + paylaşım metni +
  günlük hatırlatma bildirimi seçilen dilde. Ayarlardan dil seçimi (veya
  cihaz dilini izle). Her dil **kendi alfabesinde ve kendi popüler klavyesinde**
  oynanır (Türkçe-Q, Almanca QWERTZ, Fransızca AZERTY, diğerleri QWERTY):
  Türkçe 29 harf (İ/ı ayrımı doğru), İspanyolca Ñ. Şifre matematiği her alfabe
  için determinizm ve sabit-noktasızlık testiyle kanıtlı.
- **"Ink & Gold" asil kimlik:** Sıcak mürekkep zemin + şampanya altını
  vurgular + zarif garnet (eski mavi-merkezli palet ve amatör logo elden
  geçti; logo, ikon, splash, web ve mağaza görselleri tutarlı).
- **Atmosfer & ses:** prosedürel üretilmiş (telifsiz) sakin akor döngüsü
  (C-Am-F-G…, sessizlikten başlayıp sessizliğe çözülerek dikişsiz döner;
  cızırtısız), **müzik ve efekt için ayrı ses kaydırıcıları**, arka plana
  geçişte ani kesme yerine yumuşak fade, çözümde müzik kısılır (duck).
  Sesler MEDYA kanalında. Kelime tamamlama çanı, çözümde yeşil dalga +
  konfeti, yumuşak ekran geçişleri.
- **Her cihazda oynanış:** dokunmatik + **fiziksel klavye** (harf yaz,
  Backspace/Delete sil, oklarla gez, Ctrl/Cmd+Z geri al), PC, tablet ve
  TV için tam destek.
- **3 tema** (açık/koyu/sepya), ayarlanabilir yazı boyutu, renk körü dostu
  palet, titreşim, zen modu, günlük hatırlatma bildirimi.
- **Gelir:** AdMob (banner yalnız menü + sonuç ekranında, çözüm ekranı
  daima reklamsız; geçiş reklamı 3 çözümde bir + 120 sn arayla; ödüllü
  reklam isteğe bağlı) ve tek seferlik **Premium** (reklamsız + sınırsız
  ipucu + 2 bonus paket). GDPR/UMP onay akışı entegre.

## Teknik özet

- **Flutter** (stable) · Android `targetSdk 36`, `minSdk 24` · yalnız
  Android yayını; web derlemesi sadece önizleme amaçlı.
- Backend yok, hesap yok, oyun verisi cihazda kalır (mağaza "Veri
  güvenliği" formu için büyük avantaj).
- Deterministik motor: gün/şifre seçimi her cihazda ve platformda birebir
  aynıdır (özel 32-bit RNG + FNV-1a; golden-vector testleriyle kilitli).
- 200+ otomatik test CI'da her push'ta koşar (motor + 7 alfabenin şifre
  matematiği, veri seti + ses varlığı doğrulaması, harf-girişi/undo/süre
  regresyonları, fiziksel klavye, yerelleştirme, streak gün sınırları,
  ekonomi, premium kapılama, müzik/ses ayarları, kutlama animasyonları,
  uçtan uca çözüm akışı). CI ayrıca `dart format` ve `flutter analyze`
  geçişini zorunlu tutar.
- **i18n:** `flutter_localizations` + gen-l10n; çeviriler `lib/l10n/app_*.arb`
  dosyalarında. Yeni dil eklemek = bir alfabe kaydı + bir ARB dosyası.

### Yerelde geliştirme (opsiyonel)

```bash
bash tool/setup_flutter.sh          # Flutter SDK kurar (Linux)
flutter pub get
flutter test                        # tüm testler
flutter run -d chrome               # tarayıcıda çalıştır
```

### Sürüm çıkarma

`pubspec.yaml` içindeki `version: 1.0.0+1` satırında `+1`'i her Play
yüklemesinde artırın (`1.0.1+2`, `1.0.2+3`…), push'layın, Actions'tan yeni
AAB'yi indirin.

## Dürüst beklenti notu

Hiçbir mağaza uygulamasında gelir *garantisi* verilemez. Bu proje, organik
keşif şansını en üst düzeye çıkaran kanıtlanmış unsurları eksiksiz uygular:
doğru niş (talep kanıtlı, rekabet zayıf), ASO'ya hazır mağaza metinleri,
günlük alışkanlık döngüsü + bildirim, paylaşım virali, puan isteme akışı ve
hazır reklam+premium altyapısı. İlk haftalarda indirmeler yavaş başlar;
mağaza sıralaması oturdukça (genellikle 2-3 ay) organik trafik birikir.
