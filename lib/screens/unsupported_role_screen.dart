import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../data/models.dart';
import '../providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// لوحات الشركات والإدارة تُدار من لوحة الويب، وليست في التطبيق.
/// هذه الشاشة تظهر بدل عرض بيانات تجريبية غير حقيقية.
class UnsupportedRoleScreen extends ConsumerWidget {
  final AppRole role;
  const UnsupportedRoleScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompany = role == AppRole.company;
    return Scaffold(
      appBar: AppBar(title: Text(isCompany ? 'حساب شركة' : 'حساب إدارة')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.desktop_windows_rounded,
                  size: 64, color: AppColors.muted),
              const SizedBox(height: 18),
              Text(
                isCompany
                    ? 'إدارة الشركة متاحة من لوحة الويب'
                    : 'إدارة المنصة متاحة من لوحة الويب',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              const Text(
                'لا يعرض التطبيق بيانات إدارية تجريبية. سجّل الدخول من لوحة الويب لإدارة الحساب أو الطلبات.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, height: 1.7),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => ref.read(authProvider.notifier).logout(),
                child: const Text('تسجيل الخروج'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
