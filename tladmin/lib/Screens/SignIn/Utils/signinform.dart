import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../Api/signinauth.dart';
import '../../../constants.dart';
import '../../HomeScreen/home.dart';

//login form for the on initial load of the homescreen before signin into to the admin dashboard
Widget formLogin(
  BuildContext context,
  Function(bool) setLoading,
  bool isLoading,
  bool obscureText,
  VoidCallback togglePasswordVisibility,
  TextEditingController emailController,
  TextEditingController passwordController,
) {
  Future<void> _signInWithEmailAndPassword() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    setLoading(true);

    User? user = await signInWithEmailAndPassword(email, password);
    if (user != null) {
      print('User signed in successfully');
      Navigator.pushNamedAndRemoveUntil(
          context, AdminPage.routeName, (route) => false);
    } else {
      // Show a snackbar with the error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to sign in')),
      );
    }

    setLoading(false);
  }

  return Column(
    children: [
      //textfield for the admin to enter email
      TextField(
        controller: emailController,
        decoration: InputDecoration(
          hintText: "Enter your email here",
          fillColor: kGreyColor500,
          filled: true,
          labelStyle: const TextStyle(fontSize: 12),
          contentPadding: const EdgeInsets.only(left: 30),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: kBlueColor),
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: kBlueColor),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
      const SizedBox(
        height: 30,
      ),

      //password textfield
      TextField(
        controller: passwordController,
        decoration: InputDecoration(
          hintText: "Password",
          counterText: 'Forget password?',
          suffixIcon: IconButton(
            icon: Icon(
              obscureText
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: kGreyColor800,
            ),
            onPressed: togglePasswordVisibility,
          ),
          fillColor: kGreyColor500,
          filled: true,
          labelStyle: const TextStyle(fontSize: 12),
          contentPadding: const EdgeInsets.only(left: 30),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: kBlueColor),
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: kBlueColor),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        obscureText: obscureText,
      ),
      const SizedBox(
        height: 40,
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
        //Button for the signin of the user
        child: ElevatedButton(
          onPressed: isLoading ? null : _signInWithEmailAndPassword,
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
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: kWhiteColor,
                    ),
                  )
                : const Center(child: Text('Sign In')),
          ),
        ),
      ),
    ],
  );
}
