import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../components/home.dart';
import '../../services/local_auth_service.dart';
import '../../theme/app_text.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_widgets.dart';
import '../SignIn/sign_in_screen.dart';

/// Create an account. Password rules and messages come straight from the
/// design's signup validation.
class SignUpScreen extends ConsumerStatefulWidget {
  static String routeName = 'SignUpScreen';

  const SignUpScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  static final _emailRe = RegExp(r'^[\w.-]+@([\w-]+\.)+[\w]{2,4}$');
  static final _passwordRe =
      RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#$&*~;%]).{8,}$');
  static const _passwordHint =
      'Password should contain at least: 1 uppercase, 1 lowercase, 1 number, '
      '1 special character, 8+ characters.';

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _showPassword = false;
  bool _busy = false;
  final Map<String, String> _errors = {};

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
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
              Text('Create an account', style: TLText.authTitle(t.text)),
              const SizedBox(height: 4),
              Text(
                'Start learning with TutorLink',
                style: TLText.body(t.textSub),
              ),
              const SizedBox(height: 24),
              TLField(
                hint: 'Full name',
                controller: _nameController,
                keyboardType: TextInputType.name,
                errorText: _errors['name'],
              ),
              const SizedBox(height: 14),
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
              const SizedBox(height: 14),
              TLField(
                hint: 'Confirm password',
                controller: _confirmController,
                obscureText: !_showPassword,
                errorText: _errors['confirm'],
              ),
              const SizedBox(height: 20),
              TLButton(
                label: 'Sign up',
                busy: _busy,
                onPressed: _busy ? null : _submit,
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Have an account?', style: TLText.sub(t.textSub)),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () => Navigator.pushReplacementNamed(
                        context, SignInScreen.routeName),
                    child: Text('Sign in', style: TLText.link(TLTokens.primary)),
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
    final name = _nameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    final errors = <String, String>{};
    if (name.isEmpty) errors['name'] = 'Please enter your name';
    if (!_emailRe.hasMatch(email)) errors['email'] = 'Please enter a valid email';
    if (!_passwordRe.hasMatch(password)) {
      errors['password'] = _passwordHint;
    } else if (_confirmController.text.trim() != password) {
      errors['confirm'] = 'Passwords do not match';
    }

    setState(() {
      _errors
        ..clear()
        ..addAll(errors);
    });
    if (errors.isNotEmpty) return;

    setState(() => _busy = true);
    try {
      final student = await ref
          .read(authProvider.notifier)
          .signUp(name, email, password);
      if (!mounted) return;
      if (student == null) {
        setState(() =>
            _errors['email'] = 'An account with that email already exists');
        return;
      }
      Navigator.pushNamedAndRemoveUntil(
          context, HomeScreensBuilder.routeName, (route) => false);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
