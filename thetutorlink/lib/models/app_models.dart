// Tutor is this app's logged-in identity (the local stand-in for the
// Firebase Auth user + its 'Tutors' Firestore doc, merged into one object).
class Tutor {
  final String id;
  String name;
  final String email;
  String userImage;
  String contact;
  bool available;
  List<String> students;

  Tutor({
    required this.id,
    required this.name,
    required this.email,
    this.userImage = '',
    this.contact = '',
    this.available = true,
    List<String>? students,
  }) : students = students ?? [];

  Tutor copyWith({
    String? name,
    String? userImage,
    String? contact,
    bool? available,
    List<String>? students,
  }) {
    return Tutor(
      id: id,
      name: name ?? this.name,
      email: email,
      userImage: userImage ?? this.userImage,
      contact: contact ?? this.contact,
      available: available ?? this.available,
      students: students ?? this.students,
    );
  }
}

class Student {
  final String id;
  final String name;
  final int age;
  final String userImage;
  List<String> activeCourses;
  List<String> allCourses;
  List<String> pendingCourses;
  List<String> tutors;

  Student({
    required this.id,
    required this.name,
    required this.age,
    required this.userImage,
    List<String>? activeCourses,
    List<String>? allCourses,
    List<String>? pendingCourses,
    List<String>? tutors,
  })  : activeCourses = activeCourses ?? [],
        allCourses = allCourses ?? [],
        pendingCourses = pendingCourses ?? [],
        tutors = tutors ?? [];
}

class Course {
  final String id;
  final String name;
  final double duration;

  Course({required this.id, required this.name, this.duration = 1});
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

class RequestRecord {
  final String id;
  final String studentId;
  final String tutorId;
  final String courseId;
  bool isPending;
  bool isAccepted;
  bool isRejected;

  RequestRecord({
    required this.id,
    required this.studentId,
    required this.tutorId,
    required this.courseId,
    this.isPending = true,
    this.isAccepted = false,
    this.isRejected = false,
  });
}

class ChatMessage {
  final String message;
  final DateTime time;
  final String senderId;

  ChatMessage({required this.message, required this.time, required this.senderId});
}

class BookFile {
  final String name;
  final String url;

  BookFile({required this.name, required this.url});
}
