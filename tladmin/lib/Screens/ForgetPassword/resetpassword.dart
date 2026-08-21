import 'package:flutter/material.dart';

import '../SignIn/signinscreen.dart';

/// Standalone reset route. The console itself raises
/// [ForgotPasswordDialog] inline from the sign-in screen; this route keeps a
/// deep link to the same flow working.
class ResetPasswordScreen extends StatelessWidget {
  static String routeName = 'ResetPasswordScreen';

  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: ForgotPasswordDialog(),
        ),
      ),
    );
  }
}
