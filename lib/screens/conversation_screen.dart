import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/adaptive.dart';
import '../core/ui/time_format.dart';
import '../data/models.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/app_image.dart';

/// محادثة حجز واحدة: الرسائل من الخادم فقط، ولا ردود تلقائية.
class ConversationScreen extends ConsumerStatefulWidget {
  final String bookingId;
  final String title;
  final String avatarUrl;

  const ConversationScreen({
    super.key,
    required this.bookingId,
    this.title = 'المحادثة',
    this.avatarUrl = '',
  });

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _loading = true;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final error = await ref.read(chatProvider.notifier).load(widget.bookingId);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = error;
    });
    _jumpBottom();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    final error =
        await ref.read(chatProvider.notifier).send(widget.bookingId, text);
    if (!mounted) return;
    if (error != null) {
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.error,
      ));
      return;
    }
    _ctrl.clear();
    HapticFeedback.lightImpact();
    setState(() => _sending = false);
    _jumpBottom();
  }

  Future<void> _report() async {
    final reasonCtrl = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الإبلاغ عن محادثة'),
        content: TextField(
          controller: reasonCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'اذكر سبب الإبلاغ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, reasonCtrl.text.trim()),
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
    if (reason == null || reason.length < 3) return;
    final error =
        await ref.read(chatProvider.notifier).report(widget.bookingId, reason);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error ?? 'تم إرسال البلاغ، وتُراجع خلال 24 ساعة'),
      behavior: SnackBarBehavior.floating,
      backgroundColor: error == null ? AppColors.success : AppColors.error,
    ));
  }

  void _jumpBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider)[widget.bookingId] ?? const [];

    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            AppAvatar(url: widget.avatarUrl, radius: 18, label: widget.title),
            const SizedBox(width: 10),
            Flexible(
              child: Text(widget.title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'إبلاغ',
            onPressed: _report,
            icon: const Icon(Icons.flag_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildBody(messages)),
          _buildInput(context),
        ],
      ),
    );
  }

  Widget _buildBody(List<MessageModel> messages) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _load,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }
    if (messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'لا توجد رسائل بعد. اكتب رسالتك إلى مقدّم الخدمة.',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.mutedText),
          ),
        ),
      );
    }
    final myId = ref.read(authProvider).user?.id ?? '';
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, i) {
        final m = messages[i];
        final showDay =
            i == 0 || m.timestamp.day != messages[i - 1].timestamp.day;
        return Column(
          children: [
            if (showDay) _dayChip(m.timestamp, context),
            _bubble(m, m.senderId == myId, context),
          ],
        );
      },
    );
  }

  Widget _dayChip(DateTime time, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: context.isDark
              ? Colors.white10
              : Colors.black.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(daySeparatorLabel(time),
            style: TextStyle(fontSize: 10.5, color: context.mutedText)),
      ),
    );
  }

  Widget _bubble(MessageModel m, bool mine, BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: m.content));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('تم نسخ الرسالة'),
            behavior: SnackBarBehavior.floating));
      },
      child: Align(
        alignment: mine ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
            color: mine ? AppColors.primary : context.surface,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(mine ? 4 : 18),
              bottomRight: Radius.circular(mine ? 18 : 4),
            ),
            border: Border.all(
                color: mine ? AppColors.primary : context.stroke),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(m.content,
                  style: TextStyle(
                      fontSize: 13.5,
                      height: 1.45,
                      color: mine ? Colors.white : context.ink)),
              const SizedBox(height: 4),
              Text(DateFormat('HH:mm').format(m.timestamp),
                  style: TextStyle(
                      fontSize: 9.5,
                      color: mine ? Colors.white60 : AppColors.textHint)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 4, 14, 12),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: context.stroke),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: const InputDecoration(
                  hintText: 'اكتب رسالة...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                ),
              ),
            ),
            IconButton(
              onPressed: _sending ? null : _send,
              icon: _sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.send_rounded, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
