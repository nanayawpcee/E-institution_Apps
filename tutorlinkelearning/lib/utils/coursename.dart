class CoursesType {
  String courseId;
  String name;
  String image;
  String details;
  String department;
  int rating;
  double duration;
  String videoUrl;
  List<String> tutorIds;
  DateTime createdAt;

  CoursesType({
    this.duration = 0.0,
    this.courseId = '',
    this.name = '',
    this.image = '',
    this.details = '',
    this.department = '',
    this.rating = 0,
    this.videoUrl = '',
    List<String>? tutorIds,
    DateTime? createdAt,
  })  : tutorIds = tutorIds ?? [],
        createdAt = createdAt ?? DateTime.now();
}
