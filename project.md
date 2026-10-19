# Proje: Kan Bağış Grafiği

## Amaç
Kullanıcı uygunluk formunu doldurup bir kan grubu seçer ve "Bağış Ekle" der.
Uygunsa seçilen kan grubunun sayısı 1 artar ve 8 kan grubunu gösteren
sütun grafiğe yansır. Uygun değilse sebepleri gösterilir, grafik değişmez.

## Teknoloji
- Flutter (Dart), Material 3
- Grafik: fl_chart
- State: ValueNotifier + ValueListenableBuilder (ek state paketi yok)
- Veri: sadece bellekte

## Sayfalar (2 sayfa, alttaki NavigationBar ile geçiş)

### Sayfa 1: Bağış Ekle
- Yaş alanı (sayı)
- Kilo alanı (sayı, kg)
- Onay kutusu: "Son 12 ayda dövme yaptırdım"
- Onay kutusu: "Kan bağışına engel bir hastalığım var"
- 8 kan grubu seçim butonu: A+, A-, B+, B-, AB+, AB-, 0+, 0-
- "Bağış Ekle" butonu
- Altta sabit uyarı: "Eğitim amaçlı uygulamadır, gerçek karar Kızılay doktorundadır."

### Sayfa 2: Grafik
- 8 sütunlu sütun grafik (her kan grubu için bir sütun, başlangıçta hepsi 0)
- Toplam bağış sayısı
- "Sıfırla" butonu (tüm sayıları 0 yapar)

## Uygunluk kuralları
Bağış ancak aşağıdakilerin HEPSİ sağlanırsa kabul edilir:
1. Yaş 18 ile 65 arasında (dahil)
2. Kilo en az 50 kg
3. Son 12 ayda dövme yok
4. Kan bağışına engel hastalık yok

Ek durumlar:
- Kan grubu seçilmemişse bağış eklenmez: "Kan grubu seçin."
- Yaş veya kilo boş/geçersizse bağış eklenmez: "Yaş ve kilo geçerli sayı olmalı."
- Uygun değilse TÜM sebepler liste olarak gösterilir (SnackBar veya diyalog).
- Sağlık bilgileri kaydedilmez, sadece o anki kontrol için kullanılır.

## Veri
- Bağış sayıları: Map<String, int> (kan grubu -> adet), ValueNotifier içinde
- Seçili kan grubu: ValueNotifier<String?>
- Tek bir BloodDonationController vardır, iki sayfa da aynı örneği kullanır

## Klasör yapısı
lib/
  main.dart
  features/
    blood_donation/
      controllers/blood_donation_controller.dart
      models/eligibility.dart
      view/add_donation_view.dart
      view/chart_view.dart
      widgets/blood_type_selector.dart
      widgets/blood_bar_chart.dart
test/
  eligibility_test.dart
  blood_donation_controller_test.dart

## Kapsam dışı
Giriş/kayıt, veritabanı, bildirim, harita, çoklu dil, kalıcı veri.

## Kabul senaryoları (hepsi çalışmalı)
1. Uygulama açılınca grafikte 8 sütun var ve hepsi 0.
2. Yaş 25, kilo 70, dövme yok, hastalık yok, A+ seçili, "Bağış Ekle": grafikte A+ = 1.
3. Aynısı tekrar: A+ = 2, toplam = 2.
4. Kilo 45 ile denenirse bağış eklenmez, "Kilo en az 50 kg olmalı." gösterilir.
5. Hastalık kutusu işaretliyse bağış eklenmez, sebep gösterilir.
6. Kan grubu seçmeden "Bağış Ekle" denenirse "Kan grubu seçin." gösterilir.
7. Sayfa değiştirip dönünce sayılar korunur.
8. "Sıfırla" tüm sütunları 0 yapar.

## Teslim kriterleri
- flutter analyze: hata ve uyarı yok
- flutter test: tüm testler geçer
- Kabul senaryolarının hepsi elle denenmiş
- README: kısa kurulum ve çalıştırma adımları