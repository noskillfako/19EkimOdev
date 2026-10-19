import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BloodBarChart extends StatelessWidget {
  const BloodBarChart({super.key, required this.counts});

  final Map<String, int> counts;

  static const Map<String, List<Color>> typeGradients = {
    'A+': [Color(0xFFFF1744), Color(0xFFFF5252)],
    'A-': [Color(0xFFE91E63), Color(0xFFFF4081)],
    'B+': [Color(0xFF8E24AA), Color(0xFFBA68C8)],
    'B-': [Color(0xFF673AB7), Color(0xFF9575CD)],
    'AB+': [Color(0xFFFF6D00), Color(0xFFFFAB40)],
    'AB-': [Color(0xFFFF3D00), Color(0xFFFF6E40)],
    '0+': [Color(0xFF00BFA5), Color(0xFF64FFDA)],
    '0-': [Color(0xFF00B0FF), Color(0xFF80D8FF)],
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final types = counts.keys.toList();
    final maxValue = counts.values.fold<int>(0, (a, b) => a > b ? a : b);
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
          for (var i = 0; i < types.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: counts[types[i]]!.toDouble(),
                  width: 20,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  gradient: LinearGradient(
                    colors: counts[types[i]]! > 0
                        ? (typeGradients[types[i]] ?? [
                            colorScheme.primary,
                            colorScheme.tertiary,
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
                if (index < 0 || index >= types.length) {
                  return const SizedBox.shrink();
                }
                final typeName = types[index];
                final colors = typeGradients[typeName];
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    typeName,
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
              final type = types[group.x.toInt()];
              return BarTooltipItem(
                '$type\n${rod.toY.toInt()} Bağış',
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
