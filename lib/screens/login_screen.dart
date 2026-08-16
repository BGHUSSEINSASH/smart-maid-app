import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../data/demo_data.dart';
import 'main_shell.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            ref.read(authProvider.notifier).loginAs(DemoData.admin);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainShell()),
              (route) => false,
            );
          },
          child: const Text('دخول الإدارة (Admin)'),
        ),
      ),
    );
  }
}
