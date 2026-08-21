class AllTutors {
  final String id;
  final String name;
  final String email;
  final String imageUrl;
  final String contact;
  final int completedClassCount;
  final bool tutorAvailability;
  final double tutorRating;
  int activeClassCount;
  int pendingClassCount;
  List<String> courses;

  AllTutors({
    required this.id,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.contact,
    required this.completedClassCount,
    required this.tutorAvailability,
    required this.tutorRating,
    this.activeClassCount = 0,
    this.pendingClassCount = 0,
    this.courses = const [],
  });
}

class AllCourses {
  final String id;
  final String name;
  final String imageUrl;
  final String department;
  final String info;
  // final bool tutorAvailability;
  final double courseRating;
  final double duration;
  String? videoUrl;
  int activeClassCount;
  int pendingClassCount;
  int numberOfTutors;
  List<String> tutors;

  /// When the course was published. Drives the dashboard's growth chart.
  final DateTime createdAt;

  AllCourses({
    required this.id,
    required this.name,
    required this.info,
    required this.imageUrl,
    required this.department,
    // required this.tutorAvailability,
    required this.courseRating,
    this.duration = 0,
    this.videoUrl,
    this.activeClassCount = 0,
    this.numberOfTutors = 0,
    this.pendingClassCount = 0,
    this.tutors = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

// Mirrors a `Classroom` record: an active class session linking a tutor to a course.
class ClassroomRecord {
  final String id;
  final String courseId;
  final String tutorId;

  ClassroomRecord({
    required this.id,
    required this.courseId,
    required this.tutorId,
  });
}

// Mirrors a `Requests` record: a pending-or-resolved request for a class.
class RequestRecord {
  final String id;
  final String courseId;
  final String tutorId;
  final bool isPending;

  /// When the request was raised. Drives the dashboard's revenue chart.
  final DateTime date;

  RequestRecord({
    required this.id,
    required this.courseId,
    required this.tutorId,
    this.isPending = true,
    DateTime? date,
  }) : date = date ?? DateTime.now();
}

class TutorReview {
  final String id;
  final String tutorId;
  final String postedBy;
  final String message;
  final DateTime timePosted;
  final String userImage;
  final int rating;

  TutorReview({
    required this.id,
    required this.tutorId,
    required this.postedBy,
    required this.message,
    required this.timePosted,
    required this.userImage,
    required this.rating,
  });
}

/// An uploaded book file. The design's Books table shows name, size and
/// upload date, so the record carries more than the file name.
class BookFile {
  BookFile({
    required this.name,
    required this.sizeBytes,
    DateTime? uploadedAt,
  }) : uploadedAt = uploadedAt ?? DateTime.now();

  final String name;
  final int sizeBytes;
  final DateTime uploadedAt;

  String get sizeLabel {
    if (sizeBytes <= 0) return '—';
    if (sizeBytes >= 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    if (sizeBytes >= 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(0)} KB';
    }
    return '$sizeBytes B';
  }
}
