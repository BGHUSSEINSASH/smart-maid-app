import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/catalog.dart';
import 'features/auth/presentation/app_lock_screen.dart';
import 'l10n/app_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/security_provider.dart';
import 'providers/settings_provider.dart';

class SmartMaidApp extends ConsumerStatefulWidget {
  const SmartMaidApp({super.key});

  @override
  ConsumerState<SmartMaidApp> createState() => _SmartMaidAppState();
}

class _SmartMaidAppState extends ConsumerState<SmartMaidApp> {
  late final routerConfig = buildRouter(
    () => ref.read(authProvider).isLoggedIn,
    currentRole: () => ref.read(authProvider).user?.role,
    bookingById: (id) => ref
        .read(myBookingsProvider)
        .where((b) => b.id == id)
        .firstOrNull,
  );

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'شغالتي',
      debugShowCheckedModeBanner: false,
      routerConfig: routerConfig,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.followSystem
          ? ThemeMode.system
          : (settings.darkMode ? ThemeMode.dark : ThemeMode.light),
      // التطبيق عربي بالكامل؛ لا خيار لغة إنجليزية نصف مترجمة.
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final security = ref.watch(securityProvider);
        final loggedIn = ref.watch(authProvider).isLoggedIn;
        // بوابة القفل: تظهر فوق كل شيء عند تفعيل القفل ووجود جلسة.
        final showLock = loggedIn && security.mustUnlock;
        // حجم الخط في الإعدادات يُضاف إلى حجم النظام بدل استبداله.
        final systemScale = MediaQuery.textScalerOf(context).scale(1);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(systemScale * settings.textScale),
            // إعدادات إمكانية الوصول — تؤثر app-wide عبر MediaQuery:
            // highContrast يُعلم Flutter برفع التباين في الويدجت المدعومة.
            // disableAnimations يوقف الرسوم المتحركة (تقليل الحركة).
            highContrast: settings.highContrast,
            disableAnimations: settings.reduceMotion,
          ),
          child: showLock
              ? AppLockScreen(
                  onDone: () =>
                      ref.read(securityProvider.notifier).unlock(),
                  onForgot: () => ref.read(authProvider.notifier).logout(),
                )
              : child!,
        );
      },
    );
  }
}

/// يحمّل كتالوج الخدمات من الخادم مرة واحدة عند الإقلاع.
final catalogProvider = FutureProvider<void>((ref) => Catalog.hydrate());
