import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/adaptive.dart';
import '../data/models.dart';
import '../providers/auth_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/wallet_provider.dart';
import '../providers/worker_provider.dart';
import '../widgets/app_image.dart';

/// لوحة العاملة: ملفها الحقيقي، حالة توفّرها، وطلباتها الواردة من الخادم.
class WorkerDashboardScreen extends ConsumerStatefulWidget {
  const WorkerDashboardScreen({super.key});

  @override
  ConsumerState<WorkerDashboardScreen> createState() =>
      _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends ConsumerState<WorkerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(workerProvider.notifier).load();
      ref.read(walletProvider.notifier).refresh();
    });
  }

  Future<void> _toggleAvailable(bool value) async {
    final error =
        await ref.read(workerProvider.notifier).setAvailable(value);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _finishJob(BookingModel b) async {
    final done = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد إنهاء المهمة'),
        content: const Text(
          'سيُسجَّل الحجز كمكتمل، ويُحسب المبلغ نقداً بعد إتمام الخدمة.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('تأكيد الإنهاء'),
          ),
        ],
      ),
    );
    if (done != true) return;
    final error =
        await ref.read(workerProvider.notifier).setStatus(b.id, 'completed');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error ?? 'تم تسجيل إنهاء المهمة'),
      backgroundColor: error == null ? AppColors.success : AppColors.error,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workerProvider);
    final user = ref.watch(authProvider).user;
    final currency = ref.watch(currencyProvider);
    final wallet = ref.watch(walletProvider);
    final profile = state.profile;
    final active = state.incoming
        .where((b) =>
            b.status == BookingStatus.confirmed || b.status == BookingStatus.pending)
        .toList();
    final completed = state.incoming
        .where((b) => b.status == BookingStatus.completed)
        .toList();
    final earnings = completed.fold<double>(0, (sum, b) => sum + b.total);

    return Scaffold(
      appBar: AppBar(title: const Text('لوحتي')),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(workerProvider.notifier).load();
          await ref.read(walletProvider.notifier).refresh();
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(children: [
                AppAvatar(
                  url: '',
                  radius: 30,
                  label: profile?.name ?? user?.name ?? '',
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مرحباً، ${(profile?.name ?? user?.name ?? '').split(' ').first} 👋',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 17),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile == null
                            ? 'أكمل ملفك لتصلك الطلبات'
                            : '${profile.category} • ${profile.city}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
            if (state.error != null) ...[
              const SizedBox(height: 12),
              Text(state.error!,
                  style: const TextStyle(color: AppColors.error, fontSize: 12)),
            ],
            if (profile != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: profile.available
                      ? AppColors.success.withValues(alpha: 0.09)
                      : AppColors.warning.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: profile.available
                          ? AppColors.success
                          : AppColors.warning,
                      width: 1.3),
                ),
                child: Row(children: [
                  Icon(
                      profile.available
                          ? Icons.wifi_tethering_rounded
                          : Icons.do_not_disturb_on_rounded,
                      color: profile.available
                          ? AppColors.success
                          : AppColors.warning,
                      size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      profile.available
                          ? 'أنت متاحة لاستقبال الطلبات الآن'
                          : 'وضع الإيقاف المؤقت',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                          color: profile.available
                              ? AppColors.success
                              : AppColors.warning),
                    ),
                  ),
                  Switch(
                    value: profile.available,
                    onChanged: _toggleAvailable,
                  ),
                ]),
              ),
            ],
            const SizedBox(height: 18),
            Row(children: [
              _Stat(
                  value: currency.format(earnings),
                  label: 'مكتمل (${completed.length})',
                  color: AppColors.primary,
                  icon: Icons.trending_up_rounded),
              const SizedBox(width: 12),
              _Stat(
                  value: currency.format(wallet.balanceUsd),
                  label: 'رصيد المحفظة',
                  color: AppColors.success,
                  icon: Icons.wallet_rounded),
            ]),
            const SizedBox(height: 22),
            Text('طلبات نشطة (${active.length})',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: context.ink)),
            const SizedBox(height: 10),
            if (active.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text('لا توجد طلبات نشطة.',
                    style: TextStyle(color: context.mutedText)),
              ),
            ...active.map((b) {
              final confirmed = b.status == BookingStatus.confirmed;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.stroke),
                ),
                child: Column(children: [
                  Row(children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                          confirmed
                              ? Icons.check_circle_outline_rounded
                              : Icons.hourglass_empty_rounded,
                          size: 21,
                          color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${b.service} — ${b.timeSlot}',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.5,
                                  color: context.ink)),
                          if (b.notes.isNotEmpty)
                            Text('📝 ${b.notes}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 11, color: context.mutedText)),
                        ],
                      ),
                    ),
                    Text(currency.format(b.total),
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.success,
                            fontSize: 13)),
                  ]),
                  const SizedBox(height: 10),
                  if (confirmed)
                    SizedBox(
                      height: 38,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 38),
                            backgroundColor: AppColors.success,
                            tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap),
                        onPressed: () => _finishJob(b),
                        icon: const Icon(Icons.task_alt_rounded, size: 17),
                        label: const Text('إنهاء المهمة',
                            style: TextStyle(fontSize: 12.5)),
                      ),
                    )
                  else
                    const Text(
                      'بانتظار قبولك من تبويب الطلبات الواردة.',
                      style: TextStyle(fontSize: 11.5, color: AppColors.muted),
                    ),
                ]),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;
  const _Stat({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 19, color: color),
            const SizedBox(height: 8),
            FittedBox(
                child: Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 17))),
            Text(label,
                style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}
