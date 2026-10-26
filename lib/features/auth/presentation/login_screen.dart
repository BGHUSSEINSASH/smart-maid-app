import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/demo_data.dart';
import '../../../data/models.dart';
import '../../../providers/auth_provider.dart';
import 'auth_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _showDev = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _err(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.error,
    ));
  }

  Future<void> _submit() async {
    final ok = await ref
        .read(authProvider.notifier)
        .login(_emailCtrl.text, _passCtrl.text);
    if (!mounted) return;
    if (ok) {
      context.go('/');
    } else {
      _err(ref.read(authProvider).error ?? 'تعذر تسجيل الدخول');
    }
  }

  Future<void> _google() async {
    final ok = await ref.read(authProvider.notifier).signInWithGoogle();
    if (!mounted) return;
    ok ? context.go('/') : _err(ref.read(authProvider).error ?? 'فشل الدخول');
  }

  Future<void> _apple() async {
    final ok = await ref.read(authProvider.notifier).signInWithApple();
    if (!mounted) return;
    ok ? context.go('/') : _err(ref.read(authProvider).error ?? 'فشل الدخول');
  }

  Future<void> _quick(AppUser user) async {
    await ref.read(authProvider.notifier).loginAs(user);
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.bgDeep, AppColors.cardDark]
                : const [Color(0xFFF8FAFF), Color(0xFFEDEBFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Container(
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A4F46E5),
                        blurRadius: 28,
                        offset: Offset(0, 18),
                      ),
                    ],
                    border: Border.all(color: AppColors.stroke),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            gradient: AppColors.heroGradient,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Icon(Icons.cleaning_services_rounded,
                              size: 38, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('مرحباً بعودتك',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary)),
                      const SizedBox(height: 6),
                      const Text('سجّل دخولك لمتابعة حجوزاتك وخدماتك',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 13.5, color: AppColors.muted)),
                      const SizedBox(height: 22),
                      AuthField(
                        controller: _emailCtrl,
                        label: 'البريد الإلكتروني',
                        icon: Icons.alternate_email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        action: TextInputAction.next,
                      ),
                      const SizedBox(height: 14),
                      AuthField(
                        controller: _passCtrl,
                        label: 'كلمة المرور',
                        icon: Icons.lock_rounded,
                        obscure: _obscure,
                        action: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        suffix: IconButton(
                          icon: Icon(_obscure
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          onPressed: () => context.push('/forgot-password'),
                          child: const Text('نسيت كلمة المرور؟'),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: auth.isLoading ? null : _submit,
                          icon: auth.isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.login_rounded, size: 19),
                          label: Text(auth.isLoading
                              ? 'جارٍ الدخول...'
                              : 'تسجيل الدخول'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const AuthDivider(),
                      const SizedBox(height: 16),
                      SocialButton.google(
                          onTap: auth.isLoading ? null : _google),
                      if (SocialButton.showApple) ...[
                        const SizedBox(height: 10),
                        SocialButton.apple(
                            onTap: auth.isLoading ? null : _apple),
                      ],
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('ليس لديك حساب؟',
                              style: TextStyle(color: AppColors.muted)),
                          TextButton(
                            onPressed: () => context.push('/register'),
                            child: const Text('إنشاء حساب جديد'),
                          ),
                        ],
                      ),
                      const Divider(color: AppColors.stroke),
                      TextButton.icon(
                        onPressed: () => setState(() => _showDev = !_showDev),
                        icon: Icon(
                            _showDev
                                ? Icons.expand_less_rounded
                                : Icons.developer_mode_rounded,
                            size: 18),
                        label: const Text('دخول سريع للاختبار',
                            style: TextStyle(fontSize: 12)),
                      ),
                      if (_showDev) _devRow(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _devRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          _quickRole('👤', 'عميل', DemoData.customer),
          const SizedBox(width: 8),
          _quickRole('👩‍💼', 'عاملة', DemoData.workerUser),
          const SizedBox(width: 8),
          _quickRole('🏢', 'شركة', DemoData.companyUser),
          const SizedBox(width: 8),
          _quickRole('🛡️', 'إدارة', DemoData.admin),
        ],
      ),
    );
  }

  Widget _quickRole(String emoji, String label, AppUser user) {
    return Expanded(
      child: Material(
        color: AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => _quick(user),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 4),
                Text(label,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
