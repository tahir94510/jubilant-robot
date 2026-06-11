# İçerik Ekleme Sistemi — Yeni Bulmacalar Nasıl Eklenir?

Uygulama sunucusuz çalıştığı için "içerik güncellemesi" = **yeni sürüm**.
Süreç bilinçli olarak basit tutuldu ve kalite testlerle otomatik zorlanıyor:
yanlış formatta, kopya, çok kısa/uzun veya atıfsız bir söz eklerseniz CI
kırmızıya döner ve paket üretilmez — yani bozuk içerik kullanıcıya asla
ulaşamaz.

## Önerilen kadans

- **Çeyrekte bir +50 söz** (mevcut kategorilere dağıtılmış) — mağaza
  kaydını "taze" tutar, sadık oyunculara malzeme verir.
- **Aralık ayında sezonluk temalı paket** (ör. "Winter Wisdom") — mağaza
  görselleri/metniyle birlikte güncellenirse keşif ivmesi sağlar.
- En pratiği: bana "yeni içerik partisi hazırla" demeniz — kamu malı
  havuzdan derleyip, test ettirip, sürümü hazırlarım. Kendiniz eklemek
  isterseniz tarif aşağıda.

## Adım adım: mevcut bir kategoriye söz ekleme

1. `assets/data/quotes/` altında ilgili dosyayı açın (wisdom/humor/
   proverbs/literature/science — premium: shakespeare/stoic).
2. Dizinin sonuna şu şemayla satır ekleyin:

   ```json
   {"id": "wis2-001", "text": "...", "author": "...", "source": "...", "category": "wisdom"}
   ```

   **Kurallar (testlerin zorladıkları):**
   - `id` benzersiz; **yeni partiler yeni önek kullanır**: `wis2-`,
     `hum2-`, `prv2-`… (sıralama kararlılığı için).
   - `text` ASCII, 20–180 harf arası, başka bir sözün kopyası değil.
   - **Telif:** yalnız kamu malı — 1929 öncesi yayın/ölüm; emin değilseniz
     `source` alanına dürüstçe `Attributed` yazın, modern kişilerden
     alıntı EKLEMEYİN.
   - `category` dosya adıyla aynı.
3. Sürümü artırın: `pubspec.yaml` → `version: 1.1.0+2` (sondaki sayı her
   yüklemede +1) ve `lib/config/app_config.dart` → `appVersion: '1.1.0'`.
4. Push → CI testleri içeriği denetler → yeşilse `quotecrack-release-aab`
   hazır → KALITE_KONTROL B turundan 2-3 madde → Play Console'a yükleyin.

## Sistem neye otomatik uyum sağlar?

| Alan | Davranış |
|---|---|
| Paketler | Kategoriye eklenen söz, ilgili paket(ler)de kendiliğinden görünür; paket sayaçları (`12/68` gibi) kendiliğinden güncellenir |
| Zorluk rafları | Yeni sözün zorluğu koddan hesaplanır, doğru rafa düşer |
| Günlük havuz | Ücretsiz kategorilere eklenenler günlük havuza kendiliğinden girer |
| Başarımlar | Sayaç tabanlı oldukları için değişiklik gerekmez |
| Eski oyuncular | İlerleme/seri/jetonlar aynen korunur (kayıtlar söz kimliğine bağlı) |

**Dürüst teknik not:** Günlük bulmaca sırası yıl bazında havuzdan
türetilir; havuz büyüyünce o yılın KALAN günlük sırası yeniden karılır
(çok düşük olasılıkla yıl içinde bir söz ikinci kez "günün bulmacası"
olabilir). Çeyrek başına bir ekleme kadansında pratikte fark edilmez;
istenirse içerik partilerini 1 Ocak güncellemelerinde yayınlayarak tamamen
önlenebilir.

## Yeni TEMALI paket eklemek (kod gerekir)

Yeni bir kategori dosyası + `lib/models/pack.dart` içindeki `Pack.catalog`
listesine kayıt ister. Bunu bana bırakın: "X temalı paket ekleyelim" deyin;
içerik + kod + test + görsel metin güncellemeleriyle birlikte hazırlarım.
