import 'package:flutter/material.dart';
import '../services/business-service.dart';
import 'termsOfService.dart';
import 'privacyPolicy.dart';
import 'businessLogin.dart';
import 'businessRegister.dart';

import 'package:flutter/gestures.dart';

class BusinessWelcomePage extends StatefulWidget {
  const BusinessWelcomePage({super.key});

  @override
  State<BusinessWelcomePage> createState() => _BusinessWelcomePageState();
}

class _BusinessWelcomePageState extends State<BusinessWelcomePage> {
  final TextEditingController _emailController = TextEditingController();
  final BusinessService _businessService = BusinessService();
  String? _errorMessage;
  List<Map<String, dynamic>> _allBusinesses = [];

  @override
  void initState() {
    super.initState();
    _fetchBusinesses();
  }

  Future<void> _fetchBusinesses() async {
    try {
      final businesses = await _businessService.getAllBusinesses();
      setState(() {
        _allBusinesses = businesses;
      });
    } catch (e) {
      print('Error fetching businesses: $e');
    }
  }

void _handleContinue() {
  final email = _emailController.text.trim();

  final isEmailUsed = _allBusinesses.any((business) => business['salonEmail'] == email);

  setState(() {
    if (email.isEmpty) {
      _errorMessage = "Please enter your email.";
    } else if (isEmailUsed) {
      _errorMessage = "Email already registered, Sign in!";
    } else {
      _errorMessage = null;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BusinessRegisterPage(
            email: email,
            backgroundColor: const Color.fromARGB(255, 244, 171, 165),
          ),
        ),
      ).then((_) {
        _fetchBusinesses();
      });
    }
  });
}

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 171, 165),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Image.asset(
                'assets/images/logo.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Create an Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Enter your email to sign up for this app',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    hintText: 'email@domain.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 14.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 14.0,
                      ),
                    ),
                    child: const Text('Continue'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Visibility(
                visible: !isKeyboardOpen,
                child: Column(
                  children: [
                    const SizedBox(height: 200),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                          children: [
                            const TextSpan(
                              text: 'By clicking continue, you agree to our ',
                            ),
                            TextSpan(
                              text: 'Terms of Service',
                              style: const TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.black,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const TermsOfServicePage(
                                        backgroundColor: Color.fromARGB(255, 244, 171, 165),
                                      ),
                                    ),
                                  );
                                },
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: const TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.black,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const PrivacyPolicyPage(
                                        backgroundColor: Color.fromARGB(255, 244, 171, 165),
                                      ),
                                    ),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            const TextSpan(
                              text: 'You already have an account? ',
                            ),
                            TextSpan(
                              text: 'Sign in',
                              style: const TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.black,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BusinessLoginPage(
                                        backgroundColor: const Color.fromARGB(255, 244, 171, 165),
                                      ),
                                    ),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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
