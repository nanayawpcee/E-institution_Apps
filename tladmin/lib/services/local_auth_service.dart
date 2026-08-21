import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';

class _FakeAccount {
  final String email;
  final String password;
  _FakeAccount(this.email, this.password);
}

// Local stand-in for Firebase Auth: seeded fake admin accounts, session
// persisted via shared_preferences instead of Firebase's authStateChanges().
class AuthController extends StateNotifier<AppUser?> {
  AuthController() : super(null) {
    _restoreSession();
  }

  static const _sessionKey = 'tladmin_session_email';

  // Administrators are provisioned out of band — the console has no
  // self-registration path, so this list is fixed at build time.
  final List<_FakeAccount> _accounts = [
    _FakeAccount('admin@tutorlink.com', 'Admin123!'),
  ];

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_sessionKey);
    if (email != null) {
      state = AppUser(id: email, email: email);
    }
  }

  Future<AppUser?> signIn(String email, String password) async {
    final matches = _accounts.where((a) =>
        a.email.toLowerCase() == email.toLowerCase() &&
        a.password == password);
    if (matches.isEmpty) return null;

    final user = AppUser(id: email, email: email);
    state = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, email);
    return user;
  }

  Future<void> signOut() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}

final authProvider =
    StateNotifierProvider<AuthController, AppUser?>((ref) => AuthController());
