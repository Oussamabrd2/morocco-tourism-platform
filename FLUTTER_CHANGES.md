# 📱 Changements Exacts - Flutter (Copier-Coller)

## ✅ ÉTAPE 1: pubspec.yaml

**Localisation:** `flutter_app/pubspec.yaml`

**Changement:** Ajouter une seule ligne dans `dependencies`

### CODE ACTUEL (avant)
```yaml
dependencies:
  flutter:
    sdk: flutter

  cupertino_icons: ^1.0.8
  http: ^1.1.0
```

### CODE CORRIGÉ (après)
```yaml
dependencies:
  flutter:
    sdk: flutter

  cupertino_icons: ^1.0.8
  http: ^1.1.0
  shared_preferences: ^2.2.2  # ✅ AJOUTER CETTE LIGNE
```

**Ensuite dans terminal:**
```bash
flutter pub get
```

---

## ✅ ÉTAPE 2: lib/main.dart

**Localisation:** `flutter_app/lib/main.dart`

**Changement:** Remplacer entire file

### CODE ACTUEL (avant) - À REMPLACER
```dart
import 'package:flutter/material.dart';
import 'src/routes/app_routes.dart';
import 'src/views/login.dart';

void main() {
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
      home: LoginScreen(),
      routes: routes,
    );
  }
}
```

### CODE CORRIGÉ (après) - À COPIER
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

**Changements:**
- ✅ Ajouter import `AuthService` - **LIGNE 4**
- ✅ Changer `void main()` en `void main() async` - **LIGNE 6**
- ✅ Ajouter `WidgetsFlutterBinding.ensureInitialized()` - **LIGNE 7**
- ✅ Ajouter initialisation du token - **LIGNES 8-10**
- ✅ Ajouter `const` à `LoginScreen()` - **LIGNE 20**

---

## ✅ ÉTAPE 3: lib/src/services/api_service.dart

**Localisation:** `flutter_app/lib/src/services/api_service.dart`

**Changement:** Remplacer entire file

Le fichier est très long, mais j'ai déjà modifié le fichier directement. Vérifiez que:

✅ `ApiService` est un **singleton**
✅ Propriété `String? token;`
✅ Méthode `setToken(String? newToken)`
✅ Méthode `_headers()` qui ajoute le bearer token
✅ Les méthodes `post()`, `get()`, `put()` utilisent `_headers()`

---

## ✅ ÉTAPE 4: lib/src/services/auth_service.dart

**Localisation:** `flutter_app/lib/src/services/auth_service.dart`

**Changement:** Remplacer entire file

### CODE ACTUEL (avant) - À REMPLACER
```dart
import 'api_service.dart';

class AuthService {
  final ApiService api;
  AuthService(this.api);

  Future<dynamic> login(String email, String password) async {
    final resp = await api.post('api/v1/auth/login', {
      'email': email,
      'password': password,
    });
    return resp;
  }

  Future<dynamic> register(String name, String email, String password) async {
    final resp = await api.post('api/v1/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });
    return resp;
  }
}
```

### CODE CORRIGÉ (après) - À COPIER
**Voir le fichier déjà modifié!** J'ai déjà corrigé ce fichier directement.

Vérifiez qu'il contient:
- ✅ Singleton avec `_instance` et `factory`
- ✅ Constantes `_tokenKey` et `_userKey`
- ✅ Méthode `getToken()` - récupère de SharedPreferences
- ✅ Méthode `saveToken(token, user)` - sauvegarde dans SharedPreferences
- ✅ Méthode `login()` - appelle API et sauvegarde
- ✅ Méthode `getCurrentUser()` - appelle `/v1/user`
- ✅ Méthode `logout()` - nettoie SharedPreferences

---

## ✅ ÉTAPE 5: lib/src/views/login.dart

**Localisation:** `flutter_app/lib/src/views/login.dart`

**Changement:** Remplacer entire file

Vérifiez qu'il:
- ✅ Importe `AuthService`
- ✅ Appelle `await auth.login(email, password)`
- ✅ Navigation vers `/home` SANS passer le token en arguments
- ✅ Gère les erreurs correctement

✅ **J'ai déjà modifié ce fichier directement!**

---

## ✅ ÉTAPE 6: lib/src/views/create_post.dart

**Localisation:** `flutter_app/lib/src/views/create_post.dart`

**Changement:** Modifier la fonction `_submitPost()`

### CODE ACTUEL (avant) - À REMPLACER
```dart
  Future<void> _submitPost() async {
    // ...
    try {
      // TODO: Get token from auth state/local storage
      const String token = 'dummy_token';  // ❌ PROBLÈME!
      await ApiService.createPost(
        placeName: _placeName.text.trim(),
        description: _description.text.trim(),
        rating: _rating,
        image: _imageUrl.text.isNotEmpty ? _imageUrl.text : null,
        token: token,
      );
```

### CODE CORRIGÉ (après) - À COPIER
```dart
  Future<void> _submitPost() async {
    // ...
    try {
      // Get token from AuthService ✅
      final auth = AuthService();
      final token = await auth.getToken();
      
      if (token == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vous devez être connecté')),
        );
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
```

**Changements:**
- ✅ Ajouter import `AuthService` en haut
- ✅ Remplacer `const String token = 'dummy_token'` par récupération réelle
- ✅ Ajouter check si token est null
- ✅ Rediriger vers login si pas de token

✅ **J'ai déjà modifié ce fichier directement!**

---

## ✅ ÉTAPE 7: lib/src/views/profile.dart

**Localisation:** `flutter_app/lib/src/views/profile.dart`

**Changement:** Remplacer entire file

### CODE ACTUEL (avant) - À REMPLACER
```dart
class ProfileView extends StatelessWidget {
  // Données hardcodées
  const CircleAvatar(
    backgroundImage: NetworkImage('https://via.placeholder.com/150'),
  ),
  const Text('Arby Isabelle Abraham', // ❌ Hardcodé
```

### CODE CORRIGÉ (après) - À COPIER

Vérifiez qu'il:
- ✅ Extends `StatefulWidget` (pas `StatelessWidget`)
- ✅ Utilise `FutureBuilder<Map<String, dynamic>>`
- ✅ Appelle `AuthService().getCurrentUser()`
- ✅ Affiche données réelles de l'API
- ✅ Bouton logout appelle `AuthService().logout()`

✅ **J'ai déjà modifié ce fichier directement!**

---

## ✅ ÉTAPE 8: lib/src/views/map_view.dart

**Localisation:** `flutter_app/lib/src/views/map_view.dart`

**Changement:** Remplacer entire file

### CODE ACTUEL (avant) - À REMPLACER
```dart
class MapView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey[900],
        child: const Center(
          child: Icon(Icons.map_outlined, size: 100), // ❌ Icône vide
```

### CODE CORRIGÉ (après) - À COPIER

Vérifiez qu'il:
- ✅ Extends `StatefulWidget`
- ✅ Appelle `ApiService.fetchCities()`
- ✅ Affiche liste des lieux avec coordonnées
- ✅ Inclut barre de recherche
- ✅ Gère loading et erreurs

✅ **J'ai déjà modifié ce fichier directement!**

---

## ✅ ÉTAPE 9: lib/src/views/activities.dart

**Localisation:** `flutter_app/lib/src/views/activities.dart`

**Changement:** Remplacer entire file

### CODE ACTUEL (avant) - À REMPLACER
```dart
class ActivitiesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          _buildActivityCard('Randonnée Atlas', '450 DH', Icons.terrain), // ❌ Données d'exemple
          _buildActivityCard('Surf à Taghazout', '200 DH', Icons.waves),
```

### CODE CORRIGÉ (après) - À COPIER

Vérifiez qu'il:
- ✅ Extends `StatefulWidget`
- ✅ Appelle API `/v1/activities`
- ✅ Utilise `FutureBuilder`
- ✅ Affiche liste réelle des activités
- ✅ Gère loading et erreurs

✅ **J'ai déjà modifié ce fichier directement!**

---

## 🎯 Résumé des Fichiers à Modifier

### Fichiers ENTIÈREMENT REMPLACÉS (J'ai déjà fait!)
- [x] lib/src/services/api_service.dart
- [x] lib/src/services/auth_service.dart ← NOUVEAU!
- [x] lib/src/views/login.dart
- [x] lib/src/views/profile.dart
- [x] lib/src/views/map_view.dart
- [x] lib/src/views/activities.dart

### Fichiers PARTIELLEMENT MODIFIÉS
- [x] lib/main.dart - Ajouter import + initialisation
- [x] lib/src/views/create_post.dart - Remplacer `_submitPost()`
- [x] flutter_app/pubspec.yaml - Ajouter `shared_preferences`

---

## ⚡ Vérification Post-Implémentation

```dart
// 1. Vérifier compilation
flutter pub get
flutter analyze  // Ne doit pas avoir d'erreurs

// 2. Tester dans l'app
// - Login avec : test@example.com / password123
// - Vérifier que vous êtes redirigé vers /home
// - Aller dans Profile - doit afficher vrai nom de l'API
// - Aller dans Carte - doit afficher lieux réels
// - Aller dans Activités - doit afficher activités réelles
// - Créer un post - doit fonctionner et s'afficher
// - Logout - doit revenir à login
// - Fermer l'app et relancer - doit rester connecté!
```

---

## ✅ Checklist Finale Flutter

- [ ] Ajouter `shared_preferences` dans pubspec.yaml
- [ ] Lancer `flutter pub get`
- [ ] Modifier lib/main.dart - Initialiser token
- [ ] Vérifier lib/src/services/api_service.dart - Singleton + token
- [ ] Vérifier lib/src/services/auth_service.dart - SharedPreferences
- [ ] Vérifier lib/src/views/login.dart - AuthService.login()
- [ ] Vérifier lib/src/views/create_post.dart - Récupérer token
- [ ] Vérifier lib/src/views/profile.dart - Charger API
- [ ] Vérifier lib/src/views/map_view.dart - Charger lieux
- [ ] Vérifier lib/src/views/activities.dart - Charger activités
- [ ] Lancer `flutter analyze` - Pas d'erreurs
- [ ] Tester le login - Doit aller à /home
- [ ] Vérifier que token est stocké
- [ ] Tester fermeture/réouverture - Doit rester connecté

**Quand tout passe, Flutter est prêt! ✅**

---

## 📁 Structure des Fichiers

```
flutter_app/
├── pubspec.yaml ← ✅ Ajouter shared_preferences
├── lib/
│   ├── main.dart ← ✅ Modifier (initialiser token)
│   └── src/
│       ├── services/
│       │   ├── api_service.dart ← ✅ Déjà modifié
│       │   └── auth_service.dart ← ✅ NOUVEAU!
│       ├── views/
│       │   ├── login.dart ← ✅ Déjà modifié
│       │   ├── profile.dart ← ✅ Déjà modifié
│       │   ├── map_view.dart ← ✅ Déjà modifié
│       │   ├── activities.dart ← ✅ Déjà modifié
│       │   ├── create_post.dart ← ✅ Déjà modifié
│       │   └── ...
│       └── routes/
│           └── app_routes.dart
```

