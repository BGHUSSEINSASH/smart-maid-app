import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/ai/assistant_engine.dart';
import '../core/api/api_client.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/adaptive.dart';
import '../data/repository.dart';

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantEntry {
  final String text;
  final bool fromUser;
  final List<AssistantMatch> matches;

  _AssistantEntry({
    required this.text,
    required this.fromUser,
    this.matches = const [],
  });
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<_AssistantEntry> _entries = [
    _AssistantEntry(
      fromUser: false,
      text:
          'مرحباً! أنا مساعد شغالتي.\nصف لي ما تحتاجه — مثلاً «أحتاج عاملة طبخ 3 مرات بالأسبوع» — وسأقترح المتاح لك.',
    ),
  ];
  bool _thinking = false;

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _thinking) return;
    _ctrl.clear();
    setState(() {
      _thinking = true;
      _entries.add(_AssistantEntry(text: text, fromUser: true));
    });
    _jumpBottom();

    final matches = matchWorkers(text);
    // المساعد يعمل عبر خادمنا فقط (لا اتصال مباشر بأي نموذج من الهاتف)،
    // وإن لم يكن النموذج مفعّلاً على الخادم تُستخدم مطابقة الكلمات المحلية.
    String reply;
    try {
      reply = await TrustRepository.askAi(text);
    } on ApiException {
      reply = buildFallbackReply(text, matches);
    }

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _thinking = false;
      _entries.add(_AssistantEntry(
        text: reply,
        fromUser: false,
        matches: matches,
      ));
    });
    _jumpBottom();
  }

  void _jumpBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppColors.assistantGradient,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Text('🔍', style: TextStyle(fontSize: 17)),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('المساعد',
                  style: TextStyle(fontSize: 15.5)),
              const Text(
                    'وضع المطابقة',
                    style: TextStyle(fontSize: 10.5, color: AppColors.muted),
                ),
            ],
          ),
        ]),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: _entries.length + (_thinking ? 1 : 0),
              itemBuilder: (context, i) {
                if (_thinking && i == _entries.length) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: context.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: context.stroke),
                      ),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2)),
                        SizedBox(width: 8),
                        Text('يفكر...', style: TextStyle(fontSize: 12)),
                      ]),
                    ),
                  );
                }
                final e = _entries[i];
                return Align(
                  alignment: e.fromUser
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 11),
                    constraints: BoxConstraints(
                        maxWidth:
                            MediaQuery.of(context).size.width * 0.8),
                    decoration: BoxDecoration(
                      color: e.fromUser
                          ? AppColors.primary
                          : context.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color:
                              e.fromUser ? AppColors.primary : context.stroke),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.text,
                          style: TextStyle(
                              fontSize: 13.5,
                              height: 1.55,
                              color: e.fromUser
                                  ? Colors.white
                                  : context.ink),
                        ),
                        for (final m in e.matches)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => context.push('/worker/${m.workerId}'),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 9),
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.07),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.3)),
                                ),
                                child: Row(children: [
                                  const Icon(Icons.person_search_rounded,
                                      size: 16, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text('${m.name} — ${m.reason}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700)),
                                  ),
                                  const Icon(Icons.chevron_left_rounded,
                                      size: 15, color: AppColors.muted),
                                ]),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              margin: const EdgeInsets.fromLTRB(14, 4, 14, 12),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: context.stroke),
              ),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'مثال: أحتاج عاملة تنظيف عميق...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      fillColor: Colors.transparent,
                      hintStyle:
                          TextStyle(fontSize: 13, color: context.mutedText),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _send,
                  icon: const Icon(Icons.send_rounded,
                      color: AppColors.primary),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
