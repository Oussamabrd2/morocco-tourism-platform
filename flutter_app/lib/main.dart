import 'package:flutter/material.dart';
import 'src/services/auth_service.dart';
import 'src/routes/app_routes.dart';
import 'src/views/welcome.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService().initializeToken();
  runApp(const ZiaratApp());
}

class ZiaratApp extends StatelessWidget {
  const ZiaratApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ziarat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.orange,
          secondary: Colors.orangeAccent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF1A1A1A),
          contentTextStyle: TextStyle(color: Colors.white),
        ),
      ),
      // SplashScreen devient le point d'entrée — elle décide où aller
      home: const SplashScreen(),
      routes: appRoutes,
    );
  }
}

/// SplashScreen — vérifie si l'utilisateur est connecté au démarrage
/// - Token valide   → /home
/// - Token invalide → /welcome
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    _checkAuth();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    // Attendre l'animation + vérification token
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 1400)),
      _verifyToken(),
    ]);
  }

  Future<void> _verifyToken() async {
    try {
      // Vérifie si token existe localement
      final token = await AuthService().getToken();

      if (token == null) {
        // Pas de token → welcome
        _navigate('/welcome');
        return;
      }

      // Vérifie si le token est encore valide côté Laravel
      final isValid = await AuthService().verifyTokenWithServer();

      if (!mounted) return;

      if (isValid) {
        _navigate('/home');
      } else {
        // Token expiré ou supprimé → nettoyer et aller au login
        await AuthService().logout();
        _navigate('/welcome');
      }
    } catch (_) {
      // Erreur réseau → aller au welcome par sécurité
      _navigate('/welcome');
    }
  }

  void _navigate(String route) {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fade,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orangeAccent, width: 2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.explore_outlined,
                    color: Colors.orangeAccent, size: 52),
              ),
              const SizedBox(height: 20),
              const Text(
                'ZIARAT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 6,
                ),
              ),
              Container(height: 3, width: 36, color: Colors.orangeAccent),
              const SizedBox(height: 48),
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.orangeAccent,
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
