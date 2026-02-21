import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

/// Simple user model for storing basic Google info.
class GoogleUser {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;

  GoogleUser({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
      };
}

/// Service handling Google Sign-In, local storage and backend integration.
class GoogleAuthService {
  // Configure your backend base URL here (replace with your Laravel app URL).
  static const String backendBaseUrl = 'http://192.168.0.164:8000';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>['email', 'profile'],
  );

  /// Sign in with Google, send info to backend, and store returned token + user locally.
  /// Returns stored backend token on success, or throws on error.
  Future<String?> signIn() async {
    final account = await _googleSignIn.signIn();
    if (account == null) return null; // user aborted

    final auth = await account.authentication;
    final idToken = auth.idToken; // send to backend to verify

    final user = GoogleUser(
      id: account.id,
      name: account.displayName ?? '',
      email: account.email,
      photoUrl: account.photoUrl,
    );

    // Send Google UID, name and email (and id_token) to Laravel backend
    final uri = Uri.parse('$backendBaseUrl/api/google-login');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'google_uid': user.id,
        'name': user.name,
        'email': user.email,
        'id_token': idToken,
      }),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Backend login failed: ${res.statusCode} ${res.body}');
    }

    // Expect backend returns JSON containing a token and optionally user data
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final backendToken = body['token']?.toString();

    // Save token and user locally using SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    if (backendToken != null) await prefs.setString('backend_token', backendToken);
    await prefs.setString('google_user', jsonEncode(user.toJson()));

    return backendToken;
  }

  /// Sign out from Google and clear stored data.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('backend_token');
    await prefs.remove('google_user');
  }

  /// Retrieve locally stored Google user info (if any).
  Future<GoogleUser?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('google_user');
    if (raw == null) return null;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return GoogleUser(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
    );
  }

  /// Get stored backend token (if any).
  Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('backend_token');
  }
}
