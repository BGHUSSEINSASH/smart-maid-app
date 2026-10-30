import '../core/api/api_client.dart';
import '../core/session/session_store.dart';

/// خدمات الخادم (المستحقات، النزاعات، المساعد) — بلا أي بديل تجريبي:
/// كل فشل يُعاد كرسالة خطأ للمستخدم.
class TrustRepository {
  TrustRepository._();

  // ---------- Settlements ----------

  static Future<List<SettlementRecord>> settlementHistory() async {
    await _auth();
    final res = await ApiClient.get('/settlements/history');
    final list = (res['records'] as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(SettlementRecord.fromJson)
        .toList();
  }

  // ---------- AI Assistant ----------

  /// المساعد يعمل فقط عند تهيئة مزوّد النموذج على الخادم.
  /// يرمي [ApiException] بالرسالة المناسبة إن لم يكن متاحاً.
  static Future<String> askAi(String message) async {
    await _auth();
    final res = await ApiClient.post(
      '/ai/chat',
      {'message': message},
      timeout: const Duration(seconds: 25),
    );
    final reply = res['reply']?.toString();
    if (reply == null || reply.trim().isEmpty) {
      throw const ApiException('لا يوجد رد من المساعد حالياً');
    }
    return reply;
  }

  // ---------- Disputes ----------

  static Future<void> openDispute({
    required String bookingId,
    required String category,
    required String subject,
    required String detail,
  }) async {
    await _auth();
    await ApiClient.post('/disputes', {
      'bookingId': bookingId,
      'category': category,
      'subject': subject,
      'detail': detail,
    });
  }

  // ---------- SOS ----------

  /// تنبيه الطوارئ. الخادم هو مصدر الحقيقة: إن لم تكن قناة الاستقبال مفعّلة
  /// يردّ برقي 503 برسالة صريحة، فنعِد رسالته كما هي بدل ادّعاء أن فريقاً
  /// استلم التنبيه (مبدأ «لا ادعاءات غير مدعومة» في مراجعة المتاجر).
  static Future<SosResult> sendSos({
    required String location,
    required String message,
  }) async {
    await _auth();
    try {
      final res = await ApiClient.post('/sos', {
        'location': location,
        'message': message,
      });
      return SosResult(res['message']?.toString() ?? 'تم إرسال التنبيه');
    } on ApiException catch (e) {
      return SosResult(e.message);
    }
  }

  static Future<void> _auth() async {
    final token = await SessionStore.loadToken();
    if (token != null) ApiClient.setToken(token);
  }
}

class SosResult {
  final String message;
  const SosResult(this.message);
}

class SettlementRecord {
  final String month;
  final double totalEarnings;
  final double platformFee;
  final double netPayout;
  final int bookingsCount;
  final bool settled;

  const SettlementRecord({
    required this.month,
    required this.totalEarnings,
    required this.platformFee,
    required this.netPayout,
    required this.bookingsCount,
    this.settled = true,
  });

  factory SettlementRecord.fromJson(Map<String, dynamic> j) => SettlementRecord(
    month: j['month']?.toString() ?? '',
    totalEarnings: (j['totalEarnings'] as num?)?.toDouble() ?? 0,
    platformFee: (j['platformFee'] as num?)?.toDouble() ?? 0,
    netPayout: (j['netPayout'] as num?)?.toDouble() ?? 0,
    bookingsCount: (j['bookingsCount'] as num?)?.toInt() ?? 0,
    settled: j['settled'] == true,
  );
}
