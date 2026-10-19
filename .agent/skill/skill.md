---
name: flutter-chart-feature
description: Flutter'da fl_chart ile grafik içeren yeni bir ekran veya özellik modülü eklerken kullan. controller/model/view/widgets ayrımı, ValueNotifier ile reaktif state ve grafik güncelleme kurallarını uygular.
---

# Flutter Chart Feature

## Ne zaman kullan
- Yeni bir özellik modülü açarken (klasör yapısı, controller, view, grafik widget'ı)
- Mevcut bir veriyi grafikle göstermen istendiğinde

## Ne zaman kullanma
- Sadece küçük hata düzeltmesi veya metin/renk değişikliği yaparken

## Kurallar
1. Her özellik `lib/features/<feature_name>/` altında olur ve dört klasör içerir:
   `controllers/`, `models/`, `view/`, `widgets/`.
2. Mantık, UI ve model asla aynı dosyada olmaz.
3. State için `ValueNotifier` + `ValueListenableBuilder` kullan. Başka state paketi ekleme.
4. `ValueNotifier` içindeki koleksiyonu (Map/List) ASLA yerinde değiştirme.
   Yeni bir kopya oluşturup `value`'ya ata, yoksa UI güncellenmez.
5. Controller'ı tek yerde (uygulamanın kök widget'ı) oluştur, `initState`'te yarat,
   `dispose`'ta temizle ve view'lara constructor ile ver. View içinde controller yaratma.
6. Widget'lar varsayılan olarak `StatelessWidget` olur. `StatefulWidget` sadece
   yaşam döngüsü gereken kaynaklar için (`TextEditingController`, kök kabuk) kullanılır;
   bunlar `dispose` edilir.
7. Mümkün olan her widget'ta `const` kullan. Controller alan widget'lar const olamaz,
   bu normaldir.
8. İş kuralları (ör. uygunluk kontrolü) UI'dan bağımsız, saf fonksiyon olarak
   `models/` altında yazılır ve test edilir.
9. Grafik widget'ı veriyi parametre olarak alır, kendi başına veri üretmez
   ve controller'ı bilmez.
10. Boş/başlangıç durumu her zaman ele alınır (ör. tüm değerler 0 iken grafik çökmemeli).
11. Kullanıcıya görünen metinler Türkçedir. Kod ve değişken adları İngilizcedir.

## Adımlar
1. `project.md`'yi oku ve kapsam dışı olanı yapma.
2. Klasör yapısını oluştur.
3. Modeli ve saf kural fonksiyonlarını yaz, test et.
4. Controller'ı yaz (aşağıdaki kalıba uy).
5. Grafik widget'ını yaz.
6. View'ları yaz.
7. `main.dart`'ta kök kabuğu ve iki sayfalı NavigationBar'ı kur.
8. Testleri yaz ve çalıştır.
9. Bitirme kontrolünü yap.

## Kod kalıpları

### Controller
```dart
import 'package:flutter/foundation.dart';

class BloodDonationController {
  static const List<String> bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', '0+', '0-',
  ];

  final ValueNotifier<Map<String, int>> counts =
      ValueNotifier<Map<String, int>>({for (final t in bloodTypes) t: 0});
  final ValueNotifier<String?> selectedType = ValueNotifier<String?>(null);

  void selectType(String type) => selectedType.value = type;

  void reset() {
    counts.value = {for (final t in bloodTypes) t: 0};
  }

  void dispose() {
    counts.dispose();
    selectedType.dispose();
  }
}
```

Bağış ekleme metodu da controller'da olur: kan grubu seçili mi bakar, uygunluk
fonksiyonunu çağırır, uygunsa sayıyı artırır. Map'i yerinde değil, KOPYALAYARAK güncelle:

```dart
counts.value = {...counts.value, type: counts.value[type]! + 1};
```

### Kök kabuk (controller'ın sahibi)
```dart
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final BloodDonationController _controller = BloodDonationController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      AddDonationView(controller: _controller),
      ChartView(controller: _controller),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.add), label: 'Bağış Ekle'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Grafik'),
        ],
      ),
    );
  }
}
```

### Reaktif view
```dart
ValueListenableBuilder<Map<String, int>>(
  valueListenable: controller.counts,
  builder: (context, counts, _) => BloodBarChart(counts: counts),
)
```

### Grafik widget'ı (fl_chart)
```dart
class BloodBarChart extends StatelessWidget {
  const BloodBarChart({super.key, required this.counts});

  final Map<String, int> counts;

  @override
  Widget build(BuildContext context) {
    final types = counts.keys.toList();
    final maxValue = counts.values.fold<int>(0, (a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        maxY: (maxValue < 5 ? 5 : maxValue + 1).toDouble(),
        barGroups: [
          for (var i = 0; i < types.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [BarChartRodData(toY: counts[types[i]]!.toDouble())],
            ),
        ],
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text(types[value.toInt()]),
            ),
          ),
        ),
      ),
    );
  }
}
```

### Uygunluk fonksiyonu (models/eligibility.dart)
```dart
class EligibilityResult {
  const EligibilityResult({required this.eligible, this.reasons = const []});

  final bool eligible;
  final List<String> reasons;
}

EligibilityResult checkEligibility({
  required int age,
  required double weight,
  required bool hasRecentTattoo,
  required bool hasBlockingDisease,
}) {
  final reasons = <String>[];
  if (age < 18 || age > 65) reasons.add('Yaş 18-65 aralığında olmalı.');
  if (weight < 50) reasons.add('Kilo en az 50 kg olmalı.');
  if (hasRecentTattoo) reasons.add('Son 12 ayda dövme yaptırılmamış olmalı.');
  if (hasBlockingDisease) reasons.add('Kan bağışına engel bir hastalığınız var.');
  return EligibilityResult(eligible: reasons.isEmpty, reasons: reasons);
}
```

## Yapma listesi
- Tek dosyada her şeyi yazma.
- Veritabanı, Firebase, backend veya ekstra state paketi ekleme.
- Controller'ı view içinde oluşturma.
- Map/List'i yerinde değiştirip UI'ın güncellenmesini bekleme.
- `project.md`'de olmayan özellik ekleme.
- Sağlık bilgilerini kaydetme veya loglama.
- Tıbbi kesinlik iddia eden metin yazma. Uyarı metni her zaman görünür kalsın.

## Bitirme kontrolü
1. `flutter pub get`
2. `flutter analyze` hatasız ve uyarısız
3. `flutter test` tüm testler geçer
4. `project.md`'deki 8 kabul senaryosu tek tek kontrol edilir
5. Kısa bir özet yaz: hangi dosyalar eklendi, hangi senaryolar denendi