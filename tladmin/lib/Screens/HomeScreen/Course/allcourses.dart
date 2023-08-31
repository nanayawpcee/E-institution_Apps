import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tladmin/constants.dart';
import '../../../models/tutorclass.dart';

class AllCoursesScreen extends StatefulWidget {
  static String routeName = 'AllCoursesScreen';

  @override
  _AllCoursesScreenState createState() => _AllCoursesScreenState();
}

class _AllCoursesScreenState extends State<AllCoursesScreen> {
  List<AllCourses> _courses = [];
  AllCourses? _selectedCourse;

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  void fetchCourses() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('Courses').get();

    List<AllCourses> courses = [];

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      AllCourses course = AllCourses(
          id: doc.id,
          name: doc['courseName'],
          imageUrl: doc['courseIcon'],
          department: doc['department'],
          courseRating: doc['ratings'],
          info: doc['courseInfo'],
          activeClassCount: 0,
          pendingClassCount: 0,
          tutors: [],
          numberOfTutors: 0);

      // Fetch additional data
      await fetchActiveClasses(course);
      await fetchPendingClasses(course);
      await fetchNumberOfTutors(course);

      courses.add(course);
    }

    setState(() {
      _courses = courses;
      if (courses.isNotEmpty) {
        _selectedCourse =
            courses[0]; // Set the 1st tutor as selected by default
      }
    });
  }

  Future<void> fetchNumberOfTutors(AllCourses course) async {
    DocumentSnapshot courseSnapshot = await FirebaseFirestore.instance
        .collection('Courses')
        .doc(course.id)
        .get();

    List<dynamic> tutors = courseSnapshot['tutors'] ?? [];

    setState(() {
      course.numberOfTutors = tutors.length;
    });
  }

  Future<void> fetchActiveClasses(AllCourses course) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Classroom')
        .where('courseId', isEqualTo: course.id)
        .get();

    course.activeClassCount = querySnapshot.docs.length;
  }

  Future<void> fetchPendingClasses(AllCourses course) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Requests')
        .where('courseId', isEqualTo: course.id)
        .where('isPending', isEqualTo: true)
        .get();

    course.pendingClassCount = querySnapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: DataTable(
            decoration: const BoxDecoration(color: kGreyColor500),
            border: TableBorder.all(
              color: kGreyColor600,
              borderRadius:
                  const BorderRadius.only(bottomLeft: Radius.circular(8)),
            ),
            dividerThickness: 3,
            showBottomBorder: true,
            columns: const [
              DataColumn(label: Text('Course Icon')),
              DataColumn(label: Text('Course Name')),
              DataColumn(label: Text('Department')),
              DataColumn(label: Text('Rating')),
            ],
            rows: _courses.map((allCourses) {
              return DataRow(
                onSelectChanged: (selected) {
                  setState(() {
                    _selectedCourse = allCourses;
                  });
                },
                cells: [
                  DataCell(
                    Container(
                      decoration: BoxDecoration(
                        color: kGreyColor500,
                        image: DecorationImage(
                          image: NetworkImage(allCourses.imageUrl),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                  DataCell(Text(allCourses.name)),
                  DataCell(Text(allCourses.department)),
                  DataCell(Text(allCourses.courseRating.toStringAsFixed(1))),
                ],
              );
            }).toList(),
          ),
        ),
        Expanded(
          flex: 0,
          child: _selectedCourse != null
              ? SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 5,
                    height: MediaQuery.of(context).size.height / 1.2,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: kGreyColor700),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          height: 100,
                          width: 80,
                          decoration: BoxDecoration(
                            color: kGreyColor500,
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: NetworkImage(_selectedCourse!.imageUrl),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('Name: ${_selectedCourse!.name}'),
                              Text(
                                  'Department: ${_selectedCourse!.department}'),
                              Text(
                                  'Rating: ${_selectedCourse!.courseRating.toStringAsFixed(1)}'),
                              Text(
                                'Course Info: ${_selectedCourse!.info}',
                                softWrap: true,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Active Classes: ${_selectedCourse!.activeClassCount}',
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Pending Classes: ${_selectedCourse!.pendingClassCount}',
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Number of Tutors: ${_selectedCourse!.numberOfTutors}',
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const Center(
                  child: Text('No Course selected'),
                ),
        ),
      ],
    );
  }
}
