/// lib/views/signup.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _pageController = PageController();
  int _currentStep = 0;

  // Champs
  final _email    = TextEditingController();
  final _name     = TextEditingController();
  final _password = TextEditingController();
  String  _gender     = 'Man';
  DateTime? _birthDate;
  File?   _avatarFile;

  bool    _loading = false;
  bool    _obscure = true;
  String? _error;

  static const int _totalSteps = 5;

  @override
  void dispose() {
    _pageController.dispose();
    _email.dispose();
    _name.dispose();
    _password.dispose();
    super.dispose();
  }

  // ── Validation ─────────────────────────────────────────────────────────────

  bool _isValidEmail(String e) =>
      RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(e);

  void _nextStep() {
    setState(() => _error = null);

    switch (_currentStep) {
      case 0:
        if (!_isValidEmail(_email.text.trim())) {
          setState(() => _error = 'Email invalide');
          return;
        }
      case 1:
        if (_name.text.trim().length < 3) {
          setState(() => _error = 'Nom trop court (minimum 3 caractères)');
          return;
        }
      case 2:
        if (_password.text.length < 8) {
          setState(() => _error = 'Mot de passe trop court (minimum 8 caractères)');
          return;
        }
      // step 3 = genre, step 4 = photo + naissance → optionnels
    }

    if (_currentStep < _totalSteps - 1) {
      _goTo(_currentStep + 1);
    } else {
      _submit();
    }
  }

  void _goTo(int step) {
    _pageController.animateToPage(step,
        duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
  }

  // ── Pick avatar ────────────────────────────────────────────────────────────

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 600,
    );
    if (picked != null) setState(() => _avatarFile = File(picked.path));
  }

  Future<void> _pickAvatarCamera() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 600,
    );
    if (picked != null) setState(() => _avatarFile = File(picked.path));
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.orangeAccent),
            title: const Text('Galerie', style: TextStyle(color: Colors.white)),
            onTap: () { Navigator.pop(context); _pickAvatar(); },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.orangeAccent),
            title: const Text('Appareil photo', style: TextStyle(color: Colors.white)),
            onTap: () { Navigator.pop(context); _pickAvatarCamera(); },
          ),
          if (_avatarFile != null)
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text('Supprimer', style: TextStyle(color: Colors.redAccent)),
              onTap: () { Navigator.pop(context); setState(() => _avatarFile = null); },
            ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  // ── Pick birth date ────────────────────────────────────────────────────────

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 18),
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year - 5),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.orangeAccent,
            surface: Color(0xFF1A1A1A),
          ),
          dialogBackgroundColor: const Color(0xFF111111),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    try {
      // 1. Register → get token
      final user = await AuthService().register(
        _name.text.trim(),
        _email.text.trim(),
        _password.text,
        _gender,
        birthDate: _birthDate != null
            ? '${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2,'0')}-${_birthDate!.day.toString().padLeft(2,'0')}'
            : null,
      );

      // 2. Upload avatar if selected
      if (_avatarFile != null) {
        try {
          await ApiService().uploadAvatar(_avatarFile!);
        } catch (_) {
          // Avatar upload failure is non-blocking — account still created
        }
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      setState(() => _error = msg);
      // Redirect to relevant step
      if (msg.toLowerCase().contains('email')) _goTo(0);
      else if (msg.toLowerCase().contains('name') || msg.toLowerCase().contains('nom')) _goTo(1);
      else if (msg.toLowerCase().contains('password') || msg.toLowerCase().contains('mot de passe')) _goTo(2);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () =>
              _currentStep > 0 ? _goTo(_currentStep - 1) : Navigator.pop(context),
        ),
        title: Text(
          'Étape ${_currentStep + 1} sur $_totalSteps',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ),
      body: Column(children: [
        // Progress bar
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: (_currentStep + 1) / _totalSteps),
          duration: const Duration(milliseconds: 300),
          builder: (_, value, __) => LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey.shade900,
            color: Colors.orangeAccent,
            minHeight: 3,
          ),
        ),

        // Pages
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (p) => setState(() { _currentStep = p; _error = null; }),
            children: [
              _buildStepEmail(),
              _buildStepName(),
              _buildStepPassword(),
              _buildStepGender(),
              _buildStepProfilePhoto(),
            ],
          ),
        ),

        // Google button
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

        // CTA button
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: Colors.black,
              border: Border(top: BorderSide(color: Colors.grey.shade900))),
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
                  ? const SizedBox(height: 22, width: 22,
                      child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                  : Text(
                      _currentStep == _totalSteps - 1 ? 'CRÉER MON COMPTE' : 'CONTINUER',
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
            ),
          ),
        ),
      ]),
    );
  }

  // ── Step 0 — Email ─────────────────────────────────────────────────────────

  Widget _buildStepEmail() => _stepWrapper(
    title: 'Quel est votre email ?',
    subtitle: 'Nous l\'utiliserons pour sécuriser votre compte.',
    child: TextField(
      controller: _email,
      keyboardType: TextInputType.emailAddress,
      autofocus: true,
      style: const TextStyle(color: Colors.white),
      decoration: _deco('Ex: vous@email.com',
          prefix: const Icon(Icons.email_outlined, color: Colors.grey, size: 20)),
    ),
  );

  // ── Step 1 — Nom ───────────────────────────────────────────────────────────

  Widget _buildStepName() => _stepWrapper(
    title: 'Quel est votre nom ?',
    subtitle: 'Il apparaîtra sur vos posts et votre profil.',
    child: TextField(
      controller: _name,
      style: const TextStyle(color: Colors.white),
      decoration: _deco('Prénom et Nom',
          prefix: const Icon(Icons.person_outline, color: Colors.grey, size: 20)),
    ),
  );

  // ── Step 2 — Mot de passe ──────────────────────────────────────────────────

  Widget _buildStepPassword() => _stepWrapper(
    title: 'Choisissez un mot de passe',
    subtitle: 'Minimum 8 caractères.',
    child: TextField(
      controller: _password,
      obscureText: _obscure,
      style: const TextStyle(color: Colors.white),
      decoration: _deco('Mot de passe',
        prefix: const Icon(Icons.lock_outline, color: Colors.grey, size: 20),
        suffix: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey, size: 20),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    ),
  );

  // ── Step 3 — Genre ─────────────────────────────────────────────────────────

  Widget _buildStepGender() => _stepWrapper(
    title: 'Vous êtes...',
    subtitle: 'Aide à personnaliser votre expérience.',
    child: Column(
      children: ['Man', 'Woman', 'Non-binary', 'Prefer not to say'].map((g) {
        final sel = _gender == g;
        return GestureDetector(
          onTap: () => setState(() => _gender = g),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: sel ? Colors.orange.withOpacity(0.1) : const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: sel ? Colors.orangeAccent : Colors.grey.shade800, width: sel ? 1.5 : 1),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(g,
                  style: TextStyle(
                      color: sel ? Colors.orangeAccent : Colors.white, fontSize: 16)),
              if (sel)
                const Icon(Icons.check_circle, color: Colors.orangeAccent, size: 22),
            ]),
          ),
        );
      }).toList(),
    ),
  );

  // ── Step 4 — Photo + naissance ─────────────────────────────────────────────

  Widget _buildStepProfilePhoto() => _stepWrapper(
    title: 'Finalisez votre profil',
    subtitle: 'Photo de profil et date de naissance (optionnels).',
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      // Avatar picker
      Center(
        child: GestureDetector(
          onTap: _showAvatarPicker,
          child: Stack(children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFF1A1A1A),
              backgroundImage: _avatarFile != null ? FileImage(_avatarFile!) : null,
              child: _avatarFile == null
                  ? const Icon(Icons.person, color: Colors.grey, size: 60)
                  : null,
            ),
            Positioned(
              bottom: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                    color: Colors.orangeAccent, shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt, color: Colors.black, size: 18),
              ),
            ),
          ]),
        ),
      ),

      const SizedBox(height: 10),
      const Center(
        child: Text('Appuyer pour choisir une photo',
            style: TextStyle(color: Colors.grey, fontSize: 13)),
      ),

      const SizedBox(height: 32),

      // Birth date picker
      const Text('Date de naissance',
          style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      GestureDetector(
        onTap: _pickBirthDate,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: _birthDate != null ? Colors.orangeAccent : Colors.grey.shade800),
          ),
          child: Row(children: [
            Icon(Icons.cake_outlined,
                color: _birthDate != null ? Colors.orangeAccent : Colors.grey, size: 20),
            const SizedBox(width: 12),
            Text(
              _birthDate != null ? _formatDate(_birthDate!) : 'Sélectionner une date',
              style: TextStyle(
                  color: _birthDate != null ? Colors.white : Colors.grey,
                  fontSize: 15),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios,
                color: Colors.grey.shade700, size: 14),
          ]),
        ),
      ),

      if (_birthDate != null) ...[
        const SizedBox(height: 8),
        Text(
          '${DateTime.now().year - _birthDate!.year} ans',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    ]),
  );

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _stepWrapper({
    required String title,
    required String subtitle,
    required Widget child,
  }) =>
      SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 15)),
          const SizedBox(height: 32),
          child,
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                ),
                child: Row(children: [
                  const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 13))),
                ]),
              ),
            ),
        ]),
      );

  InputDecoration _deco(String hint,
      {Widget? prefix, Widget? suffix}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        prefixIcon: prefix,
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade800),
            borderRadius: BorderRadius.circular(12)),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orangeAccent),
            borderRadius: BorderRadius.all(Radius.circular(12))),
      );
}
