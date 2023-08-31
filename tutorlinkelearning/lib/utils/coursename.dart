class CoursesType {
  String courseId;
  String name;
  String image;
  String details;
  String department;
  int rating;
  double duration;

  CoursesType(
      {this.duration = 0.0,
      this.courseId = '',
      this.name = '',
      this.image = '',
      this.details = '',
      this.department = '',
      this.rating = 0});

  // Factory constructor to create an instance from a Firestore document snapshot
  factory CoursesType.fromMap(Map<String, dynamic> map) {
    return CoursesType(
        courseId: map['courseId'] ?? '',
        name: map['courseName'] ?? '',
        image: map['courseIcon'] ?? '',
        details: map['courseInfo'] ?? '',
        department: map['department'] ?? '',
        duration: map['duration'] ?? 0.0,
        rating: map['ratings'] ?? '');
  }
}
