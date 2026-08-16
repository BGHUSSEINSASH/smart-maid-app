import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models.dart';
import '../data/demo_data.dart';

// ── Booking flow (single booking being created) ────────────────────────────

class BookingFlowState {
  final WorkerModel? worker;
  final DateTime? date;
  final String? timeSlot;
  final bool isPaid;
  final BookingType bookingType;
  final List<String> selectedExtras;

  const BookingFlowState({
    this.worker,
    this.date,
    this.timeSlot,
    this.isPaid = false,
    this.bookingType = BookingType.daily,
    this.selectedExtras = const [],
  });

  BookingFlowState copyWith({
    WorkerModel? worker,
    DateTime? date,
    String? timeSlot,
    bool? isPaid,
    BookingType? bookingType,
    List<String>? selectedExtras,
  }) => BookingFlowState(
    worker: worker ?? this.worker,
    date: date ?? this.date,
    timeSlot: timeSlot ?? this.timeSlot,
    isPaid: isPaid ?? this.isPaid,
    bookingType: bookingType ?? this.bookingType,
    selectedExtras: selectedExtras ?? this.selectedExtras,
  );

  double get baseTotal {
    final h = worker?.hourlyRate ?? 0;
    switch (bookingType) {
      case BookingType.daily:
        return h * 8;
      case BookingType.weekly:
        return h * 8 * 5 * 0.9;
      case BookingType.monthly:
        return h * 8 * 22 * 0.8;
      case BookingType.annual:
        return h * 8 * 22 * 11 * 0.7;
    }
  }

  double get extrasTotal => DemoData.extraServices
      .where((e) => selectedExtras.contains(e.id))
      .fold(0.0, (sum, e) => sum + e.priceUsd);

  double get total => baseTotal + extrasTotal;

  String get bookingTypeLabel {
    switch (bookingType) {
      case BookingType.daily:
        return 'يومي';
      case BookingType.weekly:
        return 'أسبوعي';
      case BookingType.monthly:
        return 'شهري';
      case BookingType.annual:
        return 'سنوي';
    }
  }
}

class BookingFlowNotifier extends StateNotifier<BookingFlowState> {
  BookingFlowNotifier() : super(const BookingFlowState());

  void selectWorker(WorkerModel w) => state = state.copyWith(worker: w);
  void selectDate(DateTime d) => state = state.copyWith(date: d);
  void selectTimeSlot(String t) => state = state.copyWith(timeSlot: t);
  void setBookingType(BookingType t) => state = state.copyWith(bookingType: t);
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
  void reset() => state = const BookingFlowState();
}

final bookingFlowProvider =
    StateNotifierProvider<BookingFlowNotifier, BookingFlowState>(
      (ref) => BookingFlowNotifier(),
    );

// ── My bookings list ────────────────────────────────────────────────────────

class MyBookingsNotifier extends StateNotifier<List<BookingModel>> {
  MyBookingsNotifier() : super(DemoData.bookings);

  void add(BookingModel b) => state = [b, ...state];

  void cancelBooking(String id) {
    state = state
        .map(
          (b) => b.id == id ? b.copyWith(status: BookingStatus.cancelled) : b,
        )
        .toList();
  }
}

final myBookingsProvider =
    StateNotifierProvider<MyBookingsNotifier, List<BookingModel>>(
      (ref) => MyBookingsNotifier(),
    );
