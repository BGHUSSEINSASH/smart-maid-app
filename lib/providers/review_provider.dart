import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../data/models.dart';

/// تقييمات حقيقية فقط — تُحمَّل من الخادم لكل عاملة، وتبدأ فارغة.
class ReviewsNotifier extends StateNotifier<Map<String, List<ReviewModel>>> {
  ReviewsNotifier() : super(const {});

  List<ReviewModel> forWorker(String workerId) =>
      state[workerId] ?? const [];

  double averageFor(String workerId) {
    final list = forWorker(workerId);
    if (list.isEmpty) return 0;
    return list.fold(0.0, (s, r) => s + r.rating) / list.length;
  }

  Future<String?> load(String workerId) async {
    try {
      final res = await ApiClient.get('/reviews/worker/$workerId');
      final list = (res['reviews'] as List?) ?? const [];
      final parsed = list.whereType<Map<String, dynamic>>().map((json) {
        return ReviewModel(
          id: json['id']?.toString() ?? '',
          reviewerName: '',
          reviewerImage: '',
          rating: (json['rating'] as num?)?.toDouble() ?? 0,
          comment: json['comment']?.toString() ?? '',
          date: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
              DateTime.now(),
        );
      }).toList();
      state = {...state, workerId: parsed};
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  /// إضافة تقييم تتم على الخادم بعد حجز مكتمل، ثم نُحدّث القائمة محلياً.
  void addReview({
    required String workerId,
    required String reviewerName,
    required String reviewerImage,
    required double rating,
    required String comment,
  }) {
    final review = ReviewModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      reviewerName: reviewerName,
      reviewerImage: reviewerImage,
      rating: rating,
      comment: comment,
      date: DateTime.now(),
    );
    state = {
      ...state,
      workerId: [review, ...forWorker(workerId)],
    };
  }
}

final reviewsProvider =
    StateNotifierProvider<ReviewsNotifier, Map<String, List<ReviewModel>>>(
      (ref) => ReviewsNotifier(),
    );

final reviewsCountProvider = Provider<int>((ref) {
  return ref
      .watch(reviewsProvider)
      .values
      .fold(0, (sum, list) => sum + list.length);
});
