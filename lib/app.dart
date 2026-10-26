import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/app_lock_screen.dart';
import 'l10n/app_localizations.dart';
import 'providers/auth_provider.dart';
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
      locale: Locale(settings.language),
      supportedLocales: AppLocalizations.supportedLocales,
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
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(settings.textScale),
          ),
          child: showLock
              ? AppLockScreen(
                  onDone: () =>
                      ref.read(securityProvider.notifier).unlock(),
                )
              : child!,
        );
      },
    );
  }
}


