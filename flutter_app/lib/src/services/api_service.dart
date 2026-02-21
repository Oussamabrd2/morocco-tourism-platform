import 'dart:convert';
import 'package:http/http.dart' as http;

// The API base URL
const String apiBase = 'http://192.168.0.164:8000';

class Post {
  final int id;
  final String userName;
  final String placeName;
  final String description;
  final double rating;
  final String? image;
  final String createdAt;

  Post({
    required this.id,
    required this.userName,
    required this.placeName,
    required this.description,
    required this.rating,
    this.image,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json['id'] as int,
    userName: json['user_name'] ?? json['user']?['name'] ?? 'Unknown',
    placeName: json['place_name'] ?? json['title'] ?? '',
    description: json['description'] ?? json['body'] ?? '',
    rating: (json['rating'] is num)
        ? (json['rating'] as num).toDouble()
        : double.tryParse('${json['rating']}') ?? 0.0,
    image: json['image'] as String?,
    createdAt: json['created_at'] ?? '',
  );
}

class City {
  final int id;
  final String name;
  final String description;
  final String? image;
  final double rating;
  final double? latitude;
  final double? longitude;

  City({
    required this.id,
    required this.name,
    required this.description,
    this.image,
    required this.rating,
    this.latitude,
    this.longitude,
  });

  factory City.fromJson(Map<String, dynamic> json) => City(
    id: json['id'] as int,
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    image: json['image'] as String?,
    rating: (json['rating'] is num)
        ? (json['rating'] as num).toDouble()
        : double.tryParse('${json['rating']}') ?? 0.0,
    latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
    longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
  );
}

class ApiService {
  static final ApiService _instance = ApiService._internal();

  String? token;
  final String baseUrl = '$apiBase/api';

  ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  /// Set token after login
  void setToken(String? newToken) {
    token = newToken;
  }

  /// Clear token on logout
  void clearToken() {
    token = null;
  }

  /// Build headers with authorization if token exists
  Map<String, String> _headers() => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  // ============== Authenticated Requests ==============

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

  // ============== Public Posts ==============

  static Future<List<Post>> fetchPosts() async {
    final uri = Uri.parse('$apiBase/api/v1/posts');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final List posts = data['data'] is List ? data['data'] : [];
      return posts.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load posts: ${res.statusCode}');
  }

  // ============== Locations (Cities) ==============

  static Future<List<City>> fetchCities() async {
    final uri = Uri.parse('$apiBase/api/v1/locations');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final List locations = data['data'] is List ? data['data'] : [];
      return locations.map((e) => City.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load locations: ${res.statusCode}');
  }

  // ============== Create Post ==============

  static Future<Map<String, dynamic>> createPost({
    required String placeName,
    required String description,
    required double rating,
    String? image,
    required String token,
  }) async {
    final uri = Uri.parse('$apiBase/api/v1/posts');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = jsonEncode({
      'place_name': placeName,
      'description': description,
      'rating': rating,
      if (image != null && image.isNotEmpty) 'image': image,
    });
    final res = await http.post(uri, headers: headers, body: body);
    if (res.statusCode == 201 || res.statusCode == 200) {
      return json.decode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to create post: ${res.statusCode} - ${res.body}');
  }
}
