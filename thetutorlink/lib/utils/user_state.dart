import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Components/home.dart';
import '../Screens/Splash_Screen/splash.dart';
import '../services/local_auth_service.dart';

/// Keeps the tutor signed in across app restarts — the local stand-in for
/// watching Firebase's authStateChanges().
class UserState extends ConsumerWidget {
  const UserState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tutor = ref.watch(authProvider);
    return tutor == null ? const SplashScreen() : const HomeScreensBuilder();
  }
}
