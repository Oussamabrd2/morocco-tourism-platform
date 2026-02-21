# 📝 Codes Complets Corrigés

## Backend Laravel

### 1. routes/api.php

```php
<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\PostController;
use App\Http\Controllers\Api\LocationController;
use App\Http\Controllers\Api\RatingController;
use App\Http\Controllers\Api\ActivityController;

Route::prefix('v1')->group(function () {
    // Auth publiques
    Route::post('auth/register', [AuthController::class, 'register']);
    Route::post('auth/login', [AuthController::class, 'login']);

    Route::middleware('auth:sanctum')->group(function () {
        Route::post('auth/logout', [AuthController::class, 'logout']);

        // User - Utilisateur courant + autres utilisateurs
        Route::get('user', [UserController::class, 'current']);
        Route::get('users/{id}', [UserController::class, 'show']);
        Route::put('users/{id}', [UserController::class, 'update']);
        Route::put('user', [UserController::class, 'updateCurrent']);

        // Posts
        Route::apiResource('posts', PostController::class)->only(['index','show','store','destroy']);

        // Ratings
        Route::post('locations/{id}/ratings', [RatingController::class, 'store']);

        // Activities
        Route::post('activities', [ActivityController::class, 'store']);
        Route::post('activities/{id}/join', [ActivityController::class, 'join']);
        Route::post('activities/{id}/cancel', [ActivityController::class, 'cancel']);
    });

    // Public endpoints
    Route::get('posts', [PostController::class, 'index']);
    Route::get('posts/{id}', [PostController::class, 'show']);
    Route::get('locations', [LocationController::class, 'index']);
    Route::get('locations/{id}', [LocationController::class, 'show']);
    Route::get('locations/{id}/ratings', [RatingController::class, 'index']);
    Route::get('activities', [ActivityController::class, 'index']);
    Route::get('activities/{id}', [ActivityController::class, 'show']);
});
```

### 2. app/Http/Controllers/Api/UserController.php

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;

class UserController extends Controller
{
    /**
     * Get the current authenticated user
     */
    public function current(Request $request)
    {
        return response()->json(['data' => $request->user()]);
    }

    /**
     * Get a specific user by ID with their posts
     */
    public function show($id)
    {
        $user = User::with('posts')->findOrFail($id);
        return response()->json(['data' => $user]);
    }

    /**
     * Update current authenticated user's profile
     */
    public function updateCurrent(Request $request)
    {
        $user = $request->user();
        $data = $request->only(['name', 'email', 'avatar_url', 'bio']);
        $user->update($data);
        return response()->json(['data' => $user]);
    }

    /**
     * Update a specific user (authorization required)
     */
    public function update(Request $request, $id)
    {
        $user = User::findOrFail($id);
        $this->authorize('update', $user);
        $data = $request->only(['name', 'email', 'avatar_url', 'bio']);
        $user->update($data);
        return response()->json(['data' => $user]);
    }
}
```

### 3. app/Http/Controllers/Api/PostController.php

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Post;
use Illuminate\Http\Request;

class PostController extends Controller
{
    public function index(Request $request)
    {
        $posts = Post::with(['user','images','location'])->latest()->paginate(10);
        return response()->json($posts);
    }

    public function show($id)
    {
        $post = Post::with(['user','images','location','comments'])->findOrFail($id);
        return response()->json(['data' => $post]);
    }

    public function store(Request $request)
    {
        $this->authorize('create', Post::class);
        
        // Accepte les deux formats (Laravel ou Flutter)
        $data = $request->validate([
            'title' => 'nullable|string',
            'body' => 'nullable|string',
            'place_name' => 'nullable|string',        // Format Flutter
            'description' => 'nullable|string',       // Format Flutter
            'location_id' => 'nullable|exists:locations,id',
            'rating' => 'nullable|numeric|min:0|max:5',
        ]);
        
        $data['user_id'] = $request->user()->id;
        
        // Map Flutter fields to Laravel if needed
        if (isset($data['place_name']) && !isset($data['title'])) {
            $data['title'] = $data['place_name'];
        }
        if (isset($data['description']) && !isset($data['body'])) {
            $data['body'] = $data['description'];
        }
        
        $post = Post::create($data);
        return response()->json(['data' => $post], 201);
    }

    public function destroy(Request $request, $id)
    {
        $post = Post::findOrFail($id);
        $this->authorize('delete', $post);
        $post->delete();
        return response()->json(['message' => 'Deleted']);
    }
}
```

### 4. app/Http/Controllers/Api/AuthController.php (sans changement)

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\RegisterRequest;
use App\Http\Requests\LoginRequest;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function register(RegisterRequest $request)
    {
        try {
            $data = $request->validated();

            $user = User::create([
                'name' => $data['name'],
                'email' => $data['email'],
                'password' => Hash::make($data['password']),
            ]);

            $token = $user->createToken('api-token')->plainTextToken;

            return response()->json(['data' => ['user' => $user, 'token' => $token]], 201);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Registration failed: ' . $e->getMessage()], 500);
        }
    }

    public function login(LoginRequest $request)
    {
        try {
            $creds = $request->validated();

            $user = User::where('email', $creds['email'])->first();

            if (!$user || !Hash::check($creds['password'], $user->password)) {
                return response()->json(['message' => 'Invalid credentials'], 401);
            }

            $token = $user->createToken('api-token')->plainTextToken;

            return response()->json(['data' => ['user' => $user, 'token' => $token]], 200);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Login failed: ' . $e->getMessage()], 500);
        }
    }

    public function logout(Request $request)
    {
        try {
            $request->user()->currentAccessToken()->delete();
            return response()->json(['message' => 'Logged out'], 200);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Logout failed'], 500);
        }
    }
}
```

---

## Frontend Flutter

### 1. pubspec.yaml (dépendances)

```yaml
name: flutter_app
description: "A new Flutter project."
publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: ^3.10.4

dependencies:
  flutter:
    sdk: flutter

  cupertino_icons: ^1.0.8
  http: ^1.1.0
  shared_preferences: ^2.2.2  # ✅ Pour persistance du token

dev_dependencies:
  flutter_test:
    sdk: flutter

  flutter_lints: ^6.0.0

flutter:
  uses-material-design: true
```

### 2. lib/main.dart

```dart
import 'package:flutter/material.dart';
import 'src/routes/app_routes.dart';
import 'src/views/login.dart';
import 'src/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize token from SharedPreferences on app startup
  final auth = AuthService();
  await auth.initializeToken();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tourisme Social',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      routes: routes,
    );
  }
}
```

### 3. lib/src/services/api_service.dart

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

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

  // Authenticated requests
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

  // Static methods for public endpoints
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
```

### 4. lib/src/services/auth_service.dart

```dart
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

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final api = ApiService();
    final response = await api.post('v1/auth/register', {
      'name': name,
      'email': email,
      'password': password,
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
```

### 5. lib/src/views/login.dart

```dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _login() async {
    if (_email.text.isEmpty || _password.text.isEmpty) {
      setState(() => _error = 'Email et mot de passe requis');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final auth = AuthService();
      final result = await auth.login(_email.text.trim(), _password.text);
      
      if (!mounted) return;
      
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Erreur: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'E-mail'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _password,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text('Se connecter'),
                  ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              child: const Text("S'inscrire"),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 6. lib/src/views/profile.dart (voir fichier principal pour le code complet)

Voir [ProfileView corrigée](../flutter_app/lib/src/views/profile.dart) - Charge l'utilisateur depuis API

### 7. lib/src/views/map_view.dart (voir fichier principal pour le code complet)

Voir [MapView corrigée](../flutter_app/lib/src/views/map_view.dart) - Affiche lieux avec coordonnées

### 8. lib/src/views/activities.dart (voir fichier principal pour le code complet)

Voir [ActivitiesView corrigée](../flutter_app/lib/src/views/activities.dart) - Charge activités depuis API

### 9. lib/src/views/create_post.dart (voir fichier principal pour le code complet)

Voir [CreatePostScreen corrigée](../flutter_app/lib/src/views/create_post.dart) - Utilise token de SharedPreferences

---

## 🔑 Points Clés de la Correction

| Fichier | Problème | Solution |
|---------|----------|----------|
| `ApiService` | Confusion statique/instance | Singleton avec `setToken()` |
| `AuthService` | Pas de persistance token | `SharedPreferences` + sauvegarde auto |
| `LoginScreen` | Token passé dans args | Sauvegardé directement par `AuthService` |
| `PostController` | Champs incorrects | Map `place_name` → `title` |
| `UserController` | Pas de route `/user` | Ajout méthode `current()` |
| `routes/api.php` | Route `/user` manquante | Ajout route GET/PUT `user` |
| `ProfileView` | Données statiques | FutureBuilder + API call |
| `MapView` | Pas de lieux | Affiche liste avec coordonnées |
| `ActivitiesView` | Données statiques | FutureBuilder + API call |
| `CreatePostScreen` | dummy_token | Récupère token depuis AuthService |

