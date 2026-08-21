import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Components/home.dart';
import '../../services/local_auth_service.dart';
import '../../theme/app_text.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_widgets.dart';
import '../Profile/models/dialog.dart';

/// Sign in. Tutors are onboarded by an administrator, so there is no sign-up
/// path here — just credentials, a reset sheet and a route to support.
class SignInScreen extends ConsumerStatefulWidget {
  static String routeName = 'SignInScreen';

  const SignInScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  static final emailRe = RegExp(r'^[\w.-]+@([\w-]+\.)+[\w]{2,4}$');

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _showPassword = false;
  bool _busy = false;
  final Map<String, String> _errors = {};

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return Scaffold(
      backgroundColor: t.bg,
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
            children: [
              Text('Welcome back', style: TLText.authTitle(TLTokens.primary)),
              const SizedBox(height: 4),
              Text(
                'Sign in to your tutor account',
                style: TLText.body(t.textSub),
              ),
              const SizedBox(height: 24),
              TLField(
                hint: 'Email address',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                errorText: _errors['email'],
              ),
              const SizedBox(height: 14),
              TLField(
                hint: 'Password',
                controller: _passwordController,
                obscureText: !_showPassword,
                errorText: _errors['password'],
                suffix: TLRevealToggle(
                  revealed: _showPassword,
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => showTLSheet<void>(
                    context: context,
                    builder: (context) => const ForgotPasswordSheet(),
                  ),
                  child: const Text('Forgot password?'),
                ),
              ),
              const SizedBox(height: 8),
              TLButton(
                label: 'Sign in',
                busy: _busy,
                onPressed: _busy ? null : _submit,
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Need an account?', style: TLText.sub(t.textSub)),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () => helpCenterDialog(context),
                    child: Text(
                      'Contact support',
                      style: TLText.link(TLTokens.primary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    final errors = <String, String>{};
    if (!emailRe.hasMatch(email)) errors['email'] = 'Please enter a valid email';
    if (password.isEmpty) errors['password'] = 'Please enter your password';

    setState(() {
      _errors
        ..clear()
        ..addAll(errors);
    });
    if (errors.isNotEmpty) return;

    setState(() => _busy = true);
    try {
      final tutor =
          await ref.read(authProvider.notifier).signIn(email, password);
      if (!mounted) return;
      if (tutor == null) {
        setState(() => _errors['password'] = 'Invalid email or password');
        return;
      }
      Navigator.pushNamedAndRemoveUntil(
          context, HomeScreensBuilder.routeName, (route) => false);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

/// Reset-link sheet raised from "Forgot password?".
class ForgotPasswordSheet extends StatefulWidget {
  const ForgotPasswordSheet({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<ForgotPasswordSheet> {
  final _controller = TextEditingController();
  String? _error;
  bool _sent = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Reset your password', style: TLText.cardTitle(t.text)),
        const SizedBox(height: 6),
        Text(
          'Enter your email to receive a reset link.',
          style: TLText.sub(t.textSub),
        ),
        if (_sent)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              'Reset email sent.',
              style: TLText.link(TLTokens.success),
            ),
          )
        else ...[
          const SizedBox(height: 14),
          TLField(
            hint: 'Email address',
            controller: _controller,
            keyboardType: TextInputType.emailAddress,
            errorText: _error,
          ),
          const SizedBox(height: 16),
          TLButton(label: 'Send link', onPressed: _send),
        ],
      ],
    );
  }

  void _send() {
    if (!_SignInScreenState.emailRe.hasMatch(_controller.text.trim())) {
      setState(() => _error = 'Please enter a valid email');
      return;
    }
    setState(() {
      _error = null;
      _sent = true;
    });
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) Navigator.pop(context);
    });
  }
}
