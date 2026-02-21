# 📝 Changements Exacts - Laravel (Copier-Coller)

## ✅ FICHIER 1: routes/api.php

**Localisation:** `routes/api.php`

**Changement:** Ajouter 2 routes après la ligne `Route::middleware('auth:sanctum')->group(function () {`

### CODE ACTUEL (avant)
```php
Route::middleware('auth:sanctum')->group(function () {
    Route::post('auth/logout', [AuthController::class, 'logout']);

    // User
    Route::get('users/{id}', [UserController::class, 'show']);
    Route::put('users/{id}', [UserController::class, 'update']);
```

### CODE CORRIGÉ (après)
```php
Route::middleware('auth:sanctum')->group(function () {
    Route::post('auth/logout', [AuthController::class, 'logout']);

    // User - Get current authenticated user and update profile
    Route::get('user', [UserController::class, 'current']);
    Route::get('users/{id}', [UserController::class, 'show']);
    Route::put('users/{id}', [UserController::class, 'update']);
    Route::put('user', [UserController::class, 'updateCurrent']);
```

**Différence:**
- ✅ Ligne 1: `Route::get('user', [UserController::class, 'current']);` - **AJOUTER**
- ✅ Ligne 4: `Route::put('user', [UserController::class, 'updateCurrent']);` - **AJOUTER**

---

## ✅ FICHIER 2: app/Http/Controllers/Api/UserController.php

**Localisation:** `app/Http/Controllers/Api/UserController.php`

**Changement:** Remplacer TOUT LE FICHIER par le code ci-dessous

### CODE ACTUEL (avant) - À REMPLACER
```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function show($id)
    {
        $user = User::with('posts')->findOrFail($id);
        return response()->json(['data' => $user]);
    }

    public function update(Request $request, $id)
    {
        $user = User::findOrFail($id);
        $this->authorize('update', $user);
        $data = $request->only(['name','email','avatar_url','bio']);
        $user->update($data);
        return response()->json(['data' => $user]);
    }
}
```

### CODE CORRIGÉ (après) - À COPIER
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

**Changements:**
- ✅ Ajouter la nouvelle méthode `current()` - **LIGNES 14-18**
- ✅ Ajouter la nouvelle méthode `updateCurrent()` - **LIGNES 24-30**
- ✅ Ajouter commentaires pour clarté

---

## ✅ FICHIER 3: app/Http/Controllers/Api/PostController.php

**Localisation:** `app/Http/Controllers/Api/PostController.php`

**Changement:** Remplacer la méthode `store()` uniquement

### CODE ACTUEL (avant) - À REMPLACER
```php
    public function store(Request $request)
    {
        $this->authorize('create', Post::class);
        $data = $request->validate(['title'=>'nullable|string','body'=>'nullable|string','location_id'=>'nullable|exists:locations,id']);
        $data['user_id'] = $request->user()->id;
        $post = Post::create($data);
        return response()->json(['data' => $post], 201);
    }
```

### CODE CORRIGÉ (après) - À COPIER
```php
    public function store(Request $request)
    {
        $this->authorize('create', Post::class);
        $data = $request->validate([
            'title' => 'nullable|string',
            'body' => 'nullable|string',
            'place_name' => 'nullable|string',
            'description' => 'nullable|string',
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

**Changements:**
- ✅ Formater la validation sur plusieurs lignes - **LIGNES 3-10**
- ✅ Ajouter validation pour `place_name` - **LIGNE 6**
- ✅ Ajouter validation pour `description` - **LIGNE 7**
- ✅ Ajouter validation pour `rating` - **LIGNE 10**
- ✅ Ajouter mapping automatique - **LIGNES 13-18**

---

## 🎯 Résumé des Modifications

### routes/api.php
```
+ Route::get('user', [UserController::class, 'current']);
+ Route::put('user', [UserController::class, 'updateCurrent']);
```

### UserController.php
```
+ Méthode current()
+ Méthode updateCurrent()
```

### PostController.php
- **DANS store()**
```
+ Accepter 'place_name' et 'description'
+ Accepter 'rating'
+ Mapper automatiquement place_name → title
+ Mapper automatiquement description → body
```

---

## ⚡ Ordre d'Application

1. ✅ Modifier `PostController.php` - La plus simple
2. ✅ Modifier `UserController.php` - Remplacement complet
3. ✅ Modifier `routes/api.php` - Dernière étape

---

## 🔐 Vérification Post-Implémentation

```bash
# 1. Vérifier que Laravel démarre sans erreur
php artisan serve --host=0.0.0.0 --port=8000

# 2. Lister les routes
php artisan route:list | grep -E "(user|post)"

# Output devrait inclure:
# GET     /api/v1/user           -> UserController@current
# PUT     /api/v1/user           -> UserController@updateCurrent
# POST    /api/v1/posts          -> PostController@store

# 3. Tester avec Postman ou curl:

# GET /user (authentifié)
curl -H "Authorization: Bearer TOKEN" \
     http://192.168.0.164:8000/api/v1/user

# POST /posts (avec champs Flutter)
curl -X POST \
     -H "Authorization: Bearer TOKEN" \
     -H "Content-Type: application/json" \
     -d '{
       "place_name": "Jemaa el-Fna",
       "description": "Amazing",
       "rating": 5
     }' \
     http://192.168.0.164:8000/api/v1/posts
```

---

## ✅ Checklist Finale Laravel

- [ ] Modifier `routes/api.php` - Ajouter 2 routes
- [ ] Modifier `UserController.php` - Remplacer le fichier
- [ ] Modifier `PostController.php` - Remplacer la méthode `store()`
- [ ] Tester les routes avec `php artisan route:list`
- [ ] Tester login avec Postman (récupère token)
- [ ] Tester GET /user (endpoint fonctionne)
- [ ] Tester POST /posts avec champs Flutter (accepte les champs)
- [ ] Pas d'erreurs dans `storage/logs/laravel.log`

**Dès que tout passe, Laravel est prêt! ✅**

