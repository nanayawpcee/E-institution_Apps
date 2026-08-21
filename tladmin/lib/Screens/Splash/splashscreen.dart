import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/local_auth_service.dart';
import '../../theme/app_assets.dart';
import '../../theme/app_text.dart';
import '../../theme/app_tokens.dart';
import '../HomeScreen/home.dart';
import '../SignIn/signinscreen.dart';

/// Brand-gradient splash. Routes straight into the console when a session was
/// restored, otherwise to sign-in.
class SplashScreen extends ConsumerStatefulWidget {
  static String routeName = 'SplashScreen';

  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      final signedIn = ref.read(authProvider) != null;
      Navigator.pushNamedAndRemoveUntil(
        context,
        signedIn ? AdminPage.routeName : SignInScreen.routeName,
        (route) => false,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: TLTokens.brandGradient),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 26, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Image.asset(
                  TLAssets.logo,
                  width: 190,
                  fit: BoxFit.contain,
                  semanticLabel: 'TutorLink',
                ),
              ),
              const SizedBox(height: 26),
              Text(
                'Administration',
                style: TLText.brand(Colors.white).copyWith(fontSize: 24),
              ),
              const SizedBox(height: 10),
              Text(
                'The best e-learning platform on campus',
                style: TLText.body(Colors.white.withValues(alpha: 0.8)),
              ),
              const SizedBox(height: 34),
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
