import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String icon; // emoji
  final DateTime time;
  bool read;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.icon,
    required this.time,
    this.read = false,
  });
}

class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  NotificationsNotifier() : super(const []);

  void markAllRead() {
    state = state.map((n) => n..read = true).toList();
  }

  void markRead(String id) {
    state = state.map((n) => n..read = n.id == id ? true : n.read).toList();
  }

  void addNotification(AppNotification n) {
    state = [n, ...state];
  }

  int get unreadCount => state.where((n) => !n.read).length;
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<AppNotification>>(
      (ref) => NotificationsNotifier(),
    );

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).where((n) => !n.read).length;
});
