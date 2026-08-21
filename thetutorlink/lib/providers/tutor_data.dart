import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_models.dart';

// In-memory stand-in for the Firestore `Students`/`Courses`/`Classroom`/
// `Requests` collections and the Realtime Database `chats` node, seeded
// with fake data.
class TutorAppData {
  final List<Student> students;
  final List<Course> courses;
  final List<ClassroomRecord> classrooms;
  final List<RequestRecord> requests;
  final Map<String, List<ChatMessage>> chats;
  final List<BookFile> bookFiles;

  const TutorAppData({
    required this.students,
    required this.courses,
    required this.classrooms,
    required this.requests,
    required this.chats,
    required this.bookFiles,
  });

  TutorAppData copyWith({
    List<Student>? students,
    List<Course>? courses,
    List<ClassroomRecord>? classrooms,
    List<RequestRecord>? requests,
    Map<String, List<ChatMessage>>? chats,
    List<BookFile>? bookFiles,
  }) {
    return TutorAppData(
      students: students ?? this.students,
      courses: courses ?? this.courses,
      classrooms: classrooms ?? this.classrooms,
      requests: requests ?? this.requests,
      chats: chats ?? this.chats,
      bookFiles: bookFiles ?? this.bookFiles,
    );
  }
}

class TutorAppDataNotifier extends StateNotifier<TutorAppData> {
  TutorAppDataNotifier() : super(_seed());

  static String chatKey(String tutorId, String studentId) =>
      '${tutorId}_$studentId';

  static TutorAppData _seed() {
    final students = [
      Student(
        id: 's1',
        name: 'Kojo Asante',
        age: 20,
        userImage: 'https://picsum.photos/seed/student-s1/200',
      ),
      Student(
        id: 's2',
        name: 'Abena Sarpong',
        age: 22,
        userImage: 'https://picsum.photos/seed/student-s2/200',
      ),
      Student(
        id: 's3',
        name: 'Yaw Boateng',
        age: 19,
        userImage: 'https://picsum.photos/seed/student-s3/200',
      ),
    ];

    final courses = [
      Course(id: 'c1', name: 'Programming Languages', duration: 12),
      Course(id: 'c2', name: 'Mathematics', duration: 10),
    ];

    final now = DateTime.now();
    final classrooms = [
      ClassroomRecord(
        id: 'cls1',
        courseId: 'c1',
        studentId: 's1',
        tutorId: 't1',
        startTime: now.subtract(const Duration(days: 2)),
        endTime: now.add(const Duration(days: 10)),
        resources: [
          ClassMaterial(
            title: 'Course Outline',
            url: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
            time: now.subtract(const Duration(days: 2)),
          ),
        ],
      ),
    ];

    final requests = [
      RequestRecord(
          id: 'r1', studentId: 's1', tutorId: 't1', courseId: 'c1', isPending: false, isAccepted: true),
      RequestRecord(id: 'r2', studentId: 's2', tutorId: 't1', courseId: 'c1'),
      RequestRecord(id: 'r3', studentId: 's3', tutorId: 't1', courseId: 'c2'),
    ];

    return TutorAppData(
      students: students,
      courses: courses,
      classrooms: classrooms,
      requests: requests,
      chats: {
        chatKey('t1', 's1'): [
          ChatMessage(
              message: 'Hi! Looking forward to our session.',
              time: now.subtract(const Duration(hours: 3)),
              senderId: 's1'),
          ChatMessage(
              message: 'Me too, see you then!',
              time: now.subtract(const Duration(hours: 2)),
              senderId: 't1'),
        ],
      },
      bookFiles: [
        BookFile(
          name: 'Intro_to_Programming.pdf',
          url: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        ),
      ],
    );
  }

  Student? studentById(String id) {
    final match = state.students.where((s) => s.id == id);
    return match.isEmpty ? null : match.first;
  }

  List<Student> studentsByIds(List<String> ids) =>
      ids.map(studentById).whereType<Student>().toList();

  Course? courseById(String id) {
    final match = state.courses.where((c) => c.id == id);
    return match.isEmpty ? null : match.first;
  }

  ClassroomRecord? classroomFor(String studentId, String tutorId) {
    final match = state.classrooms
        .where((c) => c.studentId == studentId && c.tutorId == tutorId);
    return match.isEmpty ? null : match.first;
  }

  ClassroomRecord getOrCreateClassroom(
      String studentId, String tutorId, String courseId) {
    final existing = classroomFor(studentId, tutorId);
    if (existing != null) return existing;

    final course = courseById(courseId);
    final now = DateTime.now();
    final classroom = ClassroomRecord(
      id: 'cls${state.classrooms.length + 1}${DateTime.now().microsecondsSinceEpoch}',
      courseId: courseId,
      studentId: studentId,
      tutorId: tutorId,
      startTime: now,
      endTime: now.add(Duration(hours: (course?.duration ?? 1).toInt())),
    );
    state = state.copyWith(classrooms: [...state.classrooms, classroom]);
    return classroom;
  }

  void addResource(String classroomId, String title, String url) {
    final classroom = state.classrooms.where((c) => c.id == classroomId);
    if (classroom.isEmpty) return;
    classroom.first.resources = [
      ...classroom.first.resources,
      ClassMaterial(title: title, url: url, time: DateTime.now()),
    ];
    state = state.copyWith();
  }

  void removeResource(String classroomId, String url) {
    final classroom = state.classrooms.where((c) => c.id == classroomId);
    if (classroom.isEmpty) return;
    classroom.first.resources =
        classroom.first.resources.where((r) => r.url != url).toList();
    state = state.copyWith();
  }

  void addAssignment(String classroomId, String title, String url) {
    final classroom = state.classrooms.where((c) => c.id == classroomId);
    if (classroom.isEmpty) return;
    classroom.first.assignments = [
      ...classroom.first.assignments,
      ClassMaterial(title: title, url: url, time: DateTime.now()),
    ];
    state = state.copyWith();
  }

  // Mirrors the old accept/reject flow: flips the request's status flags,
  // and on acceptance links the student to the tutor's course roster.
  void resolveRequest(String requestId, {required bool accepted}) {
    final match = state.requests.where((r) => r.id == requestId);
    if (match.isEmpty) return;
    final request = match.first;
    request.isPending = false;
    request.isAccepted = accepted;
    request.isRejected = !accepted;

    if (accepted) {
      final student = studentById(request.studentId);
      if (student != null) {
        if (!student.activeCourses.contains(request.courseId)) {
          student.activeCourses = [...student.activeCourses, request.courseId];
        }
        if (!student.allCourses.contains(request.courseId)) {
          student.allCourses = [...student.allCourses, request.courseId];
        }
        student.pendingCourses =
            student.pendingCourses.where((c) => c != request.courseId).toList();
        if (!student.tutors.contains(request.tutorId)) {
          student.tutors = [...student.tutors, request.tutorId];
        }
      }
    }
    state = state.copyWith();
  }

  void sendChatMessage(String tutorId, String studentId, String senderId, String message) {
    final key = chatKey(tutorId, studentId);
    final existing = state.chats[key] ?? [];
    final updated = {
      ...state.chats,
      key: [...existing, ChatMessage(message: message, time: DateTime.now(), senderId: senderId)],
    };
    state = state.copyWith(chats: updated);
  }

  void addBookFile(String name, String url) {
    state = state.copyWith(bookFiles: [...state.bookFiles, BookFile(name: name, url: url)]);
  }
}

final tutorDataProvider =
    StateNotifierProvider<TutorAppDataNotifier, TutorAppData>(
        (ref) => TutorAppDataNotifier());
