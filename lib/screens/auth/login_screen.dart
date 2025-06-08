// screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:haushalt_app/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      // THIS IS A PLACEHOLDER LOGIN.
      // In a real app, you would send _usernameController.text and _passwordController.text
      // to your Django backend's authentication endpoint.
      // If successful, you would navigate to HomeScreen and save the received auth token.

      // For now, simply navigate to the home screen.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anmelden'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.house_siding,
                  size: 100,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 30),
                Text(
                  'Willkommen beim Haushaltsmanager!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).primaryColorDark),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Benutzername',
                    hintText: 'Geben Sie Ihren Benutzernamen ein',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte geben Sie Ihren Benutzernamen ein';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Passwort',
                    hintText: 'Geben Sie Ihr Passwort ein',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte geben Sie Ihr Passwort ein';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50), // Make button full width
                  ),
                  child: const Text('Anmelden'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}