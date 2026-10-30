import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import 'auth_provider.dart';

enum WalletTxType { topup, payment, withdrawal, earning, refund }

class WalletTransaction {
  final String id;
  final String title;
  final double amountUsd;
  final WalletTxType type;
  final DateTime date;

  const WalletTransaction({
    required this.id,
    required this.title,
    required this.amountUsd,
    required this.type,
    required this.date,
  });

  bool get isCredit =>
      type == WalletTxType.topup ||
      type == WalletTxType.earning ||
      type == WalletTxType.refund;
}

class WalletState {
  final double balanceUsd;
  final List<WalletTransaction> transactions;
  final bool loading;
  final String? error;

  const WalletState({
    this.balanceUsd = 0,
    this.transactions = const [],
    this.loading = false,
    this.error,
  });

  WalletState copyWith({
    double? balanceUsd,
    List<WalletTransaction>? transactions,
    bool? loading,
    String? error,
    bool clearError = false,
  }) => WalletState(
    balanceUsd: balanceUsd ?? this.balanceUsd,
    transactions: transactions ?? this.transactions,
    loading: loading ?? this.loading,
    error: clearError ? null : (error ?? this.error),
  );
}

/// المحفظة تُقرأ من الخادم فقط. لا يوجد في التطبيق أي كود يزيد الرصيد
/// أو يسحبه: الشحن والسحب يحتاجان مزوّد دفع فعلي (غير مفعّل في هذا الإصدار).
class WalletNotifier extends StateNotifier<WalletState> {
  WalletNotifier(this._ref) : super(const WalletState());

  final Ref _ref;

  Future<void> refresh() async {
    if (_ref.read(authProvider).user == null) {
      state = const WalletState();
      return;
    }
    state = state.copyWith(loading: true, clearError: true);
    try {
      final res = await ApiClient.get('/wallet');
      final list = (res['transactions'] as List?) ?? const [];
      state = WalletState(
        balanceUsd: (res['balance'] as num?)?.toDouble() ?? 0,
        transactions: list.whereType<Map<String, dynamic>>().map((json) {
          return WalletTransaction(
            id: json['id']?.toString() ?? '',
            title: json['title']?.toString() ?? '',
            amountUsd: (json['amount'] as num?)?.toDouble() ?? 0,
            type: WalletTxType.values.firstWhere(
              (t) => t.name == json['type'],
              orElse: () => WalletTxType.payment,
            ),
            date: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
                DateTime.now(),
          );
        }).toList(),
      );
    } on ApiException catch (e) {
      state = state.copyWith(loading: false, error: e.message);
    }
  }
}

final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>(
  (ref) => WalletNotifier(ref),
);
