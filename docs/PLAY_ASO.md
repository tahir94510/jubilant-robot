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
   ES/PT-BR/DE/FR/HI'yi başta otomatik çeviriye bırakabilirsin, trafik
   oturunca elle eklersin. Oyun her durumda İngilizce kalır; yalnız mağaza
   metni çevrilir. Play Console > Store listings > Add language.
2. **Ekran görüntüleri (dönüşümün belkemiği).** 5-8 telefon görseli; ilk 2'si
   en kritik. Her görsele kısa bir başlık şeridi ekle (ör. "Her gün yeni bir
   şifre", "Tamamen çevrim dışı"). Sıra için STORE_LISTING.md'deki öneriye bak.
3. **Feature graphic + kısa tanıtım videosu.** Feature graphic hazır
   (store_assets/). 20-30 sn'lik bir video dönüşümü belirgin artırır
   (opsiyonel ama değerli).
4. **Başlık ve kısa açıklama keyword'leri.** Yapıldı: cryptogram, cryptoquote,
   cipher puzzle başlıkta/açıklamada doğal geçiyor. Başlık 30 karakter dolu
   kullanılmalı (şu an "Quotecrack: Cryptogram Puzzle").
5. **Kategori ve etiketler.** Kategori: Word/Puzzle. Play Console'da en fazla
   5 "tag" seç (cryptogram, word puzzle, brain, quotes, daily).
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
