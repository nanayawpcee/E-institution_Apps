import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:tutorlinkelearning/constants.dart';

import '../Screens/SignUp/emailverification.dart';

class signupauth extends StatefulWidget {
  signupauth({
    super.key,
    required GlobalKey<FormState> formkey,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required TextEditingController nameController,
  })  : _formkey = formkey,
        _emailController = emailController,
        _passwordController = passwordController,
        _nameController = nameController;

  final GlobalKey<FormState> _formkey;
  final TextEditingController _emailController;
  final TextEditingController _passwordController;
  final TextEditingController _nameController;

  @override
  State<signupauth> createState() => _signupauthState();
}

class _signupauthState extends State<signupauth> {
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Variable to track loading state
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      InkWell(
          child: GestureDetector(
        //Sign up Account and Move to the Home Screen
        //Firebase authentication
        onTap: () async {
          if (widget._formkey.currentState!.validate()) {
            setState(() {
              _isLoading = true;
            });

            try {
              UserCredential userCredential =
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(
                email: widget._emailController.text.trim().toLowerCase(),
                password: widget._passwordController.text.trim(),
              );

              User? user = userCredential.user;
              if (user != null) {
                final _uid = user.uid;
                String? fcmToken = await FirebaseMessaging.instance.getToken();
                await FirebaseFirestore.instance
                    .collection('Students')
                    .doc(_uid)
                    .set({
                  'id': _uid,
                  'All': [],
                  'Pending': [],
                  'Completed': [],
                  'bookmarks':[],
                  'fcmToken': fcmToken, 
                  'Active': [],
                  'tutors': [],
                  'userImage': "",
                  'name': widget._nameController.text,
                  'email': widget._emailController.text,
                  'createAt': Timestamp.now(),
                });
                // Send email verification
                await user.sendEmailVerification();

                // Navigate to Email Verification Screen
                // ignore: use_build_context_synchronously
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EmailVerificationScreen()),
                );
              } else {
                // Handle the case when the user is null
                _showErrorDialog('User creation failed. User is null.');
              }
            } catch (e) {
              // Handle the exception
              _showErrorDialog('Error during sign up: $e');
            } finally {
              setState(() {
                _isLoading = false;
              });
            }
          }
        },

        //Sign up button widget and it's decoration
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: kBlueColor,
            ),
            child: Center(
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text(
                        "SIGN UP",
                        style: TextStyle(
                            color: Theme.of(context)
                                .copyWith()
                                .scaffoldBackgroundColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      )),
          ),
        ),
      )),
      // this is to show CircularProgressIndicator when loading
      if (_isLoading)
        const Positioned.fill(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
    ]);
  }
}
