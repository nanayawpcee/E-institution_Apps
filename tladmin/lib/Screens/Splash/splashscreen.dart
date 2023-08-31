import 'dart:async';
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../SignIn/signinscreen.dart';


class SplashScreen extends StatefulWidget {
  static String routeName = 'SplashScreen';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Timer _timer;
 

  @override
  void initState() {
    super.initState();
    //set a waiting timer for the splash screen
    _timer = Timer(Duration(milliseconds: 5000), () {
       Navigator.pushNamedAndRemoveUntil(
          context, SignInScreen.routeName, (route) => false);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();// dispose timer after the time elapse
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kBlueColor,
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
              "Welcome to the best E-Learning Platform on campus",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            )
          ],
        ));
  }
}
