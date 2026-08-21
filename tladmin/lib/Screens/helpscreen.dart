import 'package:flutter/material.dart';

import '../theme/app_text.dart';
import '../theme/app_tokens.dart';
import '../theme/app_widgets.dart';

class _Faq {
  const _Faq(this.question, this.answer);
  final String question;
  final String answer;
}

/// Standalone route, used by the "Help" link on the sign-in screen. Inside the
/// console the shell renders [HelpBody] directly.
class HelpScreen extends StatelessWidget {
  static String routeName = 'HelpScreen';

  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help Center')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(28, 26, 28, 40),
        child: HelpBody(),
      ),
    );
  }
}

class HelpBody extends StatefulWidget {
  const HelpBody({Key? key}) : super(key: key);

  @override
  State<HelpBody> createState() => _HelpBodyState();
}

class _HelpBodyState extends State<HelpBody> {
  static const List<_Faq> _faqs = [
    _Faq(
      'How do I add a new course?',
      'Go to Courses > Add Course, fill in the name, department, duration and '
          'info, upload an icon, then click Add Course.',
    ),
    _Faq(
      'How do I onboard a tutor?',
      'Go to Tutors > Add Tutor. The tutor must be assigned to an existing '
          'course, which you pick from the Assign course dropdown.',
    ),
    _Faq(
      'Can I export data for reporting?',
      'Yes — every table (courses, tutors, reviews, books) has an Export CSV '
          'button, and you can export just a selection using the checkboxes.',
    ),
    _Faq(
      'What happens to session requests?',
      'Requests raised by students appear under Requests. Mark them resolved '
          'once the session has taken place.',
    ),
  ];

  final Set<String> _open = {};

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TLPageHeader(
          title: 'Help Center',
          subtitle: 'Answers for common admin tasks',
        ),
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final faq in _faqs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TLPanel(
                    padding: const EdgeInsets.all(14),
                    radius: 14,
                    onTap: () => setState(() {
                      if (!_open.remove(faq.question)) _open.add(faq.question);
                    }),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                faq.question,
                                style: TLText.cardTitle(t.text),
                              ),
                            ),
                            Text(
                              _open.contains(faq.question) ? '−' : '+',
                              style: TLText.sub(t.textSub).copyWith(fontSize: 16),
                            ),
                          ],
                        ),
                        if (_open.contains(faq.question)) ...[
                          const SizedBox(height: 8),
                          Text(
                            faq.answer,
                            style: TLText.bodyStrong(t.textSub).copyWith(
                              fontWeight: FontWeight.w400,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: t.cardAlt,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Still need help?', style: TLText.cardTitle(t.text)),
                    const SizedBox(height: 4),
                    Text(
                      'Contact platform support at support@tutorlink.app '
                      'or +233 50 493 0005',
                      style: TLText.sub(t.textSub),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
