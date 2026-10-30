import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// خطأ API مقروء — يُعرض للمستخدم بدل تمرير فشل صامت.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  const ApiException(this.message, {this.statusCode, this.code});

  bool get isNetwork => statusCode == null;
  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}

/// عميل HTTP واحد لكل نداءات الخادم.
///
/// لا يوجد أي رجوع صامت إلى بيانات تجريبية: كل فشل يرمي [ApiException]
/// لتظهر حالة خطأ حقيقية مع زر «إعادة المحاولة».
class ApiClient {
  ApiClient._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://smaidapi.vercel.app/api/v1',
  );

  static String? _token;
  static void setToken(String? token) => _token = token;
  static String? get token => _token;

  static Future<Map<String, dynamic>> get(
    String path, {
    Duration timeout = const Duration(seconds: 10),
  }) async =>
      _asMap(await _send('GET', path, timeout: timeout));

  /// لمسارات تُعيد مصفوفة JSON.
  static Future<List<dynamic>> getList(
    String path, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final value = await _send('GET', path, timeout: timeout);
    if (value is List) return value;
    if (value is Map && value['workers'] is List) {
      return value['workers'] as List;
    }
    return const [];
  }

  static Map<String, dynamic> _asMap(dynamic value) =>
      value is Map<String, dynamic> ? value : const {};

  static Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    Duration timeout = const Duration(seconds: 15),
  }) async =>
      _asMap(await _send('POST', path, body: body, timeout: timeout));

  static Future<Map<String, dynamic>> patch(
    String path,
    Map<String, dynamic> body, {
    Duration timeout = const Duration(seconds: 15),
  }) async =>
      _asMap(await _send('PATCH', path, body: body, timeout: timeout));

  static Future<Map<String, dynamic>> delete(
    String path, {
    Duration timeout = const Duration(seconds: 15),
  }) async =>
      _asMap(await _send('DELETE', path, timeout: timeout));

  static Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final uri = _uri(path);
    http.Response res;
    try {
      final request = http.Request(method, uri)
        ..headers.addAll(_headers());
      if (body != null) request.body = jsonEncode(body);
      final streamed = await request.send().timeout(timeout);
      res = await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw const ApiException(
        'انتهت مهلة الاتصال بالخادم. تحقق من الإنترنت وأعد المحاولة.',
      );
    } catch (_) {
      throw const ApiException(
        'تعذر الاتصال بالخادم. تحقق من الإنترنت وأعد المحاولة.',
      );
    }

    dynamic decoded;
    if (res.bodyBytes.isNotEmpty) {
      try {
        decoded = jsonDecode(utf8.decode(res.bodyBytes));
      } catch (_) {
        decoded = null;
      }
    }
    final map = decoded is Map<String, dynamic> ? decoded : null;

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return decoded ?? const <String, dynamic>{};
    }

    throw ApiException(
      _messageFor(map, res.statusCode),
      statusCode: res.statusCode,
      code: map?['code']?.toString(),
    );
  }

  static String _messageFor(Map<String, dynamic>? body, int status) {
    final raw = body?['message'] ?? body?['error'];
    if (raw is String && raw.trim().isNotEmpty && !_isMachineSentence(raw)) {
      return raw;
    }
    switch (status) {
      case 400:
        return 'البيانات غير صحيحة. راجع الحقول وأعد المحاولة.';
      case 401:
        return 'انتهت الجلسة. سجّل الدخول من جديد.';
      case 403:
        return 'ليست لديك صلاحية لهذا الإجراء.';
      case 404:
        return 'العنصر غير موجود.';
      case 409:
        return 'لا يمكن تنفيذ الإجراء في الحالة الحالية.';
      case 429:
        return 'محاولات كثيرة. انتظر قليلاً ثم أعد المحاولة.';
      case 503:
        return 'الخدمة غير متاحة حالياً.';
      default:
        if (status >= 500) return 'خطأ في الخادم. أعد المحاولة لاحقاً.';
        return 'تعذر إتمام الطلب ($status).';
    }
  }

  /// رسائل الخادم الإنجليزية العامة لا تُعرض للمستخدم العربي.
  static bool _isMachineSentence(String value) =>
      RegExp(r'^[A-Za-z ]+$').hasMatch(value.trim());

  static Uri _uri(String path) {
    final base = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    final clean = path.replaceFirst(RegExp(r'^/+'), '');
    return Uri.parse('$base$clean');
  }

  static Map<String, String> _headers() => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };
}
