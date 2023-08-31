import 'package:flutter/material.dart';
import 'package:tladmin/Components/registerbutton.dart';
import '../../../utils/responsive.dart';
import '../signinscreen.dart';
import '../../helpscreen.dart';
import '../../policyscreen.dart';
import 'menuitem.dart';

class Menu extends StatelessWidget {
  final bool isSignUp;
  final Function(bool) onToggleSignUp;

  Menu({required this.isSignUp, required this.onToggleSignUp});


// Use this for app responsiveness
  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: buildMobileLayout(context),
      tablet: buildTabletLayout(context),
      desktop: buildDesktopLayout(context),
    );
  }
//for desktop layout in case user maximize size of the window
  Widget buildDesktopLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              menuItem(
                title: 'Home',
                onTap: () {
                  // Navigate to the Body column
                  Navigator.pushNamed(context, SignInScreen.routeName);
                },
              ),
              menuItem(
                title: 'Policies',
                onTap: () {
                  // Navigate to PolicyScreen
                  Navigator.pushNamed(context, PolicyScreen.routeName);
                },
              ),
              menuItem(
                title: 'Help',
                onTap: () {
                  // Navigate to HelpScreen
                  Navigator.pushNamed(context, HelpScreen.routeName);
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 60,
              ),
              menuItem(
                title: 'Sign In',
                isActive: !isSignUp,
                onTap: () {
                  onToggleSignUp(!isSignUp);
                },
              ),
              if (!isSignUp)
                registerButton(
                  onTap: () {
                    onToggleSignUp(true);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
//for tablet layout in case user reduce size of the window
  Widget buildTabletLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              menuItem(
                title: 'Policies',
                onTap: () {
                  // Navigate to PolicyScreen
                  Navigator.pushNamed(context, PolicyScreen.routeName);
                },
              ),
              menuItem(
                title: 'Help',
                onTap: () {
                  // Navigate to HelpScreen
                  Navigator.pushNamed(context, HelpScreen.routeName);
                },
              ),
            ],
          ),
          Row(
            children: [
              menuItem(
                title: 'Sign In',
                isActive: !isSignUp,
                onTap: () {
                  onToggleSignUp(!isSignUp);
                },
              ),
              if (!isSignUp)
                registerButton(
                  onTap: () {
                    onToggleSignUp(true);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
//for mobile layout in case user reduce size of the window
  Widget buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  menuItem(
                    title: 'Home',
                    onTap: () {
                      // Navigate to the Body column
                      Navigator.pushNamed(context, SignInScreen.routeName);
                    },
                  ),
                  menuItem(
                    title: 'Policies',
                    onTap: () {
                      // Navigate to PolicyScreen
                      Navigator.pushNamed(context, PolicyScreen.routeName);
                    },
                  ),
                  menuItem(
                    title: 'Help',
                    onTap: () {
                      // Navigate to HelpScreen
                      Navigator.pushNamed(context, HelpScreen.routeName);
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  menuItem(
                    title: 'Sign In',
                    isActive: !isSignUp,
                    onTap: () {
                      onToggleSignUp(!isSignUp);
                    },
                  ),
                  if (!isSignUp)
                    registerButton(
                      onTap: () {
                        onToggleSignUp(true);
                      },
                    ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}
