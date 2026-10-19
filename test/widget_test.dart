import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kan_testi_uygulama/main.dart';

void main() {
  testWidgets('Uygulama açılışında başlangıç verisi, navigasyon, dark mode ve sıfırlama testi', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const BloodDonationApp());
    await tester.pumpAndSettle();

    // 1. Sayfa 1: Bağış Ekle bileşenleri görünür olmalı
    expect(find.text('Kan Grubu Seçin'), findsOneWidget);
    expect(find.text('Yaş'), findsOneWidget);
    expect(find.text('Kilo (kg)'), findsOneWidget);
    expect(find.text('Son 12 ayda dövme yaptırdım'), findsOneWidget);
    expect(find.text('Kan bağışına engel bir hastalığım var'), findsOneWidget);
    expect(
      find.text('Eğitim amaçlı uygulamadır, gerçek karar Kızılay doktorundadır.'),
      findsOneWidget,
    );

    // 2. Dark mode butonu çalışmalı
    await tester.tap(find.byTooltip('Karanlık Mod'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Açık Mod'), findsOneWidget);

    // Açık moda geri dön
    await tester.tap(find.byTooltip('Açık Mod'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Karanlık Mod'), findsOneWidget);

    // 3. Grafik sayfasına geçiş (Uygulama ilk açıldığında rastgele veriler grafikte olmalı)
    await tester.tap(find.byIcon(Icons.bar_chart_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Toplam Bağış'), findsOneWidget);
    // Başlangıçta 0'dan büyük rastgele veri olmalı
    expect(find.text('0 ünite'), findsNothing);

    // 4. Haftalık Dağılım segmentine geçiş
    await tester.tap(find.text('Haftalık Dağılım (7 Gün)'));
    await tester.pumpAndSettle();
    expect(find.text('Haftalık Bağış Dağılımı'), findsOneWidget);

    // 5. Bağış Ekle sayfasına dön ve manuel bağış ekle
    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle();

    await tester.tap(find.text('A+'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Yaş'), '25');
    await tester.enterText(find.widgetWithText(TextField, 'Kilo (kg)'), '70');
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Bağış Ekle'));
    await tester.pumpAndSettle();

    // 6. Sıfırla butonuna tıkla ve tüm verilerin 0 olduğunu doğrula
    await tester.tap(find.byIcon(Icons.bar_chart_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Sıfırla'));
    await tester.pumpAndSettle();

    expect(find.text('0 ünite'), findsOneWidget);
  });
}
