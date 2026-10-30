import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../data/repository.dart';

// ---------------- Settlements ----------------

class SettlementsState {
  final List<SettlementRecord> records;
  final bool loading;
  final String? error;

  const SettlementsState({
    this.records = const [],
    this.loading = false,
    this.error,
  });
}

class SettlementsNotifier extends StateNotifier<SettlementsState> {
  SettlementsNotifier() : super(const SettlementsState()) {
    _load();
  }

  Future<void> _load() async {
    state = const SettlementsState(loading: true);
    try {
      final records = await TrustRepository.settlementHistory();
      if (!mounted) return;
      state = SettlementsState(records: records);
    } on ApiException catch (e) {
      if (!mounted) return;
      state = SettlementsState(error: e.message);
    }
  }

  Future<void> refresh() => _load();
}

final settlementsProvider =
    StateNotifierProvider<SettlementsNotifier, SettlementsState>(
      (ref) => SettlementsNotifier(),
    );
