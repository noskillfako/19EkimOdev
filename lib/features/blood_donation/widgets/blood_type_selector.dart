import 'package:flutter/material.dart';

class BloodTypeSelector extends StatelessWidget {
  const BloodTypeSelector({
    super.key,
    required this.bloodTypes,
    required this.selectedType,
    required this.onTypeSelected,
  });

  final List<String> bloodTypes;
  final String? selectedType;
  final ValueChanged<String> onTypeSelected;

  static const Map<String, Color> typeColors = {
    'A+': Color(0xFFFF1744),
    'A-': Color(0xFFE91E63),
    'B+': Color(0xFF8E24AA),
    'B-': Color(0xFF673AB7),
    'AB+': Color(0xFFFF6D00),
    'AB-': Color(0xFFFF3D00),
    '0+': Color(0xFF00BFA5),
    '0-': Color(0xFF00B0FF),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: bloodTypes.map((type) {
            final isSelected = selectedType == type;
            final vibrantColor = typeColors[type] ?? colorScheme.primary;

            return InkWell(
              onTap: () => onTypeSelected(type),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: (constraints.maxWidth - 30) / 4 > 60
                    ? (constraints.maxWidth - 30) / 4
                    : 70,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            vibrantColor,
                            vibrantColor.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected
                      ? null
                      : colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? vibrantColor
                        : colorScheme.outlineVariant.withValues(alpha: 0.5),
                    width: isSelected ? 2.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: vibrantColor.withValues(alpha: 0.45),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.water_drop,
                      size: 22,
                      color: isSelected ? Colors.white : vibrantColor,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      type,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: isSelected ? Colors.white : colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
