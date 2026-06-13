# Quotecrack — Cryptogram Puzzles

Ünlü sözleri harf-şifresi çözerek bulduğunuz, tamamen çevrimdışı çalışan bir
kelime bulmaca oyunu. Küresel İngilizce konuşan kitle için tasarlandı;
Google Play'de yayımlanmaya hazırdır.

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
   > saklı" — kod görünür ama kopyalanması/yayınlanması yasak; (3) imza
   > anahtarları ve hesap bilgileri repoda DEĞİL, şifreli Secrets kasasında.
   > Pages ilk kurulum: Settings → Pages → Source: "GitHub Actions"
   > (yapıldı). Pages kapatılırsa CI yine yeşil kalır, yalnız önizleme ve
   > gizlilik sayfası yayından düşer — bu yüzden kapatmayın.

   (Reklam/satın alma web'de bilerek kapalıdır — oyunun kendisini test
   edersiniz.)

2. **Telefonunuzda dene (gerçek deneyim):**
   GitHub → **Actions** → en üstteki yeşil çalışma → **Artifacts** →
   `quotecrack-debug-apk` dosyasını indirin, telefonunuza atıp kurun.
   ("Bilinmeyen kaynaklara izin ver" sorusuna onay vermeniz gerekir.
   Debug APK'da Google'ın TEST reklamları görünür — bu normaldir.)

3. **Play Store paketleri (yayın için):**
   İmza secret'ları eklendiğinden aynı Artifacts listesinde şunlar da
   oluşur:
   - `quotecrack-release-aab` → Play Console'a yüklenen dosya
   - `quotecrack-release-apk` → mağazaya gidecek paketin birebir aynısını
     telefonda son kez doğrulamak için (⚠️ gerçek reklamlar aktif —
     görüntüleyin ama TIKLAMAYIN)

> Sürüm öncesi/sonrası tüm kontroller tek yerde:
> [docs/KALITE_KONTROL.md](docs/KALITE_KONTROL.md) — her push'ta CI'ın
> otomatik kanıtladıkları + 27 maddelik cihaz turu + yayın rutini.
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
> hesaplardan, üretime geçmeden önce **12 testçinin kesintisiz 14 gün**
> uygulamayı kapalı testte kullanmasını ister. Yani "bugün yükle, yarın
> yayında" değil; **~3 hafta** planlayın. Testçi bulma stratejileri rehberde.

## Oyun ne içeriyor?

- **Günlük bulmaca:** Tarihe göre herkese aynı söz düşer (Wordle mantığı),
  yıl içinde tekrar etmez; seri (streak), takvim ısı haritası ve
  Wordle-tarzı sonuç paylaşımı var.
- **510 el ile derlenmiş, tamamı kamu malı (public domain) söz** — telif
  riski sıfır: Twain, Wilde, Austen, Shakespeare, atasözleri…
- **11 paket:** 4 zorluk + 5 tema + 2 premium (Shakespeare, Stoacılık).
- **İpucu ekonomisi:** Başlangıçta 10 jeton, her çözümde +1, ödüllü
  reklamla +3, premium'da sınırsız.
- **16 başarım, istatistikler, 30 saniyelik etkileşimli öğretici.**
- **Atmosfer:** prosedürel üretilmiş (telifsiz) sakin akor döngüsü
  (C-Am-F-G…, sessizlikten başlayıp sessizliğe çözülerek dikişsiz döner;
  pad + nazik melodi + düzenli arpej, cızırtısız), ayrı "Music" anahtarı +
  ana ekranda hızlı sustur ikonu, çözümde müzik kısılır (duck). Sesler
  MEDYA kanalında (ses tuşları medyayı ayarlar). Kelime tamamlama çanı,
  çözümde tahtada yeşil dalga + konfeti kutlaması, yumuşak ekran geçişleri.
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
- 132 otomatik test CI'da her push'ta koşar (motor, veri seti + ses varlığı
  doğrulaması, streak gün sınırları, ekonomi, premium kapılama, müzik/ses
  ayarları, kutlama animasyonları, uçtan uca çözüm akışı).

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
