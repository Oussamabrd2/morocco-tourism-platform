import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../models/post_model.dart';
import '../models/location_model.dart';
import '../models/activity_model.dart';

const String apiBase = 'http://192.168.0.164:8000';

/// Singleton service handling networking for the Flutter app.
class ApiService {
  static final ApiService _instance = ApiService._internal();

  String? token;
  final String baseUrl = '$apiBase/api';

  ApiService._internal();

  factory ApiService() => _instance;

  void setToken(String? newToken) {
    token = newToken;
  }

  void clearToken() {
    token = null;
  }

  Map<String, String> _headers() => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  // ------------------------------------------------------------------
  // low-level helpers
  Future<http.Response> post(String path, Map<String, dynamic> body) {
    return http.post(
      Uri.parse('$baseUrl/$path'),
      headers: _headers(),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> get(String path) {
    return http.get(Uri.parse('$baseUrl/$path'), headers: _headers());
  }

  Future<http.Response> put(String path, Map<String, dynamic> body) {
    return http.put(
      Uri.parse('$baseUrl/$path'),
      headers: _headers(),
      body: jsonEncode(body),
    );
  }

  // ------------------------------------------------------------------
  // high-level public endpoints used across views
  // ------------------------------------------------------------------

  Future<List<PostModel>> fetchPosts() async {
    final uri = Uri.parse('$apiBase/api/v1/posts');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final List posts = data['data'] is List ? data['data'] : [];
      return posts
          .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load posts: ${res.statusCode}');
  }

  Future<List<LocationModel>> fetchLocations() async {
    final uri = Uri.parse('$apiBase/api/v1/locations');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final List locs = data['data'] is List ? data['data'] : [];
      return locs
          .map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load locations: ${res.statusCode}');
  }

  Future<Map<String, dynamic>> createPost({
    required String title,
    required String body,
    required int score,
    File? imageFile,
  }) async {
    final uri = Uri.parse('$baseUrl/v1/posts');
    final request = http.MultipartRequest('POST', uri);
    if (token != null) request.headers['Authorization'] = 'Bearer $token!';
    request.fields['title'] = title;
    request.fields['body'] = body;
    request.fields['score'] = score.toString();
    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
    }
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode == 201 || res.statusCode == 200) {
      return json.decode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to create post: ${res.statusCode} - ${res.body}');
  }

  // ------------------------------------------------------------------
  // activities
  Future<List<ActivityModel>> fetchActivities() async {
    final res = await get('v1/activities');
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final List acts = data['data'] is List ? data['data'] : [];
      return acts
          .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load activities: ${res.statusCode}');
  }

  Future<ActivityModel> fetchActivity(int id) async {
    final res = await get('v1/activities/$id');
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return ActivityModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to load activity: ${res.statusCode}');
  }

  Future<Map<String, dynamic>> joinActivity(int id) async {
    final res = await post('v1/activities/$id/join', {});
    if (res.statusCode == 200) {
      return json.decode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to join activity: ${res.statusCode}');
  }

  Future<Map<String, dynamic>> cancelActivity(int id) async {
    final res = await post('v1/activities/$id/cancel', {});
    if (res.statusCode == 200) {
      return json.decode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to cancel activity: ${res.statusCode}');
  }

  Future<Map<String, dynamic>> createActivity({
    required String title,
    String? description,
    int? capacity,
    double? price,
  }) async {
    final payload = <String, dynamic>{'title': title};
    if (description != null) payload['description'] = description;
    if (capacity != null) payload['capacity'] = capacity;
    if (price != null) payload['price'] = price;
    final res = await post('v1/activities', payload);
    if (res.statusCode == 201 || res.statusCode == 200) {
      return json.decode(res.body) as Map<String, dynamic>;
    }
    throw Exception(
      'Failed to create activity: ${res.statusCode} - ${res.body}',
    );
  }

  // ------------------------------------------------------------------
  // user/profile
  Future<Map<String, dynamic>> getCurrentUser() async {
    final res = await get('v1/user');
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return data['data'] as Map<String, dynamic>;
    }
    throw Exception('Failed to fetch current user: ${res.statusCode}');
  }

  Future<Map<String, dynamic>> updateUser(Map<String, dynamic> fields) async {
    final res = await put('v1/user', fields);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return data['data'] as Map<String, dynamic>;
    }
    throw Exception('Failed to update user: ${res.statusCode} - ${res.body}');
  }
}
