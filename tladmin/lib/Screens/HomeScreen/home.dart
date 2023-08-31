import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:tladmin/Screens/HomeScreen/Books/addbooks.dart';
import 'package:tladmin/Screens/HomeScreen/Course/addcourses.dart';
import 'package:tladmin/Screens/HomeScreen/Course/allcourses.dart';
import 'package:tladmin/Screens/HomeScreen/Tutors/acceptedtutors.dart';

import 'package:tladmin/Screens/HomeScreen/dashboard.dart';
import 'package:tladmin/Screens/HomeScreen/Tutors/alltutors.dart';
import 'package:tladmin/Screens/HomeScreen/Tutors/tutorreviews.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tladmin/constants.dart';

import '../SignIn/signinscreen.dart';

class AdminPage extends StatefulWidget {
  static String routeName = 'AdminPage';

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Widget _selectedScreen = DashBoard();

//we set place place holders using the switch cases to get the bucket pages
  currentScreen(item) {
    switch (item.route) {
      case 'DashBoard':
        setState(() {
          _selectedScreen = DashBoard();
        });
        break;
      case 'AllTutorsScreen':
        setState(() {
          _selectedScreen = AllTutorsScreen();
        });
        break;
      case 'AddCourse':
        setState(() {
          _selectedScreen = AddCourse();
        });
        break;
      case 'AllCoursesScreen':
        setState(() {
          _selectedScreen = AllCoursesScreen();
        });
        break;
      case 'TutorReviews':
        setState(() {
          _selectedScreen = TutorReviews();
        });
        break;
      case 'AddAcceptedTutors':
        setState(() {
          _selectedScreen = AddAcceptedTutorScreen();
        });
        break;
      case 'AddBooks':
        setState(() {
          _selectedScreen = AddBooksPage();
        });
        break;
    }
  }
// Admin Scaffold widget from pub.dev with Ui fit for admin page
  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('TUTORLINK ADMINISTRATION'),
        centerTitle: true,
      ),
      sideBar: SideBar(
        items: const [
          AdminMenuItem(
            title: 'Dashboard',
            route: 'DashBoard',
            icon: Icons.dashboard,
          ),
          AdminMenuItem(
            title: 'Courses',
            icon: Icons.file_copy,
            children: [
              AdminMenuItem(
                title: 'Add Course',
                route: 'AddCourse',
              ),
              AdminMenuItem(
                title: 'Course Status',
                route: 'AllCoursesScreen',
                // children: [],
              ),
            ],
          ),
          AdminMenuItem(
            title: 'Tutor',
            icon: Icons.file_copy,
            children: [
              AdminMenuItem(
                title: 'Tutors',
                route: 'AllTutorsScreen', 
              ),
              AdminMenuItem(
                title: 'Accepted Tutors',
                children: [
                  AdminMenuItem(
                    title: 'Add Tutors',
                    route: 'AddAcceptedTutors',
                  ),
                  AdminMenuItem(
                    title: 'Reviews',
                    route: 'TutorReviews',
                  ),
                ],
              ),
            ],
          ),
          AdminMenuItem(
              title: 'Books',
              icon: Icons.library_books_rounded,
              children: [AdminMenuItem(title: 'Add Books', route: 'AddBooks')])
        ],
        selectedRoute: 'AdminPage', 
        onSelected: (item) {
          currentScreen(item);
        },
        header: Container(
          height: 50,
          width: double.infinity,
          color: kGreyColor900,
          child: const Center(
            child: Text(
              'Admin Menu',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
        footer: GestureDetector(
          onTap: () {
            _auth.signOut();
            Navigator.pushNamedAndRemoveUntil(
                context, SignInScreen.routeName, (route) => false);
          },
          child: Container(
            height: 50,
            width: double.infinity,
            color: kRedColor,
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_outlined),
                  Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(child: _selectedScreen),
    );
  }
}
