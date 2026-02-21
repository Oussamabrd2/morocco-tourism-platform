import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/google_auth_service.dart';

/// Simple Material page offering Google Sign-In and logout.
class GoogleLoginPage extends StatefulWidget {
  const GoogleLoginPage({super.key});

  @override
  State<GoogleLoginPage> createState() => _GoogleLoginPageState();
}

class _GoogleLoginPageState extends State<GoogleLoginPage> {
  final GoogleAuthService _authService = GoogleAuthService();
  GoogleUser? _user;
  String? _token;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadStored();
  }

  Future<void> _loadStored() async {
    final u = await _authService.getStoredUser();
    final t = await _authService.getStoredToken();
    setState(() {
      _user = u;
      _token = t;
    });
  }

  Future<void> _handleSignIn() async {
    setState(() => _loading = true);
    try {
      final token = await _authService.signIn();
      final u = await _authService.getStoredUser();
      setState(() {
        _user = u;
        _token = token;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signed in successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign in failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _handleSignOut() async {
    setState(() => _loading = true);
    await _authService.signOut();
    setState(() {
      _user = null;
      _token = null;
      _loading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signed out')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Sign-In')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_user != null) ...[
                CircleAvatar(
                  radius: 40,
                  backgroundImage: _user!.photoUrl != null ? NetworkImage(_user!.photoUrl!) : null,
                  child: _user!.photoUrl == null ? const Icon(Icons.person, size: 40) : null,
                ),
                const SizedBox(height: 12),
                Text(_user!.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(_user!.email, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _loading ? null : _handleSignOut,
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign out'),
                ),
              ] else ...[
                const Text('Sign in with Google to continue', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                    onPressed: _loading ? null : _handleSignIn,
                    icon: Image.asset('assets/images/app_icon.png', width: 24, height: 24),
                    label: _loading ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Sign in with Google'),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              if (_token != null) SelectableText('Backend token: $_token', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
