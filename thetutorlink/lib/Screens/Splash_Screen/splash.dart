import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:thetutorlink/Components/home.dart';
import 'package:thetutorlink/constants.dart';
import 'package:flutter/material.dart';
import 'package:thetutorlink/Screens/Onboarding/onboarding.dart';

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
    _timer = Timer(Duration(milliseconds: 5000), () {
      _navigateToOnboard();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _navigateToOnboard() {
    User? user = _auth.currentUser;

    if (user != null) {
      Navigator.pushNamedAndRemoveUntil(
          context, HomeScreenBuilder.routeName, (route) => false);
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
