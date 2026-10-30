import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../core/storage/local_store.dart';
import '../data/models.dart';
import '../data/catalog.dart';
import 'auth_provider.dart';
import 'offers_provider.dart';

class BookingFlowState {
  final WorkerModel? worker;
  final DateTime? date;
  final String? timeSlot;
  final bool isPaid;
  final BookingType bookingType;
  final List<String> selectedExtras;
  final String? paymentIntentId;
  final String? bookingId;
  final String bookingStatus;
  final String paymentStatus;
  final String notes;
  final bool expressFee;
  final bool needTools;

  const BookingFlowState({
    this.worker,
    this.date,
    this.timeSlot,
    this.isPaid = false,
    this.bookingType = BookingType.daily,
    this.selectedExtras = const [],
    this.paymentIntentId,
    this.bookingId,
    this.bookingStatus = 'draft',
    this.paymentStatus = 'pending',
    this.notes = '',
    this.expressFee = false,
    this.needTools = false,
  });

  BookingFlowState copyWith({
    WorkerModel? worker,
    DateTime? date,
    String? timeSlot,
    bool? isPaid,
    BookingType? bookingType,
    List<String>? selectedExtras,
    String? paymentIntentId,
    String? bookingId,
    String? bookingStatus,
    String? paymentStatus,
    String? notes,
    bool? expressFee,
    bool? needTools,
  }) {
    return BookingFlowState(
      worker: worker ?? this.worker,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      isPaid: isPaid ?? this.isPaid,
      bookingType: bookingType ?? this.bookingType,
      selectedExtras: selectedExtras ?? this.selectedExtras,
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
      bookingId: bookingId ?? this.bookingId,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
      expressFee: expressFee ?? this.expressFee,
      needTools: needTools ?? this.needTools,
    );
  }

  bool get hasBooking => bookingId != null || worker != null;

  double get baseTotal {
    final h = worker?.hourlyRate ?? 0;
    switch (bookingType) {
      case BookingType.daily:
        return h * 8;
      case BookingType.weekly:
        return h * 8 * 5 * 0.9;
      case BookingType.monthly:
        return h * 8 * 22 * 0.8;
    }
  }

  double get extrasTotal => Catalog.extraServices
      .where((e) => selectedExtras.contains(e.id))
      .fold(0.0, (sum, e) => sum + e.priceUsd);

  static const double _expressFee = 5.0;
  static const double _toolsFee = 10.0;

  double get expressFeeTotal => expressFee ? _expressFee : 0.0;
  double get toolsFeeTotal => needTools ? _toolsFee : 0.0;

  double get total => baseTotal + extrasTotal + expressFeeTotal + toolsFeeTotal;

  String get bookingTypeLabel {
    switch (bookingType) {
      case BookingType.daily:
        return 'يومي';
      case BookingType.weekly:
        return 'أسبوعي';
      case BookingType.monthly:
        return 'شهري';
    }
  }
}

class BookingFlowNotifier extends StateNotifier<BookingFlowState> {
  BookingFlowNotifier() : super(const BookingFlowState());

  void selectWorker(WorkerModel w) => state = state.copyWith(worker: w);
  void selectDate(DateTime d) => state = state.copyWith(date: d);
  void selectTimeSlot(String t) => state = state.copyWith(timeSlot: t);
  void setBookingType(BookingType t) => state = state.copyWith(bookingType: t);
  void setNotes(String n) => state = state.copyWith(notes: n);
  void toggleExpressFee() => state = state.copyWith(expressFee: !state.expressFee);
  void toggleNeedTools() => state = state.copyWith(needTools: !state.needTools);
  void toggleExtra(String id) {
    final list = List<String>.from(state.selectedExtras);
    if (list.contains(id)) {
      list.remove(id);
    } else {
      list.add(id);
    }
    state = state.copyWith(selectedExtras: list);
  }

  void pay() => state = state.copyWith(isPaid: true);
  void setPaymentIntent(String id) =>
      state = state.copyWith(paymentIntentId: id, paymentStatus: 'pending');

  void setFromBooking(Map<String, dynamic> booking) {
    final id = booking['id']?.toString();
    final status = booking['status']?.toString() ?? state.bookingStatus;
    final payment = booking['paymentStatus']?.toString() ?? state.paymentStatus;
    state = state.copyWith(
      bookingId: id ?? state.bookingId,
      bookingStatus: status,
      paymentStatus: payment,
    );
  }

  void setStatus({
    required String bookingStatus,
    required String paymentStatus,
  }) {
    state = state.copyWith(
      bookingStatus: bookingStatus,
      paymentStatus: paymentStatus,
    );
  }

  void reset() => state = const BookingFlowState();
}

final bookingFlowProvider =
    StateNotifierProvider<BookingFlowNotifier, BookingFlowState>(
      (ref) => BookingFlowNotifier(),
    );

class MyBookingsNotifier extends StateNotifier<List<BookingModel>> {
  // حساب جديد بلا حجوزات وهمية — الحجوزات تظهر بعد إنشائها فعلاً.
  MyBookingsNotifier() : super(LocalStore.bookingsCache ?? const []);

  void add(BookingModel b) {
    state = [b, ...state];
    LocalStore.persistBookings(state);
  }

  /// يستبدل الكاش المحلي بقائمة الخادم (الكاش للعرض دون اتصال فقط).
  void replaceAll(List<BookingModel> list) {
    state = list;
    LocalStore.persistBookings(state);
  }

  void cancelBooking(String id) => _setStatus(id, BookingStatus.cancelled);

  void completeBooking(String id) => _setStatus(id, BookingStatus.completed);

  void confirmBooking(String id) => _setStatus(id, BookingStatus.confirmed);

  void startBooking(String id) => _setStatus(id, BookingStatus.inProgress);

  void markPaid(String id) {
    state = state
        .map((b) =>
            b.id == id ? b.copyWith(paymentStatus: PaymentStatus.paid) : b)
        .toList();
    LocalStore.persistBookings(state);
  }

  void updateBooking(BookingModel updated) {
    state = state.map((b) => b.id == updated.id ? updated : b).toList();
    LocalStore.persistBookings(state);
  }

  void _setStatus(String id, BookingStatus s) {
    state = state
        .map((b) => b.id == id ? b.copyWith(status: s) : b)
        .toList();
    LocalStore.persistBookings(state);
  }
}

final myBookingsProvider =
    StateNotifierProvider<MyBookingsNotifier, List<BookingModel>>(
      (ref) => MyBookingsNotifier(),
    );

class BookingTotals {
  final double subtotal;
  final double discount;
  final double total;
  const BookingTotals({
    required this.subtotal,
    required this.discount,
    required this.total,
  });
}

final bookingTotalsProvider = Provider<BookingTotals>((ref) {
  final flow = ref.watch(bookingFlowProvider);
  final coupon = ref.watch(couponProvider);
  final subtotal = flow.total;
  final discount = coupon?.discountFor(subtotal) ?? 0;
  return BookingTotals(
    subtotal: subtotal,
    discount: discount,
    total: (subtotal - discount).clamp(0, double.infinity),
  );
});

typedef BookingResult = ({bool ok, String bookingId, String? error});

/// يحوّل خانة الوقت العربية ("10:00 صباحاً") إلى ساعة 24.
int slotHour(String slot) {
  final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(slot);
  if (match == null) return 9;
  var hour = int.tryParse(match.group(1)!) ?? 9;
  final isPm = slot.contains('مساء');
  final isNoon = slot.contains('ظهراً');
  if (isNoon && hour < 12) hour = 12;
  if (isPm && hour < 12) hour += 12;
  return hour.clamp(0, 23);
}

/// ينشئ الحجز على الخادم فعلياً. لا يوجد أي نجاح محلي وهمي:
/// عند الفشل يُعاد الخطأ ليُعرض للمستخدم.
Future<BookingResult> confirmCurrentBooking(WidgetRef ref) async {
  final flow = ref.read(bookingFlowProvider);
  final totals = ref.read(bookingTotalsProvider);
  if (!flow.hasBooking || flow.date == null || flow.timeSlot == null) {
    return (ok: false, bookingId: '', error: 'أكمل بيانات الحجز أولاً');
  }
  final worker = flow.worker!;
  final scheduled = DateTime(
    flow.date!.year,
    flow.date!.month,
    flow.date!.day,
    slotHour(flow.timeSlot!),
  );

  try {
    final res = await ApiClient.post('/bookings', {
      'workerId': worker.id,
      'contractType': switch (flow.bookingType) {
        BookingType.daily => 'daily',
        BookingType.weekly => 'weekly',
        BookingType.monthly => 'monthly',
      },
      'hours': switch (flow.bookingType) {
        BookingType.daily => 8,
        BookingType.weekly => 8,
        BookingType.monthly => 8,
      },
      'scheduledFor': scheduled.toIso8601String(),
      'notes': flow.notes,
      'paymentMethod': 'cash',
    });

    final id = res['id']?.toString() ?? '';
    if (id.isEmpty) {
      return (ok: false, bookingId: '', error: 'استجابة غير صالحة من الخادم');
    }

    final booking = BookingModel(
      id: id,
      workerId: worker.id,
      workerName: worker.name,
      workerImage: worker.imageUrl,
      userId: ref.read(authProvider).user?.id ?? '',
      date: scheduled,
      timeSlot: flow.timeSlot!,
      service: worker.category,
      total: (res['total'] as num?)?.toDouble() ?? totals.total,
      status: BookingStatus.pending,
      paymentStatus: PaymentStatus.unpaid,
      notes: flow.notes,
    );
    ref.read(myBookingsProvider.notifier).add(booking);
    ref.read(bookingFlowProvider.notifier).setFromBooking({
      'id': id,
      'status': 'pending',
      'paymentStatus': 'unpaid',
    });
    return (ok: true, bookingId: id, error: null);
  } on ApiException catch (e) {
    return (ok: false, bookingId: '', error: e.message);
  }
}

/// يحمل حجوزات المستخدم من الخادم ويستبدل الكاش المحلي.
Future<String?> refreshBookings(WidgetRef ref) async {
  try {
    final res = await ApiClient.get('/bookings');
    final list = (res['bookings'] as List?) ?? const [];
    final bookings = list
        .whereType<Map<String, dynamic>>()
        .map(bookingFromApi)
        .toList();
    ref.read(myBookingsProvider.notifier).replaceAll(bookings);
    return null;
  } on ApiException catch (e) {
    return e.message;
  }
}

BookingModel bookingFromApi(Map<String, dynamic> json) {
  final worker = Catalog.byId(json['workerId']?.toString() ?? '');
  final scheduled =
      DateTime.tryParse(json['scheduledFor']?.toString() ?? '') ??
          DateTime.now();
  final status = switch (json['status']?.toString()) {
    'accepted' => BookingStatus.confirmed,
    'completed' => BookingStatus.completed,
    'cancelled' || 'rejected' => BookingStatus.cancelled,
    _ => BookingStatus.pending,
  };
  final payment = switch (json['paymentStatus']?.toString()) {
    'paid' => PaymentStatus.paid,
    'refunded' => PaymentStatus.refunded,
    _ => PaymentStatus.unpaid,
  };
  return BookingModel(
    id: json['id']?.toString() ?? '',
    workerId: json['workerId']?.toString() ?? '',
    workerName: worker?.name ?? 'خدمة منزلية',
    workerImage: worker?.imageUrl ?? '',
    userId: json['userId']?.toString() ?? '',
    date: scheduled,
    timeSlot: '${scheduled.hour.toString().padLeft(2, '0')}:'
        '${scheduled.minute.toString().padLeft(2, '0')}',
    service: worker?.category ?? '',
    total: (json['total'] as num?)?.toDouble() ?? 0,
    status: status,
    paymentStatus: payment,
    notes: json['notes']?.toString() ?? '',
  );
}
