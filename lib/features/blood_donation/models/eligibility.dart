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
  if (age < 18 || age > 65) {
    reasons.add('Yaş 18-65 aralığında olmalı.');
  }
  if (weight < 50) {
    reasons.add('Kilo en az 50 kg olmalı.');
  } else if (weight > 150) {
    reasons.add('Kilo en fazla 150 kg olmalı.');
  }
  if (hasRecentTattoo) {
    reasons.add('Son 12 ayda dövme yaptırılmamış olmalı.');
  }
  if (hasBlockingDisease) {
    reasons.add('Kan bağışına engel bir hastalığınız var.');
  }
  return EligibilityResult(eligible: reasons.isEmpty, reasons: reasons);
}
