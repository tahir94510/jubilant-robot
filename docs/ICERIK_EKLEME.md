# İçerik Ekleme Sistemi: Yeni Sözler ve Başarımlar Nasıl Eklenir?

Uygulama sunucusuz çalıştığı için "içerik güncellemesi" demek yeni sürüm
demektir. Süreç bilinçli olarak basit tutuldu ve kalite testlerle otomatik
zorlanıyor: yanlış formatta, kopya, çok kısa/uzun veya atıfsız bir söz
eklerseniz CI kırmızıya döner ve paket üretilmez. Yani bozuk içerik
kullanıcıya asla ulaşamaz.

## Önerilen kadans

- Çeyrekte bir +50 söz (mevcut kategorilere dağıtılmış): mağaza kaydını taze
  tutar, sadık oyunculara malzeme verir.
- Aralık ayında sezonluk temalı paket (ör. "Winter Wisdom"): mağaza
  görselleri/metniyle birlikte güncellenirse keşif ivmesi sağlar.
- En pratiği bana "yeni içerik partisi hazırla" demeniz: kamu malı havuzdan
  derleyip, test ettirip, sürümü hazırlarım. Kendiniz eklemek isterseniz
  tarif aşağıda.

## Adım adım: mevcut bir kategoriye söz ekleme

1. `assets/data/quotes/` altında ilgili dosyayı açın (wisdom/humor/
   proverbs/literature/science; premium: shakespeare/stoic).
2. Dizinin sonuna şu şemayla satır ekleyin:

   ```json
   {"id": "wis2-001", "text": "...", "author": "...", "source": "...", "category": "wisdom"}
   ```

   Kurallar (`test/data/quotes_validation_test.dart` zorlar):
   - `id` benzersiz. Yeni partiler yeni önek kullanır: `wis2-`, `hum2-`,
     `prv2-` gibi (sıralama kararlılığı için).
   - `text` ASCII, 20 ile 180 harf arası, başka bir sözün kopyası değil
     (normalize edilmiş metin birebir karşılaştırılarak denetlenir).
   - Telif: yalnız kamu malı (1929 öncesi yayın/ölüm). Emin değilseniz
     yaşayan kişilerden veya modern eserlerden alıntı EKLEMEYİN.
   - `author` "Unknown" olamaz; halk malı için "Anonymous" veya "Proverb".
   - `category` dosya adıyla aynı.
3. Sürümü artırın (aşağıdaki "Sürüm ve içerik revizyonu" bölümü).
4. Push edin. CI testleri içeriği denetler; yeşilse `quotecrack-release-aab`
   hazırdır. KALITE_KONTROL B turundan 2-3 madde, sonra Play Console.

## Adım adım: yeni başarım (achievement) ekleme

Başarımlar `lib/models/achievement.dart` içindeki `catalog` listesinde durur.
Her biri yalnız `GameStats` alanlarına bakan saf bir koşuldur, bu yüzden
ekleme güvenlidir.

1. Ait olduğu grubun (çözüm sayısı / seri / ipucusuz / hız / günlük) yanına
   yeni bir `Achievement` ekleyin:

   ```dart
   Achievement(
     id: 'solve_500',                  // benzersiz, kalıcı
     title: 'Grandmaster',             // benzersiz, özgün
     description: 'Solve 500 puzzles', // benzersiz, net
     icon: Icons.shield_outlined,      // benzersiz bir ikon
     isUnlocked: (s) => s.totalSolved >= 500,
     addedInVersion: 2,                // yeni içerik partisi numarası
   ),
   ```

   Kalite kuralı (`test/logic/achievements_test.dart` zorlar): id, başlık,
   açıklama ve ikon tüm katalogda benzersiz olmalı. Eşiği mevcut bir başarımla
   aynı yapmayın; her başarım gerçekten ayrı bir hedef olsun (yüzeysel kopya
   değil).

2. `docs/STORE_LISTING.md` içindeki "N achievements to unlock" sayısını ve
   `test/logic/content_badge_test.dart` içindeki toplam/parti sayısını
   güncelleyin (ekleme kasıtlı kalsın, kazara silme yakalansın).

## Sürüm ve içerik revizyonu

İki ayrı numara var; karıştırmayın:

- **Sürüm** (`pubspec.yaml` → `version: 1.1.5+8`, `app_config.dart` →
  `appVersion`): her Play yüklemesinde artar.
- **İçerik revizyonu** (`app_config.dart` → `contentVersion`): yalnız yeni bir
  söz/başarım partisi eklerken +1 artar. Bu partideki yeni başarımlara
  `addedInVersion: <yeni contentVersion>` verin.

## "NEW" etiketi nasıl çalışır (otomatik)

Yeni eklenen başarımlar (ve ileride paketler) oyuncu ilgili ekranı açana
kadar küçük bir "NEW" rozeti taşır:

- Her öğede bir `addedInVersion` vardır; `AppConfig.contentVersion` mevcut en
  yüksek revizyondur.
- Oyuncunun gördüğü son revizyon `AppSettings.seenContentVersion`'da saklanır.
- `addedInVersion > seenContentVersion` olan öğe "yeni" sayılır. İlgili ekran
  açılınca `SettingsController.markContentSeen()` çağrılır ve rozetler bir
  sonraki sefere temizlenir.

Yani yeni içerik eklerken tek yapmanız gereken `addedInVersion` vermek ve
gerekiyorsa `contentVersion`'ı artırmaktır; rozet kendiliğinden gelir ve gider.

## Ses ve görselleri yeniden üretme

Ses ve raster görseller elle düzenlenmez; üreticilerden çıkar ve kendi kalite
öz-denetimlerini çalıştırır:

- `python3 tool/generate_sounds.py`: efektler. Her dosya tam sessizlikte
  başlayıp biter; tepe seviyesi role göre dengelenir (kutlama en gür, tuş
  vuruşu en hafif).
- `python3 tool/generate_music.py`: ~128 sn, iki bölümlü sakin müzik yatağı,
  22.05 kHz mono. Döngü dikişi sessizlikten geçer; betik klip/DC/dikiş
  kontrollerini kendi yapar ve hata varsa durur.
- `python3 tool/generate_icons.py`: tüm ikonlar, splash, bildirim glifi, web
  ikonları, Play ikonu, feature graphic. `dart run flutter_launcher_icons`
  ÇALIŞTIRMAYIN.

Değiştirdikten sonra `flutter test` ses ve içerik testlerini de doğrular.

## Sistem neye otomatik uyum sağlar?

| Alan | Davranış |
|---|---|
| Paketler | Kategoriye eklenen söz ilgili paket(ler)de kendiliğinden görünür; paket sayaçları (`12/68` gibi) kendiliğinden güncellenir |
| Zorluk rafları | Yeni sözün zorluğu koddan hesaplanır, doğru rafa düşer. Raf merdiveni **aktif dile** göre çalışır: oyuncu Türkçe'deyse Başlangıç→Uzman rafları Türkçe sözlerle, İngilizce'deyse İngilizce sözlerle dolar |
| Günlük havuz | Günlük bulmaca da **aktif dile** göre seçilir: her dilin kendi günlük havuzu vardır (İngilizce için ücretsiz kategoriler; diğer diller için o dilin yerel sözleri) |
| Sayaç başarımları | Mevcut sözlerle kendiliğinden ilerler; YENİ başarım eklemek ayrı bir adımdır (yukarı bakın) |
| Eski oyuncular | İlerleme/seri/jeton aynen korunur (kayıtlar söz/başarım kimliğine bağlı) |

Dürüst teknik not: günlük bulmaca sırası yıl bazında havuzdan türetilir;
havuz büyüyünce o yılın kalan günlük sırası yeniden karılır (çok düşük
olasılıkla yıl içinde bir söz ikinci kez "günün bulmacası" olabilir). Çeyrek
başına bir ekleme kadansında pratikte fark edilmez; istenirse içerik
partilerini 1 Ocak güncellemelerinde yayınlayarak tamamen önlenebilir.

Diller için: İngilizce havuz bir artık yılı (366+) kapsar, bu yüzden yıl
içinde tekrar olmaz. Yerel dil havuzları daha küçük olabilir; bu durumda
günlük seçim havuz boyutuna göre **deterministik biçimde döngüye girer**
(aynı gün herkes için aynı bulmaca olur, ama küçük havuzda yıl içinde tekrar
mümkündür). Havuz büyüdükçe tekrar aralığı kendiliğinden açılır.

## Zorluk eşikleri (çok söz eklerken DİKKAT)

`app_config.dart` içindeki `beginnerMax/casualMax/skilledMax` eşikleri veri
setinin çeyrekliklerine sabitlidir ve `quotes_validation_test` her zorluk
kovasında en az 40 söz olmasını zorlar. Büyük bir parti eklerken dağılım
kayabilir ve eşikleri yeniden hesaplamak gerekebilir; emin değilseniz büyük
partiyi bana bırakın.

## Yeni TEMALI paket eklemek (kod gerekir)

Yeni bir kategori dosyası ve `lib/models/pack.dart` içindeki `Pack.catalog`
listesine kayıt ister. Bunu bana bırakın: "X temalı paket ekleyelim" deyin;
içerik, kod, test ve görsel/metin güncellemeleriyle birlikte hazırlarım.
