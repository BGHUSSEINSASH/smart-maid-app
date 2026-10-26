import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/demo_data.dart';
import '../../data/models.dart';
import '../../screens/booking_screen.dart';
import '../../screens/chat_list_screen.dart';
import '../../screens/conversation_screen.dart';
import '../../screens/faq_screen.dart';
import '../../screens/favorites_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/security_settings_screen.dart';
import '../../screens/loyalty_screen.dart';
import '../../screens/main_shell.dart';
import '../../screens/my_bookings_screen.dart';
import '../../screens/offers_screen.dart';
import '../../screens/onboarding_screen.dart';
import '../../screens/payment_screen.dart';
import '../../screens/referral_screen.dart';
import '../../screens/search_screen.dart';
import '../../screens/splash_screen.dart';
import '../../screens/wallet_screen.dart';
import '../../screens/worker_profile_screen.dart';
import '../../screens/active_booking_screen.dart';
import '../../screens/completion_screen.dart';
import '../../screens/subscription_screen.dart';
import '../../screens/compare_screen.dart';
import '../../screens/tips_screen.dart';
import '../../screens/support_ticket_screen.dart';
import '../../screens/accessibility_screen.dart';
import '../../screens/admin_audit_log_screen.dart';
import '../../screens/company_billing_screen.dart';
import '../../screens/sos_screen.dart';
import '../../screens/kyc_screen.dart';
import '../../screens/settlements_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// المسارات المقيّدة بأدوار محددة. أي مسار غير مذكور هنا متاح لكل الأدوار.
const Map<String, Set<AppRole>> _roleRestrictedRoutes = {
  '/admin/audit': {AppRole.admin},
  '/company/billing': {AppRole.company},
  '/settlements': {AppRole.worker, AppRole.company},
  '/kyc': {AppRole.worker},
};

GoRouter buildRouter(
  bool Function() isLoggedIn, {
  AppRole? Function()? currentRole,
}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final loggedIn = isLoggedIn();
      final loc = state.matchedLocation;
      const public = {
        '/splash',
        '/login',
        '/onboarding',
        '/register',
        '/forgot-password',
      };
      if (!loggedIn && !public.contains(loc)) {
        return '/splash';
      }
      if (loggedIn && (loc == '/splash' || loc == '/login')) {
        return '/';
      }
      // حارس الأدوار: منع وصول دور لمسار مخصص لدور آخر.
      if (loggedIn) {
        final allowed = _roleRestrictedRoutes[loc];
        if (allowed != null) {
          final role = currentRole?.call();
          if (role != null && !allowed.contains(role)) {
            return '/';
          }
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'shell',
        builder: (context, state) => const MainShell(),
      ),
      GoRoute(
        path: '/worker/:id',
        name: 'worker',
        pageBuilder: (context, state) => SlidePage(
          key: state.pageKey,
          child: () {
            final id = state.pathParameters['id'] ?? '';
            final all = [...DemoData.workers, ...DemoData.companyWorkers];
            final worker = all.where((w) => w.id == id).firstOrNull ??
                DemoData.workers.first;
            return WorkerProfileScreen(worker: worker);
          }(),
        ),
      ),
      GoRoute(
        path: '/booking',
        name: 'booking',
        pageBuilder: (context, state) =>
            SlidePage(key: state.pageKey, child: const BookingScreen()),
      ),
      GoRoute(
        path: '/bookings',
        name: 'bookings',
        pageBuilder: (context, state) =>
            SlidePage(key: state.pageKey, child: const MyBookingsScreen()),
      ),
      GoRoute(
        path: '/payment',
        name: 'payment',
        pageBuilder: (context, state) =>
            SlidePage(key: state.pageKey, child: const PaymentScreen()),
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        pageBuilder: (context, state) =>
            SlidePage(key: state.pageKey, child: const ChatListScreen()),
      ),
      GoRoute(
        path: '/chat/support',
        name: 'chat-support',
        pageBuilder: (context, state) => SlidePage(
            key: state.pageKey, child: const ConversationScreen.support()),
      ),
      GoRoute(
        path: '/wallet',
        name: 'wallet',
        pageBuilder: (context, state) =>
            SlidePage(key: state.pageKey, child: const WalletScreen()),
      ),
      GoRoute(
        path: '/loyalty',
        name: 'loyalty',
        pageBuilder: (context, state) =>
            SlidePage(key: state.pageKey, child: const LoyaltyScreen()),
      ),
      GoRoute(
        path: '/offers',
        name: 'offers',
        pageBuilder: (context, state) =>
            SlidePage(key: state.pageKey, child: const OffersScreen()),
      ),
      GoRoute(
        path: '/favorites',
        name: 'favorites',
        pageBuilder: (context, state) =>
            SlidePage(key: state.pageKey, child: const FavoritesScreen()),
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        pageBuilder: (context, state) {
          final q = state.uri.queryParameters['q'] ?? '';
          return SlidePage(
              key: state.pageKey,
              child: SearchScreen(initialQuery: q));
        },
      ),
      GoRoute(
        path: '/faq',
        name: 'faq',
        pageBuilder: (context, state) =>
            SlidePage(key: state.pageKey, child: const FaqScreen()),
      ),
      GoRoute(
        path: '/active-booking/:id',
        name: 'active-booking',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final all = [...DemoData.bookings];
          final booking = all.where((b) => b.id == id).firstOrNull ??
              DemoData.bookings.first;
          return SlidePage(
              key: state.pageKey,
              child: ActiveBookingScreen(booking: booking));
        },
      ),
      GoRoute(
        path: '/completion/:bookingId',
        name: 'completion',
        pageBuilder: (context, state) {
          final id = state.pathParameters['bookingId'] ?? '';
          final all = [...DemoData.bookings];
          final booking = all.where((b) => b.id == id).firstOrNull ??
              DemoData.bookings.first;
          return SlidePage(
              key: state.pageKey,
              child: CompletionScreen(booking: booking));
        },
      ),
      GoRoute(
        path: '/subscription',
        name: 'subscription',
        pageBuilder: (context, state) =>
            SlidePage(key: state.pageKey, child: const SubscriptionScreen()),
      ),
      GoRoute(
        path: '/compare',
        name: 'compare',
        pageBuilder: (context, state) {
          final w1 = state.uri.queryParameters['w1'];
          final w2 = state.uri.queryParameters['w2'];
          return SlidePage(
              key: state.pageKey,
              child: CompareScreen(worker1Id: w1, worker2Id: w2));
        },
      ),
      GoRoute(
        path: '/tips',
        name: 'tips',
        pageBuilder: (context, state) =>
            SlidePage(key: state.pageKey, child: const TipsScreen()),
      ),
      GoRoute(
        path: '/support',
        name: 'support',
        pageBuilder: (context, state) =>
            SlidePage(key: state.pageKey, child: const SupportTicketScreen()),
      ),
      GoRoute(
        path: '/accessibility',
        name: 'accessibility',
        pageBuilder: (context, state) =>
            SlidePage(key: state.pageKey, child: const AccessibilityScreen()),
      ),
      GoRoute(
        path: '/security',
        name: 'security',
        pageBuilder: (context, state) =>
            SlidePage(key: state.pageKey, child: const SecuritySettingsScreen()),
      ),
      GoRoute(
        path: '/admin/audit',
        name: 'admin-audit',
        pageBuilder: (context, state) =>
            SlidePage(key: state.pageKey, child: const AdminAuditLogScreen()),
      ),
      GoRoute(
        path: '/company/billing',
        name: 'company-billing',
        pageBuilder: (context, state) =>
            SlidePage(key: state.pageKey, child: const CompanyBillingScreen()),
      ),
      GoRoute(
        path: '/referral',
        name: 'referral',
        pageBuilder: (context, state) =>
            SlidePage(key: state.pageKey, child: const ReferralScreen()),
      ),
      GoRoute(
        path: '/sos',
        name: 'sos',
        pageBuilder: (context, state) =>
            SlidePage(key: state.pageKey, child: const SosScreen()),
      ),
      GoRoute(
        path: '/kyc',
        name: 'kyc',
        pageBuilder: (context, state) =>
            SlidePage(key: state.pageKey, child: const KycScreen()),
      ),
      GoRoute(
        path: '/settlements',
        name: 'settlements',
        pageBuilder: (context, state) =>
            SlidePage(key: state.pageKey, child: const SettlementsScreen()),
      ),
    ],
  );
}

class SlidePage<T> extends CustomTransitionPage<T> {
  SlidePage({required super.key, required super.child})
      : super(
          transitionDuration: const Duration(milliseconds: 320),
          transitionsBuilder: (_, animation, _, child) {
            final curved = CurvedAnimation(
                parent: animation, curve: Curves.easeOutCubic);
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.045),
                end: Offset.zero,
              ).animate(curved),
              child: FadeTransition(opacity: curved, child: child),
            );
          },
        );
}

