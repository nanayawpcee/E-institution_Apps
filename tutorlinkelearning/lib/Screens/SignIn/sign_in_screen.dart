import 'package:firebase_auth/firebase_auth.dart';
import 'package:tutorlinkelearning/Backend/signinauth.dart';
import 'package:tutorlinkelearning/components/textform.dart';
import 'package:tutorlinkelearning/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../SignUp/signupscreen.dart';

class SignInScreen extends StatefulWidget {
  static String routeName = 'SignInScreen';
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _signinformkey = GlobalKey<FormState>();
  final _passwordResetFormKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _emailController =
      TextEditingController(text: '');
  final TextEditingController _passwordController =
      TextEditingController(text: '');

  late bool _passwordVisible;
  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //This is to say the user  taps anywhere on the
      //screen, the keyboard should hide
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _signinformkey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 60,
                    ),
                    // The header of the sign In page
                    // this comes first in this scaffold
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Welcome back",
                          style: TextStyle(
                            color: kBlueColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text(
                      "Login to continue",
                      style: TextStyle(
                          color: kBlueColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Textform(
                      boxname: "Email Address",
                      controller: _emailController,
                      preIcon: Icon(Icons.email_outlined),
                      keyboardtype: TextInputType.emailAddress,
                      validator: (value) {
                        if (value!.isEmpty ||
                            !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$')
                                .hasMatch(value!)) {
                          return 'Please enter a valid Email';
                        }
                        return null;
                      },
                    ),
                    PasswordForm(
                        boxname: "Enter Password",
                        controller: _passwordController,
                        preIcon: const Icon(Icons.lock_sharp),
                        keyboardtype: TextInputType.visiblePassword,
                        visiblePassword: _passwordVisible,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your password';
                          } else if (!RegExp(
                                  r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*;~%]).{8,}$') //validation key
                              .hasMatch(value!)) {
                            return 'Password should contain at least:\n'
                                '- 1 uppercase letter,\n'
                                '- 1 lowercase letter,\n'
                                '- 1 special character,\n'
                                '- Minimum length of 8 characters';
                          }
                          return null;
                        }),
                    const SizedBox(
                      height: 16,
                    ),
                    //This widget contains a pop-up dialog to enable the user to reset password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(14))),
                                    child: SizedBox(
                                        height: 400,
                                        //width: 600,

                                        child: Form(
                                          key: _passwordResetFormKey,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    //this is to go back the dialog box or cancel
                                                    //password reset
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: SvgPicture.asset(
                                                        'assets/icons/close.svg',
                                                        height: 40,
                                                        width: 40,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const Text(
                                                  "Forgot your Password?",
                                                  style: TextStyle(
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.all(4.0),
                                                  child: Text(
                                                    "Enter your email address and we will share a link to create a new password.",
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                Textform(
                                                  boxname: '',
                                                  preIcon: Icon(
                                                      Icons.email_outlined),
                                                  keyboardtype: TextInputType
                                                      .emailAddress,
                                                  controller: _emailController,
                                                  validator: (value) {
                                                    if (value!.isEmpty ||
                                                        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$')
                                                            .hasMatch(value!)) {
                                                      return 'Please enter a valid Email';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                                InkWell(
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      if (_passwordResetFormKey
                                                          .currentState!
                                                          .validate()) {
                                                        try {
                                                          await _auth
                                                              .sendPasswordResetEmail(
                                                                  email:
                                                                      _emailController
                                                                          .text);
                                                          Navigator.pop(
                                                              context); // Close the dialog
                                                          _showSuccessDialog(
                                                              context,
                                                              'Password reset email sent.');
                                                        } catch (e) {
                                                          _showErrorDialog(
                                                              context,
                                                              e.toString());
                                                        }
                                                      }
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        height: 60,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          color: kBlueColor,
                                                        ),
                                                        child: Center(
                                                            child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            SvgPicture.asset(
                                                                'assets/icons/send.svg'),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            Text(
                                                              "Send",
                                                              style: TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .copyWith()
                                                                      .scaffoldBackgroundColor,
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ],
                                                        )),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )),
                                  );
                                });
                          },
                          child: const Text(
                            "Forgot Password? ",
                            style: TextStyle(
                                color: kBlueColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    InkWell(
                      child: signinauth(
                          onError: (error) {
                            _showErrorDialog(context, error);
                          },
                          signinformkey: _signinformkey,
                          auth: _auth,
                          emailController: _emailController,
                          passwordController: _passwordController),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    //beneath the log in bottom
                    // this widget contains the signup option and route
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignUpScreen()),
                            );
                          },
                          child: const Text(
                            "Sign up now",
                            style: TextStyle(
                                color: kBlueColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//show a dialog with the message that email is verified
void _showSuccessDialog(context, String message) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

// This fuction is to show a dialog box containing error
//when connecting with the backend

void _showErrorDialog(context, String errorMessage) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Error'),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
