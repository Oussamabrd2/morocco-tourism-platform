# 📋 Corrections du Système d'Authentification Sanctum + Flutter

## 🔍 Problèmes Identifiés et Corrigés

### **❌ Problèmes Flutter**

1. **Token non stocké en persistant**
   - ❌ Le token était passé par arguments à la navigation mais jamais sauvegardé
   - ✅ FIXÉ: Utilisation de `SharedPreferences` avec `AuthService`

2. **Token non utilisé dans les requêtes API**
   - ❌ CreatePostScreen utilisait `'dummy_token'` en dur
   - ❌ ApiService avait une confusion entre méthodes statiques et instance
   - ✅ FIXÉ: Singleton `ApiService` avec `setToken()` centralisé

3. **Headers Authorization manquants**
   - ❌ Les headers `Authorization: Bearer token` n'étaient pas systématiquement inclus
   - ✅ FIXÉ: Méthode `_headers()` qui ajoute le token automatiquement si présent

4. **ProfileView affichait des données statiques**
   - ❌ Pas d'appel à l'API `/user`
   - ✅ FIXÉ: `FutureBuilder` qui charge `AuthService.getCurrentUser()`

5. **MapView ne chargeait pas les lieux**
   - ❌ Affichait juste une icône de carte vide
   - ✅ FIXÉ: Appel à `ApiService.fetchCities()` et affichage des coordonnées

6. **ActivitiesView affichait données d'exemple**
   - ❌ Liste statique en dur
   - ✅ FIXÉ: Récupération depuis API `/v1/activities`

### **❌ Problèmes Laravel**

1. **PostController.store() n'acceptait pas les bons champs**
   - ❌ Attendait `title` et `body`, mais Flutter envoyait `place_name` et `description`
   - ✅ FIXÉ: Validation accepte et mappe les deux ensembles de champs

2. **Route GET /user manquante**
   - ❌ Pas de endpoint pour récupérer l'utilisateur actuel authentifié
   - ✅ FIXÉ: Ajout de `Route::get('user', [UserController::class, 'current'])`

3. **UserController incomplet**
   - ❌ Pas de méthode `current()` ni `updateCurrent()`
   - ✅ FIXÉ: Ajout de ces deux méthodes

---

## ✨ Solutions Implémentées

### **Laravel Routes** (`routes/api.php`)

```php
Route::prefix('v1')->group(function () {
    // Auth publiques
    Route::post('auth/register', [AuthController::class, 'register']);
    Route::post('auth/login', [AuthController::class, 'login']);

    // Routes protégées par Sanctum
    Route::middleware('auth:sanctum')->group(function () {
        Route::post('auth/logout', [AuthController::class, 'logout']);

        // User - ✅ NOUVEAU: Route pour utilisateur courant
        Route::get('user', [UserController::class, 'current']);
        Route::get('users/{id}', [UserController::class, 'show']);
        Route::put('users/{id}', [UserController::class, 'update']);
        Route::put('user', [UserController::class, 'updateCurrent']);

        // Posts
        Route::apiResource('posts', PostController::class)->only(['index','show','store','destroy']);

        // Autres routes protégées
        Route::post('locations/{id}/ratings', [RatingController::class, 'store']);
        Route::post('activities', [ActivityController::class, 'store']);
        Route::post('activities/{id}/join', [ActivityController::class, 'join']);
        Route::post('activities/{id}/cancel', [ActivityController::class, 'cancel']);
    });

    // Endpoints publics
    Route::get('posts', [PostController::class, 'index']);
    Route::get('posts/{id}', [PostController::class, 'show']);
    Route::get('locations', [LocationController::class, 'index']);
    Route::get('locations/{id}', [LocationController::class, 'show']);
    Route::get('locations/{id}/ratings', [RatingController::class, 'index']);
    Route::get('activities', [ActivityController::class, 'index']);
    Route::get('activities/{id}', [ActivityController::class, 'show']);
});
```

### **UserController** - Méthodes Ajoutées

```php
/**
 * Get the current authenticated user
 */
public function current(Request $request)
{
    return response()->json(['data' => $request->user()]);
}

/**
 * Update current authenticated user
 */
public function updateCurrent(Request $request)
{
    $user = $request->user();
    $data = $request->only(['name', 'email', 'avatar_url', 'bio']);
    $user->update($data);
    return response()->json(['data' => $user]);
}
```

### **PostController.store()** - Validation Améliorée

```php
public function store(Request $request)
{
    $this->authorize('create', Post::class);
    $data = $request->validate([
        'title' => 'nullable|string',
        'body' => 'nullable|string',
        'place_name' => 'nullable|string',        // ✅ Champs Flutter
        'description' => 'nullable|string',       // ✅ Champs Flutter
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
```

---

## 🎯 Flutter - Services Corrigés

### **AuthService** - Gestion Token + SharedPreferences

```dart
class AuthService {
  static final AuthService _instance = AuthService._internal();
  
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  AuthService._internal();
  factory AuthService() => _instance;

  // ✅ Récupérer token sauvegardé
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // ✅ Sauvegarder token après login
  Future<void> saveToken(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user));
    ApiService().setToken(token);
  }

  // ✅ Login complet
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

  // ✅ Récupérer utilisateur courant depuis API
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

  // ✅ Nettoyer à la déconnexion
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    ApiService().clearToken();
  }
}
```

### **ApiService** - Singleton avec Token Centralisé

```dart
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

  // ✅ Headers avec Authorization automatique
  Map<String, String> _headers() => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  // ✅ Requêtes avec headers automatiques
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
}
```

### **LoginScreen** - Stockage Token

```dart
void _login() async {
  setState(() => _loading = true);
  try {
    final auth = AuthService();
    // ✅ Le token est automatiquement sauvegardé par AuthService.login()
    final result = await auth.login(_email.text.trim(), _password.text);
    
    if (!mounted) return;
    // ✅ Navigation simple, token est déjà en SharedPreferences
    Navigator.pushReplacementNamed(context, '/home');
  } catch (e) {
    setState(() => _error = 'Erreur: ${e.toString()}');
  } finally {
    if (mounted) setState(() => _loading = false);
  }
}
```

### **CreatePostScreen** - Token depuis SharedPreferences

```dart
Future<void> _submitPost() async {
  setState(() => _isLoading = true);
  try {
    final auth = AuthService();
    // ✅ Récupérer le token sauvegardé
    final token = await auth.getToken();
    
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    await ApiService.createPost(
      placeName: _placeName.text.trim(),
      description: _description.text.trim(),
      rating: _rating,
      image: _imageUrl.text.isNotEmpty ? _imageUrl.text : null,
      token: token,
    );
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post créé avec succès!'))
    );
    Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
  }
}
```

### **ProfileView** - Charger depuis API

```dart
class _ProfileViewState extends State<ProfileView> {
  late Future<Map<String, dynamic>> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _loadUser();
  }

  Future<Map<String, dynamic>> _loadUser() async {
    final auth = AuthService();
    var user = await auth.getUser(); // Cache d'abord
    if (user != null) return user;
    
    // Sinon, appel API
    return await auth.getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // Gestion d'erreur...
        }
        
        final user = snapshot.data ?? {};
        final name = user['name'] ?? 'Utilisateur';
        final email = user['email'] ?? '';
        
        return Center(
          child: Text(name), // ✅ Données réelles de l'API
        );
      },
    );
  }
}
```

### **MapView** - Charger Lieux avec Coordonnées

```dart
class _MapViewState extends State<MapView> {
  late Future<List<City>> _locationsFuture;

  @override
  void initState() {
    super.initState();
    _locationsFuture = ApiService.fetchCities();
  }

  Widget _buildLocationCard(City location) {
    return Card(
      child: ListTile(
        title: Text(location.name),
        subtitle: Column(
          children: [
            Text(location.description),
            // ✅ Afficher les coordonnées
            if (location.latitude != null && location.longitude != null)
              Text(
                '📍 ${location.latitude!.toStringAsFixed(4)}, ${location.longitude!.toStringAsFixed(4)}',
              ),
          ],
        ),
      ),
    );
  }
}
```

### **ActivitiesView** - Charger depuis API

```dart
class _ActivitiesViewState extends State<ActivitiesView> {
  late Future<List<Activity>> _activitiesFuture;

  Future<List<Activity>> _fetchActivities() async {
    final uri = Uri.parse('$apiBase/api/v1/activities');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final List activities = data['data'] is List ? data['data'] : [];
      return activities
        .map((e) => Activity.fromJson(e as Map<String, dynamic>))
        .toList();
    }
    throw Exception('Failed to load activities');
  }
}
```

---

## 📦 Dépendances Ajoutées

**pubspec.yaml:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  http: ^1.1.0
  shared_preferences: ^2.2.2  # ✅ NOUVEAU pour persistance token
```

---

## 🔐 Flux d'Authentification Complet

```
1. Utilisateur login avec email/password
   ↓
2. LoginScreen appelle AuthService.login()
   ↓
3. AuthService envoie requête API POST /v1/auth/login
   ↓
4. Laravel retourne { data: { user, token } }
   ↓
5. AuthService sauvegarde token dans SharedPreferences
   ↓
6. AuthService met à jour ApiService.setToken(token)
   ↓
7. Navigation vers HomeScreen
   ↓
8. Toutes les requêtes incluent "Authorization: Bearer token"
   ↓
9. API retourne données - requêtes réussies ✅
```

---

## ⚠️ Erreurs Possibles et Solutions

| Erreur | Cause | Solution |
|--------|-------|----------|
| **401 Unauthorized** | Token manquant ou expiré | Vérifier SharedPreferences, se reconnecter |
| **Posts ne s'affichent pas** | Champs mal mappés (place_name vs title) | PostController map les deux formats ✅ |
| **Profile affiche données statiques** | ProfileView n'appelle pas API | Utilise AuthService.getCurrentUser() ✅ |
| **Map vide** | MapView ne charge pas les lieux | Appel à ApiService.fetchCities() ✅ |
| **"No token found"** | Token pas sauvegardé au login | LoginScreen utilise AuthService ✅ |
| **CORS error** | Headers manquants | ApiService ajoute automatiquement ✅ |

---

## ✅ Checklist d'Implémentation

- [x] AuthService avec SharedPreferences
- [x] ApiService singleton avec token centralisé
- [x] LoginScreen sauvegarde token
- [x] CreatePostScreen récupère token
- [x] ProfileView charge depuis API
- [x] MapView affiche lieux avec coordonnées
- [x] ActivitiesView charge depuis API
- [x] Laravel routes protégées par Sanctum
- [x] UserController.current() pour /user
- [x] PostController accepte champs Flutter
- [x] Headers Authorization automatiques

