import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/adaptive.dart';
import '../data/models.dart';
import '../providers/booking_provider.dart';
import '../widgets/app_image.dart';
import 'assistant_screen.dart';
import 'conversation_screen.dart';

/// المحادثات مربوطة بحجوزات المستخدم الفعلية: لا محادثات تجريبية ولا دعم
/// وهمي. أي حجز يفتح محادثة مع مقدّم الخدمة.
class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref
        .watch(myBookingsProvider)
        .where((b) => b.status != BookingStatus.cancelled)
        .toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;

    return Scaffold(
      appBar: AppBar(title: const Text('الرسائل')),
      body: RefreshIndicator(
        onRefresh: () async {
          await refreshBookings(ref);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _AssistantTile(onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AssistantScreen()));
            }),
            const SizedBox(height: 16),
            if (bookings.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Column(
                  children: [
                    Icon(Icons.chat_bubble_outline_rounded,
                        size: 64, color: AppColors.textHint),
                    const SizedBox(height: 12),
                    const Text('لا توجد محادثات بعد',
                        style: TextStyle(color: AppColors.muted)),
                    const SizedBox(height: 6),
                    const Text(
                      'تُفتح المحادثة مع مقدّم الخدمة بعد إنشاء حجز.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              )
            else
              ...bookings.map((b) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.stroke),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    leading: AppAvatar(
                      url: b.workerImage,
                      radius: 26,
                      label: b.workerName,
                    ),
                    title: Text(b.workerName,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text(
                      '${b.service} • ${DateFormat('d/M').format(b.date)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12.5, color: AppColors.muted),
                    ),
                    trailing: const Icon(Icons.chevron_left_rounded),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConversationScreen(
                          bookingId: b.id,
                          title: b.workerName,
                          avatarUrl: b.workerImage,
                        ),
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _AssistantTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AssistantTile({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: context.heroSoftGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text('🔍', style: TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('المساعد',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15)),
                  Text('يساعدك في اختيار الخدمة المناسبة',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_left_rounded, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}
