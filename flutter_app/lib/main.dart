import 'package:flutter/material.dart';
import 'src/routes/app_routes.dart';
import 'src/views/login.dart';
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
      title: 'Tourisme Social',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
      routes: routes,
    );
  }
}
