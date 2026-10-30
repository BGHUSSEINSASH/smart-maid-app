import '../core/api/api_client.dart';
import 'models.dart';

/// كتالوج المنصة الفعلي — يُحمَّل من الخادم، ويبدأ فارغاً.
///
/// لا توجد بيانات تجريبية هنا: لا وجوه أشخاص حقيقيين، ولا تقييمات ولا
/// أعداد عاملات مُختلقة. أي شاشة تعرض هذا الكتالوج تعرض ما يخدمه الخادم.
class Catalog {
  Catalog._();

  static List<WorkerModel> workers = const [];
  static List<WorkerModel> companyWorkers = const [];
  static List<CompanyModel> companies = const [];

  static bool loaded = false;
  static String? loadError;

  static WorkerModel? byId(String id) {
    for (final worker in [...workers, ...companyWorkers]) {
      if (worker.id == id) return worker;
    }
    return null;
  }

  static Future<void> hydrate() async {
    try {
      final items = await ApiClient.getList('/workers/search');
      workers = items
          .whereType<Map<String, dynamic>>()
          .map(_workerFromJson)
          .toList();
      loaded = true;
      loadError = null;
    } on ApiException catch (e) {
      loadError = e.message;
      loaded = false;
    } catch (_) {
      loadError = 'تعذر تحميل الخدمات';
      loaded = false;
    }
  }

  static WorkerModel _workerFromJson(Map<String, dynamic> json) => WorkerModel(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    category: json['category']?.toString() ?? '',
    imageUrl: '',
    rating: (json['rating'] as num?)?.toDouble() ?? 0,
    reviewCount: (json['reviewsCount'] as num?)?.toInt() ?? 0,
    jobsCompleted: 0,
    hourlyRate: (json['hourlyRate'] as num?)?.toDouble() ?? 0,
    location: json['city']?.toString() ?? '',
    isAvailable: json['available'] == true,
    skills: const [],
    about: json['bio']?.toString() ?? '',
  );

  /// خدمات إضافية اختيارية بأسعار معلنة في التطبيق.
  static const extraServices = <ExtraService>[
    ExtraService(id: 'deep', name: 'تنظيف عميق', icon: '🧹', priceUsd: 20),
    ExtraService(id: 'laundry', name: 'غسيل ملابس', icon: '👕', priceUsd: 15),
    ExtraService(id: 'iron', name: 'كي الملابس', icon: '👔', priceUsd: 10),
    ExtraService(id: 'cooking', name: 'طبخ', icon: '🍳', priceUsd: 25),
    ExtraService(id: 'baby', name: 'رعاية أطفال', icon: '👶', priceUsd: 20),
    ExtraService(id: 'shopping', name: 'تسوق ومشتريات', icon: '🛒', priceUsd: 15),
    ExtraService(id: 'elderly', name: 'رعاية مسنين', icon: '👴', priceUsd: 20),
    ExtraService(id: 'plants', name: 'رعاية النباتات', icon: '🌱', priceUsd: 8),
  ];

  static const categories = [
    ('🏠', 'تنظيف'),
    ('👶', 'أطفال'),
    ('🍳', 'طبخ'),
    ('👴', 'مسنون'),
    ('🧹', 'عميق'),
    ('🏢', 'مكاتب'),
  ];

  static const timeSlots = [
    '08:00 صباحاً',
    '09:00 صباحاً',
    '10:00 صباحاً',
    '11:00 صباحاً',
    '12:00 ظهراً',
    '01:00 مساءً',
    '02:00 مساءً',
    '03:00 مساءً',
    '04:00 مساءً',
    '05:00 مساءً',
  ];
}
