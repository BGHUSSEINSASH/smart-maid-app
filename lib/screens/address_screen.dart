import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../core/theme/app_theme.dart';
import '../providers/address_provider.dart';

class AddressScreen extends ConsumerStatefulWidget {
  const AddressScreen({super.key});

  @override
  ConsumerState<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends ConsumerState<AddressScreen> {
  List<({String display, double lat, double lon})> _osmResults = [];
  Timer? _debounce;

  void _searchOsmDebounced(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () => _searchOsm(q));
  }

  Future<void> _searchOsm(String q) async {
    if (q.trim().length < 3) {
      setState(() => _osmResults = []);
      return;
    }
    try {
      final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/search?format=json&limit=5&q=${Uri.encodeComponent(q.trim())}');
      final res = await http
          .get(uri, headers: {'User-Agent': 'SmartMaidApp/1.0'})
          .timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final list = jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
        setState(() {
          _osmResults = list
              .map((e) => (
                    display: e['display_name'].toString(),
                    lat: double.parse(e['lat'].toString()),
                    lon: double.parse(e['lon'].toString()),
                  ))
              .toList();
        });
      }
    } catch (_) {
      if (mounted) setState(() => _osmResults = []);
    }
  }

  void _form({AddressModel? existing, ({String display, double lat, double lon})? prefill}) {
    final labelCtrl =
        TextEditingController(text: existing?.label ?? '');
    final cityCtrl = TextEditingController(text: existing?.city ?? '');
    final detailsCtrl = TextEditingController(
        text: existing?.details ?? prefill?.display ?? '');
    double? lat = existing?.lat ?? prefill?.lat;
    double? lon = existing?.lon ?? prefill?.lon;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
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
              Text(existing == null ? 'إضافة عنوان' : 'تعديل العنوان',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              TextField(
                controller: labelCtrl,
                decoration:
                    const InputDecoration(labelText: 'الوسم (منزل، مكتب...)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cityCtrl,
                decoration: const InputDecoration(labelText: 'المدينة'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: detailsCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                    labelText: 'التفاصيل الكاملة'),
                onChanged: (v) => _searchOsmDebounced(v),
              ),
              if (_osmResults.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  constraints: const BoxConstraints(maxHeight: 160),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.stroke),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _osmResults.length,
                    itemBuilder: (ctx, i) {
                      final r = _osmResults[i];
                      return ListTile(
                        dense: true,
                        leading:
                            const Icon(Icons.place_rounded, size: 17),
                        title: Text(r.display,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11.5)),
                        onTap: () {
                          setState(() {
                            detailsCtrl.text = r.display;
                            lat = r.lat;
                            lon = r.lon;
                            _osmResults = [];
                          });
                        },
                      );
                    },
                  ),
                ),
              if (lat != null && lon != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(children: [
                    const Icon(Icons.gps_fixed_rounded,
                        size: 13, color: AppColors.success),
                    const SizedBox(width: 5),
                    Text(
                      'الموقع: ${lat!.toStringAsFixed(4)}, ${lon!.toStringAsFixed(4)}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.success),
                    ),
                  ]),
                ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (labelCtrl.text.trim().isEmpty ||
                        cityCtrl.text.trim().isEmpty) {
                      return;
                    }
                    final notifier = ref.read(addressProvider.notifier);
                    if (existing == null) {
                      notifier.add(labelCtrl.text.trim(),
                          cityCtrl.text.trim(), detailsCtrl.text.trim(),
                          lat: lat, lon: lon);
                    } else {
                      notifier.update(existing.copyWith(
                        label: labelCtrl.text.trim(),
                        city: cityCtrl.text.trim(),
                        details: detailsCtrl.text.trim(),
                        lat: lat,
                        lon: lon,
                      ));
                    }
                    Navigator.pop(ctx);
                  },
                  child:
                      Text(existing == null ? 'إضافة' : 'حفظ التعديلات'),
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
    final addresses = ref.watch(addressProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(title: const Text('عناويني')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _form(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_location_alt_rounded, size: 19),
        label: const Text('عنوان جديد'),
      ),
      body: addresses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off_rounded,
                      size: 64, color: AppColors.textHint),
                  const SizedBox(height: 12),
                  const Text('لا توجد عناوين محفوظة'),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: addresses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final a = addresses[i];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color:
                            a.isDefault ? AppColors.primary : AppColors.stroke,
                        width: a.isDefault ? 1.6 : 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(
                          a.isDefault
                              ? Icons.home_rounded
                              : Icons.location_on_rounded,
                          color: AppColors.primary,
                          size: 21,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('${a.label} — ${a.city}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 15)),
                        ),
                        if (a.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text('افتراضي',
                                style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary)),
                          ),
                      ]),
                      const SizedBox(height: 6),
                      Text(a.details,
                          style: const TextStyle(
                              fontSize: 13, height: 1.5, color: AppColors.muted)),
                      const SizedBox(height: 10),
                      Row(children: [
                        if (!a.isDefault)
                          TextButton.icon(
                            onPressed: () => ref
                                .read(addressProvider.notifier)
                                .setDefault(a.id),
                            icon: const Icon(Icons.star_border_rounded,
                                size: 16),
                            label: const Text('تعيين كافتراضي',
                                style: TextStyle(fontSize: 12)),
                          ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => _form(existing: a),
                          icon: const Icon(Icons.edit_outlined, size: 18),
                        ),
                        IconButton(
                          onPressed: () => ref
                              .read(addressProvider.notifier)
                              .remove(a.id),
                          icon: const Icon(Icons.delete_outline_rounded,
                              size: 18, color: AppColors.error),
                        ),
                      ]),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

