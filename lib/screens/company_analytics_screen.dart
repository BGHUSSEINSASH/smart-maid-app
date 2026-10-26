import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme/app_theme.dart';
import '../data/demo_data.dart';

class CompanyAnalyticsScreen extends StatelessWidget {
  const CompanyAnalyticsScreen({super.key});

  static const weeklyRevenue = [320, 410, 280, 520, 610, 480, 700];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(title: const Text('تحليلات الأداء')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(children: [
            _Kpi(value: '36', label: 'طلبات الأسبوع', color: AppColors.primary),
            const SizedBox(width: 12),
            _Kpi(value: '94%', label: 'نسبة الإنجاز', color: AppColors.success),
            const SizedBox(width: 12),
            _Kpi(value: '4.8', label: 'رضا العملاء', color: AppColors.warning),
          ]),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.stroke),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('الإيرادات الأسبوعية (\$)',
                    style: TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 18),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 800,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(),
                        rightTitles: const AxisTitles(),
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const days = [
                                'سبت', 'أحد', 'اثنين', 'ثلاثاء',
                                'أربعاء', 'خميس', 'جمعة'
                              ];
                              final i = value.toInt().clamp(0, 6);
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(days[i],
                                    style: const TextStyle(
                                        fontSize: 9.5,
                                        color: AppColors.muted)),
                              );
                            },
                          ),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(7, (i) {
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: weeklyRevenue[i].toDouble(),
                              width: 18,
                              borderRadius: BorderRadius.circular(6),
                              color: i == DateTime.now().weekday - 1
                                  ? AppColors.primary
                                  : AppColors.primary.withValues(alpha: 0.35),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.stroke),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('توزيع الخدمات',
                    style:
                        TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 190,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 44,
                      sections: [
                        PieChartSectionData(
                            value: 45,
                            title: '45%',
                            color: AppColors.primary,
                            titleStyle: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w800)),
                        PieChartSectionData(
                            value: 25,
                            title: '25%',
                            color: AppColors.accent,
                            titleStyle: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        PieChartSectionData(
                            value: 20,
                            title: '20%',
                            color: AppColors.success,
                            titleStyle: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w800)),
                        PieChartSectionData(
                            value: 10,
                            title: '10%',
                            color: AppColors.warning,
                            titleStyle: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(spacing: 14, runSpacing: 6, children: const [
                  _Legend(color: AppColors.primary, label: 'تنظيف منازل'),
                  _Legend(color: AppColors.accent, label: 'رعاية أطفال'),
                  _Legend(color: AppColors.success, label: 'طبخ'),
                  _Legend(color: AppColors.warning, label: 'أخرى'),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...DemoData.companyWorkers.take(3).map((w) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.stroke),
                ),
                child: Row(children: [
                  CircleAvatar(
                      radius: 21, backgroundImage: NetworkImage(w.imageUrl)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(w.name,
                          style: const TextStyle(fontWeight: FontWeight.w700))),
                  const Icon(Icons.star_rounded,
                      size: 15, color: AppColors.warning),
                  Text(' ${w.rating}',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ]),
              )),
        ],
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _Kpi({required this.value, required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(children: [
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w900, fontSize: 20, color: color)),
          const SizedBox(height: 3),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: AppColors.muted)),
        ]),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 9, height: 9, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(fontSize: 11.5)),
    ]);
  }
}
