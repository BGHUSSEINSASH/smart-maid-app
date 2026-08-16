import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> with TickerProviderStateMixin {
  final _ctrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [
    {
      'isMe': false,
      'content': 'مرحباً بعملاء النخبة، كيف يسعدنا خدمتك اليوم؟ 👑',
      'time': '10:00 ص'
    }
  ];

  late final AnimationController _bgAnimation;

  @override
  void initState() {
    super.initState();
    _bgAnimation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgAnimation.dispose();
    _ctrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    if (_ctrl.text.trim().isEmpty) return;
    HapticFeedback.mediumImpact(); // 21: التفاعل اللمسي
    setState(() {
      _messages.add({
        'isMe': true,
        'content': _ctrl.text.trim(),
        'time': 'الآن'
      });
      _ctrl.clear();
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117), // 10: كحلي عميق (Dark Sapphire)
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // 2: عناصر زجاجية
            child: AppBar(
              backgroundColor: Colors.white.withAlpha(10), // 4: تجنب الخطوط القاطعة
              elevation: 0,
              centerTitle: true,
              title: Column(
                children: [
                  const Text(
                    'المساعد الشخصي', // 35: دردشة الكونسيرج (Concierge)
                    style: TextStyle(
                      color: Color(0xFFE8D399), // 10: ذهبي هادئ وشامبين
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      fontFamily: 'Cairo', // 5: طباعة فاخرة
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'متصل الآن',
                    style: TextStyle(
                      color: Colors.white.withAlpha(150),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              iconTheme: const IconThemeData(color: Color(0xFFE8D399)),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // 1: خلفيات متدرجة وحيوية (Mesh Gradients)
          AnimatedBuilder(
            animation: _bgAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: -100 + (_bgAnimation.value * 50),
                    left: -100,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1D4E3F), // Emerald / Dark Turquoise
                        boxShadow: [BoxShadow(color: Color(0xFF1D4E3F), blurRadius: 100, spreadRadius: 100)],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -50 - (_bgAnimation.value * 50),
                    right: -50,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE8D399).withAlpha(50), // Bronze/Champagne glow
                        boxShadow: [BoxShadow(color: const Color(0xFFE8D399).withAlpha(50), blurRadius: 120, spreadRadius: 80)],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          
          // Chat View
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(top: 120, left: 20, right: 20, bottom: 20),
                  itemCount: _messages.length,
                  physics: const BouncingScrollPhysics(), // 13: حركة ارتدادية للسوائل
                  itemBuilder: (ctx, i) {
                    final msg = _messages[i];
                    final isMe = msg['isMe'] as bool;
                    
                    return TweenAnimationBuilder(
                      // 12: دخول الرسائل المتتالي والتأخير (Staggered Animation with Fade/Slide)
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut, // Spring logic
                      builder: (context, double val, child) {
                        return Transform.translate(
                          offset: Offset(0, 50 * (1 - val)),
                          child: Opacity(
                            opacity: val.clamp(0.0, 1.0),
                            child: Align(
                              alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20).copyWith(
                                    topLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
                                    topRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
                                  ),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // 2: Glass Card UI
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: isMe ? Colors.white.withAlpha(20) : const Color(0xFF1D4E3F).withAlpha(80),
                                        border: Border.all(
                                          color: isMe ? Colors.white.withAlpha(40) : const Color(0xFFE8D399).withAlpha(50),
                                          width: 1, // 4: Inner Glow Alternative using transparent border
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            msg['content'] as String,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              height: 1.4,
                                              fontFamily: 'Cairo',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            msg['time'] as String,
                                            style: TextStyle(
                                              color: Colors.white.withAlpha(120),
                                              fontSize: 9,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              
              // 47: المساعد الصوتي أو شريط الإدخال العائم 
              ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.only(top: 16, bottom: 32, left: 16, right: 16),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(80),
                      border: Border(top: BorderSide(color: Colors.white.withAlpha(20))),
                    ),
                    child: Row(
                      children: [
                        // Microphone voice concierge
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(10),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withAlpha(20)),
                          ),
                          child: const Icon(Icons.mic_none_rounded, color: Color(0xFFE8D399), size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _ctrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'تحدث إلى الكونسيرج...',
                              hintStyle: TextStyle(color: Colors.white.withAlpha(100), fontSize: 13),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white.withAlpha(15),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            ),
                            onSubmitted: (_) => _send(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 16: النبض المتزامن للزر & 18: تفجير وتفاعل (Morphing effect applied by InkWell/scaling)
                        ElevatedButton(
                          onPressed: _send,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE8D399), // Royal Gold
                            foregroundColor: const Color(0xFF0F1117), // Deep Sapphire text
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(14),
                            elevation: 10,
                            shadowColor: const Color(0xFFE8D399).withAlpha(100),
                          ),
                          child: const Icon(Icons.send_rounded, size: 20),
                        ),
                      ],
                    ),
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
