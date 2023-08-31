import 'package:flutter/material.dart';
import 'package:tladmin/Screens/HomeScreen/Course/addcourses.dart';
import 'package:tladmin/Screens/HomeScreen/Course/allcourses.dart';
import 'package:tladmin/Screens/HomeScreen/Tutors/acceptedtutors.dart';
import 'package:tladmin/Screens/HomeScreen/dashboard.dart';
import 'package:tladmin/Screens/HomeScreen/home.dart';
import 'package:tladmin/Screens/HomeScreen/Tutors/alltutors.dart';
import 'package:tladmin/Screens/HomeScreen/Tutors/tutorreviews.dart';
import 'package:tladmin/Screens/helpscreen.dart';
import 'package:tladmin/Screens/policyscreen.dart';
import '../Screens/ForgetPassword/resetpassword.dart';
import '../Screens/SignIn/signinscreen.dart';
import '../Screens/Splash/splashscreen.dart';

//these are the routes nameed for with unique names 
//for easy navigations between screens
Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => SplashScreen(),
  HelpScreen.routeName: (context) => HelpScreen(),
  PolicyScreen.routeName: (context) => PolicyScreen(),
  AdminPage.routeName: (context) => AdminPage(),
  AddCourse.routeName: (context) => AddCourse(),
  DashBoard.routeName: (context) => DashBoard(),
  AddAcceptedTutorScreen.routeName: (context) => AddAcceptedTutorScreen(),
  TutorReviews.routeName: (context) => TutorReviews(),
  AllCoursesScreen.routeName: (context) => AllCoursesScreen(),
  AllTutorsScreen.routeName: (context) => AllTutorsScreen(),
  SignInScreen.routeName: (context) => SignInScreen(),
  ResetPasswordScreen.routeName: (context) => ResetPasswordScreen(),
};
