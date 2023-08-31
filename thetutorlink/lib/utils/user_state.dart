import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thetutorlink/Screens/Splash_Screen/splash.dart';
import 'package:thetutorlink/components/home.dart';

class UserState extends StatefulWidget {
  @override
  State<UserState> createState() => _UserState();
}

class _UserState extends State<UserState> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, userSnapshot) {
        if (userSnapshot.data == null) {
          return SplashScreen();
        } else if (userSnapshot.hasData) {
          return HomeScreenBuilder();
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
