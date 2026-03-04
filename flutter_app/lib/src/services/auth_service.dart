import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'dart:convert';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return jsonDecode(userJson) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> saveToken(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user));
    ApiService().setToken(token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    ApiService().clearToken();
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  Future<void> initializeToken() async {
    final token = await getToken();
    if (token != null) {
      ApiService().setToken(token);
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final api = ApiService();
    final response = await api.post('v1/auth/login', {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final token = body['data']['token'] as String;
      final user = body['data']['user'] as Map<String, dynamic>;

      await saveToken(token, user);

      return {'success': true, 'user': user, 'token': token};
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Login failed');
    }
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String gender,
  ) async {
    final api = ApiService();
    final response = await api.post('v1/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'gender': gender,
    });

    if (response.statusCode == 201) {
      final body = jsonDecode(response.body);
      final token = body['data']['token'] as String;
      final user = body['data']['user'] as Map<String, dynamic>;

      await saveToken(token, user);

      return {'success': true, 'user': user, 'token': token};
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Registration failed');
    }
  }

  Future<void> logout() async {
    await clearToken();
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final api = ApiService();
    final response = await api.get('v1/user');

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final user = body['data'] as Map<String, dynamic>;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user));

      return user;
    } else {
      throw Exception('Failed to fetch current user');
    }
  }
}
