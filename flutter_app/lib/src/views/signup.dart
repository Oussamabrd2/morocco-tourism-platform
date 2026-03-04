/// lib/views/signup.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _pageController = PageController();
  int _currentStep = 0;

  final _name     = TextEditingController();
  final _email    = TextEditingController();
  final _password = TextEditingController();
  String _gender  = 'Man';

  bool    _loading = false;
  String? _error;

  @override
  void dispose() {
    _pageController.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool _isValidEmail(String e) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(e);

  void _nextStep() {
    setState(() => _error = null);
    if (_currentStep == 0 && !_isValidEmail(_email.text)) {
      setState(() => _error = 'Email invalide'); return;
    }
    if (_currentStep == 1 && _name.text.trim().length < 3) {
      setState(() => _error = 'Nom trop court (min 3 caractères)'); return;
    }
    if (_currentStep == 2 && _password.text.length < 8) {
      setState(() => _error = 'Mot de passe trop court (min 8 caractères)'); return;
    }
    if (_currentStep < 3) {
      _goTo(_currentStep + 1);
    } else {
      _signup();
    }
  }

  void _goTo(int step) {
    _pageController.animateToPage(step,
        duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
  }

  Future<void> _signup() async {
    setState(() { _loading = true; _error = null; });
    try {
      // FIX: pass gender + use AuthService (which saves token)
      await AuthService().register(
          _name.text.trim(), _email.text.trim(), _password.text, _gender);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      setState(() => _error = msg);
      // Redirect to correct step based on error
      if (msg.toLowerCase().contains('email')) _goTo(0);
      else if (msg.toLowerCase().contains('name') || msg.toLowerCase().contains('nom')) _goTo(1);
      else if (msg.toLowerCase().contains('password')) _goTo(2);
    } finally {
      if (mounted) setState(() => _loading = false);
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
          onPressed: () => _currentStep > 0 ? _goTo(_currentStep - 1) : Navigator.pop(context),
        ),
        title: Text('Étape ${_currentStep + 1} sur 4',
            style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentStep + 1) / 4,
            backgroundColor: Colors.grey.shade900,
            color: Colors.orangeAccent,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (p) => setState(() => _currentStep = p),
              children: [
                _step('Quel est votre email ?',
                    'Nous l\'utiliserons pour sécuriser votre compte.',
                    TextField(controller: _email, keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: _deco('Ex: vous@email.com'))),
                _step('Quel est votre nom ?', 'Il apparaîtra sur vos posts.',
                    TextField(controller: _name, style: const TextStyle(color: Colors.white),
                        decoration: _deco('Prénom et Nom'))),
                _step('Mot de passe', 'Minimum 8 caractères.',
                    TextField(controller: _password, obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: _deco('Mot de passe'))),
                _step('Vous êtes...', 'Aide à personnaliser votre expérience.',
                    Column(children: ['Man','Woman','Non-binary','Prefer not to say'].map((g) {
                      final sel = _gender == g;
                      return GestureDetector(
                        onTap: () => setState(() => _gender = g),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            color: sel ? Colors.orange.withOpacity(0.1) : const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: sel ? Colors.orange : Colors.grey.shade800),
                          ),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text(g, style: TextStyle(color: sel ? Colors.orange : Colors.white, fontSize: 16)),
                            if (sel) const Icon(Icons.check_circle, color: Colors.orange),
                          ]),
                        ),
                      );
                    }).toList())),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Colors.grey.shade800),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () => Navigator.pushNamed(context, '/google-login'),
                child: const Text('S\'inscrire avec Google',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: Colors.black, border: Border(top: BorderSide(color: Colors.grey.shade900))),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: _loading ? null : _nextStep,
                child: _loading
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : Text(_currentStep == 3 ? 'CRÉER MON COMPTE' : 'CONTINUER',
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _step(String title, String subtitle, Widget child) => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 15)),
      const SizedBox(height: 35),
      child,
      if (_error != null)
        Padding(padding: const EdgeInsets.only(top: 16),
            child: Text(_error!, style: const TextStyle(color: Colors.redAccent))),
    ]),
  );

  InputDecoration _deco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.white24),
    filled: true,
    fillColor: const Color(0xFF1A1A1A),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade800), borderRadius: BorderRadius.circular(12)),
    focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.orangeAccent), borderRadius: BorderRadius.all(Radius.circular(12))),
  );
}
