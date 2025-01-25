import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  final Color backgroundColor;

  const TermsOfServicePage({super.key, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Terms of Service'),
        backgroundColor: backgroundColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '1. Introduction',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Welcome to [Your Service Name]. These Terms of Service ("Terms") govern your use of our website, applications, and other related services (collectively, the "Services"). By accessing or using the Services, you agree to comply with these Terms. If you do not agree, please refrain from using the Services.',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 16),
              Text(
                '2. Eligibility',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'By using the Services, you represent that you are at least 18 years old or have the legal capacity to form a binding contract in your jurisdiction. Minors may use the Services only under the supervision of a parent or legal guardian who agrees to these Terms.',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 16),
              Text(
                '3. Account Registration',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'To access certain features of the Services, you may need to register for an account. You agree to:\n- Provide accurate and up-to-date information during registration.\n- Maintain the confidentiality of your account credentials.\n- Notify us immediately of any unauthorized use of your account.',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 16),
              Text(
                '4. User Conduct',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'You agree not to use the Services for any unlawful or prohibited activities, including but not limited to:\n- Violating applicable laws or regulations.\n- Engaging in fraudulent, deceptive, or harmful activities.\n- Infringing on the intellectual property rights of others.\n- Distributing viruses or malicious software.',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 16),
              Text(
                '5. Privacy Policy',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Your use of the Services is also governed by our Privacy Policy, which outlines how we collect, use, and protect your personal information. By using the Services, you consent to our data practices as described in the Privacy Policy.',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 16),
              Text(
                '6. Termination',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'We may terminate or suspend your access to the Services at our discretion, with or without cause, and without prior notice. Upon termination, your right to use the Services will immediately cease.',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
