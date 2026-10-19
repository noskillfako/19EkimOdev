import 'package:flutter/material.dart';
import '../controllers/blood_donation_controller.dart';
import '../widgets/blood_bar_chart.dart';
import '../widgets/weekly_bar_chart.dart';

enum ChartMode { bloodType, weekly }

class ChartView extends StatefulWidget {
  const ChartView({super.key, required this.controller});

  final BloodDonationController controller;

  @override
  State<ChartView> createState() => _ChartViewState();
}

class _ChartViewState extends State<ChartView> {
  ChartMode _selectedMode = ChartMode.bloodType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/app_icon.png',
                width: 28,
                height: 28,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            const Text('Bağış Grafiği'),
          ],
        ),
        centerTitle: true,
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: widget.controller.themeMode,
            builder: (context, mode, _) {
              final isCurrentDark = mode == ThemeMode.dark;
              return IconButton(
                tooltip: isCurrentDark ? 'Açık Mod' : 'Karanlık Mod',
                icon: Icon(
                  isCurrentDark ? Icons.light_mode : Icons.dark_mode_outlined,
                  color: isCurrentDark ? const Color(0xFFFFD600) : null,
                ),
                onPressed: widget.controller.toggleTheme,
              );
            },
          ),
          IconButton(
            tooltip: 'Sıfırla',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              widget.controller.reset();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tüm bağış sayıları sıfırlandı.'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ValueListenableBuilder<Map<String, int>>(
          valueListenable: widget.controller.counts,
          builder: (context, counts, _) {
            final totalDonations =
                counts.values.fold<int>(0, (sum, count) => sum + count);

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Total Donations Hero Card
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [
                                const Color(0xFFD50000),
                                const Color(0xFFFF1744),
                              ]
                            : [
                                const Color(0xFFFF1744),
                                const Color(0xFFFF5252),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF1744).withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22.0,
                      vertical: 18.0,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.bloodtype,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Toplam Bağış',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$totalDonations ünite',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Chart View Switcher: Blood Types vs Weekly
                  SegmentedButton<ChartMode>(
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    segments: const [
                      ButtonSegment(
                        value: ChartMode.bloodType,
                        icon: Icon(Icons.bloodtype_outlined),
                        label: Text(
                          'Kan Grupları (8)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ButtonSegment(
                        value: ChartMode.weekly,
                        icon: Icon(Icons.calendar_view_week_outlined),
                        label: Text(
                          'Haftalık Dağılım (7 Gün)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    selected: {_selectedMode},
                    onSelectionChanged: (newSelection) {
                      setState(() => _selectedMode = newSelection.first);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Main Chart Card
                  Card(
                    elevation: 0,
                    color: isDark ? const Color(0xFF161922) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedMode == ChartMode.bloodType
                                    ? '8 Kan Grubu Dağılımı'
                                    : 'Haftalık Bağış Dağılımı',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _selectedMode == ChartMode.bloodType
                                      ? '8 Sütun'
                                      : 'Pzt - Paz (7 Gün)',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 270,
                            child: _selectedMode == ChartMode.bloodType
                                ? BloodBarChart(counts: counts)
                                : ValueListenableBuilder<Map<String, int>>(
                                    valueListenable: widget.controller.weeklyCounts,
                                    builder: (context, weeklyCounts, _) =>
                                        WeeklyBarChart(
                                      weeklyCounts: weeklyCounts,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Reset Button
                  OutlinedButton.icon(
                    onPressed: () {
                      widget.controller.reset();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tüm bağış sayıları sıfırlandı.'),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.restart_alt),
                    label: const Text(
                      'Sıfırla',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFF1744),
                      side: const BorderSide(color: Color(0xFFFF8A80), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
