# 🧪 Guide de Test et Déploiement

## ✅ Checklist Complète d'Implémentation

### Backend Laravel

- [x] **routes/api.php**
  - Ajouter route `GET /user` pour utilisateur authentifié
  - Ajouter route `PUT /user` pour mise à jour profil
  - Routes protégées par `auth:sanctum`

- [x] **UserController.php**
  - Méthode `current()` - retourne l'utilisateur authentifié
  - Méthode `updateCurrent()` - met à jour l'utilisateur actuel

- [x] **PostController.php**
  - `store()` accepte `place_name` et `description` (champs Flutter)
  - Map automatiquement vers `title` et `body` (champs Laravel)
  - Valide le rating (0-5)

- [x] **config/sanctum.php**
  - Vérifier configuration CORS
  - Token prefix configuré si nécessaire

### Frontend Flutter

- [x] **pubspec.yaml**
  - Ajouter dépendance `shared_preferences: ^2.2.2`

- [x] **lib/main.dart**
  - `WidgetsFlutterBinding.ensureInitialized()`
  - Appeler `AuthService().initializeToken()` avant `runApp()`

- [x] **lib/src/services/api_service.dart**
  - Singleton `ApiService` avec `setToken()`
  - Méthode `_headers()` ajoute Bearer token automatiquement
  - Méthodes `post()`, `get()`, `put()` avec headers

- [x] **lib/src/services/auth_service.dart**
  - Singleton `AuthService`
  - Sauvegarde token dans `SharedPreferences`
  - Méthodes: `login()`, `register()`, `logout()`, `getCurrentUser()`
  - Initialise token au démarrage

- [x] **lib/src/views/login.dart**
  - Appelle `AuthService.login()`
  - Token sauvegardé automatiquement
  - Navigation vers `/home` sans passer le token

- [x] **lib/src/views/create_post.dart**
  - Récupère token avec `AuthService.getToken()`
  - Vérifie que token existe
  - Utilise token pour `ApiService.createPost()`

- [x] **lib/src/views/profile.dart**
  - `FutureBuilder` appelle `AuthService.getCurrentUser()`
  - Affiche données réelles de l'API
  - Bouton logout appelle `AuthService.logout()`

- [x] **lib/src/views/map_view.dart**
  - Appelle `ApiService.fetchCities()`
  - Affiche liste des lieux avec coordonnées
  - Recherche dans les lieux

- [x] **lib/src/views/activities.dart**
  - Appelle API pour les activités
  - Affiche liste avec prix et localisation
  - Gère erreurs et rechargement

---

## 🧪 Étapes de Test

### 1️⃣ Test Backend Laravel

```bash
# 1. S'assurer que Laravel tourne
php artisan serve --host=192.168.0.164 --port=8000

# 2. Tester l'enregistrement
POST http://192.168.0.164:8000/api/v1/auth/register
Header: Content-Type: application/json
Body: {
  "name": "Test User",
  "email": "test@example.com",
  "password": "password123"
}
Response: { "data": { "user": {...}, "token": "..." } }

# 3. Tester login
POST http://192.168.0.164:8000/api/v1/auth/login
Body: {
  "email": "test@example.com",
  "password": "password123"
}
Response: { "data": { "user": {...}, "token": "3|..." } }

# 4. Tester GET /user (protégé)
GET http://192.168.0.164:8000/api/v1/user
Header: Authorization: Bearer 3|...
Response: { "data": { "id": 1, "name": "Test User", ... } }

# 5. Tester créer un post (protégé)
POST http://192.168.0.164:8000/api/v1/posts
Header: Authorization: Bearer 3|...
Body: {
  "place_name": "Jemaa el-Fna",
  "description": "Amazing place!",
  "rating": 5
}
Response: { "data": { "id": 1, "title": "Jemaa el-Fna", ... }, "201" }

# 6. Tester GET /locations
GET http://192.168.0.164:8000/api/v1/locations
Response: { "data": [...], "links": {...}, "meta": {...} }
```

### 2️⃣ Test Frontend Flutter

#### Phase 1: Authentification

1. **Test Login**
   - Ouvrir l'app
   - Entrer email: `test@example.com` / password: `password123`
   - Cliquer "Se connecter"
   - ✅ Doit naviguer vers `/home`
   - ✅ Token doit être sauvegardé dans SharedPreferences

2. **Vérifier token stocké**
   - À debug/logcat: imprimer `AuthService().getToken()`
   - ✅ Token doit commencer par `3|` (format Sanctum)

3. **Test Logout**
   - Aller dans Profile
   - Cliquer "Se déconnecter"
   - ✅ Doit revenir au LoginScreen
   - ✅ Token doit être supprimé

#### Phase 2: Profil

1. **Test ProfileView**
   - Après login, cliquer sur onglet Profil (page 5)
   - ✅ Doit afficher nom réel de l'API (pas "Arby Isabelle Abraham")
   - ✅ Doit afficher email réel
   - ✅ Vérifier dans Network tab que requête GET `/v1/user` est envoyée

2. **Vérifier headers Authorization**
   - Ouvrir Network tab (DevTools)
   - Faire un refresh du profil
   - ✅ La requête doit avoir un header `Authorization: Bearer <token>`

#### Phase 3: Créer un Post

1. **Test CreatePostScreen**
   - Depuis Feed, cliquer le bouton + orange
   - Remplir: nom du lieu, description, note
   - (Optionnel: URL image)
   - Cliquer "Publier"
   - ✅ Doit naviguer vers Feed
   - ✅ Vérifier requête POST `/v1/posts` avec Authorization header
   - ✅ Post doit s'afficher dans le feed

2. **Vérifier champs**
   - Dans Network tab, vérifier body:
   ```json
   {
     "place_name": "...",
     "description": "...",
     "rating": 5
   }
   ```
   - ✅ Laravel mappe automatiquement vers `title` et `body`

#### Phase 4: Map

1. **Test MapView**
   - Aller dans onglet Carte
   - ✅ Doit charger liste des lieux (pas vide)
   - ✅ Chaque lieu affiche coordonnées: `📍 latitude, longitude`
   - ✅ Vérifier requête GET `/v1/locations`

2. **Test Recherche**
   - Taper dans la barre de recherche
   - ✅ Doit filtrer les lieux en temps réel

#### Phase 5: Activités

1. **Test ActivitiesView**
   - Aller dans onglet Activités
   - ✅ Doit afficher liste des activités
   - ✅ Vérifier requête GET `/v1/activities`
   - ✅ Chaque activité affiche: titre, description, prix, localisation

#### Phase 6: Feed

1. **Test FeedView**
   - Aller dans onglet Accueil
   - ✅ Doit afficher liste des posts
   - ✅ Vérifier requête GET `/v1/posts`
   - ✅ Posts récents doivent s'afficher avec donnéesusers

---

## 🔧 Commandes Utiles

### Laravel

```bash
# Vérifier les routes
php artisan route:list

# Tester une route
php artisan tinker
> User::find(1)->createToken('test')->plainTextToken

# Voir les migrations
php artisan migrate:status

# Seeder données test
php artisan db:seed

# Logs erreurs
tail -f storage/logs/laravel.log
```

### Flutter

```bash
# Lancer app avec logs
flutter run -v

# Logs DevTools
flutter pub global activate devtools
devtools

# Inspecter SharedPreferences
# Dans l'app, utiliser DevTools Storage tab
```

---

## 🐛 Dépannage

| Symptôme | Cause | Solution |
|----------|-------|----------|
| **Apps refuse de se connecter** | IP localhost:8000 incorrecte | Mettre l'IP correcte de la machine (192.168.0.164) |
| **401 Unauthorized** | Token manquant ou expiré | Vérifier SharedPreferences et headers Authorization |
| **Profile affiche "Unknown"** | API retourne pas les bonnes données | Vérifier que POST `/user` retourne `{ "data": { "user": {...} } }` |
| **Pas de posts/lieux** | Pas de données en base | Créer des données via Artisan seeder |
| **"No token found"** | Token pas sauvegardé au login | Vérifier que `AuthService.saveToken()` est appelé |
| **CORS error** | Headers incorrects | ApiService ajoute automatiquement les headers |
| **Crashes au logout** | Erreur suppression token | Vérifier que `clearToken()` gère null |

---

## 📊 Matrice de Requêtes

```
┌─────────────────────────────────────────────────────────────────┐
│ REQUÊTE                           │ TOKEN │ RÉPONSE            │
├─────────────────────────────────────────────────────────────────┤
│ POST /auth/register               │ ✗     │ { user, token }    │
│ POST /auth/login                  │ ✗     │ { user, token }    │
│ POST /auth/logout                 │ ✓     │ { message }        │
│ GET /user (profil)                │ ✓     │ { data: user }     │
│ PUT /user (update)                │ ✓     │ { data: user }     │
│ GET /users/{id}                   │ ✓     │ { data: user }     │
│ PUT /users/{id}                   │ ✓     │ { data: user }     │
│ GET /posts                         │ ✗     │ { data: [...] }    │
│ GET /posts/{id}                   │ ✗     │ { data: {...} }    │
│ POST /posts                        │ ✓     │ { data: post }     │
│ DELETE /posts/{id}                │ ✓     │ { message }        │
│ GET /locations                    │ ✗     │ { data: [...] }    │
│ GET /locations/{id}               │ ✗     │ { data: {...} }    │
│ POST /locations/{id}/ratings      │ ✓     │ { data: rating }   │
│ GET /locations/{id}/ratings       │ ✗     │ { data: [...] }    │
│ GET /activities                   │ ✗     │ { data: [...] }    │
│ GET /activities/{id}              │ ✗     │ { data: {...} }    │
│ POST /activities                  │ ✓     │ { data: activity } │
│ POST /activities/{id}/join        │ ✓     │ { data: [...] }    │
│ POST /activities/{id}/cancel      │ ✓     │ { message }        │
└─────────────────────────────────────────────────────────────────┘
✓ = Requiert token Bearer
✗ = Public
```

---

## 📱 Données de Test

### Utilisateur Test

```json
{
  "name": "Test User",
  "email": "test@example.com",
  "password": "password123"
}
```

### Lieu Test (pour insérer en BD)

```php
// database/seeders/DatabaseSeeder.php
Location::create([
    'name' => 'Jemaa el-Fna',
    'description' => 'Famous square in Marrakech',
    'latitude' => 31.6276,
    'longitude' => -8.0066,
    'address' => 'Jemaa el-Fna, Marrakech',
    'city' => 'Marrakech',
    'country' => 'Morocco'
]);
```

### Activité Test

```php
Activity::create([
    'title' => 'Randonnée Atlas',
    'description' => 'Exploration des montagnes',
    'location_id' => 1,
    'organizer_id' => 1,
    'start_at' => now()->addDays(5),
    'end_at' => now()->addDays(6),
    'capacity' => 10,
    'price' => 450.00
]);
```

---

## 🎉 Résumé des Corrections

| Composant | Avant | Après |
|-----------|-------|-------|
| **Token** | Passé en args | Sauvegardé dans SharedPreferences |
| **Authentification** | Manuelle | Centralisée dans AuthService |
| **Headers API** | Incomplets | Automatiques avec Bearer token |
| **Profil** | Données statiques | Chargé depuis API /user |
| **Carte** | Vide | Affiche lieux avec coordonnées |
| **Activités** | Données d'exemple | Chargées depuis API |
| **Posts** | Champs incompatibles | Mapping automatique place_name→title |
| **Routes protégées** | GET /user manquante | Ajoutée avec UserController.current() |

**Tous les problèmes identifiés ont été corrigés! ✅**

