import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/nav/app_nav.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/adaptive.dart';
import '../data/catalog.dart';
import '../data/models.dart';
import '../providers/auth_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/health_provider.dart';
import '../providers/notifications_provider.dart';
import '../providers/recommendations_provider.dart';

import '../widgets/app_image.dart';
import '../widgets/pro_components.dart';
import '../widgets/micro_interactions.dart';
import 'booking_detail_screen.dart';
import 'booking_screen.dart';
import 'notifications_screen.dart';
import 'offers_screen.dart';
import 'search_screen.dart';
import 'worker_profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final String _query = '';

  late final PageController _bannerController;
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;

  static const _banners = [
    _HeroBannerData(
      title: 'خصم 50% على أول حجز',
      subtitle: 'استخدم كود SMART50 عند الحجز واستمتع بالخدمة.',
      chip: 'عرض محدود',
      statLabel: 'وفّرت هذا الأسبوع',
      statValue: '1,250 ر.س',
      icon: Icons.local_offer_rounded,
      gradient: LinearGradient(
        colors: [Color(0xFF4F46E5), Color(0xFF6366F1), Color(0xFF7C3AED)],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
      ctaPrimary: 'احجز الآن',
      ctaSecondary: 'التفاصيل',
    ),
    _HeroBannerData(
      title: 'باقة شهرية للمنزل',
      subtitle: 'تنظيف وغسيل وكي بجدولة مرنة وخصم على التعاقد الطويل.',
      chip: 'الأكثر طلباً',
      statLabel: 'تشمل',
      statValue: 'تنظيف + غسيل + كي',
      icon: Icons.workspace_premium_rounded,
      gradient: LinearGradient(
        colors: [Color(0xFF0EA5E9), Color(0xFF2563EB), Color(0xFF4F46E5)],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
      ctaPrimary: 'ابدأ الباقة',
      ctaSecondary: 'قارن الخطط',
    ),
    _HeroBannerData(
      title: 'حجز سريع في نفس اليوم',
      subtitle: 'عاملات متاحات الآن في منطقتك، تصل خلال وقت قصير.',
      chip: 'متاح الآن',
      statLabel: 'الحجز',
      statValue: 'حسب الموعد المتاح',
      icon: Icons.bolt_rounded,
      gradient: LinearGradient(
        colors: [Color(0xFF7C3AED), Color(0xFF9333EA), Color(0xFFEC4899)],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
      ctaPrimary: 'احجز الآن',
      ctaSecondary: 'المناطق المتاحة',
    ),
  ];

  static const _stories = [
    {'emoji': '💸', 'label': 'العروض', 'color': 0xFF2FB78A},
    {'emoji': '🧹', 'label': 'تنظيف عميق', 'color': 0xFF3B82F6},
    {'emoji': '👶', 'label': 'رعاية أطفال', 'color': 0xFF8B5CF6},
    {'emoji': '🍳', 'label': 'طبخ', 'color': 0xFFF59E0B},
    {'emoji': '📅', 'label': 'باقة شهرية', 'color': 0xFFEF4444},
    {'emoji': '⭐', 'label': 'الأعلى تقييماً', 'color': 0xFF10B981},
  ];

  @override
  void initState() {
    super.initState();
    _bannerController = PageController(initialPage: 0);
    _startBannerTimer();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients) {
        _currentBannerIndex = (_currentBannerIndex + 1) % _banners.length;
        _bannerController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  List<WorkerModel> get _filtered {
    var list = Catalog.workers;
    if (_query.isNotEmpty) {
      list = list
          .where((w) => w.name.contains(_query) || w.category.contains(_query))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    // الزائر يستطيع تصفح الخدمات والأسعار قبل التسجيل.
    final firstName = user?.name.split(' ').first ?? '';

    final currency = ref.watch(currencyProvider);
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: context.pageBg,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async =>
            ref.read(backendHealthProvider.notifier).check(),
        child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: context.headerGradient,
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateTime.now().hour < 12
                                  ? 'صباح الخير${firstName.isEmpty ? '' : '، $firstName'}'
                                  : (DateTime.now().hour < 18
                                        ? 'مساء الخير${firstName.isEmpty ? '' : '، $firstName'}'
                                        : 'مرحباً${firstName.isEmpty ? '' : '، $firstName'}'),
                              style: TextStyle(
                                color: context.mutedText,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateTime.now().hour < 12
                                  ? 'هل نجهز لك عاملة لبداية يوم نظيف؟'
                                  : 'رتب جدولك للغد وأنت مرتاح',
                              style: TextStyle(
                                color: context.ink,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SearchScreen())),
                        child: Tooltip(
                          message: 'بحث وفلترة',
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.search_rounded,
                                color: AppColors.primary, size: 21),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Tooltip(
                        message: 'الإشعارات',
                        child: GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const NotificationsScreen())),
                        child: Stack(children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.notifications_rounded,
                                color: AppColors.primary, size: 20),
                          ),
                          Positioned(
                            top: 4,
                            left: 4,
                            child: Consumer(
                                builder: (context, ref, _) {
                                  final unread =
                                      ref.watch(unreadCountProvider);
                                  if (unread == 0) return const SizedBox.shrink();
                                  return Container(
                                    padding:
                                        const EdgeInsets.all(3.5),
                                    decoration: const BoxDecoration(
                                      color: AppColors.error,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints:
                                        const BoxConstraints(minWidth: 17),
                                    child: Text('$unread',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 9,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800)),
                                  );
                                }),
                          ),
                         ]),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AppAvatar(
                        url: user?.imageUrl ?? '',
                        radius: 22,
                        label: user?.name ?? '',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── حقل البحث ──────────────────────────────────────────────
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SearchScreen())),
                    child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withAlpha(50),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(20),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          color: AppColors.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ابحث عن خدمة...',
                                style: TextStyle(
                                  color: AppColors.ink,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'مثال: أحتاج عاملة لتنظيف المنزل غداً',
                                style: TextStyle(
                                  color: AppColors.muted.withAlpha(150),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.mic_none_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ),
                ],
              ),
            ),
          ),

          // ── Stories ──────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                itemCount: _stories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final s = _stories[i];
                  final color = Color(s['color'] as int);
                  return Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [color, color.withAlpha(160)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: color.withAlpha(120),
                            width: 2.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            s['emoji'] as String,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s['label'] as String,
                        style: TextStyle(
                          color: context.ink,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // ── Auto-Scrolling Banners ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  SizedBox(
                    height: 212,
                    child: PageView.builder(
                      controller: _bannerController,
                      onPageChanged: (i) {
                        if (!mounted) return;
                        setState(() => _currentBannerIndex = i);
                      },
                      itemCount: _banners.length,
                      itemBuilder: (_, i) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: GestureDetector(
                            onTap: () {
                              switch (i) {
                                case 0:
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const BookingScreen()));
                                  break;
                                case 1:
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const OffersScreen()));
                                  break;
                                default:
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const SearchScreen()));
                              }
                            },
                            child: _HeroBannerCard(data: _banners[i]),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _banners.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 260),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _currentBannerIndex == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentBannerIndex == i
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.24),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Upcoming booking card ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Consumer(builder: (context, ref, _) {
              final bookings = ref.watch(myBookingsProvider);
              final upcoming = bookings
                  .where((b) =>
                      b.status == BookingStatus.confirmed ||
                      b.status == BookingStatus.pending)
                  .toList();
              if (upcoming.isEmpty) return const SizedBox.shrink();
              final next = upcoming.first;
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              BookingDetailScreen(booking: next))),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: context.heroSoftGradient,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(children: [
                      AppAvatar(url: next.workerImage, radius: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('حجزك القادم',
                                  style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.85),
                                      fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(
                                  '${next.workerName} • ${DateFormat('d/MM', 'ar').format(next.date)} — ${next.timeSlot}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13.5)),
                            ]),
                      ),
                      const Icon(Icons.chevron_left_rounded,
                          color: Colors.white70),
                    ]),
                  ),
                ),
              );
            }),
          ),

          // ── Recommendations section ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Consumer(
              builder: (context, ref, _) {
                final recommended = ref.watch(recommendationsProvider);
                if (recommended.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 20, color: AppColors.accent),
                            const SizedBox(width: 8),
                            const Text('مناسب لك',
                                style: TextStyle(
                                    fontWeight: FontWeight.w800, fontSize: 16)),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 130,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: recommended.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 10),
                          itemBuilder: (context, i) {
                            final w = recommended[i];
                            return GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          WorkerProfileScreen(worker: w))),
                              child: Container(
                                width: 110,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: AppColors.accent.withValues(alpha: 0.2)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundImage: NetworkImage(w.imageUrl),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(w.name.split(' ').first,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700)),
                                    Text('\$${w.hourlyRate}/س',
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: AppColors.accent,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ── Section title ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                children: [
                  const Text(
                    'اكتشف المزيد',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withAlpha(50),
                      ),
                    ),
                    child: Text(
                      '${filtered.length}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Worker cards ──────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _RevealOnBuild(
                    delay: Duration(milliseconds: 70 * i),
                    child: _WorkerCard(
                      worker: filtered[i],
                      currency: currency,
                      onTap: () => AppNav.pushSlide(
                          context,
                          WorkerProfileScreen(
                              worker: filtered[i])),
                    ),
                  ),
                ),
                childCount: filtered.length,
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _HeroBannerData {
  final String title;
  final String subtitle;
  final String chip;
  final String statLabel;
  final String statValue;
  final IconData icon;
  final LinearGradient gradient;
  final String ctaPrimary;
  final String ctaSecondary;

  const _HeroBannerData({
    required this.title,
    required this.subtitle,
    required this.chip,
    required this.statLabel,
    required this.statValue,
    required this.icon,
    required this.gradient,
    required this.ctaPrimary,
    required this.ctaSecondary,
  });
}

class _HeroBannerCard extends StatelessWidget {
  final _HeroBannerData data;

  const _HeroBannerCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: data.gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x334F46E5),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: -30,
            top: -24,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -18,
            bottom: -20,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(32),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        data.chip,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(data.icon, color: Colors.white, size: 22),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  data.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    height: 1.3,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data.subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.statLabel,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              data.statValue,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        data.ctaPrimary,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        data.ctaSecondary,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkerCard extends ConsumerWidget {
  final WorkerModel worker;
  final AppCurrency currency;
  final VoidCallback onTap;

  const _WorkerCard({
    required this.worker,
    required this.currency,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Stack(
            children: [
              Hero(
                tag: 'worker-${worker.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AppImage(
                    url: worker.imageUrl,
                    width: 84,
                    height: 84,
                  ),
                ),
              ),
              if (worker.isAvailable)
                Positioned(
                  bottom: -2,
                  left: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                  Expanded(
                    child: Text(
                      worker.name,
                      style: TextStyle(
                        color: context.ink,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                    AnimatedLikeButton(
                      size: 20,
                      activeColor: AppColors.error,
                      initialLiked: ref
                          .watch(favoritesProvider)
                          .contains(worker.id),
                      onChanged: (_) => ref
                          .read(favoritesProvider.notifier)
                          .toggle(worker.id),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.warning,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      worker.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: context.ink,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppColors.stroke,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.work_history_rounded,
                      size: 14,
                      color: AppColors.muted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${worker.jobsCompleted} مهمة',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        worker.category,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: worker.isAvailable
                            ? AppColors.success.withValues(alpha: 0.12)
                            : AppColors.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        worker.isAvailable ? 'متاحة الآن' : 'مشغولة',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: worker.isAvailable
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      currency.format(worker.hourlyRate),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const Text(
                      '/ساعة',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RevealOnBuild extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _RevealOnBuild({required this.child, required this.delay});

  @override
  State<_RevealOnBuild> createState() => _RevealOnBuildState();
}

class _RevealOnBuildState extends State<_RevealOnBuild> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (!mounted) return;
      setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      offset: _visible ? Offset.zero : const Offset(0, 0.08),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 420),
        opacity: _visible ? 1 : 0,
        child: widget.child,
      ),
    );
  }
}



