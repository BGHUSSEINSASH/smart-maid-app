import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_maid_app/data/models.dart';
import 'package:smart_maid_app/providers/booking_provider.dart';
import 'package:smart_maid_app/providers/favorites_provider.dart';
import 'package:smart_maid_app/providers/loyalty_provider.dart';
import 'package:smart_maid_app/providers/offers_provider.dart';

ProviderContainer makeContainer() => ProviderContainer();

const testWorker = WorkerModel(
  id: 'w_test',
  name: 'خدمة تنظيف',
  category: 'تنظيف منزلي',
  imageUrl: '',
  rating: 0,
  reviewCount: 0,
  jobsCompleted: 0,
  hourlyRate: 25,
  location: 'بغداد',
  isAvailable: true,
  skills: [],
  about: '',
);

void main() {
  group('Booking pricing', () {
    test('daily = hourly × 8', () {
      const flow = BookingFlowState(
        worker: testWorker,
        bookingType: BookingType.daily,
      );
      expect(flow.baseTotal, 200);
    });

    test('weekly gets 10% discount', () {
      const flow = BookingFlowState(
        worker: testWorker,
        bookingType: BookingType.weekly,
      );
      expect(flow.baseTotal, closeTo(25 * 40 * 0.9, 0.01));
    });

    test('monthly gets 20% discount', () {
      const flow = BookingFlowState(
        worker: testWorker,
        bookingType: BookingType.monthly,
      );
      expect(flow.baseTotal, closeTo(25 * 176 * 0.8, 0.01));
    });

    test('extras add to total', () {
      var flow = const BookingFlowState();
      expect(flow.total, 0);
      flow = const BookingFlowState(selectedExtras: ['deep', 'iron']);
      expect(flow.extrasTotal, 30);
    });

    test('time slot parsing keeps 24h hours', () {
      expect(slotHour('10:00 صباحاً'), 10);
      expect(slotHour('12:00 ظهراً'), 12);
      expect(slotHour('02:00 مساءً'), 14);
    });
  });

  group('Coupons', () {
    test('discount math is applied to the subtotal', () {
      const coupon = CouponModel(
        code: 'SMART50',
        title: 'خصم النصف',
        description: '',
        discountPercent: 50,
        minTotalUsd: 50,
      );
      expect(discountedTotal(200, coupon), 100);
      expect(couponDiscountFor(200, coupon: coupon), 100);
      expect(discountedTotal(200, null), 200);
    });

    test('an unknown coupon code is always rejected', () async {
      // كود غير موجود: يُرفض من الخادم (404) ومن دون شبكة (خطأ اتصال) —
      // النتيجة واحدة: لا قبول للكود local.
      final container = makeContainer();
      addTearDown(container.dispose);
      final r = await container.read(couponProvider.notifier).apply('NOPE123', 200);
      expect(r.ok, isFalse);
      expect(container.read(couponProvider), isNull);
    });

    test('clear resets applied coupon', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      container.read(couponProvider.notifier).clear();
      expect(container.read(couponProvider), isNull);
    });
  });

  group('Loyalty tiers', () {
    test('tier thresholds', () {
      expect(const LoyaltyState(points: 100).tier, LoyaltyTier.bronze);
      expect(const LoyaltyState(points: 700).tier, LoyaltyTier.silver);
      expect(const LoyaltyState(points: 2000).tier, LoyaltyTier.gold);
    });

    test('a fresh account starts with no points', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      expect(container.read(loyaltyProvider).points, 0);
    });

    test('redeem fails when points insufficient', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      expect(container.read(loyaltyProvider.notifier).redeem(5), isFalse);
    });
  });

  group('Favorites', () {
    test('toggle adds and removes', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      container.read(favoritesProvider.notifier).toggle('w_test');
      expect(container.read(favoritesProvider).contains('w_test'), isTrue);
      container.read(favoritesProvider.notifier).toggle('w_test');
      expect(container.read(favoritesProvider).contains('w_test'), isFalse);
    });
  });

  group('My bookings', () {
    test('a new account starts with no bookings', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      expect(container.read(myBookingsProvider), isEmpty);
    });
  });
}
