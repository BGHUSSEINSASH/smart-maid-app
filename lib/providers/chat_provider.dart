import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../data/models.dart';

/// محادثات مرتبطة بحجز فعلي — الرسائل تُقرأ وتُرسل عبر الخادم فقط.
class ChatNotifier extends StateNotifier<Map<String, List<MessageModel>>> {
  ChatNotifier() : super(const {});

  List<MessageModel> messagesFor(String bookingId) =>
      state[bookingId] ?? const [];

  Future<String?> load(String bookingId) async {
    try {
      final res = await ApiClient.get('/chat/$bookingId');
      final list = (res['messages'] as List?) ?? const [];
      final messages = list.whereType<Map<String, dynamic>>().map((json) {
        return MessageModel(
          id: json['id']?.toString() ?? '',
          senderId: json['senderId']?.toString() ?? '',
          content: json['body']?.toString() ?? '',
          timestamp: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
              DateTime.now(),
        );
      }).toList();
      state = {...state, bookingId: messages};
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<String?> send(String bookingId, String body) async {
    try {
      final res = await ApiClient.post('/chat/$bookingId', {'body': body});
      final message = MessageModel(
        id: res['id']?.toString() ?? DateTime.now().toString(),
        senderId: res['senderId']?.toString() ?? '',
        content: res['body']?.toString() ?? body,
        timestamp:
            DateTime.tryParse(res['createdAt']?.toString() ?? '') ??
                DateTime.now(),
      );
      state = {
        ...state,
        bookingId: [...messagesFor(bookingId), message],
      };
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<String?> report(String bookingId, String reason) async {
    try {
      await ApiClient.post('/chat/$bookingId/report', {'reason': reason});
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, Map<String, List<MessageModel>>>(
  (ref) => ChatNotifier(),
);
