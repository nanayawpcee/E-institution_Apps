import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutorlinkelearning/Screens/CourseDetails/coursesdetail.dart';
import 'package:tutorlinkelearning/constants.dart';

class CourseGridView extends StatelessWidget {
  final List<QueryDocumentSnapshot> courses;

  CourseGridView({required this.courses});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        String imageUrl = courses[index].get('courseIcon');
        return GestureDetector(
          onTap: () {
            // Navigate to the course page with course details
            String courseId = courses[index].id;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CourseDetailScreen(courseId: courseId),
              ),
            );
          },
          child: Container(
            height: 40,
            width: 25,
            decoration: BoxDecoration(
              color: kGreyColor500,
              image: DecorationImage(
                fit: BoxFit.contain,
                image: NetworkImage(imageUrl),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }
}
