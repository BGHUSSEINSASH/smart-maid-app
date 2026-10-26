import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/adaptive.dart';
import '../providers/currency_provider.dart';
import '../providers/company_provider.dart';

class CompanyBillingScreen extends ConsumerWidget {
  const CompanyBillingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);
    final stats = companyStatsForId('co1');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Simulated monthly settlements
    final settlements = List.generate(6, (i) {
      final month = DateTime.now().subtract(Duration(days: 30 * i));
      final revenue = (stats.totalRevenue * (0.8 + i * 0.05)).roundToDouble();
      final commission = revenue * 0.20;
      final net = revenue - commission;
      return _Settlement(
        month: month,
        totalRevenue: revenue,
        commission: commission,
        net: net,
        bookingsCount: (stats.totalBookings * (0.7 + i * 0.08)).round(),
      );
    });

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('فوترة الشركة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded),
            tooltip: 'تصدير PDF',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('جاري إنشاء كشف الحساب PDF...'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Summary card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                const Text('ملخص الفوترة',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                Text(currency.format(stats.totalRevenue),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                const Text('إجمالي الإيرادات',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                        child: _BillingStat(
                            label: 'عمولة المنصة (20%)',
                            value: currency.format(stats.platformCommission))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _BillingStat(
                            label: 'صافي الشركة',
                            value: currency.format(stats.netRevenue))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Monthly settlements
          Text('التسويات الشهرية',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textPrimary)),
          const SizedBox(height: 12),

          ...settlements.map((s) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.stroke),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            DateFormat('MMMM yyyy', 'ar').format(s.month),
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                color: AppColors.primary),
                          ),
                        ),
                        const Spacer(),
                        Text('${s.bookingsCount} حجز',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.muted)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _BillingRow('الإيرادات', currency.format(s.totalRevenue)),
                    _BillingRow('عمولة المنصة',
                        '- ${currency.format(s.commission)}'),
                    const Divider(height: 16),
                    _BillingRow('الصافي', currency.format(s.net),
                        bold: true, color: AppColors.success),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _Settlement {
  final DateTime month;
  final double totalRevenue;
  final double commission;
  final double net;
  final int bookingsCount;

  const _Settlement({
    required this.month,
    required this.totalRevenue,
    required this.commission,
    required this.net,
    required this.bookingsCount,
  });
}

class _BillingStat extends StatelessWidget {
  final String label;
  final String value;
  const _BillingStat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: [
        FittedBox(
            child: Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15))),
        const SizedBox(height: 3),
        Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75), fontSize: 10.5)),
      ]),
    );
  }
}

class _BillingRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? color;
  const _BillingRow(this.label, this.value, {this.bold = false, this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: bold ? 14 : 13,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
                  color: color ?? AppColors.muted)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: bold ? 16 : 13,
                  fontWeight: FontWeight.w800,
                  color: color ?? AppColors.textPrimary)),
        ],
      ),
    );
  }
}
