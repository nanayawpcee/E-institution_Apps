import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../Components/onboardContent.dart';
import '../../theme/app_text.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_widgets.dart';
import '../SignIn/sign_in_screen.dart';

/// Three-slide introduction: illustration, progress dots, copy, and a single
/// advancing action that ends at sign-up.
class OnboardScreen extends StatefulWidget {
  static String routeName = 'OnboardScreen';

  const OnboardScreen({Key? key}) : super(key: key);

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  final _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == onboard_data.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_isLast) {
      // Tutors are onboarded by an administrator, so the tour ends at sign-in.
      Navigator.pushNamedAndRemoveUntil(
          context, SignInScreen.routeName, (route) => false);
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  void _skip() => Navigator.pushNamedAndRemoveUntil(
      context, SignInScreen.routeName, (route) => false);

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 24,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _isLast
                      ? null
                      : InkWell(
                          onTap: _skip,
                          child: Text(
                            'Skip',
                            style: TLText.cardTitle(TLTokens.primary)
                                .copyWith(letterSpacing: 0.3),
                          ),
                        ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: onboard_data.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) => Onboard(content: onboard_data[i]),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < onboard_data.length; i++)
                    DotIndicator(isActive: i == _index),
                ],
              ),
              const SizedBox(height: 20),
              TLButton(
                label: _isLast ? 'Get Started' : 'Next',
                onPressed: _next,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One onboarding slide: illustration tile, then title and description.
class Onboard extends StatelessWidget {
  const Onboard({Key? key, required this.content}) : super(key: key);

  final OnboardContent content;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 220,
          height: 220,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: t.cardAlt,
            borderRadius: BorderRadius.circular(28),
          ),
          child: SvgPicture.asset(
            content.image,
            fit: BoxFit.contain,
            semanticsLabel: content.title,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          content.title,
          textAlign: TextAlign.center,
          style: TLText.display(t.text),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            content.description,
            textAlign: TextAlign.center,
            style: TLText.lead(t.textSub),
          ),
        ),
      ],
    );
  }
}

/// Progress dot — the active one stretches into a bar, as in the design.
class DotIndicator extends StatelessWidget {
  const DotIndicator({Key? key, this.isActive = false}) : super(key: key);

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 8,
      width: isActive ? 20 : 8,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: isActive ? TLTokens.primary : t.border,
      ),
    );
  }
}
