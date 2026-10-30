import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/adaptive.dart';
import '../data/models.dart';
import '../providers/booking_provider.dart';
import '../providers/currency_provider.dart';
import '../widgets/app_image.dart';
import 'conversation_screen.dart';

class ActiveBookingScreen extends ConsumerStatefulWidget {
  final BookingModel booking;
  const ActiveBookingScreen({super.key, required this.booking});

  @override
  ConsumerState<ActiveBookingScreen> createState() =>
      _ActiveBookingScreenState();
}

class _ActiveBookingScreenState extends ConsumerState<ActiveBookingScreen>
    with SingleTickerProviderStateMixin {
  BookingModel? _live;
  late AnimationController _pulseCtrl;

  BookingModel get b => _live ?? widget.booking;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _sync() {
    final list = ref.read(myBookingsProvider);
    final found = list.where((x) => x.id == widget.booking.id).firstOrNull;
    if (found != null && mounted) setState(() => _live = found);
  }

  String get _statusLabel => switch (b.status) {
        BookingStatus.pending => 'بانتظار قبول مقدّم الخدمة',
        BookingStatus.confirmed => 'تم قبول الحجز',
        BookingStatus.inProgress => 'الخدمة جارية الآن',
        BookingStatus.completed => 'تم إتمام الخدمة',
        BookingStatus.cancelled => 'حجز ملغى',
      };

  IconData get _statusIcon => switch (b.status) {
        BookingStatus.pending => Icons.hourglass_empty_rounded,
        BookingStatus.confirmed => Icons.check_circle_outline_rounded,
        BookingStatus.inProgress => Icons.cleaning_services_rounded,
        BookingStatus.completed => Icons.verified_rounded,
        BookingStatus.cancelled => Icons.cancel_outlined,
      };

  // انعكاس حقيقي لحالة الحجز بدل عدّاد وهمي.
  double get _statusProgress {
    switch (b.status) {
      case BookingStatus.pending:
        return 0.15;
      case BookingStatus.confirmed:
        return 0.4;
      case BookingStatus.inProgress:
        return 0.75;
      case BookingStatus.completed:
        return 1.0;
      case BookingStatus.cancelled:
        return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = _statusProgress;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('حالة الحجز'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Worker info card
          SurfaceCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                AppAvatar(url: b.workerImage, radius: 30, label: b.workerName),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.workerName,
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                              color: context.ink)),
                      Text(b.service,
                          style: TextStyle(
                              fontSize: 13, color: context.mutedText)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // حالة الحجز — لا تتبّع موقع وهمي.
          SurfaceCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_statusIcon, color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _statusLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: context.ink,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppColors.stroke,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'الموعد المجدول: ${b.timeSlot} — ${b.date.day}/${b.date.month}/${b.date.year}',
                  style: TextStyle(fontSize: 12.5, color: context.mutedText),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Booking details
          SurfaceCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _detailRow(Icons.calendar_month_rounded, 'التاريخ',
                    '${b.date.day}/${b.date.month}/${b.date.year}'),
                _detailRow(Icons.schedule_rounded, 'الوقت', b.timeSlot),
                _detailRow(Icons.badge_rounded, 'الخدمة', b.service),
                _detailRow(Icons.payments_rounded, 'الإجمالي',
                    currency.format(b.total)),
                if (b.expressFee)
                  _detailRow(Icons.speed_rounded, 'خدمة سريعة', '+\$5'),
                if (b.needTools)
                  _detailRow(Icons.build_rounded, 'أدوات التنظيف', '+\$10'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // لا تُعرض إجراءات العاملة في حساب العميل.
          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ConversationScreen(
                      bookingId: b.id,
                      title: b.workerName,
                      avatarUrl: b.workerImage,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
              label: const Text('محادثة مقدّم الخدمة',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('العودة للتفاصيل'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(fontSize: 13, color: context.mutedText)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: context.ink)),
        ],
      ),
    );
  }
}
