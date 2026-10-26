import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/adaptive.dart';
import '../providers/currency_provider.dart';
import '../providers/health_provider.dart';
import '../widgets/pro_components.dart';
import 'admin_companies_screen.dart';
import 'admin_disputes_screen.dart';
import 'admin_finance_screen.dart';
import 'admin_users_screen.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});
  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      backgroundColor: context.pageBg,
      body: CustomScrollView(
        slivers: [
          // ── Header ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: AdaptiveHeader(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings_rounded,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'مرحباً بك، مدير النظام 👋',
                              style: TextStyle(
                                color: context.mutedText,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'لوحة تحكم مؤسس النظام',
                              style: TextStyle(
                                color: context.ink,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: AppColors.heroGradient,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '⚡ صلاحيات كاملة',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

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
                      _StatCard(
                        title: 'إيرادات اليوم',
                        value: currency.format(12450),
                        icon: Icons.attach_money_rounded,
                        color: AppColors.primary,
                        isCurrency: true,
                      ),
                      _StatCard(
                        title: 'الشركات النشطة',
                        value: '14',
                        icon: Icons.business_rounded,
                        color: const Color(0xFF8B5CF6),
                      ),
                      _StatCard(
                        title: 'العاملات المتاحات',
                        value: '45',
                        icon: Icons.people_alt_rounded,
                        color: const Color(0xFF3B82F6),
                      ),
                      _StatCard(
                        title: 'الطلبات المعلقة',
                        value: '8',
                        icon: Icons.pending_actions_rounded,
                        color: AppColors.warning,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  const SectionHeader(title: 'إيرادات آخر 7 أيام'),
                  const SizedBox(height: 16),
                  ProCard(
                    child: SizedBox(
                      height: 180,
                      child: _RevenueChart(),
                    ),
                  ),

                  const SizedBox(height: 32),
                  const SectionHeader(title: 'إدارة النظام السريعة'),
                  const SizedBox(height: 16),

                  // ── Quick Actions ───────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _ActionCard(
                          title: 'المستخدمين',
                          icon: Icons.group_rounded,
                          color: const Color(0xFFE0F2FE),
                          iconColor: const Color(0xFF0284C7),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUsersScreen())),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ActionCard(
                          title: 'الشركات',
                          icon: Icons.domain_rounded,
                          color: const Color(0xFFF3E8FF),
                          iconColor: const Color(0xFF7E22CE),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCompaniesScreen())),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ActionCard(
                          title: 'المالية',
                          icon: Icons.account_balance_wallet_rounded,
                          color: const Color(0xFFDCFCE7),
                          iconColor: const Color(0xFF166534),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminFinanceScreen())),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(
                      child: _ActionCard(
                        title: 'البلاغات والنزاعات',
                        icon: Icons.gavel_rounded,
                        color: const Color(0xFFFFF7ED),
                        iconColor: const Color(0xFFEA580C),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDisputesScreen())),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ActionCard(
                        title: 'سجل التدقيق',
                        icon: Icons.receipt_long_rounded,
                        color: const Color(0xFFEEF2FF),
                        iconColor: AppColors.primary,
                        onTap: () => context.push('/admin/audit'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ActionCard(
                        title: 'الأمان',
                        icon: Icons.security_rounded,
                        color: const Color(0xFFF1F5F9),
                        iconColor: const Color(0xFF334155),
                        onTap: () => context.push('/security'),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 32),
                  const SectionHeader(title: 'أحدث التنبيهات'),
                  const SizedBox(height: 16),

                  // ── Alerts List ─────────────────────────────────────────────
                  ProCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _AlertItem(
                          title: 'طلب انضمام شركة جديدة',
                          subtitle: 'شركة النظافة المتقدمة تنتظر الموافقة',
                          time: 'منذ 10 دقائق',
                          isUrgent: true,
                        ),
                        const Divider(height: 1, indent: 60),
                        _AlertItem(
                          title: 'سحب أرباح معلق',
                          subtitle: 'تم طلب سحب بقيمة ',
                          time: 'منذ ساعة',
                          isUrgent: false,
                        ),
                        const Divider(height: 1, indent: 60),
                        _AlertItem(
                          title: 'شكوى جديدة مسجلة',
                          subtitle: 'العميل أحمد رفع تذكرة دعم للطلب #4092',
                          time: 'منذ ساعتين',
                          isUrgent: true,
                        ),
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

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isCurrency = false,
  });

  @override
  Widget build(BuildContext context) {
    return ProCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.mutedText,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(
                    color: context.ink,
                    fontSize: isCurrency ? 19 : 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
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
  final VoidCallback? onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                maxLines: 1,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
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

  const _AlertItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isUrgent,
  });

  @override
  Widget build(BuildContext context) {
    return ProListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isUrgent
              ? AppColors.error.withAlpha(20)
              : AppColors.primary.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          isUrgent ? Icons.warning_rounded : Icons.info_rounded,
          color: isUrgent ? AppColors.error : AppColors.primary,
          size: 22,
        ),
      ),
      title: title,
      subtitle: subtitle,
      trailing: Text(
        time,
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: () {},
    );
  }
}

class _RevenueChart extends StatelessWidget {
  static const _values = [8.2, 9.6, 7.4, 11.2, 10.1, 12.8, 12.45];
  static const _days = ['سبت', 'أحد', 'اثن', 'ثلا', 'أرب', 'خمي', 'جمع'];

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 14,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, meta) {
                final i = v.toInt();
                if (i < 0 || i >= _days.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(_days[i],
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.muted)),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < _values.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: _values[i],
                width: 16,
                borderRadius: BorderRadius.circular(6),
                gradient: AppColors.heroGradient,
              ),
            ]),
        ],
      ),
    );
  }
}
