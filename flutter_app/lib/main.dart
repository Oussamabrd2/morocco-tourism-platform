import 'package:flutter/material.dart';
import 'src/routes/app_routes.dart';
import 'src/views/welcome.dart';
import 'src/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final auth = AuthService();
  await auth.initializeToken();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ziarat - Tourisme Social',
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: Colors.orange,
          secondary: Colors.orangeAccent,
          surface: const Color(0xFF121212),
          error: Colors.redAccent,
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onSurface: Colors.white,
          onError: Colors.white,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
      ),
      routes: appRoutes,
    );
  }
}
