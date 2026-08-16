import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models.dart';

class AuthState {
  final AppUser? user;

  const AuthState({this.user});

  bool get isLoggedIn => user != null;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  void loginAs(AppUser user) => state = AuthState(user: user);

  void logout() => state = const AuthState();
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
