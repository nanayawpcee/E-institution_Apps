import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/local_auth_service.dart';
import '../../theme/app_assets.dart';
import '../../theme/app_text.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_widgets.dart';
import '../HomeScreen/home.dart';
import '../helpscreen.dart';
import '../policyscreen.dart';

/// Split sign-in: a brand-gradient panel on the left, the credential form on
/// the right. The panel drops away below 900px so the form gets the full width.
///
/// Sign-in only — administrators are provisioned out of band, so the console
/// deliberately offers no self-registration path.
class SignInScreen extends ConsumerStatefulWidget {
  static String routeName = 'SignInScreen';

  const SignInScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  static final _emailRe = RegExp(r'^[\w.-]+@([\w-]+\.)+[\w]{2,4}$');

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
    final showBrandPanel = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: t.bg,
      body: Row(
        children: [
          if (showBrandPanel)
            Expanded(flex: 38, child: const _BrandPanel()),
          Expanded(
            flex: 62,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 40),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: _form(t),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _form(TLTokens t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Welcome back', style: TLText.authTitle(t.text)),
        const SizedBox(height: 4),
        Text(
          'Sign in to the admin console',
          style: TLText.body(t.textSub),
        ),
        const SizedBox(height: 22),
        TLField(
          hint: 'Admin email',
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
          suffix: TextButton(
            onPressed: () => setState(() => _showPassword = !_showPassword),
            child: Text(_showPassword ? 'Hide' : 'Show'),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _openForgotPassword,
            child: const Text('Forgot password?'),
          ),
        ),
        const SizedBox(height: 14),
        TLPrimaryButton(
          label: 'Sign in',
          busy: _busy,
          onPressed: _busy ? null : _submit,
        ),
        const SizedBox(height: 26),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _footerLink('Help', HelpScreen.routeName),
            const SizedBox(width: 16),
            _footerLink('Policies', PolicyScreen.routeName),
          ],
        ),
      ],
    );
  }

  Widget _footerLink(String label, String routeName) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, routeName),
      child: Text(
        label,
        style: TLText.sub(context.tl.textSub).copyWith(fontSize: 12.5),
      ),
    );
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final errors = <String, String>{};
    if (!_emailRe.hasMatch(email)) errors['email'] = 'Please enter a valid email';
    if (password.isEmpty) errors['password'] = 'Please enter your password';

    setState(() {
      _errors
        ..clear()
        ..addAll(errors);
    });
    if (errors.isNotEmpty) return;

    setState(() => _busy = true);
    try {
      final user =
          await ref.read(authProvider.notifier).signIn(email, password);

      if (!mounted) return;
      if (user == null) {
        setState(() {
          _errors['password'] =
              'Those credentials did not match an admin account';
        });
        return;
      }
      Navigator.pushNamedAndRemoveUntil(
          context, AdminPage.routeName, (route) => false);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openForgotPassword() async {
    await showDialog<void>(
      context: context,
      builder: (_) => const ForgotPasswordDialog(),
    );
  }
}

/// The gradient half of the sign-in screen.
class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 56),
      decoration: const BoxDecoration(gradient: TLTokens.brandGradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(TLTokens.rLg),
            ),
            child: Image.asset(
              TLAssets.logo,
              width: 170,
              fit: BoxFit.contain,
              semanticLabel: 'TutorLink',
            ),
          ),
          const SizedBox(height: 28),
          Text('Administration', style: TLText.brand(Colors.white)),
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Text(
              'Manage courses, tutors, books and reviews for the TutorLink '
              'learning platform.',
              style: TLText.body(Colors.white.withValues(alpha: 0.78))
                  .copyWith(fontSize: 14.5, height: 1.55),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reset-link dialog raised from "Forgot password?".
class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  static final _emailRe = RegExp(r'^[\w.-]+@([\w-]+\.)+[\w]{2,4}$');

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
    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Reset admin password',
              style: TLText.cardTitle(t.text)
                  .copyWith(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Enter your email to receive a reset link.',
              style: TLText.bodyStrong(t.textSub)
                  .copyWith(fontWeight: FontWeight.w400),
            ),
            if (_sent)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Reset email sent.',
                  style: TLText.bodyStrong(TLTokens.success)
                      .copyWith(fontSize: 14),
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
              Row(
                children: [
                  TLSecondaryButton(
                    label: 'Cancel',
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TLPrimaryButton(
                      label: 'Send link',
                      onPressed: _send,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _send() {
    if (!_emailRe.hasMatch(_controller.text.trim())) {
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
