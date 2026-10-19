import 'package:flutter_test/flutter_test.dart';
import 'package:kan_testi_uygulama/features/blood_donation/models/eligibility.dart';

void main() {
  group('checkEligibility Tests', () {
    test('geçerli değerler ile uygunluk sağlanmalı (sınır 18 yaş, 50 kg)', () {
      final result = checkEligibility(
        age: 18,
        weight: 50.0,
        hasRecentTattoo: false,
        hasBlockingDisease: false,
      );

      expect(result.eligible, isTrue);
      expect(result.reasons, isEmpty);
    });

    test('geçerli değerler ile uygunluk sağlanmalı (üst sınır 65 yaş)', () {
      final result = checkEligibility(
        age: 65,
        weight: 80.0,
        hasRecentTattoo: false,
        hasBlockingDisease: false,
      );

      expect(result.eligible, isTrue);
      expect(result.reasons, isEmpty);
    });

    test('18 yaş altı uygun olmamalı', () {
      final result = checkEligibility(
        age: 17,
        weight: 60.0,
        hasRecentTattoo: false,
        hasBlockingDisease: false,
      );

      expect(result.eligible, isFalse);
      expect(result.reasons, contains('Yaş 18-65 aralığında olmalı.'));
    });

    test('65 yaş üstü uygun olmamalı', () {
      final result = checkEligibility(
        age: 66,
        weight: 70.0,
        hasRecentTattoo: false,
        hasBlockingDisease: false,
      );

      expect(result.eligible, isFalse);
      expect(result.reasons, contains('Yaş 18-65 aralığında olmalı.'));
    });

    test('50 kg altı uygun olmamalı (ör. 45 kg)', () {
      final result = checkEligibility(
        age: 25,
        weight: 45.0,
        hasRecentTattoo: false,
        hasBlockingDisease: false,
      );

      expect(result.eligible, isFalse);
      expect(result.reasons, contains('Kilo en az 50 kg olmalı.'));
    });

    test('150 kg üst sınırında uygun olmalı', () {
      final result = checkEligibility(
        age: 35,
        weight: 150.0,
        hasRecentTattoo: false,
        hasBlockingDisease: false,
      );

      expect(result.eligible, isTrue);
      expect(result.reasons, isEmpty);
    });

    test('150 kg üstü uygun olmamalı (ör. 155 kg)', () {
      final result = checkEligibility(
        age: 35,
        weight: 155.0,
        hasRecentTattoo: false,
        hasBlockingDisease: false,
      );

      expect(result.eligible, isFalse);
      expect(result.reasons, contains('Kilo en fazla 150 kg olmalı.'));
    });

    test('son 12 ayda dövme yaptırılmışsa uygun olmamalı', () {
      final result = checkEligibility(
        age: 30,
        weight: 70.0,
        hasRecentTattoo: true,
        hasBlockingDisease: false,
      );

      expect(result.eligible, isFalse);
      expect(result.reasons, contains('Son 12 ayda dövme yaptırılmamış olmalı.'));
    });

    test('kan bağışına engel hastalık varsa uygun olmamalı', () {
      final result = checkEligibility(
        age: 30,
        weight: 70.0,
        hasRecentTattoo: false,
        hasBlockingDisease: true,
      );

      expect(result.eligible, isFalse);
      expect(result.reasons, contains('Kan bağışına engel bir hastalığınız var.'));
    });

    test('birden fazla kural ihlalinde TÜM sebepler listede olmalı', () {
      final result = checkEligibility(
        age: 16,
        weight: 42.0,
        hasRecentTattoo: true,
        hasBlockingDisease: true,
      );

      expect(result.eligible, isFalse);
      expect(result.reasons.length, 4);
      expect(result.reasons, contains('Yaş 18-65 aralığında olmalı.'));
      expect(result.reasons, contains('Kilo en az 50 kg olmalı.'));
      expect(result.reasons, contains('Son 12 ayda dövme yaptırılmamış olmalı.'));
      expect(result.reasons, contains('Kan bağışına engel bir hastalığınız var.'));
    });
  });
}
