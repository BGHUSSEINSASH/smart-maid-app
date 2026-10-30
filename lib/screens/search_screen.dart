import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../data/catalog.dart';
import '../providers/currency_provider.dart';
import 'worker_profile_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String initialQuery;
  const SearchScreen({super.key, this.initialQuery = ''});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _queryCtrl =
      TextEditingController(text: widget.initialQuery);
  String? _category;
  double _maxPrice = 40;
  double _minRating = 0;
  String? _city;
  bool _availableOnly = false;

  @override
  void dispose() {
    _queryCtrl.dispose();
    super.dispose();
  }

  bool _matches(w) {
    final q = _queryCtrl.text.trim();
    if (q.isNotEmpty &&
        !(w.name.contains(q) ||
            w.category.contains(q) ||
            w.skills.any((s) => s.contains(q)))) {
      return false;
    }
    if (_category != null && w.category != _category) return false;
    if (w.hourlyRate > _maxPrice) return false;
    if (w.rating < _minRating) return false;
    if (_city != null && _city != 'الكل' && w.location != _city) return false;
    if (_availableOnly && !w.isAvailable) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    final all = [...Catalog.workers, ...Catalog.companyWorkers];
    final results = all.where(_matches).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // المدن تُشتق من بيانات الخادم الفعلية — لا قيم مُثبتة.
    final cities = [
      'الكل',
      ...{for (final w in all) w.location}.where((c) => c.trim().isNotEmpty),
    ];

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(title: const Text('بحث وفلترة')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: TextField(
              controller: _queryCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'ابحث بالاسم أو الخدمة أو المهارة...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _queryCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _queryCtrl.clear();
                          setState(() {});
                        }),
              ),
            ),
          ),
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                for (final c in Catalog.categories)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ChoiceChip(
                      avatar: Text(c.$1),
                      label: Text(c.$2,
                          style: TextStyle(
                              fontSize: 12,
                              color: _category == c.$2
                                  ? AppColors.primary
                                  : AppColors.muted)),
                      selected: _category == c.$2,
                      selectedColor:
                          AppColors.primary.withValues(alpha: 0.15),
                      onSelected: (sel) =>
                          setState(() => _category = sel ? c.$2 : null),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.stroke),
            ),
            child: Column(
              children: [
                Row(children: [
                  const Icon(Icons.payments_rounded,
                      size: 17, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text('أقصى سعر: ${currency.format(_maxPrice)}/ساعة',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700)),
                ]),
                Slider(
                  value: _maxPrice,
                  min: 10,
                  max: 40,
                  divisions: 6,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _maxPrice = v),
                ),
                Row(children: [
                  const Icon(Icons.star_rounded,
                      size: 17, color: AppColors.warning),
                  const SizedBox(width: 6),
                  Text('أدنى تقييم: ${_minRating.toStringAsFixed(1)}',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700)),
                ]),
                Slider(
                  value: _minRating,
                  min: 0,
                  max: 5,
                  divisions: 5,
                  activeColor: AppColors.warning,
                  onChanged: (v) => setState(() => _minRating = v),
                ),
                Row(children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _city ?? 'الكل',
                      decoration: const InputDecoration(
                          labelText: 'المدينة',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                      items: cities
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _city = v),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: const Text('متاحة فقط',
                          style: TextStyle(fontSize: 13)),
                      value: _availableOnly,
                      activeThumbColor: AppColors.primary,
                      onChanged: (v) => setState(() => _availableOnly = v),
                    ),
                  ),
                ]),
              ],
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 64, color: AppColors.textHint),
                        const SizedBox(height: 12),
                        const Text('لا نتائج مطابقة، جرّب توسيع الفلاتر'),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final w = results[i];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    WorkerProfileScreen(worker: w))),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceDark
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.stroke),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundImage: NetworkImage(w.imageUrl),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(w.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w800)),
                                    Text('${w.category} • ${w.location}',
                                        style: const TextStyle(
                                            fontSize: 11.5,
                                            color: AppColors.muted)),
                                    Row(children: [
                                      const Icon(Icons.star_rounded,
                                          size: 14, color: AppColors.warning),
                                      Text('${w.rating} (${w.reviewCount})',
                                          style: const TextStyle(
                                              fontSize: 11.5)),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 7,
                                        height: 7,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: w.isAvailable
                                              ? AppColors.success
                                              : AppColors.warning,
                                        ),
                                      ),
                                      Text(
                                          w.isAvailable
                                              ? ' متاحة'
                                              : ' مشغولة',
                                          style:
                                              const TextStyle(fontSize: 11)),
                                    ]),
                                  ],
                                ),
                              ),
                              Text(currency.format(w.hourlyRate),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary)),
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
  }
}
