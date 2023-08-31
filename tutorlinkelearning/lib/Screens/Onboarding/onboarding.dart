import 'package:tutorlinkelearning/Screens/SignUp/signupscreen.dart';
import 'package:tutorlinkelearning/components/onboardContent.dart';
import 'package:tutorlinkelearning/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../SignIn/sign_in_screen.dart';

class OnboardScreen extends StatefulWidget {
static String routeName = 'OnboardScreen';
  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  late PageController _pageController;

  int _pageIndex = 0;

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToSignUpPage() {
    if (_pageIndex < onboard_data.length - 1) {
      // Navigate to the next page
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      Navigator.pushNamedAndRemoveUntil(
          context, SignUpScreen.routeName, (route) => false);
      //
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _pageIndex < onboard_data.length -1 
                  ? GestureDetector(
                      onTap: () {
                           Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignInScreen()),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Skip",
                            style: TextStyle(
                              color: kBlueColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _pageIndex = index;
                    });
                  },
                  itemCount: onboard_data.length,
                  itemBuilder: (context, index) => Onboard(
                    image: onboard_data[index].image,
                    title: onboard_data[index].title,
                    description: onboard_data[index].description,
                    pageIndex: _pageIndex,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 50,
                    width: 140,
                    child: ElevatedButton(
                      onPressed: _navigateToSignUpPage,
                      child: Text(
                        _pageIndex < onboard_data.length - 1
                            ? "Next"
                            : "Get Started",
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              )
            ],
          )),
    ));
  }
}

class Onboard extends StatelessWidget {
  const Onboard({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    required this.pageIndex,
  });

  final String image, title, description;
  final int pageIndex;

  @override
  Widget build(BuildContext context) {
    final int pageCount = onboard_data.length;
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(12.0),
        ),
        const Spacer(),
        SvgPicture.asset(
          image,
          height: 300,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(pageCount, (index) {
            final isActive = index == pageIndex;
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: DotIndicator(isActive: isActive),
            );
          }),
        ),
        const Spacer(),
        Text(
          title,
          style: const TextStyle(
              color: kBlueColor, fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          description,
          style: Theme.of(context).copyWith().textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const Spacer()
      ],
    );
  }
}
