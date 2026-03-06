/// lib/services/auth_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _tokenKey = 'auth_token';
  static const String _userKey  = 'auth_user';

  // ── Storage ───────────────────────────────────────────────────────────────

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> saveToken(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user));
    ApiService().setToken(token);
  }

  Future<void> initializeToken() async {
    final token = await getToken();
    if (token != null) ApiService().setToken(token);
  }

  Future<bool> isLoggedIn() async => (await getToken()) != null;

  Future<void> updateCachedUser(Map<String, dynamic> updated) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(updated));
  }

  // ── Login ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await ApiService().login(email, password);
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      final data  = body['data'] as Map<String, dynamic>;
      final token = data['token'] as String;
      final user  = data['user']  as Map<String, dynamic>;
      await saveToken(token, user);
      return user;
    }
    throw Exception(body['message'] ?? 'Identifiants incorrects');
  }

  // ── Register ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String gender, {
    String? birthDate,   // format "YYYY-MM-DD"
  }) async {
    final response = await ApiService().register(
      name, email, password, gender,
      birthDate: birthDate,
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 201) {
      final data  = body['data'] as Map<String, dynamic>;
      final token = data['token'] as String;
      final user  = data['user']  as Map<String, dynamic>;
      await saveToken(token, user);
      return user;
    }

    // Parse Laravel validation errors (422)
    if (response.statusCode == 422) {
      final errors = body['errors'] as Map<String, dynamic>?;
      if (errors != null && errors.isNotEmpty) {
        final msgs = errors[errors.keys.first] as List<dynamic>;
        throw Exception(msgs.first.toString());
      }
    }
    throw Exception(body['message'] ?? 'Erreur d\'inscription');
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    try { await ApiService().post('auth/logout', {}); } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    ApiService().clearToken();
  }
}
