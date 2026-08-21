import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Components/home.dart';
import '../../services/local_auth_service.dart';
import '../../theme/app_assets.dart';
import '../../theme/app_text.dart';
import '../../theme/app_tokens.dart';
import '../Onboarding/onboarding.dart';

/// Brand splash. Goes straight to the app when a session was restored,
/// otherwise into onboarding.
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
        signedIn ? HomeScreensBuilder.routeName : OnboardScreen.routeName,
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
    final t = context.tl;
    return Scaffold(
      backgroundColor: t.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              TLAssets.logo,
              width: 220,
              fit: BoxFit.contain,
              semanticLabel: 'TutorLink',
            ),
            const SizedBox(height: 18),
            Text('For Tutors', style: TLText.lead(t.textSub)),
            const SizedBox(height: 34),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: TLTokens.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
