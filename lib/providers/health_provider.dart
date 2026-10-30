import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';

class BackendHealth {
  final bool reachable;
  final DateTime? checkedAt;

  const BackendHealth({required this.reachable, this.checkedAt});
}

class BackendHealthNotifier extends StateNotifier<BackendHealth> {
  BackendHealthNotifier() : super(const BackendHealth(reachable: true)) {
    // فحص واحد عند الإقلاع بدل الاستقصاء الدوري طوال عمر التطبيق.
    check();
  }

  Future<void> check() async {
    try {
      final res = await ApiClient.get(
        '/health',
        timeout: const Duration(seconds: 6),
      );
      state = BackendHealth(
        reachable: res['status'] == 'ok',
        checkedAt: DateTime.now(),
      );
    } on ApiException {
      state = BackendHealth(reachable: false, checkedAt: DateTime.now());
    }
  }
}

final backendHealthProvider =
    StateNotifierProvider<BackendHealthNotifier, BackendHealth>(
      (ref) => BackendHealthNotifier(),
    );
