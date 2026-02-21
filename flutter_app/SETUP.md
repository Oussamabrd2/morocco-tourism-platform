# Flutter App Setup & Connection Guide

## Issue: Demo home page instead of custom screens

**Fix Applied**: Updated `main.dart` to use your custom routes and LoginScreen as entry point.

## Required Steps on Your Device

### 1. Update Backend URL in ApiService

Edit `lib/src/services/api_service.dart` and replace the baseUrl:

```dart
// For local development (Windows/Mac/Linux machine on same network):
ApiService(baseUrl: 'http://192.168.1.X:8000/api')

// Or use your actual machine IP. To find it:
// Windows: Run `ipconfig` in terminal, look for IPv4 address (e.g., 192.168.1.100)
```

### 2. Install Dependencies

From `flutter_app/` directory:

```bash
flutter pub get
```

### 3. Check if `http` package is in pubspec.yaml

Edit `flutter_app/pubspec.yaml` and ensure this exists under `dependencies`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
```

Then run:
```bash
flutter pub get
```

### 4. Run on Phone/Emulator

From `flutter_app/` directory:

```bash
# Show available devices
flutter devices

# Run on Android device or emulator
flutter run

# Or for iOS (macOS only)
flutter run -d "device-name"
```

### 5. Troubleshooting

**"Connection refused" or "Network error":**
- Ensure backend is running: `php artisan serve` (or via XAMPP)
- Check your machine IP: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
- Phone and backend must be on **same WiFi network**
- Update baseUrl in `api_service.dart` with correct IP

**"No 'http' package":**
- Run `flutter pub get` in flutter_app directory

**Demo home page still showing:**
- Clear Flutter build cache: `flutter clean`
- Rebuild: `flutter run`

### 6. Default Login Credentials (After Backend Setup)

Once your Laravel backend is running and seeded with test data, use the app to register a new account or login with seeded users.

**Quick Reference for Backend**:
```powershell
# From PFE directory:
php artisan serve                    # Run backend (default: localhost:8000)
php artisan tinker                   # Test data creation
```
