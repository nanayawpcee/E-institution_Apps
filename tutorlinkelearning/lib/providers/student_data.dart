import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_models.dart';
import '../utils/coursename.dart';

// In-memory stand-in for the Firestore `Courses`/`Tutors`/`Requests`/
// `Reviews`/`TutorReviews` collections and the Realtime Database `chats`
// node, seeded with fake data.
class StudentAppData {
  final List<CoursesType> courses;
  final List<Tutor> tutors;
  final List<RequestRecord> requests;
  final List<Review> courseReviews;
  final List<Review> tutorReviews;
  final List<ClassroomRecord> classrooms;
  final Map<String, List<ChatMessage>> chats;
  final List<BookFile> bookFiles;

  const StudentAppData({
    required this.courses,
    required this.tutors,
    required this.requests,
    required this.courseReviews,
    required this.tutorReviews,
    required this.classrooms,
    required this.chats,
    required this.bookFiles,
  });

  StudentAppData copyWith({
    List<CoursesType>? courses,
    List<Tutor>? tutors,
    List<RequestRecord>? requests,
    List<Review>? courseReviews,
    List<Review>? tutorReviews,
    List<ClassroomRecord>? classrooms,
    Map<String, List<ChatMessage>>? chats,
    List<BookFile>? bookFiles,
  }) {
    return StudentAppData(
      courses: courses ?? this.courses,
      tutors: tutors ?? this.tutors,
      requests: requests ?? this.requests,
      courseReviews: courseReviews ?? this.courseReviews,
      tutorReviews: tutorReviews ?? this.tutorReviews,
      classrooms: classrooms ?? this.classrooms,
      chats: chats ?? this.chats,
      bookFiles: bookFiles ?? this.bookFiles,
    );
  }
}

const _samplePdf =
    'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';
const _sampleVideo =
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';

class StudentAppDataNotifier extends StateNotifier<StudentAppData> {
  StudentAppDataNotifier() : super(_seed());

  static String chatKey(String tutorId, String studentId) =>
      '${tutorId}_$studentId';

  static StudentAppData _seed() {
    final now = DateTime.now();

    final courses = [
      CoursesType(
        courseId: 'c1',
        name: 'Programming Languages',
        image: 'https://picsum.photos/seed/course-c1/300',
        details:
            'An introduction to programming paradigms, syntax and semantics '
            'across modern languages.',
        department: 'Computer Science',
        rating: 5,
        duration: 12,
        videoUrl: _sampleVideo,
        tutorIds: ['t1'],
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      CoursesType(
        courseId: 'c2',
        name: 'Calculus II',
        image: 'https://picsum.photos/seed/course-c2/300',
        details: 'Integration techniques, sequences, series and applications.',
        department: 'Mathematics',
        rating: 4,
        duration: 10,
        videoUrl: _sampleVideo,
        tutorIds: ['t2'],
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      CoursesType(
        courseId: 'c3',
        name: 'Cell Biology',
        image: 'https://picsum.photos/seed/course-c3/300',
        details: 'Structure and function of cells and their organelles.',
        department: 'Biology',
        rating: 4,
        duration: 8,
        videoUrl: _sampleVideo,
        tutorIds: ['t3'],
        createdAt: now.subtract(const Duration(days: 60)),
      ),
      CoursesType(
        courseId: 'c4',
        name: 'Interface Design',
        image: 'https://picsum.photos/seed/course-c4/300',
        details: 'Designing usable, accessible product interfaces.',
        department: 'UI/UX',
        rating: 5,
        duration: 6,
        videoUrl: _sampleVideo,
        tutorIds: ['t1', 't3'],
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];

    final tutors = [
      Tutor(
        id: 't1',
        name: 'Sarah Mensah',
        userImage: 'https://picsum.photos/seed/tutor-t1/200',
        contact: '0551234567',
        bio: 'Software engineer and lecturer with 8 years of teaching.',
        rating: 5,
        available: true,
        students: ['s1', 's2'],
      ),
      Tutor(
        id: 't2',
        name: 'Daniel Owusu',
        userImage: 'https://picsum.photos/seed/tutor-t2/200',
        contact: '0559876543',
        bio: 'Mathematician focused on making calculus intuitive.',
        rating: 4,
        available: false,
        students: ['s3'],
      ),
      Tutor(
        id: 't3',
        name: 'Ama Darko',
        userImage: 'https://picsum.photos/seed/tutor-t3/200',
        contact: '0201122334',
        bio: 'Biologist and design enthusiast.',
        rating: 4,
        available: true,
        students: ['s1'],
      ),
    ];

    return StudentAppData(
      courses: courses,
      tutors: tutors,
      requests: [
        RequestRecord(
          id: 'r1',
          courseId: 'c2',
          tutorId: 't2',
          studentId: 's1',
        ),
      ],
      courseReviews: [
        Review(
          id: 'rev1',
          targetId: 'c1',
          postedBy: 'Abena Sarpong',
          message: 'Really clear explanations, the examples helped a lot.',
          timePosted: 'Mon, Jun 3, 2026, 10:24',
          userImage: 'https://picsum.photos/seed/student-s2/200',
        ),
      ],
      tutorReviews: [
        Review(
          id: 'trev1',
          targetId: 't1',
          postedBy: 'Yaw Boateng',
          message: 'Very patient and always available for questions.',
          timePosted: 'Tue, Jun 4, 2026, 14:02',
          userImage: 'https://picsum.photos/seed/student-s3/200',
        ),
      ],
      classrooms: [
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
              url: _samplePdf,
              time: now.subtract(const Duration(days: 2)),
            ),
          ],
          assignments: [
            ClassMaterial(
              title: 'Assignment 1',
              url: _samplePdf,
              time: now.subtract(const Duration(days: 1)),
            ),
          ],
        ),
      ],
      chats: {
        chatKey('t1', 's1'): [
          ChatMessage(
            message: 'Hello! Ready for our session?',
            time: now.subtract(const Duration(hours: 3)),
            senderId: 't1',
          ),
          ChatMessage(
            message: 'Yes, see you shortly.',
            time: now.subtract(const Duration(hours: 2)),
            senderId: 's1',
          ),
        ],
      },
      bookFiles: [
        BookFile(name: 'Intro_to_Programming.pdf', url: _samplePdf),
        BookFile(name: 'Calculus_Workbook.pdf', url: _samplePdf),
      ],
    );
  }

  CoursesType? courseById(String id) {
    final match = state.courses.where((c) => c.courseId == id);
    return match.isEmpty ? null : match.first;
  }

  List<CoursesType> coursesByIds(List<String> ids) =>
      ids.map(courseById).whereType<CoursesType>().toList();

  Tutor? tutorById(String id) {
    final match = state.tutors.where((t) => t.id == id);
    return match.isEmpty ? null : match.first;
  }

  List<Tutor> tutorsByIds(List<String> ids) =>
      ids.map(tutorById).whereType<Tutor>().toList();

  List<Tutor> tutorsForCourse(String courseId) =>
      tutorsByIds(courseById(courseId)?.tutorIds ?? []);

  // The first course a tutor teaches, mirroring the old "find the course
  // whose tutors array contains this tutor" query.
  String? primaryCourseIdForTutor(String tutorId) {
    final match = state.courses.where((c) => c.tutorIds.contains(tutorId));
    return match.isEmpty ? null : match.first.courseId;
  }

  List<Review> reviewsForCourse(String courseId) =>
      state.courseReviews.where((r) => r.targetId == courseId).toList();

  List<Review> reviewsForTutor(String tutorId) =>
      state.tutorReviews.where((r) => r.targetId == tutorId).toList();

  ClassroomRecord? classroomFor(String courseId, String studentId) {
    final match = state.classrooms
        .where((c) => c.courseId == courseId && c.studentId == studentId);
    return match.isEmpty ? null : match.first;
  }

  bool hasRequest(String studentId, String courseId) => state.requests
      .any((r) => r.studentId == studentId && r.courseId == courseId);

  void sendRequest(String studentId, String tutorId, String courseId) {
    if (hasRequest(studentId, courseId)) return;
    state = state.copyWith(requests: [
      ...state.requests,
      RequestRecord(
        id: 'r${state.requests.length + 1}${DateTime.now().microsecondsSinceEpoch}',
        courseId: courseId,
        tutorId: tutorId,
        studentId: studentId,
      ),
    ]);
  }

  void addCourseReview(String courseId, String postedBy, String message,
      String timePosted, String userImage) {
    state = state.copyWith(courseReviews: [
      ...state.courseReviews,
      Review(
        id: 'rev${state.courseReviews.length + 1}',
        targetId: courseId,
        postedBy: postedBy,
        message: message,
        timePosted: timePosted,
        userImage: userImage,
      ),
    ]);
  }

  void addTutorReview(String tutorId, String postedBy, String message,
      String timePosted, String userImage) {
    state = state.copyWith(tutorReviews: [
      ...state.tutorReviews,
      Review(
        id: 'trev${state.tutorReviews.length + 1}',
        targetId: tutorId,
        postedBy: postedBy,
        message: message,
        timePosted: timePosted,
        userImage: userImage,
      ),
    ]);
  }

  // Mirrors the end-of-class teardown: drop the classroom and unenrol the
  // student from the tutor's roster.
  void closeClassroom(String classroomId, String tutorId, String studentId) {
    final tutor = tutorById(tutorId);
    if (tutor != null) {
      tutor.students = tutor.students.where((s) => s != studentId).toList();
    }
    state = state.copyWith(
      classrooms: state.classrooms.where((c) => c.id != classroomId).toList(),
    );
  }

  void addAssignment(String classroomId, String title, String url) {
    final match = state.classrooms.where((c) => c.id == classroomId);
    if (match.isEmpty) return;
    match.first.assignments = [
      ...match.first.assignments,
      ClassMaterial(title: title, url: url, time: DateTime.now()),
    ];
    state = state.copyWith();
  }

  void sendChatMessage(
      String tutorId, String studentId, String senderId, String message) {
    final key = chatKey(tutorId, studentId);
    final existing = state.chats[key] ?? [];
    state = state.copyWith(chats: {
      ...state.chats,
      key: [
        ...existing,
        ChatMessage(message: message, time: DateTime.now(), senderId: senderId),
      ],
    });
  }
}

final studentDataProvider =
    StateNotifierProvider<StudentAppDataNotifier, StudentAppData>(
        (ref) => StudentAppDataNotifier());
