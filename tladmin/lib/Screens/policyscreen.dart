import 'package:flutter/material.dart';

class PolicyScreen extends StatelessWidget {
  static String routeName = 'PolicyScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TutorLink Administrator Policies'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TutorLink Administrator Policy',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              '1. Purpose and Scope:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'This policy outlines the guidelines and responsibilities for administrators overseeing the e-learning virtual classroom platform for tutors and students. The aim is to create a conducive and secure online environment for effective teaching and learning.',
            ),
            SizedBox(height: 16.0),
            Text(
              '2. Roles and Responsibilities:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '- Administrator: The e-learning administrator is responsible for the overall management and maintenance of the virtual classroom platform. This includes user management, content moderation, technical support, and ensuring adherence to the platform\'s policies.',
            ),
            SizedBox(height: 16.0),
            Text(
              '3. User Management:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '- User Onboarding: Administrators are responsible for the smooth onboarding of tutors and students. This involves verifying identities, granting appropriate access permissions, and providing orientation on platform features.\n'
              '- Access Control: Admins must ensure that only authorized users have access to the platform. Regularly review and update user roles and permissions to maintain security and data privacy.',
            ),
            Text(
              '4. Content Management:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
                '-Content Approval: All uploaded content, such as course materials and assignments, should be reviewed by administrators for quality and adherence to guidelines before being made available to users.\n'
                'Copyright Compliance: Admins should enforce copyright policies and ensure that tutors adhere to intellectual property laws when using third-party content.'),
            Text(
              '5. Technical Support:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
                '-Issue Resolution: Administrators must promptly address technical issues reported by tutors and students, ensuring that they have a seamless learning experience.\n'
                'Platform Updates: Stay up-to-date with platform updates and technological advancements to ensure optimal performance and security.'),
            Text(
              '6. Communication and Monitoring:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
                '-Announcements: Admins should communicate important updates, changes, and maintenance schedules to all users in a timely manner.\n'
                '-Monitoring: Regularly monitor platform activities for any irregularities or inappropriate behavior. Implement tools or procedures to identify and address issues like plagiarism or harassment.'),
            Text(
              '7. Data Privacy and Security:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
                '-User Data: Admins must safeguard user data, ensuring compliance with relevant data protection regulations (e.g., GDPR, HIPAA).\n'
                '-Secure Access: Enforce strong authentication mechanisms and encryption protocols to protect user accounts and data from unauthorized access.'),
            Text(
              '8. Code of Conduct and Policies:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
                '-User Behavior: Administrators should establish and communicate a code of conduct for tutors and students, outlining expected behavior and consequences for violations.\n'
                '-Content Guidelines: Set clear content guidelines, including standards for respectful communication and appropriate course materials.'),
            Text(
              '9. Training and Support:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
                '-User Training: Provide orientation and training for tutors and students on using the platform effectively, reporting issues, and adhering to policies.\n'
                '-Support: Offer responsive customer support to address user queries and technical difficulties.'),
            Text(
              '10. Continuous Improvement:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
                "-Feedback Collection: Gather feedback from tutors and students to identify areas for improvement and enhance the platform's features and functionalities.\n"
                "-Adaptation: Continuously assess the e-learning landscape and technology trends to adapt the platform's offerings and policies accordingly."),
            Text(
              '11. Enforcement and Reporting:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
                "-Policy Enforcement: Administrators are responsible for enforcing the policies consistently and fairly. Violations should be addressed promptly, following a predetermined escalation process if necessary.\n"
                "-Incident Reporting: Establish a procedure for users to report incidents, ensuring that any breaches of security or misconduct are promptly addressed."),
            SizedBox(height: 16.0),
            Text(
              '12. Policy Review:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Administrators should periodically review and update this policy to reflect changes in technology, regulations, and the e-learning landscape.',
            ),
          ],
        ),
      ),
    );
  }
}
