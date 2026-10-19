import 'dart:math';
import 'package:flutter/material.dart';
import '../models/eligibility.dart';

class DonationResult {
  const DonationResult.success([this.message = 'Bağış başarıyla eklendi.'])
      : isSuccess = true,
        reasons = const [];

  const DonationResult.failure(this.reasons, {this.message})
      : isSuccess = false;

  final bool isSuccess;
  final String? message;
  final List<String> reasons;
}

class BloodDonationController {
  BloodDonationController({bool populateInitialData = true}) {
    if (populateInitialData) {
      _generateInitialData();
    }
  }

  static const List<String> bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    '0+',
    '0-',
  ];

  static const List<String> weekDays = [
    'Pzt',
    'Sal',
    'Çar',
    'Per',
    'Cum',
    'Cmt',
    'Paz',
  ];

  final ValueNotifier<Map<String, int>> counts =
      ValueNotifier<Map<String, int>>({for (final t in bloodTypes) t: 0});

  final ValueNotifier<Map<String, int>> weeklyCounts =
      ValueNotifier<Map<String, int>>({for (final d in weekDays) d: 0});

  final ValueNotifier<String?> selectedType = ValueNotifier<String?>(null);

  final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  int get totalDonations =>
      counts.value.values.fold<int>(0, (sum, count) => sum + count);

  void _generateInitialData() {
    final random = Random();
    final initialCounts = <String, int>{};
    final initialWeekly = <String, int>{};

    // Realistic initial distribution across 8 blood types
    for (final type in bloodTypes) {
      initialCounts[type] = 2 + random.nextInt(5); // 2 to 6 donations each
    }

    // Realistic initial distribution across 7 days of the week
    for (final day in weekDays) {
      initialWeekly[day] = 3 + random.nextInt(6); // 3 to 8 donations each
    }

    counts.value = initialCounts;
    weeklyCounts.value = initialWeekly;
  }

  void toggleTheme() {
    themeMode.value =
        themeMode.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  void selectType(String? type) {
    selectedType.value = type;
  }

  void reset() {
    counts.value = {for (final t in bloodTypes) t: 0};
    weeklyCounts.value = {for (final d in weekDays) d: 0};
  }

  DonationResult addDonation({
    required String? rawAge,
    required String? rawWeight,
    required bool hasRecentTattoo,
    required bool hasBlockingDisease,
    String? day,
  }) {
    final reasons = <String>[];

    final type = selectedType.value;
    if (type == null || type.isEmpty) {
      reasons.add('Kan grubu seçin.');
    }

    final trimmedAge = rawAge?.trim() ?? '';
    final trimmedWeight = rawWeight?.trim().replaceAll(',', '.') ?? '';

    final age = int.tryParse(trimmedAge);
    final weight = double.tryParse(trimmedWeight);

    if (age == null || weight == null) {
      reasons.add('Yaş ve kilo geçerli sayı olmalı.');
    } else {
      final eligibility = checkEligibility(
        age: age,
        weight: weight,
        hasRecentTattoo: hasRecentTattoo,
        hasBlockingDisease: hasBlockingDisease,
      );
      if (!eligibility.eligible) {
        reasons.addAll(eligibility.reasons);
      }
    }

    if (reasons.isNotEmpty) {
      return DonationResult.failure(reasons);
    }

    // Default to current weekday if not specified
    final targetDay = day ?? weekDays[(DateTime.now().weekday - 1) % 7];

    // Immutable update of maps
    counts.value = {
      ...counts.value,
      type!: counts.value[type]! + 1,
    };

    weeklyCounts.value = {
      ...weeklyCounts.value,
      targetDay: (weeklyCounts.value[targetDay] ?? 0) + 1,
    };

    return DonationResult.success('$type kan grubu bağışı eklendi.');
  }

  void dispose() {
    counts.dispose();
    weeklyCounts.dispose();
    selectedType.dispose();
    themeMode.dispose();
  }
}
