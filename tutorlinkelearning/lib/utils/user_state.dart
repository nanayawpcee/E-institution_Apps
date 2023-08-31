import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tutorlinkelearning/Screens/Splash_Screen/splash.dart';
import 'package:tutorlinkelearning/components/home.dart';

class UserState extends StatefulWidget {
  @override
  State<UserState> createState() => _UserState();
}
//this user state manages when user close app but is still loggin to enhace quick usage of the up
class _UserState extends State<UserState> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, userSnapshot) {
        if (userSnapshot.data == null) {
          return SplashScreen();
        } else if (userSnapshot.hasData) {
          return HomeScreensBuilder();
        } else if (userSnapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text('Error Occured'),
            ),
          );
        } else if (userSnapshot.connectionState == ConnectionState.waiting) {
          return SplashScreen();
        } else {
          return SplashScreen();
        }
      },
    );
  }
}
