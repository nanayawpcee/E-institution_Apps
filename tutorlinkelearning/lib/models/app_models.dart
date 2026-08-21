// Student is this app's logged-in identity (the local stand-in for the
// Firebase Auth user merged with its 'Students' Firestore doc).
class Student {
  final String id;
  String name;
  final String email;
  String userImage;
  String contact;
  List<String> activeCourses;
  List<String> pendingCourses;
  List<String> completedCourses;
  List<String> allCourses;
  List<String> bookmarks;
  List<String> tutors;

  Student({
    required this.id,
    required this.name,
    required this.email,
    this.userImage = '',
    this.contact = '',
    List<String>? activeCourses,
    List<String>? pendingCourses,
    List<String>? completedCourses,
    List<String>? allCourses,
    List<String>? bookmarks,
    List<String>? tutors,
  })  : activeCourses = activeCourses ?? [],
        pendingCourses = pendingCourses ?? [],
        completedCourses = completedCourses ?? [],
        allCourses = allCourses ?? [],
        bookmarks = bookmarks ?? [],
        tutors = tutors ?? [];

  Student copyWith({
    String? name,
    String? userImage,
    String? contact,
    List<String>? activeCourses,
    List<String>? pendingCourses,
    List<String>? completedCourses,
    List<String>? allCourses,
    List<String>? bookmarks,
    List<String>? tutors,
  }) {
    return Student(
      id: id,
      name: name ?? this.name,
      email: email,
      userImage: userImage ?? this.userImage,
      contact: contact ?? this.contact,
      activeCourses: activeCourses ?? this.activeCourses,
      pendingCourses: pendingCourses ?? this.pendingCourses,
      completedCourses: completedCourses ?? this.completedCourses,
      allCourses: allCourses ?? this.allCourses,
      bookmarks: bookmarks ?? this.bookmarks,
      tutors: tutors ?? this.tutors,
    );
  }
}

class Tutor {
  final String id;
  final String name;
  final String userImage;
  final String contact;
  final String bio;
  final int rating;
  final bool available;
  List<String> students;

  Tutor({
    required this.id,
    required this.name,
    this.userImage = '',
    this.contact = '',
    this.bio = '',
    this.rating = 0,
    this.available = true,
    List<String>? students,
  }) : students = students ?? [];
}

class Review {
  final String id;
  // The course or tutor this review was posted against.
  final String targetId;
  final String postedBy;
  final String message;
  final String timePosted;
  final String userImage;

  Review({
    required this.id,
    required this.targetId,
    required this.postedBy,
    required this.message,
    required this.timePosted,
    this.userImage = '',
  });
}

class RequestRecord {
  final String id;
  final String courseId;
  final String tutorId;
  final String studentId;
  bool isPending;
  bool isAccepted;
  bool isRejected;

  RequestRecord({
    required this.id,
    required this.courseId,
    required this.tutorId,
    required this.studentId,
    this.isPending = true,
    this.isAccepted = false,
    this.isRejected = false,
  });
}

class ClassMaterial {
  final String title;
  final String url;
  final DateTime time;

  ClassMaterial({required this.title, required this.url, required this.time});
}

class ClassroomRecord {
  final String id;
  final String courseId;
  final String studentId;
  final String tutorId;
  final DateTime startTime;
  final DateTime endTime;
  List<ClassMaterial> resources;
  List<ClassMaterial> assignments;

  ClassroomRecord({
    required this.id,
    required this.courseId,
    required this.studentId,
    required this.tutorId,
    required this.startTime,
    required this.endTime,
    List<ClassMaterial>? resources,
    List<ClassMaterial>? assignments,
  })  : resources = resources ?? [],
        assignments = assignments ?? [];
}

class ChatMessage {
  final String message;
  final DateTime time;
  final String senderId;

  ChatMessage({
    required this.message,
    required this.time,
    required this.senderId,
  });
}

class BookFile {
  final String name;
  final String url;

  BookFile({required this.name, required this.url});
}
