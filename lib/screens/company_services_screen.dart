import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../data/demo_data.dart';

class CompanyServicesScreen extends ConsumerStatefulWidget {
  const CompanyServicesScreen({super.key});

  @override
  ConsumerState<CompanyServicesScreen> createState() =>
      _CompanyServicesScreenState();
}

class _CompanyServicesScreenState extends ConsumerState<CompanyServicesScreen> {
  late final List<({String name, String emoji, double price, bool active})>
      _services = [
    for (final e in DemoData.extraServices)
      (name: e.name, emoji: e.icon, price: e.priceUsd, active: true),
    const (
      name: 'تنظيف السجاد',
      emoji: '🧶',
      price: 35.0,
      active: false
    ),
  ];

  void _editPrice(int index) {
    final ctrl = TextEditingController(
        text: _services[index].price.toStringAsFixed(0));
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('تعديل سعر ${_services[index].name}',
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'السعر (\$)', prefixText: '\$ '),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final v = double.tryParse(ctrl.text.trim());
                    if (v != null && v > 0) {
                      setState(() {
                        _services[index] =
                            (
                          name: _services[index].name,
                          emoji: _services[index].emoji,
                          price: v,
                          active: _services[index].active,
                        );
                      });
                    }
                    Navigator.pop(ctx);
                  },
                  child: const Text('حفظ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(title: const Text('خدماتنا وأسعارنا')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _services.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final s = _services[i];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.stroke),
            ),
            child: Row(children: [
              Text(s.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(s.name,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                        color:
                            s.active ? null : AppColors.textHint)),
              ),
              TextButton(
                onPressed: () => _editPrice(i),
                child: Text('\$${s.price.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
              Switch(
                value: s.active,
                activeThumbColor: AppColors.success,
                onChanged: (v) => setState(() {
                  _services[i] = (
                    name: s.name,
                    emoji: s.emoji,
                    price: s.price,
                    active: v,
                  );
                }),
              ),
            ]),
          );
        },
      ),
    );
  }
}
