import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';

class CouponModel {
  final String code;
  final String title;
  final String description;
  final double discountPercent;
  final double minTotalUsd;
  final String emoji;

  const CouponModel({
    required this.code,
    required this.title,
    required this.description,
    required this.discountPercent,
    this.minTotalUsd = 0,
    this.emoji = '🎁',
  });

  double discountFor(double total) =>
      total >= minTotalUsd ? total * discountPercent / 100 : 0;
}

/// العروض المنشورة — عرض فقط. التحقق من أي كوبون (منها أكواد النقاط
/// LOYAL…) يتم على الخادم عبر POST /offers/apply وليس هنا.
const kDemoCoupons = <CouponModel>[
  CouponModel(
    code: 'SMART50',
    title: 'خصم النصف',
    description: 'خصم 50% على أول حجز لك (حد أدنى \$50)',
    discountPercent: 50,
    minTotalUsd: 50,
    emoji: '🎉',
  ),
  CouponModel(
    code: 'SAVE15',
    title: 'وفّر 15%',
    description: 'خصم 15% على أي حجز (حد أدنى \$30)',
    discountPercent: 15,
    minTotalUsd: 30,
    emoji: '💰',
  ),
  CouponModel(
    code: 'MONTHLY10',
    title: 'باقة الشهر',
    description: 'خصم 10% على الحجوزات الشهرية (حد أدنى \$200)',
    discountPercent: 10,
    minTotalUsd: 200,
    emoji: '📅',
  ),
];

class AppliedCoupon {
  final CouponModel coupon;
  final double savedUsd;

  const AppliedCoupon({required this.coupon, required this.savedUsd});
}

class CouponNotifier extends StateNotifier<CouponModel?> {
  CouponNotifier() : super(null);

  void clear() => state = null;

  /// التحقق من الكوبون على الخادم — يشمل كوبونات النقاط (LOYAL…) وشروطها
  /// (حد أدنى، حجز أول، ملكية الكوبون). لا قبول محلي للكود.
  Future<({bool ok, String message})> apply(
      String rawCode, double total) async {
    final code = rawCode.trim().toUpperCase();
    if (code.isEmpty) {
      return (ok: false, message: 'أدخل كود الخصم');
    }
    try {
      final res = await ApiClient.post('/offers/apply', {
        'code': code,
        'total': total,
      });
      final percent = (res['discountPercent'] as num?)?.toDouble() ?? 0;
      final title = res['title']?.toString() ?? 'خصم';
      state = CouponModel(
        code: code,
        title: title,
        description: title,
        discountPercent: percent,
        minTotalUsd: 0,
      );
      final discount = (res['discount'] as num?)?.toDouble() ?? 0;
      return (
        ok: true,
        message: 'تم تطبيق خصم ${discount.toStringAsFixed(0)}%',
      );
    } on ApiException catch (e) {
      final msg = e.statusCode == 404
          ? 'كود الخصم غير صحيح أو منتهي'
          : e.message;
      return (ok: false, message: msg);
    }
  }
}

final couponProvider = StateNotifierProvider<CouponNotifier, CouponModel?>(
  (ref) => CouponNotifier(),
);

double discountedTotal(double subtotal, CouponModel? coupon) =>
    coupon == null ? subtotal : (subtotal - coupon.discountFor(subtotal)).clamp(0, double.infinity);

double couponDiscountFor(double subtotal, {CouponModel? coupon}) =>
    coupon?.discountFor(subtotal) ?? 0;

final usedCouponFlagProvider = StateProvider<bool>((ref) => false);
