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
  int activeClassCount;
  int pendingClassCount;
  int numberOfTutors;
  List<String> tutors;

  AllCourses({
    required this.id,
    required this.name,
    required this.info,
    required this.imageUrl,
    required this.department,
    // required this.tutorAvailability,
    required this.courseRating,
    this.activeClassCount = 0,
    this.numberOfTutors = 0,
    this.pendingClassCount = 0,
    this.tutors = const [],
  });
}
