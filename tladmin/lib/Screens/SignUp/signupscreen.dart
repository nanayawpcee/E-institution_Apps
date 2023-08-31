import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tladmin/Screens/HomeScreen/home.dart';
import '../../Api/signupauth.dart';
import '../../constants.dart';

class SignUpForm extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmpasswordController;
  final VoidCallback onSignInClicked;
  final bool isLoading; // Add this line
  final Function(bool) setLoading;

  SignUpForm(
      {required this.emailController,
      required this.passwordController,
      required this.confirmpasswordController,
      required this.onSignInClicked,
      required this.isLoading,
      required this.setLoading});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formkey = GlobalKey<FormState>();
  late bool _passwordVisible;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

/*this is for email validation
this includes the 8 minimum characters and at least one uppercase
and one lower case at least and a special character for the password and 
For email, must inclued @
*/

  String? _emailValidator(String? value) {
    if (value!.isEmpty) {
      return 'Please enter your email';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value!.isEmpty) {
      return 'Please enter your password';
    } else if (!RegExp(
            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
        .hasMatch(value)) {
      return 'Please password should contain at least 1 uppercase, 1 lowercase, and 1 special character';
    }
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if (value!.isEmpty) {
      return 'Please confirm your password';
    } else if (value != widget.passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

//method to register the admin
  void _registerUser() async {
    if (_formkey.currentState!.validate()) {
      widget.setLoading(
          true); // Set loading to true before calling signUp function

      String email = widget.emailController.text;
      String password = widget.passwordController.text;

      User? user = await signUpWithEmailAndPassword(email, password);
      if (user != null) {
        print('User registration successful');
        Navigator.pushNamedAndRemoveUntil(
            context, AdminPage.routeName, (route) => false);
      }

      widget
          .setLoading(false); // Set loading to false when registration is done
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formkey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            "Create An Account",
            style: TextStyle(
                color: kBlueColor, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 40,
          ),
          TextFormField(
            controller: widget.emailController,
            decoration: InputDecoration(
              labelText: "Email Address",
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            validator: _emailValidator,
          ),
          const SizedBox(
            height: 20,
          ),
          TextFormField(
            controller: widget.passwordController,
            decoration: InputDecoration(
              labelText: "Password",
              prefixIcon: const Icon(Icons.lock_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            obscureText: !_passwordVisible,
            validator: _passwordValidator,
          ),
          const SizedBox(
            height: 20,
          ),
          TextFormField(
            controller: widget.confirmpasswordController,
            decoration: InputDecoration(
              labelText: "Confirm Password",
              prefixIcon: const Icon(Icons.lock_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            obscureText: !_passwordVisible,
            validator: _confirmPasswordValidator,
          ),
          const SizedBox(
            height: 30,
          ),
          Container(
            decoration: BoxDecoration(
              color: kWhiteColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                  color: kPrimaryLightColor,
                  spreadRadius: 10,
                  blurRadius: 20,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: widget.isLoading
                  ? null // Disable the button when loading
                  : _registerUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: kBlueColor,
                foregroundColor: kWhiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: widget.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: kWhiteColor,
                        ),
                      )
                    : const Center(child: Text('Sign Up')),
              ),
            ),
          ),
          const SizedBox(
            height: 14,
          ),
        ],
      ),
    );
  }
}
