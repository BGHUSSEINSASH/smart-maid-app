import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../data/catalog.dart';
import '../data/models.dart';
import 'booking_provider.dart';

/// ملف العاملة وطلباتها الواردة — من الخادم فقط.
class WorkerProfile {
  final String id;
  final String name;
  final String city;
  final String category;
  final double hourlyRate;
  final bool available;

  const WorkerProfile({
    required this.id,
    required this.name,
    required this.city,
    required this.category,
    required this.hourlyRate,
    required this.available,
  });

  factory WorkerProfile.fromJson(Map<String, dynamic> json) => WorkerProfile(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    city: json['city']?.toString() ?? '',
    category: json['category']?.toString() ?? '',
    hourlyRate: (json['hourlyRate'] as num?)?.toDouble() ?? 0,
    available: json['available'] == true,
  );
}

class WorkerState {
  final WorkerProfile? profile;
  final List<BookingModel> incoming;
  final bool loading;
  final String? error;

  const WorkerState({
    this.profile,
    this.incoming = const [],
    this.loading = false,
    this.error,
  });
}

class WorkerNotifier extends StateNotifier<WorkerState> {
  WorkerNotifier() : super(const WorkerState());

  Future<void> load() async {
    state = const WorkerState(loading: true);
    try {
      final profile = await ApiClient.get('/workers/me');
      final res = await ApiClient.get('/bookings/worker/incoming');
      final list = (res['bookings'] as List?) ?? const [];
      state = WorkerState(
        profile: WorkerProfile.fromJson(profile),
        incoming: list.whereType<Map<String, dynamic>>().map(bookingFromApi).toList(),
      );
    } on ApiException catch (e) {
      state = WorkerState(error: e.message);
    }
  }

  Future<String?> setAvailable(bool value) async {
    try {
      final profile = await ApiClient.patch('/workers/me', {'available': value});
      state = WorkerState(
        profile: WorkerProfile.fromJson(profile),
        incoming: state.incoming,
      );
      await Catalog.hydrate();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<String?> setStatus(String bookingId, String status) async {
    try {
      await ApiClient.patch('/bookings/$bookingId/status', {'status': status});
      await load();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }
}

final workerProvider = StateNotifierProvider<WorkerNotifier, WorkerState>(
  (ref) => WorkerNotifier(),
);
