import 'package:flutter/material.dart';

import '../Screens/ForgetPassword/resetpassword.dart';
import '../Screens/HomeScreen/Books/addbooks.dart';
import '../Screens/HomeScreen/Course/addcourses.dart';
import '../Screens/HomeScreen/Course/allcourses.dart';
import '../Screens/HomeScreen/Tutors/acceptedtutors.dart';
import '../Screens/HomeScreen/Tutors/alltutors.dart';
import '../Screens/HomeScreen/Tutors/tutorreviews.dart';
import '../Screens/HomeScreen/dashboard.dart';
import '../Screens/HomeScreen/home.dart';
import '../Screens/SignIn/signinscreen.dart';
import '../Screens/Splash/splashscreen.dart';
import '../Screens/helpscreen.dart';
import '../Screens/policyscreen.dart';

/// Named routes. Inside the console, navigation runs through `adminNavProvider`
/// instead — these entries exist for the auth flow and for deep links into a
/// single page.
Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => const SplashScreen(),
  HelpScreen.routeName: (context) => const HelpScreen(),
  PolicyScreen.routeName: (context) => const PolicyScreen(),
  AdminPage.routeName: (context) => const AdminPage(),
  AddCourse.routeName: (context) => const AddCourse(),
  DashBoard.routeName: (context) => const DashBoard(),
  AddAcceptedTutorScreen.routeName: (context) => const AddAcceptedTutorScreen(),
  AddBooksPage.routeName: (context) => const AddBooksPage(),
  TutorReviews.routeName: (context) => const TutorReviews(),
  AllCoursesScreen.routeName: (context) => const AllCoursesScreen(),
  AllTutorsScreen.routeName: (context) => const AllTutorsScreen(),
  SignInScreen.routeName: (context) => const SignInScreen(),
  ResetPasswordScreen.routeName: (context) => const ResetPasswordScreen(),
};
