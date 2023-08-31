import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tutorlinkelearning/Screens/CourseDetails/coursesdetail.dart';
import 'package:tutorlinkelearning/constants.dart';
import 'package:tutorlinkelearning/utils/coursename.dart';
import 'package:flutter/material.dart';

import '../utils/dateformat.dart';

class CourseCardListView extends StatelessWidget {
  final String selectedDepartment;
  final String searchText;

  CourseCardListView({
    required this.selectedDepartment,
    required this.searchText,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Courses').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<DocumentSnapshot> courseDocuments = snapshot.data!.docs;
          final List<CoursesType> courses = courseDocuments
              .map((doc) =>
                  CoursesType.fromMap(doc.data() as Map<String, dynamic>))
              .where((course) {
            if (selectedDepartment == 'All' ||
                course.department == selectedDepartment) {
              if (searchText.isEmpty) {
                return true; // Show all courses when selectedDepartment is "All" and no search text is entered
              } else {
                return course.name
                    .toLowerCase()
                    .contains(searchText.toLowerCase());
              }
            }
            return false;
          }).toList();

          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];

              return CourseCard(
                course: course,
              );
            },
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class CourseCard extends StatelessWidget {
  final CoursesType course;

  const CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailScreen(courseId: course.courseId),
          ),
        );
      },
      child: SizedBox(
        height: 100,
        width: MediaQuery.of(context).size.width - 32,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: kGreyColor500,
                    image: DecorationImage(image: NetworkImage(course.image))),
              ),
              const SizedBox(
                width: 20,
              ),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course.name,
                        style: GoogleFonts.sourceSansPro(
                            fontWeight: FontWeight.w500, fontSize: 18)),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.star,
                          color: kYellowColor,
                        ),
                        const SizedBox(
                          width: 3,
                        ),
                        Text(course.rating.toStringAsFixed(1)),
                        const SizedBox(
                          width: 30,
                        ),
                        const Icon(Icons.av_timer_sharp),
                        Text(formatDuration(course.duration))
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//All courses card
class CoursesCard extends StatefulWidget {
  @override
  State<CoursesCard> createState() => _CoursesCardState();
  final String course;
  final String courseId;
  final String courseIcon;
  final String department;
  final int rating;
  final double duration;
  final String description;

  const CoursesCard({
    required this.courseId,
    required this.duration,
    required this.courseIcon,
    required this.course,
    required this.rating,
    required this.department,
    required this.description,
  });
}

class _CoursesCardState extends State<CoursesCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailScreen(courseId: widget.courseId),
          ),
        );
      },
      child: Card(
        elevation: 8,
        surfaceTintColor: Colors.lightGreen,
        child: Padding(
          padding:
              const EdgeInsets.only(bottom: 10, left: 10, right: 10, top: 15),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            height: 85,
            width: MediaQuery.of(context).size.width - 32,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Hero(
                  tag:
                      '${widget.courseId}_icon', // Use a unique tag for the icon
                  child: Material(
                    type: MaterialType.transparency,
                    child: Container(
                      width: 75,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: kGreyColor500,
                          image: DecorationImage(
                              image: NetworkImage(widget.courseIcon),
                              fit: BoxFit.fill)),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: '${widget.courseId}_name',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            widget.course,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                      ),
                      Text(
                        '${widget.description}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 2,
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.star,
                                color: kYellowColor,
                              ),
                              Text(
                                '${widget.rating.toDouble()}',
                                style: TextStyle(fontSize: 10),
                              ),
                              const SizedBox(
                                width: 100,
                              ),
                              const Icon(Icons.av_timer_sharp),
                              Text(
                                formatDuration(widget.duration),
                                style: TextStyle(fontSize: 10),
                              )
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// User Personalised course card for Mycourses Page
class MyCourseCard extends StatelessWidget {
  final CoursesType course;
  final bool isActive;
  final VoidCallback? onTap;

  MyCourseCard({
    required this.course,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isActive && onTap != null) {
          onTap!();
        }
      },
      child: Card(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 2, top: 2),
          child: Container(
            height: 150,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            width: MediaQuery.of(context).size.width - 40,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Material(
                  child: Container(
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: kGreyColor600,
                      image: DecorationImage(
                          image: NetworkImage(course.image), fit: BoxFit.fill),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: Text(
                            course.name,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          course.details,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          textAlign: TextAlign.start,
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Container(
                          height: 24,
                          width: MediaQuery.of(context).size.width / 4,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.black45),
                          child: Center(
                            child: Text(
                              course.department,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: kWhiteColor),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            const SizedBox(
                              width: 3,
                            ),
                            Text(course.rating.toString()),
                            const SizedBox(
                              width: 30,
                            ),
                            const Icon(Icons.av_timer_sharp),
                            Text(formatDuration(course.duration)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
