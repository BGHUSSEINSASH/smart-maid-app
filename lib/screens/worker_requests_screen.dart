import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../data/models.dart';
import '../providers/currency_provider.dart';
import '../providers/worker_provider.dart';

/// الطلبات الواردة للعاملة — تُقرأ من الخادم وتتغير حالته هناك.
class WorkerRequestsScreen extends ConsumerStatefulWidget {
  const WorkerRequestsScreen({super.key});

  @override
  ConsumerState<WorkerRequestsScreen> createState() =>
      _WorkerRequestsScreenState();
}

class _WorkerRequestsScreenState extends ConsumerState<WorkerRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => ref.read(workerProvider.notifier).load());
  }

  Future<void> _setStatus(BookingModel b, String status) async {
    final error =
        await ref.read(workerProvider.notifier).setStatus(b.id, status);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error ??
          (status == 'accepted' ? 'تم قبول الطلب' : 'تم رفض الطلب')),
      behavior: SnackBarBehavior.floating,
      backgroundColor: error == null ? AppColors.success : AppColors.error,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workerProvider);
    final currency = ref.watch(currencyProvider);
    final pending =
        state.incoming.where((b) => b.status == BookingStatus.pending).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(title: Text('الطلبات الواردة (${pending.length})')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(workerProvider.notifier).load(),
        child: _body(pending, currency, isDark),
      ),
    );
  }

  Widget _body(List<BookingModel> pending, AppCurrency currency, bool isDark) {
    if (state.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 80),
          Text(state.error!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton(
              onPressed: () => ref.read(workerProvider.notifier).load(),
              child: const Text('إعادة المحاولة'),
            ),
          ),
        ],
      );
    }
    if (pending.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 80),
          Icon(Icons.mark_email_read_rounded,
              size: 64, color: AppColors.textHint),
          const SizedBox(height: 12),
          const Center(child: Text('لا طلبات معلقة حالياً')),
        ],
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: pending.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final b = pending[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.stroke),
          ),
          child: Column(children: [
            Row(children: [
              const CircleAvatar(
                radius: 22,
                child: Icon(Icons.person_rounded, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.service,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 14)),
                    Text(
                      '${DateFormat('EEE d MMM', 'ar').format(b.date)} • ${b.timeSlot}',
                      style: const TextStyle(
                          fontSize: 11.5, color: AppColors.muted),
                    ),
                    if (b.notes.isNotEmpty)
                      Text(b.notes,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.muted)),
                  ],
                ),
              ),
              Text(currency.format(b.total),
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.success,
                      fontSize: 13)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _setStatus(b, 'rejected'),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error),
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: const Text('رفض'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _setStatus(b, 'accepted'),
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('قبول'),
                ),
              ),
            ]),
          ]),
        );
      },
    );
  }

  WorkerState get state => ref.watch(workerProvider);
}
