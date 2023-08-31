import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tutorlinkelearning/Screens/ClassRoom/coursematerialbucket.dart';

import '../../components/coursecard.dart';
import '../../components/mycoursestatus.dart';
import '../../constants.dart';

import '../../utils/coursename.dart'; // Import the provided CoursesType class

class Mycourses extends StatefulWidget {
  const Mycourses({super.key});

  @override
  State<Mycourses> createState() => _MycoursesState();
}

class _MycoursesState extends State<Mycourses> {
  int selectedIndex = 0;
  final studentId = FirebaseAuth.instance.currentUser!.uid;
  String searchQuery = '';

  String statusFromIndex(int index) {
    switch (index) {
      case 0:
        return 'All';
      case 1:
        return 'Active';
      case 2:
        return 'Pending';
      case 3:
        return 'Completed';
      default:
        return 'All';
    }
  }

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
                            'My Courses',
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
                    Expanded(
                      flex: -1,
                      child: Container(
                        child: Row(
                          children: [
                            CourseStatusList(
                              selectedIndex: selectedIndex,
                              onChanged: (index) {
                                setState(() {
                                  selectedIndex = index;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
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
                                    final courseSnapshot = filteredCourses[index];
                                    final courseData = courseSnapshot.data();
                                    // ignore: unnecessary_null_comparison
                                    if (courseData != null) {
                                      final course =
                                          CoursesType.fromMap(courseData);
                                      final courseId = courseSnapshot.id;
                                      final bool isStatusActive =
                                          statusFromIndex(selectedIndex) ==
                                              'Active';

                                      return MyCourseCard(
                                        course: course,
                                        isActive: isStatusActive,
                                        onTap: isStatusActive
                                            ? () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        CourseMaterialPage(
                                                      courseId: courseId,
                                                      studentId: studentId,
                                                    ),
                                                  ),
                                                );
                                              }
                                            : null,
                                      );
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
        final List<dynamic>? courseIds = studentSnapshot
            .get(statusFromIndex(selectedIndex)) as List<dynamic>?;

        final List<String> validCourseIds =
            courseIds?.whereType<String>().toList() ?? [];

        if (validCourseIds.isEmpty) {
          return collectionRef
              .where(FieldPath.documentId, isEqualTo: 'no_id')
              .get();
        }

        return collectionRef
            .where(FieldPath.documentId, whereIn: validCourseIds)
            .get();
      },
    );
  }
}
