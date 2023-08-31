import 'package:tutorlinkelearning/Screens/Bookmark/bookmarkedcourses.dart';
import 'package:tutorlinkelearning/Screens/CourseDetails/reviews.dart';
import 'package:tutorlinkelearning/Screens/HomeScreens/allcourses.dart';
import 'package:tutorlinkelearning/Screens/HomeScreens/dashboard.dart';
import 'package:tutorlinkelearning/Screens/Onboarding/onboarding.dart';
import 'package:tutorlinkelearning/Screens/Profile/userProfileScreen.dart';
import 'package:tutorlinkelearning/Screens/SignIn/sign_in_screen.dart';
import 'package:tutorlinkelearning/Screens/SignUp/signupscreen.dart';
import 'package:tutorlinkelearning/Screens/Splash_Screen/splash.dart';
import 'package:tutorlinkelearning/components/home.dart';
import 'package:flutter/cupertino.dart';

Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => SplashScreen(),
  OnboardScreen.routeName: (context) => OnboardScreen(),
  SignUpScreen.routeName: (context) => SignUpScreen(),
  Allcourses.routeName: (context) => Allcourses(showNewCourses: false,),
  SignInScreen.routeName: (context) => SignInScreen(),
  HomeScreensBuilder.routeName: (context) => HomeScreensBuilder(),
  DashBoardScreen.routeName: (context) => DashBoardScreen(),
  BookedMarked.routeName:(context) => BookedMarked(),
  UserProfileScreen.routeName: (context) => UserProfileScreen(),
  ReviewScreen.routeName: (context) => ReviewScreen(
        courseId: '',
      ),
};
