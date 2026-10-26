import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/adaptive.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/health_provider.dart';
import '../providers/notifications_provider.dart';
import '../providers/reminders_provider.dart';
import 'address_screen.dart';
import 'admin_companies_screen.dart';
import 'admin_disputes_screen.dart';
import 'admin_finance_screen.dart';
import 'admin_screen.dart';
import 'booking_screen.dart';
import 'chat_list_screen.dart';
import 'company_bookings_screen.dart';
import 'company_dashboard_screen.dart';
import 'company_workers_screen.dart';
import 'faq_screen.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'loyalty_screen.dart';
import 'my_bookings_screen.dart';
import 'offers_screen.dart';
import 'profile_screen.dart';
import 'subscription_screen.dart';
import 'tips_screen.dart';
import 'support_ticket_screen.dart';
import 'accessibility_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'wallet_screen.dart';
import 'worker_dashboard_screen.dart';
import 'worker_requests_screen.dart';
import 'worker_schedule_screen.dart';
import 'sos_screen.dart';
import 'kyc_screen.dart';
import 'settlements_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationsBus.sink = (title, body, icon) {
        ref.read(notificationsProvider.notifier).addNotification(
              AppNotification(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: title,
                body: body,
                icon: icon,
                time: DateTime.now(),
              ),
            );
      };
      for (final p in NotificationsBus.drain()) {
        NotificationsBus.sink!(p.title, p.body, p.icon);
      }
      ref
          .read(remindersProvider.notifier)
          .scanUpcoming(ref.read(myBookingsProvider));
    });
  }

  void _openBooking() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const BookingScreen()));
  }

  void _openMyBookings() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const MyBookingsScreen()));
  }

  void _openSettings() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    if (authState.user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final user = authState.user!;
    final tabs = _tabsForRole(user.role);
    final safeIndex = _index < tabs.length ? _index : 0;
    final showFab = user.role == AppRole.customer;
    final health = ref.watch(backendHealthProvider);
    final showOfflineBanner = !health.reachable;

    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: showOfflineBanner
          ? PreferredSize(
              preferredSize: const Size.fromHeight(34),
              child: OfflineBar(
                onRetry: () =>
                    ref.read(backendHealthProvider.notifier).check(),
              ),
            )
          : null,
      drawer: _AppDrawer(
        user: user,
        onHome: () => setState(() => _index = 0),
        onSearch: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SearchScreen())),
        onBookings: _openMyBookings,
        onBooking: _openBooking,
        onFavorites: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const FavoritesScreen())),
        onWallet: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const WalletScreen())),
        onLoyalty: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const LoyaltyScreen())),
        onOffers: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const OffersScreen())),
        onAddresses: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AddressScreen())),
        onFaq: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FaqScreen())),
        onSettings: _openSettings,
        onProfile: () => setState(() => _index = tabs.length - 1),
      ),
      body: IndexedStack(
        index: safeIndex,
        children: tabs.map((t) => t.screen).toList(),
      ),
      extendBody: true,
      floatingActionButton: showFab
          ? FloatingActionButton(
              onPressed: _openBooking,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              child: const Icon(Icons.add_rounded, size: 28),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _FloatingNavBar(
        tabs: tabs,
        selectedIndex: safeIndex,
        showFabGap: showFab,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }

  List<_Tab> _tabsForRole(AppRole role) {
    final t = AppLocalizations.of(context)!;
    switch (role) {
      case AppRole.customer:
        return [
          _Tab(t.tabHome, Icons.home_outlined, Icons.home_rounded, const HomeScreen()),
          _Tab(t.tabServices, Icons.search_rounded, Icons.manage_search_rounded, const SearchScreen()),
          _Tab(t.tabBookings, Icons.book_online_outlined, Icons.book_online_rounded, const MyBookingsScreen()),
          _Tab(t.tabChat, Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, const ChatListScreen()),
          _Tab(t.tabProfile, Icons.person_outline_rounded, Icons.person_rounded, const ProfileScreen()),
        ];
      case AppRole.worker:
        return [
          _Tab(t.tabDashboard, Icons.dashboard_outlined, Icons.dashboard_rounded, const WorkerDashboardScreen()),
          _Tab(t.tabSchedule, Icons.calendar_month_outlined, Icons.calendar_month_rounded, const WorkerScheduleScreen()),
          _Tab(t.tabRequests, Icons.mark_email_unread_outlined, Icons.mark_email_read_rounded, const WorkerRequestsScreen()),
          _Tab(t.tabChat, Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, const ChatListScreen()),
          _Tab(t.tabProfile, Icons.person_outline_rounded, Icons.person_rounded, const ProfileScreen()),
        ];
      case AppRole.company:
        return [
          _Tab(t.tabDashboard, Icons.dashboard_outlined, Icons.dashboard_rounded, const CompanyDashboardScreen()),
          _Tab(t.tabIncoming, Icons.inbox_outlined, Icons.inbox_rounded, const CompanyBookingsScreen()),
          _Tab(t.tabWorkers, Icons.groups_outlined, Icons.groups_rounded, const CompanyWorkersScreen()),
          _Tab(t.tabChat, Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, const ChatListScreen()),
          _Tab(t.tabProfile, Icons.person_outline_rounded, Icons.person_rounded, const ProfileScreen()),
        ];
      case AppRole.admin:
        return [
          _Tab(t.tabDashboard, Icons.admin_panel_settings_outlined, Icons.admin_panel_settings_rounded, const AdminScreen()),
          _Tab(t.tabCompanies, Icons.domain_outlined, Icons.domain_rounded, const AdminCompaniesScreen()),
          _Tab(t.tabFinance, Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded, const AdminFinanceScreen()),
          _Tab(t.tabDisputes, Icons.gavel_outlined, Icons.gavel_rounded, const AdminDisputesScreen()),
          _Tab(t.tabProfile, Icons.person_outline_rounded, Icons.person_rounded, const ProfileScreen()),
        ];
    }
  }
}

class _Tab {
  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final Widget screen;

  const _Tab(
    this.label,
    this.icon,
    this.selectedIcon,
    this.screen,
  );
}

class OfflineBar extends StatelessWidget {
  final VoidCallback onRetry;
  const OfflineBar({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.warning.withValues(alpha: 0.15),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 34,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 14, color: AppColors.warning),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'لا يوجد اتصال بالخادم — يعمل التطبيق ببيانات تجريبية',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 11.5, fontWeight: FontWeight.w700, color: context.ink),
                ),
              ),
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero),
                child: const Text('إعادة المحاولة',
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final List<_Tab> tabs;
  final int selectedIndex;
  final bool showFabGap;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
    this.showFabGap = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface =
        (isDark ? AppColors.surfaceDark : Colors.white).withValues(alpha: 0.92);

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.14),
            blurRadius: 28,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              color: surface,
              border: Border.all(
                color: Colors.white.withValues(alpha: isDark ? 0.06 : 0.6),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 64,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final count = tabs.length;
                    // عرض الفجوة الوسطى المخصصة لزر الـ FAB.
                    final gap = (showFabGap && count >= 4) ? 56.0 : 0.0;
                    final slotW = (constraints.maxWidth - gap) / count;

                    // موضع مؤشر التبويب النشط مع مراعاة الفجوة.
                    final mid = count ~/ 2;
                    double indicatorX = selectedIndex * slotW;
                    if (gap > 0 && selectedIndex >= mid) {
                      indicatorX += gap;
                    }

                    return Stack(
                      children: [
                        // مؤشر منزلق تحت التبويب النشط.
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutCubic,
                          left: indicatorX + 6,
                          top: 4,
                          bottom: 4,
                          width: slotW - 12,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.16),
                                  AppColors.accent.withValues(alpha: 0.14),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            for (var i = 0; i < count; i++) ...[
                              if (gap > 0 && i == mid)
                                SizedBox(width: gap),
                              SizedBox(
                                width: slotW,
                                child: _buildItem(context, i),
                              ),
                            ],
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int i) {
    final item = tabs[i];
    final selected = selectedIndex == i;
    final icon = selected ? (item.selectedIcon ?? item.icon) : item.icon;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        onTap(i);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 1, end: selected ? 1.18 : 1),
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Icon(
              icon,
              size: 23,
              color: selected ? AppColors.primary : AppColors.muted,
            ),
          ),
          const SizedBox(height: 3),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            style: TextStyle(
              fontSize: selected ? 11 : 10.5,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: selected ? AppColors.primary : AppColors.muted,
            ),
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  final AppUser user;
  final VoidCallback onHome;
  final VoidCallback onSearch;
  final VoidCallback onBookings;
  final VoidCallback onBooking;
  final VoidCallback onFavorites;
  final VoidCallback onWallet;
  final VoidCallback onLoyalty;
  final VoidCallback onOffers;
  final VoidCallback onAddresses;
  final VoidCallback onFaq;
  final VoidCallback onSettings;
  final VoidCallback onProfile;

  const _AppDrawer({
    required this.user,
    required this.onHome,
    required this.onSearch,
    required this.onBookings,
    required this.onBooking,
    required this.onFavorites,
    required this.onWallet,
    required this.onLoyalty,
    required this.onOffers,
    required this.onAddresses,
    required this.onFaq,
    required this.onSettings,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final surface = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;

    return Drawer(
      backgroundColor: bg,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: AppColors.heroGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(user.imageUrl),
                  ),
                  const SizedBox(height: 12),
                  Text(user.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(user.email,
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _DrawerItem(icon: Icons.home_rounded, label: t.tabHome, surface: surface, textColor: textColor,
                onTap: () { Navigator.pop(context); onHome(); }),
            _DrawerItem(icon: Icons.search_rounded, label: t.tabServices, surface: surface, textColor: textColor,
                onTap: () { Navigator.pop(context); onSearch(); }),
            _DrawerItem(icon: Icons.add_circle_rounded, label: t.newBooking, surface: surface, textColor: textColor,
                onTap: () { Navigator.pop(context); onBooking(); }),
            _DrawerItem(icon: Icons.receipt_long_rounded, label: t.myBookings, surface: surface, textColor: textColor,
                onTap: () { Navigator.pop(context); onBookings(); }),
            _DrawerItem(icon: Icons.favorite_rounded, label: t.favorites, surface: surface, textColor: textColor,
                onTap: () { Navigator.pop(context); onFavorites(); }),
            _DrawerItem(icon: Icons.account_balance_wallet_rounded, label: t.wallet, surface: surface, textColor: textColor,
                onTap: () { Navigator.pop(context); onWallet(); }),
            _DrawerItem(icon: Icons.emoji_events_rounded, label: t.loyaltyPoints, surface: surface, textColor: textColor,
                onTap: () { Navigator.pop(context); onLoyalty(); }),
            _DrawerItem(icon: Icons.workspace_premium_rounded, label: 'SmartGold', surface: surface, textColor: textColor,
                onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen())); }),
            _DrawerItem(icon: Icons.card_giftcard_rounded, label: t.offersCoupons, surface: surface, textColor: textColor,
                onTap: () { Navigator.pop(context); onOffers(); }),
            _DrawerItem(icon: Icons.location_on_rounded, label: t.myAddresses, surface: surface, textColor: textColor,
                onTap: () { Navigator.pop(context); onAddresses(); }),
            _DrawerItem(icon: Icons.lightbulb_rounded, label: 'نصائح التنظيف', surface: surface, textColor: textColor,
                onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const TipsScreen())); }),
            _DrawerItem(icon: Icons.emergency_rounded, label: 'زر الطوارئ', surface: surface, textColor: textColor,
                onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const SosScreen())); }),
            _DrawerItem(icon: Icons.verified_user_rounded, label: 'توثيق الهوية (KYC)', surface: surface, textColor: textColor,
                onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const KycScreen())); }),
            _DrawerItem(icon: Icons.savings_rounded, label: 'أرباحي ومستحقاتي', surface: surface, textColor: textColor,
                onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const SettlementsScreen())); }),
            _DrawerItem(icon: Icons.support_agent_rounded, label: 'تذكرة دعم', surface: surface, textColor: textColor,
                onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportTicketScreen())); }),
            _DrawerItem(icon: Icons.help_outline_rounded, label: t.faq, surface: surface, textColor: textColor,
                onTap: () { Navigator.pop(context); onFaq(); }),
            _DrawerItem(icon: Icons.accessibility_new_rounded, label: 'الإتاحة', surface: surface, textColor: textColor,
                onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AccessibilityScreen())); }),
            _DrawerItem(icon: Icons.person_rounded, label: t.tabProfile, surface: surface, textColor: textColor,
                onTap: () { Navigator.pop(context); onProfile(); }),
            _DrawerItem(icon: Icons.settings_rounded, label: t.settings, surface: surface, textColor: textColor,
                onTap: () { Navigator.pop(context); onSettings(); }),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color surface;
  final Color textColor;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.surface,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Text(label,
                    style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: textColor)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
