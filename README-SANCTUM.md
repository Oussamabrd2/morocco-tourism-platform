Sanctum Setup Notes

1) Install Sanctum (run locally):

```powershell
composer require laravel/sanctum
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
php artisan migrate
```

2) Kernel

The project includes `app/Http/Kernel.php` with `EnsureFrontendRequestsAreStateful` in the `api` middleware group. This is useful for first-party SPA setups; for mobile token-based auth you can keep this and use personal access tokens.

3) User model

`app/Models/User.php` already uses `HasApiTokens`.

4) Routes

API routes are versioned under `/api/v1/*` and protected with `auth:sanctum` where required.

5) Testing

Feature tests were added to `tests/Feature/AuthTest.php`. Run tests with:

```powershell
php artisan test
```

6) Mobile clients

For mobile apps prefer token-based authentication: use `$user->createToken('name')->plainTextToken` and send `Authorization: Bearer <token>` in requests. Store tokens securely on device (e.g., `flutter_secure_storage`).
