import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tutorclass.dart';

// In-memory stand-in for the Firestore `Courses`/`Tutors`/`Classroom`/
// `Requests`/`Reviews`/`TutorReviews` collections, seeded with fake data.
class AdminData {
  final List<AllCourses> courses;
  final List<AllTutors> tutors;
  final List<ClassroomRecord> classroom;
  final List<RequestRecord> requests;
  final int courseReviewCount;
  final List<TutorReview> tutorReviews;
  final List<BookFile> bookFiles;

  const AdminData({
    required this.courses,
    required this.tutors,
    required this.classroom,
    required this.requests,
    required this.courseReviewCount,
    required this.tutorReviews,
    required this.bookFiles,
  });

  AdminData copyWith({
    List<AllCourses>? courses,
    List<AllTutors>? tutors,
    List<ClassroomRecord>? classroom,
    List<RequestRecord>? requests,
    int? courseReviewCount,
    List<TutorReview>? tutorReviews,
    List<BookFile>? bookFiles,
  }) {
    return AdminData(
      courses: courses ?? this.courses,
      tutors: tutors ?? this.tutors,
      classroom: classroom ?? this.classroom,
      requests: requests ?? this.requests,
      courseReviewCount: courseReviewCount ?? this.courseReviewCount,
      tutorReviews: tutorReviews ?? this.tutorReviews,
      bookFiles: bookFiles ?? this.bookFiles,
    );
  }
}

DateTime _daysAgo(int days) =>
    DateTime.now().subtract(Duration(days: days));

class AdminDataNotifier extends StateNotifier<AdminData> {
  AdminDataNotifier() : super(_seed()) {
    _recomputeCounts();
  }

  int _idCounter = 1000;
  String _nextId(String prefix) => '$prefix${_idCounter++}';

  static AdminData _seed() {
    final courses = [
      AllCourses(
        id: 'c1',
        createdAt: _daysAgo(3),
        name: 'Programming Languages',
        imageUrl: 'https://picsum.photos/seed/course-c1/200',
        department: 'Computer Science',
        info: 'An introduction to core programming language concepts.',
        courseRating: 4.5,
        duration: 12,
        tutors: ['t1'],
      ),
      AllCourses(
        id: 'c2',
        createdAt: _daysAgo(30),
        name: 'Mathematics',
        imageUrl: 'https://picsum.photos/seed/course-c2/200',
        department: 'Mathematics',
        info: 'Foundational and applied mathematics.',
        courseRating: 4.2,
        duration: 10,
        tutors: ['t2'],
      ),
      AllCourses(
        id: 'c3',
        createdAt: _daysAgo(60),
        name: 'Biology',
        imageUrl: 'https://picsum.photos/seed/course-c3/200',
        department: 'Biology',
        info: 'General biology for undergraduates.',
        courseRating: 4.0,
        duration: 8,
        tutors: ['t3'],
      ),
      AllCourses(
        id: 'c4',
        createdAt: _daysAgo(95),
        name: 'Chemistry',
        imageUrl: 'https://picsum.photos/seed/course-c4/200',
        department: 'Chemistry',
        info: 'Introductory organic and inorganic chemistry.',
        courseRating: 3.8,
        duration: 9,
        tutors: ['t4'],
      ),
    ];

    final tutors = [
      AllTutors(
        id: 't1',
        name: 'Ama Owusu',
        email: 'ama.owusu@tutorlink.com',
        imageUrl: 'https://picsum.photos/seed/tutor-t1/200',
        contact: '0551234567',
        completedClassCount: 12,
        tutorAvailability: true,
        tutorRating: 4.6,
      ),
      AllTutors(
        id: 't2',
        name: 'Kwame Mensah',
        email: 'kwame.mensah@tutorlink.com',
        imageUrl: 'https://picsum.photos/seed/tutor-t2/200',
        contact: '0559876543',
        completedClassCount: 8,
        tutorAvailability: true,
        tutorRating: 4.1,
      ),
      AllTutors(
        id: 't3',
        name: 'Esi Boateng',
        email: 'esi.boateng@tutorlink.com',
        imageUrl: 'https://picsum.photos/seed/tutor-t3/200',
        contact: '0557654321',
        completedClassCount: 5,
        tutorAvailability: false,
        tutorRating: 3.9,
      ),
      AllTutors(
        id: 't4',
        name: 'Yaw Darko',
        email: 'yaw.darko@tutorlink.com',
        imageUrl: 'https://picsum.photos/seed/tutor-t4/200',
        contact: '0554567890',
        completedClassCount: 3,
        tutorAvailability: true,
        tutorRating: 4.4,
      ),
    ];

    final classroom = [
      ClassroomRecord(id: 'cls1', courseId: 'c1', tutorId: 't1'),
      ClassroomRecord(id: 'cls2', courseId: 'c2', tutorId: 't2'),
    ];

    final requests = [
      RequestRecord(
          id: 'r1',
          courseId: 'c1',
          tutorId: 't1',
          isPending: true,
          date: _daysAgo(2),
        ),
      RequestRecord(
          id: 'r2',
          courseId: 'c3',
          tutorId: 't3',
          isPending: true,
          date: _daysAgo(9),
        ),
      RequestRecord(
          id: 'r3',
          courseId: 'c2',
          tutorId: 't2',
          isPending: false,
          date: _daysAgo(16),
        ),
    ];

    final tutorReviews = [
      TutorReview(
        id: 'tr1',
        tutorId: 't1',
        postedBy: 'Kojo Asante',
        message: 'Very clear explanations, highly recommend!',
        timePosted: DateTime.now().subtract(const Duration(days: 3)),
        userImage: 'https://picsum.photos/seed/reviewer-1/100',
        rating: 5,
      ),
      TutorReview(
        id: 'tr2',
        tutorId: 't2',
        postedBy: 'Abena Sarpong',
        message: 'Helped me understand calculus a lot better.',
        timePosted: DateTime.now().subtract(const Duration(days: 7)),
        userImage: 'https://picsum.photos/seed/reviewer-2/100',
        rating: 4,
      ),
    ];

    return AdminData(
      courses: courses,
      tutors: tutors,
      classroom: classroom,
      requests: requests,
      courseReviewCount: 3,
      tutorReviews: tutorReviews,
      bookFiles: [
        BookFile(
          name: 'Intro_to_Programming.pdf',
          sizeBytes: 2516582,
          uploadedAt: _daysAgo(12),
        ),
      ],
    );
  }

  // Recomputes each course/tutor's classroom/request-derived counters, the
  // same aggregates the old code fetched with per-document Firestore queries.
  void _recomputeCounts() {
    for (final course in state.courses) {
      course.activeClassCount =
          state.classroom.where((c) => c.courseId == course.id).length;
      course.pendingClassCount = state.requests
          .where((r) => r.courseId == course.id && r.isPending)
          .length;
      course.numberOfTutors = course.tutors.length;
    }
    for (final tutor in state.tutors) {
      tutor.activeClassCount =
          state.classroom.where((c) => c.tutorId == tutor.id).length;
      tutor.pendingClassCount = state.requests
          .where((r) => r.tutorId == tutor.id && r.isPending)
          .length;
      tutor.courses = state.courses
          .where((c) => c.tutors.contains(tutor.id))
          .map((c) => c.name)
          .toList();
    }
    state = state.copyWith();
  }

  Map<String, int> get dashboardCounts => {
        'courses': state.courses.length,
        'tutors': state.tutors.length,
        'classrooms': state.classroom.length,
        'requests': state.requests.length,
        'pendingRequests': state.requests.where((r) => r.isPending).length,
        'reviews': state.courseReviewCount,
        'tutorReviews': state.tutorReviews.length,
      };

  AllCourses addCourse({
    required String name,
    required String department,
    required String info,
    required String imageUrl,
    double courseRating = 0,
    double duration = 0,
    String? videoUrl,
  }) {
    final course = AllCourses(
      id: _nextId('c'),
      name: name,
      department: department,
      info: info,
      imageUrl: imageUrl,
      courseRating: courseRating,
      duration: duration,
      videoUrl: videoUrl,
    );
    state = state.copyWith(courses: [...state.courses, course]);
    _recomputeCounts();
    return course;
  }

  // Returns null (mirrors the old "no matching course found" case) when no
  // course matches `courseName`, otherwise the new tutor record.
  AllTutors? addTutor({
    required String name,
    required String email,
    required String imageUrl,
    required String contact,
    required String courseName,
  }) {
    final course = state.courses
        .where((c) => c.name.toLowerCase() == courseName.toLowerCase())
        .cast<AllCourses?>()
        .firstWhere((c) => true, orElse: () => null);
    if (course == null) return null;

    final tutor = AllTutors(
      id: _nextId('t'),
      name: name,
      email: email,
      imageUrl: imageUrl,
      contact: contact,
      completedClassCount: 0,
      tutorAvailability: true,
      tutorRating: 0,
    );
    course.tutors = [...course.tutors, tutor.id];
    state = state.copyWith(tutors: [...state.tutors, tutor]);
    _recomputeCounts();
    return tutor;
  }

  /// Bulk-removes courses and everything derived from them, matching the
  /// design's "Delete" bulk action on the courses table.
  void deleteCourses(Set<String> ids) {
    if (ids.isEmpty) return;
    state = state.copyWith(
      courses: state.courses.where((c) => !ids.contains(c.id)).toList(),
      classroom: state.classroom.where((c) => !ids.contains(c.courseId)).toList(),
      requests: state.requests.where((r) => !ids.contains(r.courseId)).toList(),
    );
    _recomputeCounts();
  }

  /// Bulk-removes tutors, detaching them from any course that listed them.
  void deleteTutors(Set<String> ids) {
    if (ids.isEmpty) return;
    for (final course in state.courses) {
      course.tutors = course.tutors.where((t) => !ids.contains(t)).toList();
    }
    state = state.copyWith(
      tutors: state.tutors.where((t) => !ids.contains(t.id)).toList(),
      classroom: state.classroom.where((c) => !ids.contains(c.tutorId)).toList(),
      requests: state.requests.where((r) => !ids.contains(r.tutorId)).toList(),
      tutorReviews:
          state.tutorReviews.where((r) => !ids.contains(r.tutorId)).toList(),
    );
    _recomputeCounts();
  }

  /// Flips a request between pending and resolved from the Requests page.
  void setRequestPending(String id, bool isPending) {
    state = state.copyWith(
      requests: state.requests
          .map((r) => r.id == id
              ? RequestRecord(
                  id: r.id,
                  courseId: r.courseId,
                  tutorId: r.tutorId,
                  isPending: isPending,
                  date: r.date,
                )
              : r)
          .toList(),
    );
    _recomputeCounts();
  }

  void addBookFile(String fileName, {int sizeBytes = 0}) {
    state = state.copyWith(bookFiles: [
      ...state.bookFiles,
      BookFile(name: fileName, sizeBytes: sizeBytes),
    ]);
  }

  void removeBookFile(String fileName) {
    state = state.copyWith(
      bookFiles: state.bookFiles.where((b) => b.name != fileName).toList(),
    );
  }
}

final adminDataProvider =
    StateNotifierProvider<AdminDataNotifier, AdminData>(
        (ref) => AdminDataNotifier());
