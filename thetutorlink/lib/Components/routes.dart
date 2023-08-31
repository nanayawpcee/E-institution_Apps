import 'package:thetutorlink/Screens/ForgetPassword/forgetpassword.dart';
import 'package:thetutorlink/Screens/Onboarding/onboarding.dart';
import 'package:thetutorlink/Screens/Profile/userProfileScreen.dart';
import 'package:thetutorlink/Screens/SignIn/sign_in_screen.dart';

import 'package:thetutorlink/Screens/Splash_Screen/splash.dart';
import 'package:thetutorlink/Components/home.dart';
import 'package:flutter/cupertino.dart';

import '../Screens/HomeScreens/dashboard.dart';

Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => SplashScreen(),
  OnboardScreen.routeName: (context) => OnboardScreen(),

  SignInScreen.routeName: (context) => SignInScreen(),
  ResetPasswordScreen.routeName: (context) => ResetPasswordScreen(),
  HomeScreenBuilder.routeName: (context) => HomeScreenBuilder(),

 DashBoardScreen.routeName: (context) => DashBoardScreen(),
  UserProfileScreen.routeName: (context) => UserProfileScreen(),
};
