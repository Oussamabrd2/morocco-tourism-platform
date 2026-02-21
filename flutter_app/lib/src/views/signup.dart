import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String _gender = "Man";

  bool _loading = false;
  String? _error;

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _nextStep() {
    setState(() => _error = null);

    if (_currentStep == 0 && !_isValidEmail(_email.text)) {
      setState(() => _error = "Veuillez entrer un email valide.");
      return;
    }
    if (_currentStep == 1 && _name.text.length < 3) {
      setState(() => _error = "Le nom doit contenir au moins 3 caractères.");
      return;
    }
    if (_currentStep == 2 && _password.text.length < 6) {
      setState(() => _error = "Le mot de passe doit contenir au moins 6 caractères.");
      return;
    }

    if (_currentStep < 3) {
      _jumpToStep(_currentStep + 1);
    } else {
      _signup();
    }
  }

  void _jumpToStep(int step) {
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _signup() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final api = ApiService();
      final response = await api.post('v1/auth/register', {
        'name': _name.text,
        'email': _email.text,
        'password': _password.text,
        'gender': _gender,
      });

      final body = jsonDecode(response.body);

      if (response.statusCode == 201) {
        final token = body['data']['token'];
        Navigator.pushReplacementNamed(context, '/home', arguments: {'token': token});
      } else {
        String message = body['message'] ?? 'Erreur d\'inscription';
        setState(() => _error = message);

        if (message.toLowerCase().contains('email')) {
          _jumpToStep(0);
        } else if (message.toLowerCase().contains('name') || message.toLowerCase().contains('nom')) {
          _jumpToStep(1);
        } else if (message.toLowerCase().contains('password') || message.toLowerCase().contains('mot de passe')) {
          _jumpToStep(2);
        }
      }
    } catch (e) {
      setState(() => _error = 'Erreur réseau: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_currentStep > 0) {
              _jumpToStep(_currentStep - 1);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text("Étape ${_currentStep + 1} sur 4", style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ),
      body: Column(
        children: [
          // شريط التقدم (Progress Bar)
          LinearProgressIndicator(
            value: (_currentStep + 1) / 4,
            backgroundColor: Colors.grey[900],
            color: Colors.orangeAccent,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (int page) => setState(() => _currentStep = page),
              children: [
                _buildStepLayout(
                  title: "Quel est votre email ?",
                  subtitle: "Nous l'utiliserons pour sécuriser votre compte Ziarat.",
                  child: TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("Ex: oussama@email.com"),
                  ),
                ),
                _buildStepLayout(
                  title: "Quel est votre nom ?",
                  subtitle: "Votre nom apparaîtra sur vos partages et posts.",
                  child: TextField(
                    controller: _name,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("Prénom et Nom"),
                  ),
                ),
                _buildStepLayout(
                  title: "Sécurisez votre compte",
                  subtitle: "Choisissez un mot de passe robuste.",
                  child: TextField(
                    controller: _password,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("Mot de passe"),
                  ),
                ),
                _buildStepLayout(
                  title: "Vous êtes...",
                  subtitle: "Cela nous aide à personnaliser votre expérience.",
                  child: Column(
                    children: ["Man", "Woman", "Non-binary", "Prefer not to say"].map((g) {
                      bool isSelected = _gender == g;
                      return GestureDetector(
                        onTap: () => setState(() => _gender = g),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.orangeAccent.withOpacity(0.1) : const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSelected ? Colors.orangeAccent : Colors.grey[800]!),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(g, style: TextStyle(color: isSelected ? Colors.orangeAccent : Colors.white, fontSize: 16)),
                              if (isSelected) const Icon(Icons.check_circle, color: Colors.orangeAccent),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Social signup option
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Colors.grey[800]!),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/google-login');
                },
                child: const Text('S’inscrire avec Google', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildStepLayout({required String title, required String subtitle, required Widget child}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 15)),
          const SizedBox(height: 35),
          child,
          if (_error != null) 
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 14)),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.grey[900]!)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orangeAccent,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 0,
          ),
          onPressed: _loading ? null : _nextStep,
          child: _loading 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
            : Text(_currentStep == 3 ? "CRÉER MON COMPTE" : "CONTINUER", 
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24),
      filled: true,
      fillColor: const Color(0xFF1A1A1A),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[800]!), borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.orangeAccent), borderRadius: BorderRadius.circular(12)),
    );
  }
}