import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({super.key, required this.weeklyCounts});

  final Map<String, int> weeklyCounts;

  static const Map<String, List<Color>> dayGradients = {
    'Pzt': [Color(0xFF2979FF), Color(0xFF82B1FF)],
    'Sal': [Color(0xFF00B0FF), Color(0xFF80D8FF)],
    'Çar': [Color(0xFF00E5FF), Color(0xFF84FFFF)],
    'Per': [Color(0xFF651FFF), Color(0xFFB388FF)],
    'Cum': [Color(0xFFAA00FF), Color(0xFFEA80FC)],
    'Cmt': [Color(0xFFFF007F), Color(0xFFFF80AB)],
    'Paz': [Color(0xFFFF3D00), Color(0xFFFF9E80)],
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final days = weeklyCounts.keys.toList();
    final maxValue = weeklyCounts.values.fold<int>(0, (a, b) => a > b ? a : b);
    final double maxY = (maxValue < 6 ? 6 : maxValue + 2).toDouble();

    return BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxValue > 10 ? (maxValue / 5).ceilToDouble() : 2,
          getDrawingHorizontalLine: (value) => FlLine(
            color: colorScheme.outlineVariant.withValues(alpha: 0.35),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.6),
              width: 1.5,
            ),
            left: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.6),
              width: 1.5,
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < days.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: weeklyCounts[days[i]]!.toDouble(),
                  width: 22,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  gradient: LinearGradient(
                    colors: weeklyCounts[days[i]]! > 0
                        ? (dayGradients[days[i]] ?? [
                            colorScheme.tertiary,
                            colorScheme.primary,
                          ])
                        : [
                            colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                            colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                          ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ],
            ),
        ],
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: maxValue > 10 ? (maxValue / 5).ceilToDouble() : 2,
              getTitlesWidget: (value, meta) {
                if (value % 1 != 0) {
                  return const SizedBox.shrink();
                }
                return Text(
                  value.toInt().toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= days.length) {
                  return const SizedBox.shrink();
                }
                final dayName = days[index];
                final colors = dayGradients[dayName];
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    dayName,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colors != null ? colors[0] : colorScheme.onSurface,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final day = days[group.x.toInt()];
              return BarTooltipItem(
                '$day\n${rod.toY.toInt()} Bağış',
                TextStyle(
                  color: colorScheme.onInverseSurface,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
