import 'package:flutter/material.dart';
class TermsOfUse extends StatefulWidget {
  const TermsOfUse({super.key});

  @override
  State<TermsOfUse> createState() => _TermsOfUseState();
}

class _TermsOfUseState extends State<TermsOfUse> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 12),
          child: Column(
          children: [
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: 'Terms of Use for School Management App\n\n',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                    'Welcome to School Management App. These Terms of Use govern your access to and use of our school management application. By using the app, you agree to comply with these terms. Please read them carefully.\n\n',
                  ),
                  TextSpan(
                    text: 'Acceptance of Terms\n',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                    'By accessing and using this application, you confirm that you accept these Terms of Use and agree to be bound by them. If you do not agree to these terms, you must not use the app.\n\n',
                  ),
                  TextSpan(
                    text: 'Eligibility\n',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                    'This app is intended for use by authorized students, parents, teachers, and administrators of the affiliated school. Unauthorized access or use is strictly prohibited.\n\n',
                  ),
                  TextSpan(
                    text: 'User Responsibilities\n',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                    'As a user, you agree to:\n- Use the app only for its intended purpose and in compliance with all applicable laws.\n- Maintain the confidentiality of your login credentials and notify the school administration of any unauthorized access or security breaches.\n- Provide accurate and up-to-date information as required by the app.\n- Refrain from using the app to distribute harmful, illegal, or offensive content.\n\n',
                  ),
                  TextSpan(
                    text: 'Prohibited Activities\n',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                    'You are strictly prohibited from:\n- Attempting to access, tamper with, or disrupt the app’s functionality, security measures, or database.\n- Using the app for commercial purposes unrelated to the school.\n- Sharing login credentials or granting access to unauthorized users.\n- Posting or sharing harmful, defamatory, or unlawful content.\n\n',
                  ),
                  TextSpan(
                    text: 'Intellectual Property\n',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                    'All content, features, and functionality of the app, including text, graphics, logos, and software, are the exclusive property of [App Name] and its licensors. Unauthorized reproduction, distribution, or use is strictly prohibited.\n\n',
                  ),
                  TextSpan(
                    text: 'Termination of Access\n',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                    'We reserve the right to suspend or terminate your access to the app if you violate these terms or engage in activities that compromise the app’s security or integrity.\n\n',
                  ),
                  TextSpan(
                    text: 'Limitation of Liability\n',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                    'To the extent permitted by law, [App Name] and its affiliates will not be liable for any damages, including loss of data or unauthorized access, resulting from your use of the app.\n\n',
                  ),
                  TextSpan(
                    text: 'Changes to Terms of Use\n',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                    'We may update these Terms of Use periodically to reflect changes in our policies or legal requirements. Continued use of the app after such changes constitutes your acceptance of the updated terms.\n\n',
                  ),
                  TextSpan(
                    text: 'Contact Us\n',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                    'If you have any questions or concerns about these Terms of Use, please contact us at [Contact Information].\n\n',
                  ),
                  TextSpan(
                    text:
                    'By using this app, you acknowledge that you have read and understood these Terms of Use and agree to comply with them.\n\n',
                  ),
                ],
              ),
            )

          ],
              ),
        ),

    ),
    );
  }
}