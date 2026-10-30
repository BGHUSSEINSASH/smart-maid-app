import '../../../core/api/api_client.dart';
import '../../../data/models.dart';

/// نتيجة عملية مصادقة موحّدة.
class AuthResult {
  final AppUser? user;
  final String? token;
  final String? error;

  const AuthResult({this.user, this.token, this.error});

  bool get ok => user != null && error == null;

  factory AuthResult.success(AppUser user, {String? token}) =>
      AuthResult(user: user, token: token);

  factory AuthResult.failure(String error) => AuthResult(error: error);
}

abstract class AuthService {
  Future<AuthResult> signInWithEmail(String email, String password);
  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
    required AppRole role,
    String referralCode,
  });
  Future<void> deleteAccount();
}

/// مصادقة حقيقية عبر الـ API فقط: لا حسابات مضمّنة في التطبيق،
/// ولا تسجيل دخول بدون شبكة، ولا رموز ثابتة.
class ApiAuthService implements AuthService {
  ApiAuthService();

  AppRole _roleFromString(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'worker':
        return AppRole.worker;
      case 'admin':
        return AppRole.admin;
      case 'company':
        return AppRole.company;
      default:
        return AppRole.customer;
    }
  }

  AppUser _userFromJson(Map<String, dynamic> json) {
    final role = _roleFromString(json['role']?.toString());
    return AppUser(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      imageUrl: '',
      role: role,
      phone: json['phone']?.toString() ?? '',
    );
  }

  @override
  Future<AuthResult> signInWithEmail(String email, String password) async {
    if (password.length < 8) {
      return AuthResult.failure('كلمة المرور قصيرة جداً');
    }
    try {
      final res = await ApiClient.post('/auth/login', {
        'email': email.trim(),
        'password': password,
      });
      final userJson = res['user'];
      if (userJson is! Map<String, dynamic> || res['token'] == null) {
        return AuthResult.failure('استجابة غير صالحة من الخادم');
      }
      return AuthResult.success(
        _userFromJson(userJson),
        token: res['token'].toString(),
      );
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        return AuthResult.failure('البريد الإلكتروني أو كلمة المرور غير صحيحة');
      }
      return AuthResult.failure(e.message);
    }
  }

  @override
  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
    required AppRole role,
    String referralCode = '',
  }) async {
    if (name.trim().length < 2) {
      return AuthResult.failure('الرجاء إدخال الاسم كاملاً');
    }
    if (password.length < 8) {
      return AuthResult.failure('كلمة المرور يجب أن تكون 8 أحرف على الأقل');
    }
    try {
      final res = await ApiClient.post('/auth/register', {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        'role': role.name,
      });
      final userJson = res['user'];
      if (userJson is! Map<String, dynamic> || res['token'] == null) {
        return AuthResult.failure('استجابة غير صالحة من الخادم');
      }
      final token = res['token'].toString();
      // كود الإحالة يُطبَّق على الخادم بعد إنشاء الحساب مباشرة؛
      // فشله (كود غير صحيح مثلاً) لا يمنع إنشاء الحساب.
      final code = referralCode.trim();
      if (code.isNotEmpty) {
        final previous = ApiClient.token;
        ApiClient.setToken(token);
        try {
          await ApiClient.post('/referrals/apply', {'code': code});
        } on ApiException {
          // كود غير صالح أو منتهي — نتجاهل ونكمل التسجيل.
        }
        ApiClient.setToken(previous);
      }
      return AuthResult.success(
        _userFromJson(userJson),
        token: token,
      );
    } on ApiException catch (e) {
      if (e.statusCode == 409) {
        return AuthResult.failure('هذا البريد مسجّل مسبقاً، سجّل الدخول');
      }
      return AuthResult.failure(e.message);
    }
  }

  @override
  Future<void> deleteAccount() async {
    await ApiClient.delete('/auth/me');
  }

  Future<AppUser> refreshProfile() async {
    final res = await ApiClient.get('/auth/me');
    return _userFromJson(res);
  }
}
