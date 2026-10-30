import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/api/api_client.dart';
import '../core/storage/local_store.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/adaptive.dart';
import '../data/models.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_image.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late AppUser _user;
  late final _nameCtrl = TextEditingController();
  late final _phoneCtrl = TextEditingController();
  late final _locationCtrl = TextEditingController();
  String _imageUrl = '';

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    // لا حساب مسجّل: لا نشغّل تعديل ملف وهمي، بل نعود لشاشة الدخول.
    if (user == null) {
      _user = const AppUser(
          id: '', name: '', email: '', imageUrl: '', role: AppRole.customer);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/login');
      });
    } else {
      _user = user;
    }
    _nameCtrl.text = _user.name;
    _phoneCtrl.text = _user.phone;
    _locationCtrl.text = _user.location;
    _imageUrl = _user.imageUrl;
    _loadOverrides();
  }

  Future<void> _loadOverrides() async {
    final saved = await LocalStore.loadProfileFields();
    if (!mounted) return;
    setState(() {
      if (saved['name'] != null) _nameCtrl.text = saved['name']!;
      if (saved['phone'] != null) _phoneCtrl.text = saved['phone']!;
      if (saved['location'] != null) _locationCtrl.text = saved['location']!;
      if (saved['imageUrl'] != null) _imageUrl = saved['imageUrl']!;
    });
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('الاسم مطلوب'), behavior: SnackBarBehavior.floating));
      return;
    }
    final updated = AppUser(
      id: _user.id,
      name: _nameCtrl.text.trim(),
      email: _user.email,
      imageUrl: _imageUrl,
      role: _user.role,
      phone: _phoneCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
    );
    await ref.read(authProvider.notifier).updateProfile(updated);
    await LocalStore.saveProfileFields(
      name: updated.name,
      phone: updated.phone,
      location: updated.location,
      imageUrl: updated.imageUrl,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('تم حفظ ملفك الشخصي ✅'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(title: const Text('تعديل الملف الشخصي')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                AppAvatar(url: _imageUrl, radius: 46, label: _nameCtrl.text),
                const SizedBox(height: 10),
                Text(
                  'تُعرض صورتك بالأحرف الأولى حتى يُفعَّل رفع الصور على الخادم.',
                  style: TextStyle(fontSize: 11.5, color: context.mutedText),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _nameCtrl,
            decoration:
                const InputDecoration(labelText: 'الاسم الكامل'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
                labelText: 'رقم الهاتف', hintText: '07XXXXXXXXX'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _locationCtrl,
            decoration: const InputDecoration(
                labelText: 'المدينة/المنطقة', hintText: 'بغداد، الكرادة'),
          ),
          const SizedBox(height: 14),
          Row(children: [
            Icon(Icons.lock_outline_rounded,
                size: 14, color: context.mutedText),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                  'البريد الإلكتروني (${_user.email}) لا يمكن تغييره في هذا الإصدار',
                  style:
                      TextStyle(fontSize: 11.5, color: context.mutedText)),
            ),
          ]),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_rounded, size: 19),
              label: const Text('حفظ التغييرات'),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'تصدير البيانات غير متاح حالياً — سيُفعَّل مع ربط الخادم الكامل.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text('تصدير بياناتي',
                      style: TextStyle(fontSize: 13)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('حذف الحساب'),
                        content: const Text(
                            'سيتم حذف حسابك وبياناتك نهائياً من الخادم. هل أنت متأكد؟'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('إلغاء'),
                          ),
                          FilledButton(
                            style: FilledButton.styleFrom(
                                backgroundColor: AppColors.error),
                            onPressed: () async {
                              Navigator.pop(ctx);
                              final userId = _user.id;
                              try {
                                await ApiClient.delete('/auth/me');
                              } on ApiException catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'تعذّر حذف الحساب: ${e.message}'),
                                    backgroundColor: AppColors.error,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }
                              if (!mounted) return;
                              // مسح الجلسة والبيانات المحلية ثم الخروج.
                              await LocalStore.clearAll();
                              await ref.read(authProvider.notifier).logout();
                              if (mounted) context.go('/login');
                              debugPrint('delete account requested: $userId');
                            },
                            child: const Text('حذف الحساب'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_forever_rounded, size: 18),
                  label: const Text('حذف الحساب',
                      style: TextStyle(fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
