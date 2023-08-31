import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:thetutorlink/Components/home.dart';
import 'package:thetutorlink/constants.dart';

class signinauth extends StatefulWidget {
  const signinauth({
    Key? key,
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
  bool _isLoading = false;

  Future<bool> _checkTutorExistsInTutorsCollection(String tutorId) async {
    try {
      DocumentSnapshot tutorSnapshot = await FirebaseFirestore.instance
          .collection('Tutors')
          .doc(tutorId)
          .get();

      return tutorSnapshot.exists;
    } catch (e) {
      _showErrorDialog('Check internet connection and try later');
      return false;
    }
  }

  Future<bool> _isDeviceOnline() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

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

  void _showOfflineSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('You are offline. Please check your internet connection.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () async {
            if (widget._signinformkey.currentState!.validate()) {
              setState(() {
                _isLoading = true;
              });

              final String email =
                  widget._emailController.text.trim().toLowerCase();

              try {
                bool isOnline = await _isDeviceOnline();

                if (!isOnline) {
                  _showOfflineSnackbar();
                  setState(() {
                    _isLoading = false;
                  });
                  return;
                }

                await widget._auth.signInWithEmailAndPassword(
                  email: email,
                  password: widget._passwordController.text.trim(),
                );

                String tutorId = widget._auth.currentUser!.uid;

                bool tutorExistsInTutors =
                    await _checkTutorExistsInTutorsCollection(tutorId);

                await Future.delayed(Duration(milliseconds: 5000));

                if (tutorExistsInTutors) {
                  String? fcmToken =
                      await FirebaseMessaging.instance.getToken();
                  await FirebaseFirestore.instance
                      .collection('Tutors')
                      .doc(tutorId)
                      .update({'fcmToken': fcmToken});

                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    HomeScreenBuilder.routeName,
                    (route) => false,
                  );
                } else {
                  _showErrorDialog(
                      'You are not a tutor yet please contact us if you want to be tutor');
                }
              } catch (e) {
                if (e is FirebaseAuthException) {
                  if (e.code == 'user-not-found' ||
                      e.code == 'wrong-password') {
                    widget._onError('Invalid email or password');
                  } else {
                    widget._onError('Error: ${e.message}');
                  }
                } else {
                  _showErrorDialog('Error: $e');
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
                          color: Theme.of(context).scaffoldBackgroundColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ),
        if (_isLoading)
          Positioned.fill(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
