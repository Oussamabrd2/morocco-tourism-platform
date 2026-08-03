/// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/post_model.dart';
import '../models/location_model.dart';
import '../models/activity_model.dart';

// URL configurable avec : flutter run --dart-define=API_BASE_URL=http://ADRESSE_IP:8000/api/v1
const String kApiBase = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8000/api/v1',
);

class ApiService {
  // FIX: Proper singleton
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  void setToken(String? t) => _token = t;
  void clearToken() => _token = null;
  String? get token => _token;

  // FIX: All requests go through here — token always injected
  Map<String, String> _headers({bool isJson = true}) => {
    'Accept': 'application/json',
    if (isJson) 'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // ─── Base HTTP methods ───────────────────────────────────────────────────

  Future<http.Response> get(String path) =>
      http.get(Uri.parse('$kApiBase/$path'), headers: _headers());

  Future<http.Response> post(String path, Map<String, dynamic> body) =>
      http.post(Uri.parse('$kApiBase/$path'),
          headers: _headers(), body: jsonEncode(body));

  Future<http.Response> put(String path, Map<String, dynamic> body) =>
      http.put(Uri.parse('$kApiBase/$path'),
          headers: _headers(), body: jsonEncode(body));

  // FIX: DELETE method was missing — used by cancelActivity
  Future<http.Response> delete(String path) =>
      http.delete(Uri.parse('$kApiBase/$path'), headers: _headers());

  // ─── Auth ────────────────────────────────────────────────────────────────

  // FIX: login/register return structured data — caller (AuthService) saves token
  Future<http.Response> login(String email, String password) =>
      post('auth/login', {'email': email, 'password': password});

  Future<http.Response> register(
    String name, String email, String password, String gender, {
    String? birthDate,
  }) {
    final body = <String, dynamic>{
      'name':     name,
      'email':    email,
      'password': password,
      'gender':   gender,
    };
    if (birthDate != null) body['birth_date'] = birthDate;
    return post('auth/register', body);
  }

  // ─── User ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getCurrentUser() async {
    final res = await get('user');
    _assertOk(res, 'Utilisateur non trouvé');
    return (jsonDecode(res.body) as Map)['data'] as Map<String, dynamic>;
  }

  Future<void> uploadAvatar(dynamic imageFile) async {
    final uri = Uri.parse('${kApiBase}/user/avatar');
    final req = http.MultipartRequest('POST', uri);
    final headers = _headers(isJson: false);
    req.headers.addAll(headers);
    req.files.add(await http.MultipartFile.fromPath('avatar', imageFile.path));
    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode != 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      throw Exception(body['message'] ?? 'Erreur upload avatar');
    }
  }

  Future<Map<String, dynamic>> updateUser(Map<String, dynamic> updates) async {
    final res = await put('user', updates);
    _assertOk(res, 'Échec de la mise à jour du profil');
    return (jsonDecode(res.body) as Map)['data'] as Map<String, dynamic>;
  }

  // ─── Posts ───────────────────────────────────────────────────────────────

  Future<List<PostModel>> fetchPosts({int page = 1}) async {
    final res = await get('posts?page=$page');
    _assertOk(res, 'Erreur lors du chargement des posts');
    final list = (jsonDecode(res.body) as Map)['data'] as List? ?? [];
    return list.map((e) => PostModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PostModel> createPost({
    required String title,
    required String body,
    int score = 5,
    int? locationId,
    File? imageFile,
  }) async {
    final uri = Uri.parse('$kApiBase/posts');
    final request = http.MultipartRequest('POST', uri);

    // FIX: inject auth header but remove Content-Type (multipart sets its own)
    final headers = _headers(isJson: false);
    request.headers.addAll(headers);

    request.fields['title'] = title;
    request.fields['body'] = body;
    request.fields['score'] = score.toString();
    if (locationId != null) request.fields['location_id'] = locationId.toString();
    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    final res = await http.Response.fromStream(await request.send());
    if (res.statusCode == 401) throw Exception('Session expirée');
    _assertCreated(res, 'Échec de la création du post');
    return PostModel.fromJson((jsonDecode(res.body) as Map)['data'] as Map<String, dynamic>);
  }

  // ─── Locations ───────────────────────────────────────────────────────────

  Future<List<LocationModel>> fetchLocations({int page = 1}) async {
    final res = await get('locations?page=$page');
    _assertOk(res, 'Erreur lors du chargement des lieux');
    final list = (jsonDecode(res.body) as Map)['data'] as List? ?? [];
    return list.map((e) => LocationModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ─── Activities ───────────────────────────────────────────────────────────

  Future<List<ActivityModel>> fetchActivities({int page = 1}) async {
    final res = await get('activities?page=$page');
    _assertOk(res, 'Erreur lors du chargement des activités');
    final list = (jsonDecode(res.body) as Map)['data'] as List? ?? [];
    return list.map((e) => ActivityModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ActivityModel> fetchActivity(int id) async {
    final res = await get('activities/$id');
    _assertOk(res, 'Activité introuvable');
    return ActivityModel.fromJson((jsonDecode(res.body) as Map)['data'] as Map<String, dynamic>);
  }

  Future<ActivityModel> createActivity({
    required String title,
    String? description,
    int? capacity,
    double? price,
  }) async {
    final res = await post('activities', {
      'title': title,
      if (description != null) 'description': description,
      if (capacity != null) 'capacity': capacity,
      if (price != null) 'price': price,
    });
    if (res.statusCode == 401) throw Exception('Session expirée');
    if (res.statusCode == 403) throw Exception('Permission refusée');
    _assertCreated(res, 'Échec de la création de l\'activité');
    return ActivityModel.fromJson((jsonDecode(res.body) as Map)['data'] as Map<String, dynamic>);
  }

  Future<void> joinActivity(int id) async {
    final res = await post('activities/$id/join', {});
    if (res.statusCode == 401) throw Exception('Connectez-vous d\'abord');
    _assertOk(res, 'Impossible de rejoindre l\'activité');
  }

  // FIX: was POST, must be DELETE to match REST convention
  Future<void> cancelActivity(int id) async {
    final res = await delete('activities/$id/join');
    _assertOk(res, 'Impossible d\'annuler la participation');
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  void _assertOk(http.Response res, String msg) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      String? serverMsg;
      try {
        serverMsg = (jsonDecode(res.body) as Map)['message'] as String?;
      } catch (_) {}
      throw Exception(serverMsg ?? msg);
    }
  }

  void _assertCreated(http.Response res, String msg) {
    if (res.statusCode != 200 && res.statusCode != 201) {
      String? serverMsg;
      try {
        serverMsg = (jsonDecode(res.body) as Map)['message'] as String?;
      } catch (_) {}
      throw Exception(serverMsg ?? msg);
    }
  }
}
