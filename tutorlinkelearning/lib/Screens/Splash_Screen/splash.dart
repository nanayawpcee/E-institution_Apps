import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:tutorlinkelearning/components/home.dart';
import 'package:tutorlinkelearning/constants.dart';
import 'package:flutter/material.dart';
import 'package:tutorlinkelearning/Screens/Onboarding/onboarding.dart';

class SplashScreen extends StatefulWidget {
  static String routeName = 'SplashScreen';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Timer _timer;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    //set a waiting time the splash screen
    _timer = Timer(Duration(milliseconds: 5000), () {
      _navigateToOnboard();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();//dispose off timer after time elapses
  }

  void _navigateToOnboard() {
    User? user = _auth.currentUser;

    if (user != null) {
      Navigator.pushNamedAndRemoveUntil(
          context, HomeScreensBuilder.routeName, (route) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(
          context, OnboardScreen.routeName, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kWhiteColor,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    height: 150,
                    width: 150,
                    child: Image.asset('assets/images/Logop.png')),
              ],
            ),
            const Text(
              textAlign: TextAlign.center,
              "E-Learning Platform",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            )
          ],
        ));
  }
}
