import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import '../core/nav/app_nav.dart';
import '../core/theme/app_theme.dart';
import '../data/models.dart';
import '../providers/booking_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/offers_provider.dart';
import 'invoice_screen.dart';

/// الإصدار الأول يتيح الدفع النقدي عند إتمام الخدمة فقط، فلا تُجمع أي
/// بيانات بطاقة داخل التطبيق. الدفع بالبطاقة يظهر عند تهيئة مزوّد الدفع.
enum PayMethod { cash }

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key, this.bookingId});

  /// معرّف الحجز المضغوط — حتى لا يدفع المستخدم حجزاً آخر بالخطأ.
  final String? bookingId;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  PayMethod _method = PayMethod.cash;
  bool _processing = false;
  bool _paid = false;
  bool _failed = false;
  String _failReason = '';
  late final ConfettiController _confettiCtrl =
      ConfettiController(duration: const Duration(seconds: 3));

  @override
  void dispose() {
    _confettiCtrl.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    final flow = ref.read(bookingFlowProvider);
    final targetId = widget.bookingId ?? flow.bookingId;
    if (targetId == null) {
      setState(() {
        _failed = true;
        _failReason = 'لم يُسجّل الحجز على الخادم. ارجع وأعد المحاولة.';
      });
      return;
    }
    // لا حركة مالية داخل التطبيق: الحجز أُنشئ على الخادم والدفع نقداً عند
    // إتمام الخدمة. هذه الشاشة تُأكّد الإرسال فقط.
    ref.read(couponProvider.notifier).clear();
    ref.read(myBookingsProvider.notifier).confirmBooking(targetId);
    setState(() {
      _processing = false;
      _paid = true;
    });
    Haptics.success();
    _confettiCtrl.play();
  }

  @override
  Widget build(BuildContext context) {
    final totals = ref.watch(bookingTotalsProvider);
    final currency = ref.watch(currencyProvider);
    final flow = ref.watch(bookingFlowProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // مبلغ الحجز المضغوط أولاً؛ المسودة فقط عند بدء حجز جديد.
    final bookings = ref.watch(myBookingsProvider);
    BookingModel? opened;
    if (widget.bookingId != null) {
      for (final b in bookings) {
        if (b.id == widget.bookingId) opened = b;
      }
    }
    final amount = opened?.total ?? totals.total;
    final workerName = opened?.workerName ?? flow.worker?.name ?? '';

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
          title: Text(_paid ? 'تم الدفع' : (_failed ? 'فشل الدفع' : 'إتمام الدفع')),
          automaticallyImplyLeading: !_paid),
      body: _paid
          ? _buildSuccess(flow, currency)
          : _failed
              ? _buildFailed(currency)
              : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.balanceGradient,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  const Text('المبلغ المطلوب',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(currency.format(amount),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(
                    workerName.isEmpty
                        ? flow.bookingTypeLabel
                        : '$workerName • ${flow.bookingTypeLabel}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('طريقة الدفع',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text(
              'الدفع نقداً للعاملة بعد إتمام الخدمة. لا تُدخل بيانات بطاقة في التطبيق.',
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
            const SizedBox(height: 12),
            _MethodTile(
              icon: Icons.payments_rounded,
              title: 'نقداً عند إتمام الخدمة',
              subtitle: 'لا يُخصم أي مبلغ الآن',
              selected: _method == PayMethod.cash,
              onTap: () => setState(() => _method = PayMethod.cash),
            ),
          ],
        ),
      ),
      bottomSheet: !_paid
          ? Container(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 14,
                  bottom: 14 + MediaQuery.of(context).padding.bottom),
              child: SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _processing ? null : _pay,
                  icon: _processing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check_circle_outline_rounded, size: 18),
                  label: Text(_processing
                      ? 'جارٍ التأكيد...'
                      : 'تأكيد الحجز — ${currency.format(amount)}'),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildFailed(AppCurrency currency) {
    final totals = ref.read(bookingTotalsProvider);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.09),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded,
                  size: 56, color: AppColors.error),
            ),
            const SizedBox(height: 24),
            const Text('لم تتم عملية الدفع',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text(
              _failReason,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13.5, color: AppColors.muted, height: 1.6),
            ),
            const SizedBox(height: 8),
            Text('المبلغ المطلوب: ${currency.format(totals.total)}',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => setState(() {
                  _failed = false;
                  _failReason = '';
                }),
                icon: const Icon(Icons.refresh_rounded, size: 19),
                label: const Text('إعادة المحاولة'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((r) => r.isFirst),
                child: const Text('إلغاء والعودة'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccess(BookingFlowState flow, AppCurrency currency) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: const BoxDecoration(
                      color: Color(0xFFDCFCE7), shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded,
                      size: 60, color: AppColors.success),
                ),
                const SizedBox(height: 28),
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: totalsOf(flow)),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) => Text(
                    '${currency.format(v.toDouble())} 🎉',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.success),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('تم إرسال طلب الحجز',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Text(
                  'أُرسل طلبك إلى ${flow.worker?.name ?? 'العاملة'} وهو بانتظار القبول.\n'
                  'الدفع نقداً بعد إتمام الخدمة.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.muted, height: 1.6),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (_) => InvoiceScreen(
                              bookingId: widget.bookingId ?? flow.bookingId)));
                    },
                    icon: const Icon(Icons.receipt_long_rounded, size: 19),
                    label: const Text('عرض الفاتورة'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                    child: const Text('العودة للرئيسية'),
                  ),
                ),
              ],
            ),
          ),
        ),
        ConfettiWidget(
          confettiController: _confettiCtrl,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          numberOfParticles: 60,
          maxBlastForce: 24,
          minBlastForce: 8,
          gravity: 0.28,
          colors: const [
            AppColors.primary,
            AppColors.accent,
            AppColors.success,
            AppColors.warning,
          ],
        ),
      ],
    );
  }

  int totalsOf(BookingFlowState flow) =>
      ref.read(bookingTotalsProvider).total.round();
}

class _MethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _MethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Theme.of(context).brightness == Brightness.dark
                  ? AppColors.surfaceDark
                  : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.stroke,
              width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 15)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.muted)),
                ],
              ),
            ),
            Radio<bool>(
              value: true,
              groupValue: selected,
              onChanged: (_) => onTap(),
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
