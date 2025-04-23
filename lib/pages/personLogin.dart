import 'package:flutter/material.dart';
import '../services/login-service.dart';
import 'personHome.dart';
import '../auth/auth_storage.dart';

class PersonLoginPage extends StatefulWidget {
  final Color backgroundColor;

  const PersonLoginPage({
    super.key,
    required this.backgroundColor,
  });

  @override
  State<PersonLoginPage> createState() => _PersonLoginPageState();
}

class _PersonLoginPageState extends State<PersonLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Komunikat błędu (np. nieprawidłowe dane do logowania)
  String? _errorMessage;

  // Tworzymy instancję LoginService
  final LoginService _loginService = LoginService();

  /// Obsługa przycisku "Continue"
  Future<void> _handleContinue() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    print('email: $email');
    print('password: $password');

    // Wywołujemy logowanie w serwisie:
    final loginResponse = await _loginService.login(
      email: email,
      password: password,
    );

    if (loginResponse != null) {
      // Załóżmy, że loginResponse ma strukturę:
      // {
      //   "token": "...",
      //   "user": {
      //     "id": 2,
      //     "firstName": "Krzysztof",
      //     ...
      //   }
      // }
      final userMap = loginResponse['user'] as Map<String, dynamic>?;
      final token = loginResponse['token'];

      await storeToken(token);
      print('Usermap: $userMap');
      print('token: $token');

      if (isTokenExpired(token)) {
        print('Token is expired');
      } else {
        print('Token is valid');
      }
      
      // Upewniamy się, że mamy userMap z polem "id"
      if (userMap != null && userMap['id'] != null) {
        // Konwertujemy ID na String, bo PersonHomePage oczekuje typu String
        final personId = userMap['id'].toString();

        // Przejdź do PersonHomePage (lub innej strony po zalogowaniu)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PersonHomePage(personId: personId),
          ),
        );
      } else {
        // Brak usera lub ID
        setState(() {
          _errorMessage = 'Brak danych użytkownika w odpowiedzi serwera.';
        });
      }
    } else {
      // Logowanie nieudane (null zwrócone przez loginService)
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
