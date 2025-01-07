import 'package:flutter/material.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                "Privacy Policy for School Management App",
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text:
                      '\nAt School Management App, we are committed to protecting the privacy and security of your personal information. This Privacy Policy outlines how we collect, use, store, and safeguard the information of students, parents, teachers, and administrators who use our school management application. Your trust is important to us, and we are dedicated to ensuring that your data is handled responsibly and transparently.\n\n',
                    ),
                    TextSpan(
                      text: 'Information We Collect\n',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                      'To provide efficient and tailored services, we may collect the following information:\n- Personal Information: Such as names, contact details, addresses, and unique identification numbers for students, parents, teachers, and staff.\n- Educational Records: Including attendance, grades, assignments, and performance reports.\n- Administrative Data: Such as leave requests, announcements, and feedback.\n- Technical Information: Device identifiers, IP addresses, and usage data to enhance app functionality and security.\n\n',
                    ),
                    TextSpan(
                      text: 'How We Use Your Information\n',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                      'The information we collect is used to:\n- Facilitate core school operations such as attendance tracking, report generation, and communication between stakeholders.\n- Manage user profiles, enabling secure login and access to relevant features.\n- Share updates, notifications, and announcements from school administrators to users.\n- Improve app functionality by analyzing usage trends and addressing technical issues.\n\n',
                    ),
                    TextSpan(
                      text: 'Information Sharing and Disclosure\n',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                      'We value your privacy and do not share your information with third parties except in the following situations:\n- When required by law or to comply with legal obligations.\n- To authorized personnel such as teachers, school staff, or administrators for fulfilling educational or administrative purposes.\n- To service providers assisting us in delivering app features, bound by confidentiality agreements.\n\n',
                    ),
                    TextSpan(
                      text: 'Data Security\n',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                      'We implement industry-standard security measures to protect your data against unauthorized access, alteration, or disclosure. This includes encryption, secure storage solutions, and regular system updates. Users are encouraged to maintain the confidentiality of their login credentials to prevent unauthorized access.\n\n',
                    ),
                    TextSpan(
                      text: 'User Rights\n',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                      'You have the right to:\n- Access the personal data we hold about you.\n- Request corrections to inaccurate information.\n- Request deletion of your data where applicable.\n- Opt-out of non-essential communications.\n\n',
                    ),
                    TextSpan(
                      text: 'Retention of Data\n',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                      'We retain your data for as long as necessary to fulfill the purposes outlined in this policy or as required by law. Upon the closure of user accounts, we securely delete or anonymize personal data unless legal retention requirements apply.\n\n',
                    ),
                    TextSpan(
                      text: 'Changes to the Privacy Policy\n',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                      'We may update this Privacy Policy periodically to reflect changes in our practices or legal obligations. We encourage you to review this policy regularly to stay informed about how we protect your information.\n\n',
                    ),
                    TextSpan(
                      text: 'Contact Us\n',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                      'If you have any questions, concerns, or requests related to this Privacy Policy, please contact us at www.rachss.org or mail us to rachss@gmail.com\n\n',
                    ),
                    TextSpan(
                      text:
                      'By using our school management app, you acknowledge that you have read and understood this Privacy Policy and agree to its terms.\n\n',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
