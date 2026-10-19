import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kan_testi_uygulama/features/blood_donation/controllers/blood_donation_controller.dart';

void main() {
  group('BloodDonationController Tests', () {
    late BloodDonationController controller;

    setUp(() {
      // Clean controller without initial random data for pure deterministic testing
      controller = BloodDonationController(populateInitialData: false);
    });

    tearDown(() {
      controller.dispose();
    });

    test('Uygulama açılışında varsayılan olarak rastgele veriler yüklenmiş olmalı', () {
      final defaultController = BloodDonationController();
      addTearDown(() => defaultController.dispose());

      expect(defaultController.totalDonations, greaterThan(0));
      for (final type in BloodDonationController.bloodTypes) {
        expect(defaultController.counts.value[type], greaterThan(0));
      }
      for (final day in BloodDonationController.weekDays) {
        expect(defaultController.weeklyCounts.value[day], greaterThan(0));
      }
    });

    test('populateInitialData: false ile başlangıçta 8 kan grubu olmalı, hepsi 0 ve toplam 0 olmalı', () {
      expect(BloodDonationController.bloodTypes.length, 8);
      expect(
        BloodDonationController.bloodTypes,
        ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', '0+', '0-'],
      );

      final counts = controller.counts.value;
      expect(counts.length, 8);
      for (final type in BloodDonationController.bloodTypes) {
        expect(counts[type], 0);
      }
      expect(controller.totalDonations, 0);
      expect(controller.selectedType.value, isNull);
    });

    test('populateInitialData: false ile başlangıçta haftalık 7 gün hepsi 0 olmalı', () {
      expect(BloodDonationController.weekDays.length, 7);
      expect(
        BloodDonationController.weekDays,
        ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'],
      );

      final weekly = controller.weeklyCounts.value;
      expect(weekly.length, 7);
      for (final day in BloodDonationController.weekDays) {
        expect(weekly[day], 0);
      }
    });

    test('Kan grubu seçimi yapılabilmeli', () {
      controller.selectType('A+');
      expect(controller.selectedType.value, 'A+');

      controller.selectType('0-');
      expect(controller.selectedType.value, '0-');
    });

    test('Kan grubu seçilmeden bağış eklenirse hata vermeli', () {
      final result = controller.addDonation(
        rawAge: '25',
        rawWeight: '70',
        hasRecentTattoo: false,
        hasBlockingDisease: false,
      );

      expect(result.isSuccess, isFalse);
      expect(result.reasons, contains('Kan grubu seçin.'));
      expect(controller.totalDonations, 0);
    });

    test('Yaş veya kilo boş/geçersizse bağış eklenmemeli', () {
      controller.selectType('B+');

      final result1 = controller.addDonation(
        rawAge: '',
        rawWeight: '70',
        hasRecentTattoo: false,
        hasBlockingDisease: false,
      );
      expect(result1.isSuccess, isFalse);
      expect(result1.reasons, contains('Yaş ve kilo geçerli sayı olmalı.'));

      final result2 = controller.addDonation(
        rawAge: 'abc',
        rawWeight: 'def',
        hasRecentTattoo: false,
        hasBlockingDisease: false,
      );
      expect(result2.isSuccess, isFalse);
      expect(result2.reasons, contains('Yaş ve kilo geçerli sayı olmalı.'));
      expect(controller.totalDonations, 0);
    });

    test('Kilo 45 ile denenirse bağış eklenmemeli', () {
      controller.selectType('A+');

      final result = controller.addDonation(
        rawAge: '25',
        rawWeight: '45',
        hasRecentTattoo: false,
        hasBlockingDisease: false,
      );

      expect(result.isSuccess, isFalse);
      expect(result.reasons, contains('Kilo en az 50 kg olmalı.'));
      expect(controller.counts.value['A+'], 0);
      expect(controller.totalDonations, 0);
    });

    test('Kilo 150 kg üstü (ör. 160 kg) ile denenirse bağış eklenmemeli', () {
      controller.selectType('0+');

      final result = controller.addDonation(
        rawAge: '30',
        rawWeight: '160',
        hasRecentTattoo: false,
        hasBlockingDisease: false,
      );

      expect(result.isSuccess, isFalse);
      expect(result.reasons, contains('Kilo en fazla 150 kg olmalı.'));
      expect(controller.counts.value['0+'], 0);
      expect(controller.totalDonations, 0);
    });

    test('Hastalık kutusu işaretliyse bağış eklenmemeli', () {
      controller.selectType('AB+');

      final result = controller.addDonation(
        rawAge: '30',
        rawWeight: '75',
        hasRecentTattoo: false,
        hasBlockingDisease: true,
      );

      expect(result.isSuccess, isFalse);
      expect(result.reasons, contains('Kan bağışına engel bir hastalığınız var.'));
      expect(controller.counts.value['AB+'], 0);
    });

    test('Kabul Senaryosu: Yaş 25, kilo 70, dövme yok, hastalık yok, A+ seçili -> A+ = 1', () {
      controller.selectType('A+');

      final result = controller.addDonation(
        rawAge: '25',
        rawWeight: '70',
        hasRecentTattoo: false,
        hasBlockingDisease: false,
        day: 'Pzt',
      );

      expect(result.isSuccess, isTrue);
      expect(controller.counts.value['A+'], 1);
      expect(controller.weeklyCounts.value['Pzt'], 1);
      expect(controller.totalDonations, 1);
    });

    test('Kabul Senaryosu: Aynısı tekrar edildiğinde A+ = 2, toplam = 2', () {
      controller.selectType('A+');

      controller.addDonation(
        rawAge: '25',
        rawWeight: '70',
        hasRecentTattoo: false,
        hasBlockingDisease: false,
      );

      final result2 = controller.addDonation(
        rawAge: '25',
        rawWeight: '70',
        hasRecentTattoo: false,
        hasBlockingDisease: false,
      );

      expect(result2.isSuccess, isTrue);
      expect(controller.counts.value['A+'], 2);
      expect(controller.totalDonations, 2);
    });

    test('Kabul Senaryosu: Sıfırla tüm sütunları ve haftalık verileri 0 yapar', () {
      final loadedController = BloodDonationController(populateInitialData: true);
      addTearDown(() => loadedController.dispose());

      expect(loadedController.totalDonations, greaterThan(0));

      loadedController.reset();

      expect(loadedController.totalDonations, 0);
      for (final type in BloodDonationController.bloodTypes) {
        expect(loadedController.counts.value[type], 0);
      }
      for (final day in BloodDonationController.weekDays) {
        expect(loadedController.weeklyCounts.value[day], 0);
      }
    });

    test('Dark Mode toggle işlemi çalışmalı', () {
      expect(controller.themeMode.value, ThemeMode.light);

      controller.toggleTheme();
      expect(controller.themeMode.value, ThemeMode.dark);

      controller.toggleTheme();
      expect(controller.themeMode.value, ThemeMode.light);
    });

    test('Counts map güncellemesi immutable yeni kopya oluşturmalı', () {
      final initialMap = controller.counts.value;
      controller.selectType('B-');
      controller.addDonation(
        rawAge: '22',
        rawWeight: '60',
        hasRecentTattoo: false,
        hasBlockingDisease: false,
      );

      expect(identical(initialMap, controller.counts.value), isFalse);
    });
  });
}
