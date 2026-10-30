import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';

const _faqItems = <(String, String)>[
  (
    'كيف أحجز خدمة؟',
    'اختر الخدمة من الرئيسية، حدد التاريخ والوقت ونوع المدة، ثم أكد الطلب. يصل الطلب إلى مقدّم الخدمة ليَقبله، وتظهر حالة الحجز في «حجوزاتي» بعد القبول.'
  ),
  (
    'ما هي طرق الدفع المتاحة؟',
    'الدفع نقداً لمقدّم الخدمة بعد إتمام العمل. التطبيق لا يطلب بيانات بطاقة ولا يحتفظ بها.'
  ),
  (
    'هل يمكنني إلغاء الحجز؟',
    'نعم، الإلغاء مجاني حتى 24 ساعة قبل الموعد من شاشة تفاصيل الحجز. الإلغاء في وقت أقرب يحتاج مراجعة الدعم. وبما أن الدفع نقدي، لا يوجد مبلغ مخصوم عند الإلغاء.'
  ),
  (
    'كيف تعمل نقاط المكافآت؟',
    'تحصل على نقاط بعد إتمام حجز فعلي، ويمكنك استبدالها بكوبون خصم من شاشة النقاط. الكوبون يُقبل في شاشة الدفع. والنقاط غير قابلة للتحويل إلى نقد.'
  ),
  (
    'كيف أقيّم الخدمة؟',
    'التقييم يُتاح بعد إتمام الحجز فقط، ويظهر للجميع. يمكنك الإبلاغ عن أي رسالة أو مستخدم من داخل المحادثة.'
  ),
  (
    'ما الذي تحصل عليه المنصة؟',
    'المنصة لا تضيف رسوماً على السعر المعروض لك. أي عمولة على مقدّم الخدمة تُعلن له عند التسجيل.'
  ),
  (
    'هل توجد محفظة أو اشتراكات؟',
    'لا في هذا الإصدار. شحن المحفظة والاشتراكات المدفوعة غير مفعّلة، ولا يظهر أي زر لها في التطبيق.'
  ),
];

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(title: const Text('الأسئلة الشائعة')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ..._faqItems.map((e) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.stroke),
                ),
                child: ExpansionTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: Text(e.$1,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  iconColor: AppColors.primary,
                  collapsedIconColor: AppColors.muted,
                  childrenPadding:
                      const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  children: [
                    Text(e.$2,
                        style: TextStyle(
                            fontSize: 13,
                            height: 1.7,
                            color: isDark
                                ? Colors.white70
                                : AppColors.muted)),
                  ],
                ),
              )),
          const SizedBox(height: 10),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4))),
            leading: const Icon(Icons.support_agent_rounded,
                color: AppColors.primary),
            title: const Text('لم تجد إجابتك؟',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
            subtitle: const Text('تواصل مع فريق الدعم مباشرة',
                style: TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.chevron_left_rounded),
            onTap: () => context.push('/chat'),
          ),
        ],
      ),
    );
  }
}
