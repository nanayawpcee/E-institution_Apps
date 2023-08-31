class Persistent {
  static List<String> departmentList = [
    'Biology',
    'Physics',
    'Mathematics',
    'Design',
    'Computer Science',
    'Acturial Science',
    'Biochemistry',
    'UI/UX',
    'Arts and Design',
    'Geography',
    'Languages',
    'Social sciences',
  ];
}

class CoursesClass {
  final String id;
  final String name;
  final String details;
  final String department;
  final String image;
  final int rating;
  final String duration;

  CoursesClass(
      {required this.id,
      required this.name,
      required this.details,
      required this.department,
      required this.image,
      required this.rating,
      required this.duration});
}
