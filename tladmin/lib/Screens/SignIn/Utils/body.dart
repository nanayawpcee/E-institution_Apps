import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../../utils/responsive.dart';

import '../../SignUp/signupscreen.dart';
import 'signinform.dart';

class Body extends StatefulWidget {
  final bool isSignUp;
  final bool isLoading;
  final Function(bool) setLoading;// loading function

  Body(
      {required this.isSignUp,
      required this.isLoading,
      required this.setLoading});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  bool _obscureText = true;

//password visibility call method
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
// text input controllers to hold user inputs
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: buildMobileLayout(context),
      tablet: buildTabletLayout(context),
      desktop: buildDesktopLayout(context),
    );
  }

  Widget buildDesktopLayout(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          width: 360,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isSignUp
                    ? 'Sign Up to\nTutorLink Admin'
                    : 'Sign In to\nTutorLink Admin',
                style:
                    const TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                widget.isSignUp
                    ? "If you have an account already,"
                    : "If you don't have an account",
                style: const TextStyle(
                  color: kBlackColor800,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const Text(
                    'You can',
                    style: TextStyle(
                      color: kBlackColor800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Text(
                    widget.isSignUp ? 'click on signin' : 'Register ',
                    style: const TextStyle(
                      color: kBlueColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Image.asset(
                'assets/images/Logop.png',
                width: 320,
              ),
            ],
          ),
        ),
        Image.asset(
          'assets/images/starter.png',
          width: MediaQuery.of(context).size.width / 5.5,
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height / 6,
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 4,
            child: widget.isSignUp
                ? SignUpForm(
                    emailController: _emailController,
                    passwordController: _passwordController,
                    confirmpasswordController: _confirmpasswordController,
                    onSignInClicked: () {
                      formLogin(
                        context,
                        widget.setLoading,
                        widget.isLoading,
                        _obscureText,
                        _togglePasswordVisibility,
                        _emailController,
                        _passwordController,
                      );
                    },
                    isLoading: widget.isLoading,
                    setLoading: widget.setLoading,
                  )
                : formLogin(
                    context,
                    widget.setLoading,
                    widget.isLoading,
                    _obscureText,
                    _togglePasswordVisibility,
                    _emailController,
                    _passwordController,
                  ),
          ),
        ),
      ],
    );
  }
//when window size is reduced to Tablet size
  Widget buildTabletLayout(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 360,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isSignUp
                    ? 'Sign Up to\nTutorLink Admin'
                    : 'Sign In to\nTutorLink Admin',
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                widget.isSignUp
                    ? "If you have an account already,"
                    : "If you don't have an account",
                style: const TextStyle(
                  color: kBlackColor800,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const Text(
                    'You can',
                    style: TextStyle(
                      color: kBlackColor800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Text(
                    widget.isSignUp ? 'sign in here' : 'Register here',
                    style: const TextStyle(
                      color: kBlueColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Image.asset(
                'assets/images/Logop.png',
                width: 200,
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height / 6,
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 4.8,
            child: widget.isSignUp
                ? SignUpForm(
                    emailController: _emailController,
                    passwordController: _passwordController,
                    confirmpasswordController: _confirmpasswordController,
                    onSignInClicked: () {
                      formLogin(
                        context,
                        widget.setLoading,
                        widget.isLoading,
                        _obscureText,
                        _togglePasswordVisibility,//// to enable user to view password, ie set obscure text to false
                        _emailController,
                        _passwordController,
                      );
                    },
                    isLoading: widget.isLoading,
                    setLoading: widget.setLoading,
                  )
                : formLogin(
                    context,
                    widget.setLoading,
                    widget.isLoading,
                    _obscureText,
                    _togglePasswordVisibility,
                    _emailController,
                    _passwordController,
                  ),
          ),
        ),
      ],
    );
  }

//when user shrinks or reduces window size 
  Widget buildMobileLayout(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          width: 360,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.isSignUp
                    ? 'Sign Up to\nTutorLink Admin'
                    : 'Sign In to\nTutorLink Admin',
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                widget.isSignUp
                    ? "If you have an account already,"
                    : "If you don't have an account",
                style: const TextStyle(
                  color: kBlackColor800,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'You can',
                    style: TextStyle(
                      color: kBlackColor800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Text(
                    widget.isSignUp ? 'sign in here' : 'Register here',

                  style: const TextStyle(
                    color: kBlueColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Image.asset(
              'assets/images/Logop.png',
              width: 150,
            ),
          ],
        ),
      ),
      Padding(
        padding: EdgeInsets.symmetric(
          vertical: 30,
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 1.5,
          child: widget.isSignUp
              ? SignUpForm(
                  emailController: _emailController,
                  passwordController: _passwordController,
                  confirmpasswordController: _confirmpasswordController,
                  onSignInClicked: () {
                    formLogin(
                      context,
                      widget.setLoading,
                      widget.isLoading,
                      _obscureText,
                      _togglePasswordVisibility,// to enable user to view password, ie set obscure text to false
                      _emailController,
                      _passwordController
                    );
                  },
                  isLoading: widget.isLoading,
                  setLoading: widget.setLoading,
                )
              : formLogin(
                  context,
                  widget.setLoading,
                  widget.isLoading,
                  _obscureText,
                  _togglePasswordVisibility,// to enable user to view password, ie set obscure text to false
                  _emailController,
                  _passwordController
                ),
        ),
      ),
    ]);
  }
}
