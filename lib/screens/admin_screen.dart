import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../providers/currency_provider.dart';
import '../widgets/pro_components.dart';
import '../widgets/micro_interactions.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});
  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          // ── Header ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE8F8F2), AppColors.surface],
                ),
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 24,
                left: 20, right: 20, bottom: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('مرحباً بك، مدير النظام 👋', style: TextStyle(color: AppColors.muted, fontSize: 13, fontWeight: FontWeight.w600)),
                            SizedBox(height: 4),
                            Text('لوحة التحكم المركزية', style: TextStyle(color: AppColors.ink, fontSize: 24, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (_isLoading)
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList.list(
                children: List.generate(4, (_) => const Padding(padding: EdgeInsets.only(bottom: 16), child: SkeletonLoader(width: double.infinity, height: 120))),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Quick Stats ─────────────────────────────────────────────
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.4,
                    children: [
                      _StatCard(title: 'إيرادات اليوم', value: currency.format(12450), icon: Icons.attach_money_rounded, color: AppColors.primary, isCurrency: true),
                      _StatCard(title: 'الشركات النشطة', value: '14', icon: Icons.business_rounded, color: const Color(0xFF8B5CF6)),
                      _StatCard(title: 'العاملات المتاحات', value: '45', icon: Icons.people_alt_rounded, color: const Color(0xFF3B82F6)),
                      _StatCard(title: 'الطلبات المعلقة', value: '8', icon: Icons.pending_actions_rounded, color: AppColors.warning),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  const SectionHeader(title: 'إدارة النظام السريعة'),
                  const SizedBox(height: 16),
                  
                  // ── Quick Actions ───────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(child: _ActionCard(title: 'المستخدمين', icon: Icons.group_rounded, color: const Color(0xFFE0F2FE), iconColor: const Color(0xFF0284C7))),
                      const SizedBox(width: 16),
                      Expanded(child: _ActionCard(title: 'الشركات', icon: Icons.domain_rounded, color: const Color(0xFFF3E8FF), iconColor: const Color(0xFF7E22CE))),
                      const SizedBox(width: 16),
                      Expanded(child: _ActionCard(title: 'المالية', icon: Icons.account_balance_wallet_rounded, color: const Color(0xFFDCFCE7), iconColor: const Color(0xFF166534))),
                    ],
                  ),

                  const SizedBox(height: 32),
                  const SectionHeader(title: 'أحدث التنبيهات'),
                  const SizedBox(height: 16),

                  // ── Alerts List ─────────────────────────────────────────────
                  ProCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _AlertItem(title: 'طلب انضمام شركة جديدة', subtitle: 'شركة النظافة المتقدمة تنتظر الموافقة', time: 'منذ 10 دقائق', isUrgent: true),
                        const Divider(height: 1, indent: 60),
                        _AlertItem(title: 'سحب أرباح معلق', subtitle: 'تم طلب سحب بقيمة ', time: 'منذ ساعة', isUrgent: false),
                        const Divider(height: 1, indent: 60),
                        _AlertItem(title: 'شكوى جديدة مسجلة', subtitle: 'العميل أحمد رفع تذكرة دعم للطلب #4092', time: 'منذ ساعتين', isUrgent: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isCurrency;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color, this.isCurrency = false});

  @override
  Widget build(BuildContext context) {
    return ProCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              isCurrency ? 
                Text(value, style: const TextStyle(color: AppColors.ink, fontSize: 20, fontWeight: FontWeight.w900)) :
                AnimatedCounter(initialValue: int.parse(value), onChanged: (_) {}), // Visual only
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Color iconColor;

  const _ActionCard({required this.title, required this.icon, required this.color, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: iconColor.withAlpha(40)),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(color: iconColor, fontSize: 13, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _AlertItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final bool isUrgent;

  const _AlertItem({required this.title, required this.subtitle, required this.time, required this.isUrgent});

  @override
  Widget build(BuildContext context) {
    return ProListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isUrgent ? AppColors.error.withAlpha(20) : AppColors.primary.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(isUrgent ? Icons.warning_rounded : Icons.info_rounded, color: isUrgent ? AppColors.error : AppColors.primary, size: 22),
      ),
      title: title,
      subtitle: subtitle,
      trailing: Text(time, style: const TextStyle(color: AppColors.muted, fontSize: 11, fontWeight: FontWeight.w600)),
      onTap: () {},
    );
  }
}
