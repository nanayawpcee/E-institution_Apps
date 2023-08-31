import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tutorlinkelearning/Screens/CourseDetails/coursesdetail.dart';
import '../../components/coursecard.dart';
import '../../constants.dart';

import '../../utils/coursename.dart';

class BookedMarked extends StatefulWidget {
  static String routeName = 'BookMarksScreen';
  @override
  State<BookedMarked> createState() => _BookedMarkedState();
}

class _BookedMarkedState extends State<BookedMarked> {
  int selectedIndex = 0;
  final studentId = FirebaseAuth.instance.currentUser!.uid;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 30,
                          child: TextField(
                            cursorHeight: 24,
                            keyboardType: TextInputType.text,
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value; // Update the search query
                              });
                            },
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              suffixIcon: const Icon(
                                Icons.search_outlined,
                                color: kBlueColor,
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              hintText: 'Search any course',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'My BookMarked Courses',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _getCoursesStream(selectedIndex),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          final courses = snapshot.data!.docs;
                          if (courses.isEmpty) {
                            return const Center(
                              child: Text(
                                'No courses found for the selected status.',
                              ),
                            );
                          } else {
                            final filteredCourses =
                                courses.where((courseSnapshot) {
                              final courseData = courseSnapshot.data();
                              // ignore: unnecessary_null_comparison
                              if (courseData != null) {
                                final course = CoursesType.fromMap(courseData);
                                final courseName = course.name.toLowerCase();
                                return courseName
                                    .contains(searchQuery.toLowerCase());
                              } else {
                                return false;
                              }
                            }).toList();
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                child: ListView.builder(
                                  itemCount: filteredCourses.length,
                                  itemBuilder: (context, index) {
                                    final courseSnapshot =
                                        filteredCourses[index];
                                    final courseData = courseSnapshot.data();
                                    // ignore: unnecessary_null_comparison
                                    if (courseData != null) {
                                      final course =
                                          CoursesType.fromMap(courseData);
                                      final courseId = courseSnapshot.id;

                                      return MyCourseCard(
                                          course: course,
                                          isActive: true,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    CourseDetailScreen(
                                                  courseId: courseId,
                                                ),
                                              ),
                                            );
                                          });
                                    } else {
                                      return Container();
                                    }
                                  },
                                ),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _getCoursesStream(
    int selectedIndex,
  ) {
    final collectionRef = FirebaseFirestore.instance.collection('Courses');
    final studentRef =
        FirebaseFirestore.instance.collection('Students').doc(studentId);

    return studentRef.snapshots().asyncMap<QuerySnapshot<Map<String, dynamic>>>(
      (studentSnapshot) async {
        final List<dynamic>? courseIds =
            studentSnapshot.get('bookmarks') as List<dynamic>?;

        final List<String> validCourseIds =
            courseIds?.whereType<String>().toList() ?? [];

        if (validCourseIds.isEmpty) {
          return collectionRef
              .where(FieldPath.documentId, isGreaterThanOrEqualTo: 'no_id')
              .get();
        }

        return collectionRef
            .where(FieldPath.documentId, whereIn: validCourseIds)
            .get();
      },
    );
  }
}
