import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/adaptive.dart';
import '../providers/subscription_provider.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sub = ref.watch(subscriptionProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(title: const Text('SmartGold Membership')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Current status
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: sub.isActive
                  ? const LinearGradient(
                      colors: [Color(0xFFD4A574), Color(0xFFC49A6C)],
                    )
                  : AppColors.heroGradient,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                Icon(
                  sub.tier == SubscriptionTier.platinum
                      ? Icons.diamond_rounded
                      : sub.tier == SubscriptionTier.gold
                          ? Icons.workspace_premium_rounded
                          : Icons.person_rounded,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                Text(
                  sub.tier.arabicLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (sub.isActive && sub.expiresAt != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'ينتهي في ${sub.expiresAt!.day}/${sub.expiresAt!.month}/${sub.expiresAt!.year}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
                if (!sub.isActive) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'اشترك لتوفير أكثر',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Plans
          Text('اختر باقتك',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textPrimary)),
          const SizedBox(height: 16),

          _PlanCard(
            tier: SubscriptionTier.gold,
            isActive: sub.tier == SubscriptionTier.gold,
            isDark: isDark,
            onSelect: () =>
                ref.read(subscriptionProvider.notifier).subscribe(SubscriptionTier.gold),
          ),
          const SizedBox(height: 12),
          _PlanCard(
            tier: SubscriptionTier.platinum,
            isActive: sub.tier == SubscriptionTier.platinum,
            isDark: isDark,
            onSelect: () => ref
                .read(subscriptionProvider.notifier)
                .subscribe(SubscriptionTier.platinum),
          ),

          if (sub.isActive) ...[
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                onPressed: () =>
                    ref.read(subscriptionProvider.notifier).cancel(),
                icon: const Icon(Icons.cancel_rounded, size: 18),
                label: const Text('إلغاء الاشتراك'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final SubscriptionTier tier;
  final bool isActive;
  final bool isDark;
  final VoidCallback onSelect;

  const _PlanCard({
    required this.tier,
    required this.isActive,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isActive ? null : onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.08)
              : isDark
                  ? AppColors.surfaceDark
                  : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.stroke,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  tier == SubscriptionTier.platinum
                      ? Icons.diamond_rounded
                      : Icons.workspace_premium_rounded,
                  size: 24,
                  color: isActive ? AppColors.primary : AppColors.muted,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(tier.arabicLabel,
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                          color: isActive
                              ? AppColors.primary
                              : (isDark ? Colors.white : AppColors.textPrimary))),
                ),
                if (isActive)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('نشط',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  )
                else
                  Text(
                    '\$${tier.monthlyPrice.toStringAsFixed(2)}/شهر',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.primary),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            ...tier.benefits.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          size: 16, color: AppColors.success),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(b,
                            style: TextStyle(
                                fontSize: 13,
                                color:
                                    isDark ? Colors.white70 : AppColors.textSecondary)),
                      ),
                    ],
                  ),
                )),
            if (!isActive) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: onSelect,
                  icon: const Icon(Icons.star_rounded, size: 18),
                  label: const Text('اشترك الآن'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
