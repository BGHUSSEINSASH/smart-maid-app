import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../data/models.dart';
import '../providers/booking_provider.dart';
import '../providers/company_provider.dart';
import '../providers/currency_provider.dart';

class CompanyBookingsScreen extends ConsumerStatefulWidget {
  const CompanyBookingsScreen({super.key});

  @override
  ConsumerState<CompanyBookingsScreen> createState() =>
      _CompanyBookingsScreenState();
}

class _CompanyBookingsScreenState extends ConsumerState<CompanyBookingsScreen> {
  void _assignSheet(BookingModel b) {
    final workers = ref.read(companyWorkersProvider);
    String? selected = workers.isNotEmpty ? workers.first.id : null;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('إسناد طلب ${b.workerName} لعاملة',
                  style: TextStyle(
                      fontSize: 16.5, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              ...workers.map((w) => RadioListTile<String>(
                    value: w.id,
                    groupValue: selected,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setSheet(() => selected = v),
                    title: Text('${w.name} — ${w.category}',
                        style: const TextStyle(fontSize: 13.5)),
                    secondary: Icon(
                      w.isAvailable
                          ? Icons.check_circle_rounded
                          : Icons.schedule_rounded,
                      size: 17,
                      color:
                          w.isAvailable ? AppColors.success : AppColors.warning,
                    ),
                  )),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: selected == null
                      ? null
                      : () {
                          final w = workers.firstWhere((w) => w.id == selected);
                          ref.read(myBookingsProvider.notifier).confirmBooking(b.id);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('أُسند الطلب إلى ${w.name} ✅'),
                              behavior: SnackBarBehavior.floating));
                        },
                  icon: const Icon(Icons.assignment_turned_in_rounded, size: 18),
                  label: const Text('تأكيد الإسناد'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookings = ref.watch(myBookingsProvider);
    final currency = ref.watch(currencyProvider);
    final incoming = bookings
        .where((b) =>
            b.status == BookingStatus.pending ||
            b.status == BookingStatus.confirmed)
        .toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(title: Text('الطلبات الواردة (${incoming.length})')),
      body: incoming.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_rounded, size: 64, color: AppColors.textHint),
                  const SizedBox(height: 12),
                  const Text('لا توجد طلبات جديدة'),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: incoming.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final b = incoming[i];
                final pending = b.status == BookingStatus.pending;
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.stroke),
                  ),
                  child: Column(children: [
                    Row(children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundImage: NetworkImage(b.workerImage),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(b.service,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800)),
                              Text(
                                '${DateFormat('d MMM', 'ar').format(b.date)} • ${b.timeSlot}',
                                style: const TextStyle(
                                    fontSize: 11.5, color: AppColors.muted),
                              ),
                            ]),
                      ),
                      Text(currency.format(b.total),
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                    ]),
                    if (pending) ...[
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => ref
                                .read(myBookingsProvider.notifier)
                                .cancelBooking(b.id),
                            style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error),
                            icon: const Icon(Icons.close_rounded, size: 16),
                            label: const Text('رفض'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () => _assignSheet(b),
                            icon:
                                const Icon(Icons.person_search_rounded, size: 16),
                            label: const Text('قبول وإسناد'),
                          ),
                        ),
                      ]),
                    ] else
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text('مؤكد ✓',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary)),
                          ),
                        ),
                      ),
                  ]),
                );
              },
            ),
    );
  }
}
