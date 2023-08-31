import 'package:tutorlinkelearning/Backend/signupauth.dart';
import 'package:tutorlinkelearning/constants.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../components/textform.dart';
import '../SignIn/sign_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  static String routeName = 'SignUpScreen';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formkey = GlobalKey<FormState>();


  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  late bool _passwordVisible;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //This is when the user is to tap anywhere on the
      //screen, the keyboard should hide
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
              child: Form(
            key: _formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 54,
                ),
                const Text(
                  "Create An Account",
                  style: TextStyle(
                      color: kBlueColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                //The textform below is for the name  and email input
                const SizedBox(
                  height: 12,
                ),
                Textform(
                  boxname: "Name",
                  preIcon: Icon(null),
                  controller: _nameController,
                  keyboardtype: TextInputType.name,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your name';
                    } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                      return 'Please enter a valid name';
                    }
                  
                    return null;
                  },
                ),
                Textform(
                  boxname: "Email Address",
                  controller: _emailController,
                  preIcon: Icon(Icons.email_outlined),
                  keyboardtype: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email';
                    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                // The following textform field are for password and it's confirmation
                const SizedBox(
                  height: 12,
                ),
                PasswordForm(
                    boxname: "Enter Password",
                    controller: _passwordController,
                    preIcon: Icon(Icons.lock_outline),
                    keyboardtype: TextInputType.visiblePassword,
                    visiblePassword: _passwordVisible,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your password';
                      } else if (!RegExp(
                              r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
                          .hasMatch(value)) {
                        return 'Password should contain at least:\n'
                          '- 1 uppercase letter,\n'
                          '- 1 lowercase letter,\n'
                          '- 1 special character,\n'
                          '- Minimum length of 8 characters';}
                      return null;
                    }),
                PasswordForm(
                  boxname: "Confirm Password",
                  controller: _confirmPasswordController,
                  preIcon: Icon(Icons.lock_outline),
                  keyboardtype: TextInputType.visiblePassword,
                  visiblePassword: _passwordVisible,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your password';
                    } else if (!RegExp(
                            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
                        .hasMatch(value)) {
                      return 'Password should contain at least:\n'
                          '- 1 uppercase letter,\n'
                          '- 1 lowercase letter,\n'
                          '- 1 special character,\n'
                          '- Minimum length of 8 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(),
                //this authentication is triggered when the signup buttton is clicked
                //this adds User details into the backed storage
                InkWell(
                    child: signupauth(
                        formkey: _formkey,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        //auth: _auth,
                        nameController: _nameController)),
                const SizedBox(
                  height: 14,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text(
                    "Have an account already?",
                    style: TextStyle(
                        color: kBlackColor800,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  //this here is to allow old users to sign-in into their accounts
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignInScreen()),
                      );
                    },
                    child: const Text(
                      "Sign In",
                      style: TextStyle(
                          color: kBlueColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                  )
                ]),
              ],
            ),
          )),
        ),
      ),
    );
  }
}
