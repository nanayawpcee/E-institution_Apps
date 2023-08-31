import 'package:flutter/material.dart';
import 'package:tladmin/constants.dart';
import 'Utils/body.dart';
import 'Utils/menu.dart';

class SignInScreen extends StatefulWidget {
  static String routeName = 'SignInScreen';

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool isSignUp = false;
bool _isLoading = false;

//this toggle's the signup form
  void _toggleSignUp(bool isSignUp) {
    setState(() {
      this.isSignUp = isSignUp;
    });
  }

  void _setLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhiteColor,
      body: Center(
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width / 12,
          ),
          children: [
            //for the homepage interface which is the signin page on firt load
            Menu(isSignUp: isSignUp, onToggleSignUp: _toggleSignUp),
            Body(isSignUp: isSignUp, isLoading: _isLoading, setLoading: _setLoading),  
          ],
        ),
      ),
    );
  }
}
