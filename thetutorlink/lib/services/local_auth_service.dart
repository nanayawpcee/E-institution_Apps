import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_models.dart';

class _FakeAccount {
  final String email;
  final String password;
  final Tutor tutor;
  _FakeAccount(this.email, this.password, this.tutor);
}

// Local stand-in for Firebase Auth + the tutor's own Firestore doc: a seeded
// fake tutor account, session persisted via shared_preferences instead of
// Firebase's authStateChanges().
class AuthController extends StateNotifier<Tutor?> {
  AuthController() : super(null) {
    _restoreSession();
  }

  static const _sessionKey = 'thetutorlink_session_email';

  final List<_FakeAccount> _accounts = [
    _FakeAccount(
      'sarah.mensah@tutorlink.com',
      'Tutor123!',
      Tutor(
        id: 't1',
        name: 'Sarah Mensah',
        email: 'sarah.mensah@tutorlink.com',
        userImage: 'https://picsum.photos/seed/tutor-t1/200',
        contact: '0551234567',
        available: true,
        // Matches the seeded accepted request and classroom for s1, so the
        // roster, request list and classroom list agree on first launch.
        students: ['s1'],
      ),
    ),
  ];

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_sessionKey);
    if (email == null) return;
    final match = _accounts.where((a) => a.email == email);
    if (match.isNotEmpty) state = match.first.tutor;
  }

  // Mirrors signInWithEmailAndPassword: null tutor => tutor not found.
  Future<Tutor?> signIn(String email, String password) async {
    final matches = _accounts.where((a) =>
        a.email.toLowerCase() == email.trim().toLowerCase() &&
        a.password == password);
    if (matches.isEmpty) return null;

    final tutor = matches.first.tutor;
    state = tutor;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, tutor.email);
    return tutor;
  }

  Future<void> signOut() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  void updateAvailability(bool available) {
    if (state == null) return;
    state = state!.copyWith(available: available);
  }

  void updateContact(String contact) {
    if (state == null) return;
    state = state!.copyWith(contact: contact);
  }

  void updateImage(String imagePath) {
    if (state == null) return;
    state = state!.copyWith(userImage: imagePath);
  }

  void addStudent(String studentId) {
    if (state == null) return;
    if (state!.students.contains(studentId)) return;
    state = state!.copyWith(students: [...state!.students, studentId]);
  }
}

final authProvider =
    StateNotifierProvider<AuthController, Tutor?>((ref) => AuthController());
