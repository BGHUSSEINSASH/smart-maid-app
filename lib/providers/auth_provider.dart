import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../core/session/session_store.dart';
import '../core/storage/local_store.dart';
import '../data/models.dart';
import '../features/auth/data/auth_service.dart';
import 'audit_log_provider.dart';

class AuthState {
  final AppUser? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  bool get isLoggedIn => user != null;

  AuthState copyWith({AppUser? user, bool? isLoading, String? error}) =>
      AuthState(
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

final authServiceProvider = Provider<AuthService>((ref) => ApiAuthService());

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _service;
  final Ref _ref;
  AuthNotifier(this._service, this._ref) : super(const AuthState());

  Future<void> restoreSession() async {
    final token = await SessionStore.loadToken();
    final user = await SessionStore.loadUser();
    if (token != null && user != null) {
      ApiClient.setToken(token);
      // نتأكد أن الجلسة ما زالت صالحة على الخادم قبل عرض البيانات.
      try {
        final fresh = await (ApiAuthService()).refreshProfile();
        await SessionStore.saveUser(fresh);
        state = AuthState(user: fresh);
        return;
      } on ApiException catch (e) {
        if (e.isUnauthorized) {
          await SessionStore.clear();
          ApiClient.setToken(null);
          return;
        }
        // فشل شبكة: نُبقي الجلسة المحفوظة ونعرض بيانات المستخدم المخزّنة.
      }
      state = AuthState(user: user);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    final res = await _service.signInWithEmail(email, password);
    return _apply(res);
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required AppRole role,
    String referralCode = '',
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final res = await _service.signUp(
      name: name,
      email: email,
      password: password,
      role: role,
      referralCode: referralCode,
    );
    return _apply(res);
  }

  Future<bool> _apply(AuthResult res) async {
    if (res.ok) {
      ApiClient.setToken(res.token);
      await SessionStore.saveUser(res.user!, token: res.token);
      state = AuthState(user: res.user);
      _audit(AuditAction.sessionLogin,
          'دخول ${res.user!.name} (${res.user!.role.arabicLabel})',
          userId: res.user!.id);
      return true;
    }
    state = state.copyWith(
      isLoading: false,
      error: res.error ?? 'تعذر تسجيل الدخول',
    );
    return false;
  }

  void _audit(AuditAction action, String desc, {String? userId}) {
    try {
      _ref.read(auditLogProvider.notifier).log(action, desc, userId: userId);
    } catch (_) {}
  }

  Future<void> updateProfile(AppUser user) async {
    if (state.user == null) return;
    await SessionStore.saveUser(user);
    state = state.copyWith(user: user);
  }

  /// حذف الحساب نهائياً من الخادم ثم مسح كل شيء من الجهاز.
  Future<({bool ok, String? error})> deleteAccount() async {
    try {
      await _service.deleteAccount();
    } on ApiException catch (e) {
      if (!e.isUnauthorized) {
        return (ok: false, error: e.message);
      }
    }
    await LocalStore.clearAll();
    await SessionStore.clear();
    ApiClient.setToken(null);
    state = const AuthState();
    return (ok: true, error: null);
  }

  Future<void> logout() async {
    final u = state.user;
    if (u != null) {
      _audit(AuditAction.sessionLogout, 'خروج ${u.name}', userId: u.id);
    }
    ApiClient.setToken(null);
    await SessionStore.clear();
    // لا يرى المستخدم التالي بيانات المستخدم السابق.
    await LocalStore.clearAll();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.read(authServiceProvider), ref),
);
