import 'package:flutter/material.dart';
import '../services/auth-service.dart';
import '../auth/auth_storage.dart';
import 'businessHome.dart';

class BusinessLoginPage extends StatefulWidget {
  final Color backgroundColor;

  const BusinessLoginPage({
    super.key,
    required this.backgroundColor,
  });

  @override
  State<BusinessLoginPage> createState() => _BusinessLoginPageState();
}

class _BusinessLoginPageState extends State<BusinessLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  String? _errorMessage;

  Future<void> _handleContinue() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    print('email: $email');
    print('password: $password');

    final loginResponse = await _authService.login(
      email: email,
      password: password,
    );

    if (loginResponse != null) {
      final userMap = loginResponse['user'] as Map<String, dynamic>?;
      final token = loginResponse['token'];

      await storeToken(token);
      print('Usermap: $userMap');
      print('token: $token');

      if (userMap != null && userMap['id'] != null) {
        final businessOwnerId = userMap['id'].toString();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BusinessHomePage(businessId: businessOwnerId),
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'No user data found in response.';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Incorrect email or password.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
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
              const SizedBox(height: 64),
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
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    hintText: 'Password',
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
            ],
          ),
        ),
      ),
    );
  }
}
