import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/adaptive.dart';
import '../data/demo_data.dart';
import '../data/models.dart';
import '../providers/address_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/loyalty_provider.dart';
import 'address_screen.dart';
import 'catalog_screen.dart';
import 'edit_profile_screen.dart';
import 'faq_screen.dart';
import 'favorites_screen.dart';
import 'loyalty_screen.dart';
import 'notifications_screen.dart';
import 'offers_screen.dart';
import 'referral_screen.dart';
import 'settings_screen.dart';
import 'wallet_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user ?? DemoData.admin;
    final bookingsCount = ref.watch(myBookingsProvider).length;
    final favCount = ref.watch(favoritesProvider).length;
    final points = ref.watch(loyaltyProvider).points;
    final addresses = ref.watch(addressProvider).length;
    final roleLabel = user.role.arabicLabel;

    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(title: const Text('حسابي')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: AppRadii.card,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      backgroundImage: NetworkImage(user.imageUrl),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(user.email,
                              style:
                                  const TextStyle(color: Colors.white70)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(roleLabel,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _MiniStat(
                        label: 'الحجوزات', value: '$bookingsCount'),
                    _MiniStat(label: 'المفضلة', value: '$favCount'),
                    _MiniStat(label: 'النقاط', value: '$points'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _SectionLabel('المالية والمكافآت'),
          const SizedBox(height: 8),
          _MenuCard(items: [
            _MenuItem(
              icon: Icons.account_balance_wallet_rounded,
              title: 'محفظة SmartPay',
              subtitle: 'الرصيد، الشحن، والمعاملات',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const WalletScreen())),
            ),
            _MenuItem(
              icon: Icons.emoji_events_rounded,
              title: 'نقاط المكافآت',
              subtitle: '$points نقطة — استبدلها بخصومات',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LoyaltyScreen())),
            ),
            _MenuItem(
              icon: Icons.card_giftcard_rounded,
              title: 'العروض والكوبونات',
              subtitle: 'خصومات حصرية لك',
              onTap: () => _pushNamedOffers(context),
            ),
          ]),
          const SizedBox(height: 14),
          _SectionLabel('حسابي وتفضيلاتي'),
          const SizedBox(height: 8),
          _MenuCard(items: [
            _MenuItem(
              icon: Icons.edit_rounded,
              title: 'تعديل الملف الشخصي',
              subtitle: 'الاسم، الهاتف، الصورة',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen())),
            ),
            _MenuItem(
              icon: Icons.favorite_rounded,
              title: 'المفضلة',
              subtitle: '$favCount عاملة محفوظة',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const FavoritesScreen())),
            ),
            _MenuItem(
              icon: Icons.location_on_rounded,
              title: 'عناويني',
              subtitle: '$addresses عناوين محفوظة',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AddressScreen())),
            ),
            _MenuItem(
              icon: Icons.notifications_rounded,
              title: 'الإشعارات',
              subtitle: 'آخر التحديثات والعروض',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationsScreen())),
            ),
            _MenuItem(
              icon: Icons.people_alt_rounded,
              title: 'ادعُ أصدقاءك',
              subtitle: '+100 نقطة لكل صديق ينضم',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ReferralScreen())),
            ),
          ]),
          const SizedBox(height: 14),
          _SectionLabel('الدعم والإعدادات'),
          const SizedBox(height: 8),
          _MenuCard(items: [
            _MenuItem(
              icon: Icons.help_outline_rounded,
              title: 'الأسئلة الشائعة',
              subtitle: 'إجابات سريعة عن أكثر ما يسأل عنه',
              onTap: () =>
                  _pushFaq(context),
            ),
            _MenuItem(
              icon: Icons.settings_outlined,
              title: 'الإعدادات',
              subtitle: 'اللغة، الثيم، العملة، الإشعارات',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen())),
            ),
            _MenuItem(
              icon: Icons.cleaning_services_rounded,
              title: 'دليل الخدمات',
              subtitle: 'استعرض 110 خدمة مرتبة حسب الفئات',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CatalogScreen())),
            ),
          ]),
        ],
      ),
    );
  }

  void _pushNamedOffers(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const OffersScreen()));
  }

  void _pushFaq(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const FaqScreen()));
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Text(text,
          style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 14)),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<Widget> items;
  const _MenuCard({required this.items});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: AppColors.stroke)),
      child: Column(children: [
        for (var i = 0; i < items.length; i++) ...[
          items[i],
          if (i < items.length - 1)
            const Divider(height: 1, indent: 56, endIndent: 16),
        ]
      ]),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: AppColors.primary),
      ),
      title: Text(title,
          style:
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.muted)),
      trailing: const Icon(Icons.chevron_left_rounded, size: 20),
      onTap: onTap,
    );
  }
}
