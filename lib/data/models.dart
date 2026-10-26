import '../features/auth/domain/app_role.dart';

export '../features/auth/domain/app_role.dart';

enum BookingType { daily, weekly, monthly, annual }

class ExtraService {
  final String id;
  final String name;
  final String icon;
  final double priceUsd;

  const ExtraService({
    required this.id,
    required this.name,
    required this.icon,
    required this.priceUsd,
  });
}

class AppUser {
  final String id;
  final String name;
  final String email;
  final String imageUrl;
  final AppRole role;
  final String phone;
  final String location;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.role,
    this.phone = '',
    this.location = '',
  });
}

class WorkerModel {
  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final int jobsCompleted;
  final double hourlyRate;
  final String location;
  final bool isAvailable;
  final List<String> skills;
  final String about;
  final String? companyId; // null = independent worker
  final bool verified;

  const WorkerModel({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.jobsCompleted,
    required this.hourlyRate,
    required this.location,
    required this.isAvailable,
    required this.skills,
    required this.about,
    this.companyId,
    this.verified = false,
  });

  String get image => imageUrl;
  int get experienceYears => (jobsCompleted / 28).ceil();
}

class CompanyModel {
  final String id;
  final String name;
  final String logoUrl;
  final String description;
  final String location;
  final bool isPro;
  final double rating;
  final int workerCount;
  final List<String> specialties;
  final String contactEmail;
  final String contactPhone;
  static const double commissionRate = 0.20; // 20% platform commission

  const CompanyModel({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.description,
    required this.location,
    this.isPro = false,
    required this.rating,
    required this.workerCount,
    required this.specialties,
    required this.contactEmail,
    required this.contactPhone,
  });

  /// Net company revenue after 20% platform commission
  double netRevenue(double totalBookingValue) =>
      totalBookingValue * (1 - commissionRate);

  /// Platform commission from a booking
  double platformCommission(double totalBookingValue) =>
      totalBookingValue * commissionRate;

  CompanyModel copyWith({
    String? id,
    String? name,
    String? logoUrl,
    String? description,
    String? location,
    bool? isPro,
    double? rating,
    int? workerCount,
    List<String>? specialties,
    String? contactEmail,
    String? contactPhone,
  }) => CompanyModel(
    id: id ?? this.id,
    name: name ?? this.name,
    logoUrl: logoUrl ?? this.logoUrl,
    description: description ?? this.description,
    location: location ?? this.location,
    isPro: isPro ?? this.isPro,
    rating: rating ?? this.rating,
    workerCount: workerCount ?? this.workerCount,
    specialties: specialties ?? this.specialties,
    contactEmail: contactEmail ?? this.contactEmail,
    contactPhone: contactPhone ?? this.contactPhone,
  );
}

class InvoiceData {
  final String invoiceNumber;
  final DateTime date;
  final String customerName;
  final String workerName;
  final String workerImage;
  final String companyName; // empty if independent worker
  final String service;
  final String bookingType;
  final String duration;
  final String timeSlot;
  final double baseTotal;
  final double extrasTotal;
  final double total;
  final List<String> extras;

  const InvoiceData({
    required this.invoiceNumber,
    required this.date,
    required this.customerName,
    required this.workerName,
    required this.workerImage,
    this.companyName = '',
    required this.service,
    required this.bookingType,
    required this.duration,
    required this.timeSlot,
    required this.baseTotal,
    required this.extrasTotal,
    required this.total,
    required this.extras,
  });
}

enum BookingStatus { pending, confirmed, inProgress, completed, cancelled }

enum PaymentStatus { unpaid, held, paid, refunded }

class BookingModel {
  final String id;
  final String workerId;
  final String workerName;
  final String workerImage;
  final String userId;
  final DateTime date;
  final String timeSlot;
  final String service;
  final double total;
  final BookingStatus status;
  final PaymentStatus paymentStatus;
  final String notes;
  final String cancelReason;
  final bool expressFee;
  final bool needTools;
  final DateTime? arrivalTime;
  final List<String> beforeAfterPhotos;

  const BookingModel({
    required this.id,
    required this.workerId,
    required this.workerName,
    required this.workerImage,
    required this.userId,
    required this.date,
    required this.timeSlot,
    required this.service,
    required this.total,
    required this.status,
    required this.paymentStatus,
    this.notes = '',
    this.cancelReason = '',
    this.expressFee = false,
    this.needTools = false,
    this.arrivalTime,
    this.beforeAfterPhotos = const [],
  });

  BookingModel copyWith({
    String? id,
    String? workerId,
    String? workerName,
    String? workerImage,
    String? userId,
    DateTime? date,
    String? timeSlot,
    String? service,
    double? total,
    BookingStatus? status,
    PaymentStatus? paymentStatus,
    String? notes,
    String? cancelReason,
    bool? expressFee,
    bool? needTools,
    DateTime? arrivalTime,
    List<String>? beforeAfterPhotos,
  }) => BookingModel(
    id: id ?? this.id,
    workerId: workerId ?? this.workerId,
    workerName: workerName ?? this.workerName,
    workerImage: workerImage ?? this.workerImage,
    userId: userId ?? this.userId,
    date: date ?? this.date,
    timeSlot: timeSlot ?? this.timeSlot,
    service: service ?? this.service,
    total: total ?? this.total,
    status: status ?? this.status,
    paymentStatus: paymentStatus ?? this.paymentStatus,
    notes: notes ?? this.notes,
    cancelReason: cancelReason ?? this.cancelReason,
    expressFee: expressFee ?? this.expressFee,
    needTools: needTools ?? this.needTools,
    arrivalTime: arrivalTime ?? this.arrivalTime,
    beforeAfterPhotos: beforeAfterPhotos ?? this.beforeAfterPhotos,
  );
}

class ReviewModel {
  final String id;
  final String reviewerName;
  final String reviewerImage;
  final double rating;
  final String comment;
  final DateTime date;
  final List<String> photos;

  const ReviewModel({
    required this.id,
    required this.reviewerName,
    required this.reviewerImage,
    required this.rating,
    required this.comment,
    required this.date,
    this.photos = const [],
  });
}

class MessageModel {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.isRead = true,
  });
}

/// Commission constants
class AppCommission {
  static const double platformRate = 0.20; // 20% net for platform (admin)
  static const double companyRate = 0.80; // 80% to company
}

class Conversation {
  final String id;
  final WorkerModel worker;
  final List<MessageModel> messages;

  const Conversation({
    required this.id,
    required this.worker,
    required this.messages,
  });

  MessageModel? get lastMessage => messages.isNotEmpty ? messages.last : null;
  int get unreadCount => messages.where((m) => !m.isRead).length;
}
