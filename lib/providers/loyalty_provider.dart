import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/local_store.dart';

enum LoyaltyTier { bronze, silver, gold }

extension LoyaltyTierX on LoyaltyTier {
  String get label => switch (this) {
        LoyaltyTier.bronze => 'برونزي',
        LoyaltyTier.silver => 'فضي',
        LoyaltyTier.gold => 'ذهبي',
      };

  String get emoji => switch (this) {
        LoyaltyTier.bronze => '🥉',
        LoyaltyTier.silver => '🥈',
        LoyaltyTier.gold => '🥇',
      };

  double get earnRate => switch (this) {
        LoyaltyTier.bronze => 1.0,
        LoyaltyTier.silver => 1.25,
        LoyaltyTier.gold => 1.5,
      };
}

class LoyaltyState {
  final int points;
  final List<({String title, int points, DateTime date})> history;

  const LoyaltyState({
    this.points = 1250,
    this.history = const [],
  });
  LoyaltyTier get tier {
    if (points >= 1500) return LoyaltyTier.gold;
    if (points >= 500) return LoyaltyTier.silver;
    return LoyaltyTier.bronze;
  }

  LoyaltyTier get nextTier => tier == LoyaltyTier.gold
      ? LoyaltyTier.gold
      : tier == LoyaltyTier.silver
          ? LoyaltyTier.gold
          : LoyaltyTier.silver;

  int get nextTierAt => nextTier == LoyaltyTier.silver ? 500 : 1500;

  double get progressToNext =>
      nextTier == tier ? 1 : (points / nextTierAt).clamp(0.0, 1.0);

  static const int pointsPerUsdRedeem = 20;

  int pointsForDiscount(double discountUsd) =>
      (discountUsd * pointsPerUsdRedeem).round();

  LoyaltyState copyWith({
    int? points,
    List<({String title, int points, DateTime date})>? history,
  }) =>
      LoyaltyState(
        points: points ?? this.points,
        history: history ?? this.history,
      );
}

class LoyaltyNotifier extends StateNotifier<LoyaltyState> {
  LoyaltyNotifier()
      : super(LoyaltyState(
          // حساب جديد بلا نقاط ولا سجل وهمي.
          points: LocalStore.loyaltyPointsCache ?? 0,
          history: LocalStore.loyaltyHistCache ?? const [],
        ));

  void earn(int basePoints, String title) {
    final earned = (basePoints * state.tier.earnRate).round();
    final next = state.copyWith(
      points: state.points + earned,
      history: [
        (title: title, points: earned, date: DateTime.now()),
        ...state.history,
      ],
    );
    state = next;
    LocalStore.persistLoyalty(next.points, next.history);
  }

  bool redeem(double discountUsd) {
    final cost = state.pointsForDiscount(discountUsd);
    if (discountUsd <= 0 || cost > state.points) return false;
    final next = state.copyWith(
      points: state.points - cost,
      history: [
        (
          title: 'استبدال بخصم \$${discountUsd.toStringAsFixed(0)}',
          points: -cost,
          date: DateTime.now(),
        ),
        ...state.history,
      ],
    );
    state = next;
    LocalStore.persistLoyalty(next.points, next.history);
    return true;
  }

  /// مزامنة الرصيد مع رصيد الخادم بعد عملية استبدال حقيقية.
  void setPoints(int points) {
    final next = state.copyWith(points: points.clamp(0, 1 << 31));
    state = next;
    LocalStore.persistLoyalty(next.points, next.history);
  }
}

final loyaltyProvider = StateNotifierProvider<LoyaltyNotifier, LoyaltyState>(
  (ref) => LoyaltyNotifier(),
);

class ReferralState {
  final String code;
  final int invitedCount;
  final double earnedUsd;

  const ReferralState({
    this.code = '',
    this.invitedCount = 0,
    this.earnedUsd = 0,
  });
}

final referralProvider = Provider<ReferralState>((ref) => const ReferralState());

