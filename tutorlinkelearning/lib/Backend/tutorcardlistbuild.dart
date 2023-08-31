import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Screens/CourseDetails/coursesdetail.dart';
import '../components/tutorcard.dart';

class tutorcardbuilder_coursedetails extends StatelessWidget {
  const tutorcardbuilder_coursedetails({
    super.key,
    required this.widget,
  });

  final CourseDetailScreen widget;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Courses')
          .doc(widget.courseId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasData && snapshot.data!.exists) {
          // Check if the 'tutors' field exists in the DocumentSnapshot
          final data = snapshot.data!.data() as Map<String, dynamic>;
          if (data.containsKey('tutors')) {
            List<String> tutorIds = List.from(data['tutors']);

            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: tutorIds.length,
              itemBuilder: (context, index) {
                return StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Tutors')
                      .doc(tutorIds[index])
                      .snapshots(),
                  builder: (context, tutorSnapshot) {
                    if (tutorSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Container();
                    }
                    // Get tutor data from snapshot
                    var tutorData = tutorSnapshot.data;
                    if (tutorData != null) {
                      // Query the "Courses" collection to find the course containing the tutor
                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Courses')
                            .where('tutors', arrayContains: tutorData['id'])
                            .snapshots(),
                        builder: (context, courseSnapshot) {
                          if (courseSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container();
                          }
                          // Check if the course data exists and is not empty
                          var courses = courseSnapshot.data!.docs;
                          if (courses.isNotEmpty) {
                            // Assuming there's only one course with the tutor in the "tutors" array

                            // Pass the courseId to the TutorCard
                            return TutorCard(
                              tutorId: tutorData['id'],
                              imageUrl: tutorData['userImage'],
                              tutorName: tutorData['name'],
                              courseId: courses[0].id,
                              students: tutorData['students'].length,
                              isOpen: tutorData['available'],
                              rating: tutorData['rating'],
                            );
                          } else {
                            // No course found for this tutor
                            return Container();
                          }
                        },
                      );
                    } else {
                      return Container();
                    }
                  },
                );
              },
            );
          } else {
            // 'tutors' field doesn't exist in the DocumentSnapshot
            return const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text('No tutors'),
                ),
              ],
            );
          }
        } else {
          // Snapshot doesn't contain data or has encountered a bad state
          return const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text('No tutors'),
              ),
            ],
          );
        }
      },
    );
  }
}
