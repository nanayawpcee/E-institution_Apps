import 'package:flutter/widgets.dart';

import '../Screens/Bookmark/bookmarkedcourses.dart';
import '../Screens/HomeScreens/allcourses.dart';
import '../Screens/HomeScreens/dashboard.dart';
import '../Screens/Onboarding/onboarding.dart';
import '../Screens/Profile/userProfileScreen.dart';
import '../Screens/SignIn/sign_in_screen.dart';
import '../Screens/SignUp/signupscreen.dart';
import '../Screens/Splash_Screen/splash.dart';
import 'home.dart';

/// Named routes for the flows that are entered by name; everything reached
/// from a card or list is pushed with a constructed route instead.
Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => const SplashScreen(),
  OnboardScreen.routeName: (context) => const OnboardScreen(),
  SignUpScreen.routeName: (context) => const SignUpScreen(),
  SignInScreen.routeName: (context) => const SignInScreen(),
  HomeScreensBuilder.routeName: (context) => const HomeScreensBuilder(),
  Allcourses.routeName: (context) => const Allcourses(showNewCourses: false),
  DashBoardScreen.routeName: (context) => const DashBoardScreen(),
  BookedMarked.routeName: (context) => const BookedMarked(),
  UserProfileScreen.routeName: (context) => const UserProfileScreen(),
};
