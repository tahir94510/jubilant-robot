# Play Store ASO / Doğal Büyüme Rehberi

Ücretli reklam yapmadan, oyunu kendi kendine büyütecek Play Console
kaldıraçları. Sıralamayı en çok şu sinyaller belirler: başlık ve açıklamadaki
anahtar kelimeler, yükleme/çökme oranı, puan ve yorumlar, ve KALICILIK
(D1/D7/D30 geri dönüş). Kalıcılık uzun vadede en güçlü sinyaldir.

## Kritik kontrol listesi (etkiye göre sıralı)

1. **Lokalize mağaza listeleri (en büyük kaldıraç).** Google Play, listen
   olmayan dillerde otomatik (makine) çeviri GÖSTERİR, yani teknik olarak
   şart değil. Ama otomatik çeviri: (a) o dilin anahtar kelimeleri için
   sıralamada elle yazılmış liste kadar iyi değildir, (b) "Google tarafından
   çevrildi" notuyla gelir ve dönüşümü düşürür. Bu yüzden tavsiyem: en az
   **Türkçe** için elle bir liste yaz (senin pazarın, en yüksek getiri);
   ES/PT-BR/DE/FR/IT'yi başta otomatik çeviriye bırakabilirsin, trafik
   oturunca elle eklersin. NOT: Uygulamanın KENDİSİ artık 7 dilde tam
   yerelleştirilmiş (EN, TR, ES, DE, FR, IT, PT) ve her dilin kendi
   alfabesinde özgün içerik paketleri var; bu, lokalize mağaza listelerinin
   dönüşümünü daha da güçlendirir. Play Console > Store listings > Add
   language.
2. **Ekran görüntüleri (dönüşümün belkemiği).** 5-8 telefon görseli; ilk 2'si
   en kritik. Her görsele kısa bir başlık şeridi ekle (ör. "Her gün yeni bir
   şifre", "Tamamen çevrim dışı"). Sıra için STORE_LISTING.md'deki öneriye bak.
3. **Feature graphic + kısa tanıtım videosu.** Feature graphic hazır
   (store_assets/). 20-30 sn'lik bir video dönüşümü belirgin artırır
   (opsiyonel ama değerli).
4. **Başlık ve kısa açıklama keyword'leri.** Yapıldı: cryptogram, cryptoquote,
   cipher puzzle başlıkta/açıklamada doğal geçiyor. Başlık 30 karakter dolu
   kullanılmalı (şu an "Quotecrack: Cryptogram Puzzle").
5. **Kategori ve etiketler.** Aşağıdaki "Mağaza ayarları" bölümünde kesin
   seçimler verildi (kategori = Word; doğru 5 etiket; kaçınılacaklar).
6. **İçerik derecelendirme + Data safety formları.** Doldurulmalı (AdMob veri
   topladığı için Data safety'de beyan; YAYINLAMA_REHBERI'nde anlatıldı).
7. **Uygulama içi puan isteği.** Entegre (ilk birkaç çözümden sonra bir kez).
   Puan sayısı ve ortalaması doğrudan sıralama ve dönüşüm sinyalidir.
8. **app-ads.txt.** MONETIZASYON.md'de anlatıldı; gelir oturunca yap.
9. **Düzenli güncelleme kadansı.** Play "tazelik"i ödüllendirir. Çeyrekte bir
   içerik partisi (ICERIK_EKLEME.md) + "Yenilikler" notu yaz.
10. **Yorumlara yanıt ver.** Özellikle ilk haftalarda; yanıt oranı bir
    sıralama sinyali ve topluluk kurmanın en ucuz yolu.
11. **Store listing experiments (A/B).** Trafik oturduktan sonra ikon ve
    feature graphic için A/B testi aç; en iyi dönüşeni tut.

## Mağaza ayarları: kategori ve etiketler (2026 Play Console — kesin öneri)

Play Console > Grow > Store presence > **Store settings**.

### Uygulama veya oyun
**Oyun (Game).**

### Kategori
**Word (Kelime).** En doğru kategori bu: Quotecrack özünde ünlü sözleri/kelimeleri
çözdüğün bir KELİME oyunu. "Word" kategorisi "Puzzle"a göre daha odaklı ve daha
az doygun; kaliteli bir kriptogram burada daha kolay sıralanır. (Ham hacim
istersen "Puzzle" da seçilebilir, ama tavsiye "Word".)

### Etiketler (en fazla 5) — "Etiket" ve "İlgili etiket"
Play'in etiket seçici **sabit bir taksonomidir**: önce geniş bir alan ("Etiket"),
sonra altındaki spesifik bir değer ("İlgili etiket") seçilir. Etiketler birer
**anahtar kelime DEĞİLDİR** (metin aramasını doğrudan etkilemez); Google'ın
**öneri/benzer-uygulama** yerleşimini besler. Bu yüzden ölçüt **doğruluktur**:
oyununun mekaniğine uymayan bir etiket, yanlış kitleyi çeker → hızlı kaldırma →
sıralama düşer.

**Önerilen 5 etiket (öncelik sırasıyla, Etiket → İlgili etiket):**
1. **Word → Word puzzle / Word** — temel mekanik (harf-ikamesi ile kelime/söz çözme).
2. **Brain games → Brain teaser / Brain games** — kriptogram klasik bir zeka bilmecesidir.
3. **Puzzle → Logic** — tümevarımsal (harf sıklığı, kısa kelimeler) çözüm.
4. **Word → Crossword** — bulmaca/çapraz-bulmaca/cryptoquote çözenlerle kitle örtüşmesi yüksek.
5. **Education → Trivia** — içerik ünlü sözler/bilgelik; quote/trivia kitlesini çeker.

**Kaçın / değiştir:** Mevcut listendeki **"Kelime arama (Word search)"** YANLIŞ —
o, ızgarada gizli kelime bulma mekaniğidir; kriptogramla alakasız ve farklı bir
kitleyi çeker. Yerine yukarıdaki **Crossword** veya **Trivia**'yı koy.

> Not: Play yalnızca kendi sunduğu etiketlerden seçtirir ve liste zamanla küçük
> değişiklikler gösterir. İlke sabit: şu kümeden en yakın ve DOĞRU 5'i seç —
> {Word/Word puzzle, Brain games/Brain teaser, Puzzle/Logic, Crossword, Trivia}.
> Oyuncusu başka bir oyun bekleyecek hiçbir etiketi seçme.

### Tamamlanması gereken diğer mağaza unsurları
- **İçerik derecelendirme (IARC anketi):** İçerik temiz (söz + bulmaca) → beklenen
  sonuç **Everyone / PEGI 3**. Ankette **"reklam içerir"** olarak işaretle (AdMob).
- **Hedef kitle ve içerik:** Yaş gruplarını **13+** seç (reklam/IAP olduğu için
  çocuklara yönelik DEĞİL; "Designed for Families" gereksinimlerinden kaçınmak için
  13 yaş altını işaretleme).
- **Reklam beyanı:** Store settings'te **"Bu uygulama reklam içeriyor: Evet".**
- **Veri güvenliği (Data safety):** AdMob'un topladığı veriyi beyan et
  (YAYINLAMA_REHBERI.md). Oyun verisi cihazda kalır → hesap/konum yok.
- **Gizlilik politikası URL'si:** `https://tahir94510.github.io/jubilant-robot/privacy.html`.

## Kalıcılık (uzun vadeli sıralamanın motoru) - hepsi mevcut

- Günlük bulmaca + seri (streak) + isteğe bağlı hatırlatma bildirimi.
- 24 achievement + yeni içerikte "NEW" etiketi (geri dönüş için kanca).
- Wordle tarzı paylaşım metni (organik viral döngü).
- Çevrim dışı, hesapsız, reklamsız çözüm ekranı (yüksek memnuniyet, iyi yorum).

## Ölçüm

Yayından 4-6 hafta sonra: Play Console > Acquisition ile keyword/sayfa
trafiğini, Quality > Android vitals ile çökme/ANR'yi izle. Düşük D1 retention
görürsen ilk-deneyim (onboarding + ilk bulmaca) akışını sadeleştir; düşük
dönüşüm görürsen ekran görüntülerini/başlığı revize et.
