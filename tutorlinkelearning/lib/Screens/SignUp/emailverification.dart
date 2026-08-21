import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../components/home.dart';
import '../../services/local_auth_service.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  Timer? _timer;
  bool canResendEmail = false;

  // There is no mail backend locally, so the account counts as verified
  // straight away and the screen just confirms before moving on.
  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), navigateToHomeScreen);
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted) setState(() => canResendEmail = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

//this method is to navigate to the HomeScreen while removing
//the previous widget within the stack
  void navigateToHomeScreen() {
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
        context, HomeScreensBuilder.routeName, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'A verification email has been sent to your email',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: canResendEmail
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Check email for verification')),
                      );
                    }
                  : null,
              icon: const Icon(Icons.email, size: 32),
              label: const Text(
                'Resend Email',
                style: TextStyle(fontSize: 24),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(fontSize: 24),
              ),
              onPressed: () async {
                _timer?.cancel();
                await ref.read(authProvider.notifier).signOut();
                if (!context.mounted) return;
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
