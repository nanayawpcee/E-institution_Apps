import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:tutorlinkelearning/Screens/ClassRoom/assignment.dart';
import 'package:tutorlinkelearning/Screens/ClassRoom/resourse.dart';

import 'package:tutorlinkelearning/Screens/ClassRoom/settingspage.dart';
import 'package:tutorlinkelearning/constants.dart';

class CourseMaterialPage extends StatefulWidget {
  final String courseId;
  final String studentId;

  const CourseMaterialPage(
      {required this.courseId, required String this.studentId});
  @override
  _CourseMaterialPageState createState() => _CourseMaterialPageState();
}

class _CourseMaterialPageState extends State<CourseMaterialPage> {
  final PageController _pageController = PageController();
  List<Widget> _pages = [];

  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchClassroomData();
    _pages = [
      ResourcePage(
        studentId: widget.studentId,
        courseId: widget.courseId,
      ),
      AssignmentsPage(courseId: widget.courseId),
      SettingsPage(),
    ];
  }

  void _onMenuItemTap(int index) {
    setState(() {
      _currentPageIndex = index;
      _pageController.jumpToPage(index);
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _pages,
        onPageChanged: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
      ),
      drawer: Drawer(
        backgroundColor: kBlueColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              child: Text(
                'Classroom',
                style: TextStyle(fontSize: 30, color: kYellowColor),
              ),
              decoration: BoxDecoration(
                color: kGreyColor800,
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/images/class.png')),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.book,
                color: kGreyColor500,
              ),
              title: const Text('Resources',
                  style: TextStyle(color: kWhiteColor, fontSize: 18)),
              selected: _currentPageIndex == 0,
              onTap: () => _onMenuItemTap(0),
            ),
            ListTile(
              leading: const Icon(
                Icons.assignment_add,
                color: kGreyColor500,
              ),
              title: const Text(
                'Assignments',
                style: TextStyle(color: kWhiteColor, fontSize: 18),
              ),
              selected: _currentPageIndex == 1,
              onTap: () => _onMenuItemTap(1),
            ),
            ListTile(
              leading: const Icon(
                Icons.settings,
                color: kGreyColor500,
              ),
              title: const Text('Settings Page',
                  style: TextStyle(color: kWhiteColor, fontSize: 18)),
              selected: _currentPageIndex == 2,
              onTap: () => _onMenuItemTap(2),
            ),
          ],
        ),
      ),
    );
  }

// Assuming you have currentUser and widget.courseId defined somewhere.

  Future<void> fetchClassroomData() async {
    try {
      QuerySnapshot classroomSnapshot = await FirebaseFirestore.instance
          .collection('Classroom')
          .where('studentId', isEqualTo: widget.studentId)
          .where('courseId', isEqualTo: widget.courseId)
          .get();

      if (classroomSnapshot.docs.isNotEmpty) {
        DocumentSnapshot classroomDocument = classroomSnapshot.docs.first;

        String classroomId = classroomDocument.id;
        String tutorId = classroomDocument.get('tutorId');
        Timestamp endTime = classroomDocument.get('Endtime');

        if (endTime.toDate().isBefore(DateTime.now())) {
          // Class has ended, show a dialog with review and rating fields.
          String review = '';
          double rating = 0.0;

          if (widget.studentId.isNotEmpty) {
            // Fetch user's name and userImage from the Students collection.
            DocumentSnapshot studentSnapshot = await FirebaseFirestore.instance
                .collection('Students')
                .doc(widget.studentId)
                .get();

            String userName = studentSnapshot.get('name') ?? '';
            String userImage = studentSnapshot.get('userImage') ?? '';

            // ignore: use_build_context_synchronously
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Class Ended'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Please rate the tutor and the course.'),
                      RatingBar.builder(
                        initialRating: rating,
                        minRating: 1,
                        maxRating: 5,
                        direction: Axis.horizontal,
                        itemCount: 5,
                        itemSize: 30,
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: kYellowColor,
                        ),
                        onRatingUpdate: (newRating) {
                          rating = newRating;
                        },
                      ),
                      TextField(
                        onChanged: (value) {
                          review = value;
                        },
                        decoration: const InputDecoration(
                          hintText: 'Write your review...',
                        ),
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () async {
                        if (userName.isNotEmpty) {
                          // Add the review to the TutorReviews collection.
                          await FirebaseFirestore.instance
                              .collection('TutorReviews')
                              .add({
                            'message': review,
                            'timePosted': FieldValue.serverTimestamp(),
                            'postedBy': userName,
                            'userImage': userImage,
                            'rating': rating,
                            'tutorId': tutorId
                          });

                          // Delete the document.
                          await FirebaseFirestore.instance
                              .collection('Classroom')
                              .doc(classroomId)
                              .delete();
                          // Remove student from tutor's list of students
                          await FirebaseFirestore.instance
                              .collection('Tutors')
                              .doc(tutorId)
                              .update({
                            'students':
                                FieldValue.arrayRemove([widget.studentId])
                          });
                          // Update student data i.e courses
                          await FirebaseFirestore.instance
                              .collection('Students')
                              .doc(widget.studentId)
                              .update({
                            'Active': FieldValue.arrayRemove([widget.courseId]),
                            'Completed':
                                FieldValue.arrayUnion([widget.courseId])
                          });

                          // Navigate to home screen.
                          Navigator.popUntil(context, ModalRoute.withName('/'));
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                );
              },
            );
          }
        }
      } else {
        print('No classroom found for the current user and courseId.');
      }
    } catch (e) {
      print('Error fetching classroom data: $e');
    }
  }
}
