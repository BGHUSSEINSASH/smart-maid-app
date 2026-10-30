import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../providers/currency_provider.dart';
import '../providers/wallet_provider.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);
    final currency = ref.watch(currencyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(title: const Text('محفظة SmartPay')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: AppColors.balanceGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.account_balance_wallet_rounded,
                      color: Colors.white70, size: 18),
                  const SizedBox(width: 6),
                  Text('الرصيد الحالي',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9))),
                ]),
                const SizedBox(height: 10),
                Text(currency.format(wallet.balanceUsd),
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white)),
                const SizedBox(height: 14),
                Text(
                  'شحن الرصيد والسحب غير مفعّلين في هذا الإصدار. الدفع نقداً بعد إتمام الخدمة.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('سجل المعاملات (${wallet.transactions.length})',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          ...wallet.transactions.map((t) {
            final credit = t.isCredit;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.stroke),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: (credit ? AppColors.success : AppColors.error)
                          .withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      switch (t.type) {
                        WalletTxType.topup => Icons.add_card_rounded,
                        WalletTxType.payment => Icons.shopping_bag_rounded,
                        WalletTxType.withdrawal => Icons.upload_rounded,
                        WalletTxType.earning => Icons.trending_up_rounded,
                        WalletTxType.refund => Icons.replay_rounded,
                      },
                      size: 20,
                      color: credit ? AppColors.success : AppColors.error,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13.5)),
                        Text(DateFormat('yyyy/MM/dd – HH:mm').format(t.date),
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.muted)),
                      ],
                    ),
                  ),
                  Text(
                    '${t.amountUsd > 0 ? '+' : ''}${currency.format(t.amountUsd)}',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color:
                            credit ? AppColors.success : AppColors.error),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
