import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_models.dart';

class _FakeAccount {
  final String email;
  String password;
  final Student student;
  _FakeAccount(this.email, this.password, this.student);
}

// Local stand-in for Firebase Auth + the student's own Firestore doc: seeded
// fake accounts with the session persisted via shared_preferences instead of
// Firebase's authStateChanges().
class AuthController extends StateNotifier<Student?> {
  AuthController() : super(null) {
    _restoreSession();
  }

  static const _sessionKey = 'tutorlinkelearning_session_email';

  final List<_FakeAccount> _accounts = [
    _FakeAccount(
      'kojo.asante@tutorlink.com',
      'Student123!',
      Student(
        id: 's1',
        name: 'Kojo Asante',
        email: 'kojo.asante@tutorlink.com',
        userImage: 'https://picsum.photos/seed/student-s1/200',
        contact: '0551234567',
        activeCourses: ['c1'],
        pendingCourses: ['c2'],
        completedCourses: ['c3'],
        allCourses: ['c1', 'c2', 'c3'],
        bookmarks: ['c2'],
        tutors: ['t1'],
      ),
    ),
  ];

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_sessionKey);
    if (email == null) return;
    final match = _accounts.where((a) => a.email == email);
    if (match.isNotEmpty) state = match.first.student;
  }

  // Mirrors signInWithEmailAndPassword: null student => sign-in failed.
  Future<Student?> signIn(String email, String password) async {
    final matches = _accounts.where((a) =>
        a.email.toLowerCase() == email.trim().toLowerCase() &&
        a.password == password);
    if (matches.isEmpty) return null;

    final student = matches.first.student;
    state = student;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, student.email);
    return student;
  }

  // Mirrors createUserWithEmailAndPassword: null => the email is already taken.
  Future<Student?> signUp(String name, String email, String password) async {
    final normalized = email.trim().toLowerCase();
    if (_accounts.any((a) => a.email.toLowerCase() == normalized)) return null;

    final student = Student(
      id: 's${_accounts.length + 1}',
      name: name.trim(),
      email: normalized,
    );
    _accounts.add(_FakeAccount(normalized, password, student));
    state = student;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, student.email);
    return student;
  }

  Future<void> signOut() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  void updateName(String name) {
    if (state == null) return;
    state = state!.copyWith(name: name);
  }

  void updateContact(String contact) {
    if (state == null) return;
    state = state!.copyWith(contact: contact);
  }

  void updateImage(String imagePath) {
    if (state == null) return;
    state = state!.copyWith(userImage: imagePath);
  }

  void toggleBookmark(String courseId) {
    if (state == null) return;
    final bookmarks = [...state!.bookmarks];
    if (bookmarks.contains(courseId)) {
      bookmarks.remove(courseId);
    } else {
      bookmarks.add(courseId);
    }
    state = state!.copyWith(bookmarks: bookmarks);
  }

  // Mirrors the old arrayUnion on the student's 'Pending' list when a tutor
  // request is sent.
  void addPendingCourse(String courseId) {
    if (state == null) return;
    if (state!.pendingCourses.contains(courseId)) return;
    final all = state!.allCourses.contains(courseId)
        ? state!.allCourses
        : [...state!.allCourses, courseId];
    state = state!.copyWith(
      pendingCourses: [...state!.pendingCourses, courseId],
      allCourses: all,
    );
  }

  void completeCourse(String courseId) {
    if (state == null) return;
    if (state!.completedCourses.contains(courseId)) return;
    state = state!.copyWith(
      activeCourses:
          state!.activeCourses.where((c) => c != courseId).toList(),
      completedCourses: [...state!.completedCourses, courseId],
    );
  }

  void addTutor(String tutorId) {
    if (state == null) return;
    if (state!.tutors.contains(tutorId)) return;
    state = state!.copyWith(tutors: [...state!.tutors, tutorId]);
  }
}

final authProvider =
    StateNotifierProvider<AuthController, Student?>((ref) => AuthController());
