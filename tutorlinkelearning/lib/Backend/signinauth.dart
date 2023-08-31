import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:tutorlinkelearning/components/home.dart';
import 'package:tutorlinkelearning/constants.dart';

class signinauth extends StatefulWidget {
  const signinauth({
    super.key,
    required GlobalKey<FormState> signinformkey,
    required FirebaseAuth auth,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required Function(String) onError,
  })  : _signinformkey = signinformkey,
        _auth = auth,
        _emailController = emailController,
        _passwordController = passwordController,
        _onError = onError;

  final GlobalKey<FormState> _signinformkey;
  final FirebaseAuth _auth;
  final TextEditingController _emailController;
  final TextEditingController _passwordController;
  final Function(String) _onError;

  @override
  State<signinauth> createState() => _signinauthState();
}

class _signinauthState extends State<signinauth> {
  //variable for waiting property
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      GestureDetector(
        onTap: () async {
          if (widget._signinformkey.currentState!.validate()) {
            setState(() {
              _isLoading = true;
            });
            try {
              await widget._auth.signInWithEmailAndPassword(
                  email: widget._emailController.text.trim().toLowerCase(),
                  password: widget._passwordController.text.trim());

                   String? fcmToken = await FirebaseMessaging.instance.getToken();
                  await FirebaseFirestore.instance
                      .collection('Students')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .update({'fcmToken': fcmToken});

              Navigator.pushNamedAndRemoveUntil(
                  context, HomeScreensBuilder.routeName, (route) => false);
            } catch (e) {
              // Handle specific exceptions
              if (e is FirebaseAuthException) {
                if (e.code == 'user-not-found') {
                  widget._onError('User not found');
                } else if (e.code == 'wrong-password') {
                  widget._onError('Wrong password');
                } else {
                  widget._onError('Error: ${e.message}');
                }
              } else {
                widget._onError('Error: $e');
              }
            } finally {
              setState(() {
                _isLoading = false;
              });
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
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
                        "LOG IN",
                        style: TextStyle(
                            color: Theme.of(context)
                                .copyWith()
                                .scaffoldBackgroundColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      )),
          ),
        ),
      ),
      if (_isLoading)
        const Positioned.fill(
            child: Center(
          child: CircularProgressIndicator(),
        ))
    ]);
  }
}
