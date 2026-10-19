# Kan Bağış Grafiği Uygulaması

Kullanıcının kan bağışı uygunluk kriterlerini değerlendiren, bağışları 8 farklı kan grubuna ve 7 günlük haftalık dağılıma göre dinamik canlı sütun grafiklerde (fl_chart) gösteren, Dark Mode ve başlangıç demo verisi destekli Flutter uygulaması.

---

## 🚀 Öne Çıkan Özellikler

1. **🎨 Canlı & Enerjik Renk Paleti:**
   - **Kan Grubu Dağılımı (8 Sütun):** Her kan grubu için özel ve canlı mücevher tonları (Electric Crimson, Rose, Royal Amethyst, Sunset Coral, Emerald & Ocean Blue).
   - **Haftalık Dağılım (7 Gün):** Pazartesi'den Pazar'a uzanan 7 renkli canlı spektrum gradyanı (Azure -> Cyan -> Violet -> Magenta -> Coral).
   - Canlı kart gölgeleri, parlayan toplam bağış kahraman kartı ve interaktif butonlar.

2. **⚡ Otomatik Başlangıç Verileri:**
   - Uygulama ilk açıldığında grafikler doğrudan gerçekçi rastgele verilerle dolu olarak gelir (kullanıcının elle rastgele veri üretmesine gerek kalmaz).
   - İstenildiğinde "Sıfırla" butonuyla tüm veriler tek dokunuşla sıfırlanabilir.

3. **🌙 Dark Mode / Koyu Tema:**
   - Üst bardaki tema düğmesi ile tek dokunuşla Açık ve Koyu tema arasında geçiş.
   - Derin obsidyen siyahı arayüz zeminleri (`#0F1117`), yüksek kontrastlı neon vurgular.

4. **✨ Özel Uygulama İkonu & Markalama:**
   - Parlayan yakut kırmızısı kan damlası ve nabız/haç motifi içeren özel tasarım uygulama ikonu.
   - Web (`favicon.png`, `Icon-192`, `Icon-512`), Android (`mipmap-*`) ve uygulama içi başlıklara entegre edildi.

5. **📅 İkili Grafik Görünümü:**
   - Grafik ekranındaki `SegmentedButton` ile **Kan Grupları (8)** ve **Haftalık Dağılım (7 Gün)** arasında anında geçiş.

6. **🛡️ Güvenli Uygunluk Kontrolü:**
   - Yaş (18-65) ve kilo (50 - 150 kg dahil) sınırları, son 12 ayda dövme ve engel hastalık kontrolleri.
   - Tüm şartlar sağlanmadığında detaylı sebep listesi gösterimi.
   - Sabit uyarı metni: *"Eğitim amaçlı uygulamadır, gerçek karar Kızılay doktorundadır."*

7. **⚙️ Mimari:**
   - Saf `ValueNotifier` + `ValueListenableBuilder` (ekstra state paketi yok).
   - Controller üzerinde immutable state güncellemeleri.
   - `IndexedStack` ile sekmeler arası gezinirken form ve grafik durumunun korunması.

---

## 🛠️ Kurulum ve Çalıştırma

### Gereksinimler
- Flutter SDK (3.x veya üzeri)
- Dart SDK

### Adımlar

1. Bağımlılıkları yükleyin:
   ```bash
   flutter pub get
   ```

2. Testleri çalıştırın:
   ```bash
   flutter test
   ```

3. Statik kod analizini çalıştırın:
   ```bash
   dart analyze .
   ```

4. Uygulamayı çalıştırın:
   ```bash
   # Chrome üzerinde
   flutter run -d chrome

   # Windows üzerinde
   flutter run -d windows

   # Android üzerinde
   flutter run -d android
   ```

---

## 📁 Klasör Yapısı

```
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
      widgets/weekly_bar_chart.dart
test/
  eligibility_test.dart
  blood_donation_controller_test.dart
  widget_test.dart
```
