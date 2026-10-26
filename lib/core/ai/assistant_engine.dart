import '../../data/demo_data.dart';

List<dynamic> get workersPool =>
    [...DemoData.workers, ...DemoData.companyWorkers];

class AssistantMatch {
  final String workerId;
  final String name;
  final String reason;

  const AssistantMatch({
    required this.workerId,
    required this.name,
    required this.reason,
  });
}

const _kCategoryKeywords = <String, List<String>>{
  'تنظيف المنازل': ['تنظيف', 'نظافة', 'منزل', 'بيت', 'شقة'],
  'تنظيف عميق': ['عميق', 'تعقيم', 'بخار', 'سجاد', 'أثاث'],
  'طبخ وتنظيف': ['طبخ', 'أكل', 'طعام', 'مطبخ', 'وجبات', 'غداء', 'عشاء'],
  'رعاية الأطفال': ['طفل', 'أطفال', 'جليسة', 'رضيع', 'مربية'],
  'رعاية كبار السن': ['مسن', 'كبار', 'جدو', 'جدة', 'رعاية صحية'],
  'تنظيف مكاتب': ['مكتب', 'شركة', 'تجاري', 'إداري'],
};

List<AssistantMatch> matchWorkers(String query) {
  final q = query.trim();
  if (q.isEmpty) return const [];

  final wantedCategories = <String>[];
  _kCategoryKeywords.forEach((cat, keys) {
    if (keys.any(q.contains)) wantedCategories.add(cat);
  });

  final matches = <AssistantMatch>[];
  for (final cat in wantedCategories) {
    for (final w in workersPool) {
      if (w.category == cat || w.skills.any((s) => s.contains(cat))) {
        matches.add(AssistantMatch(
          workerId: w.id,
          name: w.name,
          reason:
              '${w.category} • ${w.rating.toStringAsFixed(1)}⭐ • \$${w.hourlyRate}/ساعة',
        ));
      }
    }
  }

  if (matches.isEmpty) {
    for (final w in workersPool) {
      if (w.name.contains(q) ||
          w.category.contains(q) ||
          w.skills.any((s) => q.contains(s))) {
        matches.add(AssistantMatch(
          workerId: w.id,
          name: w.name,
          reason:
              '${w.category} • ${w.rating.toStringAsFixed(1)}⭐ • \$${w.hourlyRate}/ساعة',
        ));
      }
    }
  }

  return matches.take(4).toList();
}

String buildFallbackReply(String query, List<AssistantMatch> matches) {
  if (query.trim().isEmpty) {
    return 'اكتب طلبك مثلاً: «أحتاج عاملة تنظيف عميق غداً» وسأقترح المناسب.';
  }
  if (matches.isEmpty) {
    return 'لم أجد عاملة مطابقة. جرّب ذكر نوع الخدمة (تنظيف، طبخ، رعاية أطفال أو مسنين).';
  }
  return 'وجدت ${matches.length} عاملات مناسبة لطلبك. اضغط على أي اقتراح لعرض ملفها والحجز.';
}
