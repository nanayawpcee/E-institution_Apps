import 'package:flutter/material.dart';

import '../theme/app_text.dart';
import '../theme/app_tokens.dart';

class _PolicySection {
  const _PolicySection(this.heading, this.body);
  final String heading;
  final String body;
}

/// Standalone route, used by the "Policies" link on the sign-in screen. Inside
/// the console the shell renders [PolicyBody] directly.
class PolicyScreen extends StatelessWidget {
  static String routeName = 'PolicyScreen';

  const PolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TutorLink Administrator Policies')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(28, 26, 28, 40),
        child: PolicyBody(),
      ),
    );
  }
}

class PolicyBody extends StatelessWidget {
  const PolicyBody({Key? key}) : super(key: key);

  static const List<_PolicySection> _sections = [
    _PolicySection(
      '1. Purpose and Scope',
      'This policy outlines the guidelines and responsibilities for '
          'administrators overseeing the e-learning virtual classroom platform '
          'for tutors and students. The aim is to create a conducive and secure '
          'online environment for effective teaching and learning.',
    ),
    _PolicySection(
      '2. Roles and Responsibilities',
      '- Administrator: The e-learning administrator is responsible for the '
          'overall management and maintenance of the virtual classroom '
          'platform. This includes user management, content moderation, '
          "technical support, and ensuring adherence to the platform's policies.",
    ),
    _PolicySection(
      '3. User Management',
      '- User Onboarding: Administrators are responsible for the smooth '
          'onboarding of tutors and students. This involves verifying '
          'identities, granting appropriate access permissions, and providing '
          'orientation on platform features.\n'
          '- Access Control: Admins must ensure that only authorized users have '
          'access to the platform. Regularly review and update user roles and '
          'permissions to maintain security and data privacy.',
    ),
    _PolicySection(
      '4. Content Management',
      '- Content Approval: All uploaded content, such as course materials and '
          'assignments, should be reviewed by administrators for quality and '
          'adherence to guidelines before being made available to users.\n'
          '- Copyright Compliance: Admins should enforce copyright policies and '
          'ensure that tutors adhere to intellectual property laws when using '
          'third-party content.',
    ),
    _PolicySection(
      '5. Technical Support',
      '- Issue Resolution: Administrators must promptly address technical '
          'issues reported by tutors and students, ensuring that they have a '
          'seamless learning experience.\n'
          '- Platform Updates: Stay up-to-date with platform updates and '
          'technological advancements to ensure optimal performance and '
          'security.',
    ),
    _PolicySection(
      '6. Communication and Monitoring',
      '- Announcements: Admins should communicate important updates, changes, '
          'and maintenance schedules to all users in a timely manner.\n'
          '- Monitoring: Regularly monitor platform activities for any '
          'irregularities or inappropriate behavior. Implement tools or '
          'procedures to identify and address issues like plagiarism or '
          'harassment.',
    ),
    _PolicySection(
      '7. Data Privacy and Security',
      '- User Data: Admins must safeguard user data, ensuring compliance with '
          'relevant data protection regulations (e.g., GDPR, HIPAA).\n'
          '- Secure Access: Enforce strong authentication mechanisms and '
          'encryption protocols to protect user accounts and data from '
          'unauthorized access.',
    ),
    _PolicySection(
      '8. Code of Conduct and Policies',
      '- User Behavior: Administrators should establish and communicate a code '
          'of conduct for tutors and students, outlining expected behavior and '
          'consequences for violations.\n'
          '- Content Guidelines: Set clear content guidelines, including '
          'standards for respectful communication and appropriate course '
          'materials.',
    ),
    _PolicySection(
      '9. Training and Support',
      '- User Training: Provide orientation and training for tutors and '
          'students on using the platform effectively, reporting issues, and '
          'adhering to policies.\n'
          '- Support: Offer responsive customer support to address user queries '
          'and technical difficulties.',
    ),
    _PolicySection(
      '10. Continuous Improvement',
      '- Feedback Collection: Gather feedback from tutors and students to '
          "identify areas for improvement and enhance the platform's features "
          'and functionalities.\n'
          '- Adaptation: Continuously assess the e-learning landscape and '
          "technology trends to adapt the platform's offerings and policies "
          'accordingly.',
    ),
    _PolicySection(
      '11. Enforcement and Reporting',
      '- Policy Enforcement: Administrators are responsible for enforcing the '
          'policies consistently and fairly. Violations should be addressed '
          'promptly, following a predetermined escalation process if '
          'necessary.\n'
          '- Incident Reporting: Establish a procedure for users to report '
          'incidents, ensuring that any breaches of security or misconduct are '
          'promptly addressed.',
    ),
    _PolicySection(
      '12. Policy Review',
      'Administrators should periodically review and update this policy to '
          'reflect changes in technology, regulations, and the e-learning '
          'landscape.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'TutorLink Administrator Policy',
          style: TLText.pageTitle(t.text),
        ),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final section in _sections)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.heading,
                        style: TLText.cardTitle(t.text).copyWith(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        section.body,
                        style: TLText.bodyStrong(t.textSub).copyWith(
                          fontWeight: FontWeight.w400,
                          height: 1.65,
                        ),
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
