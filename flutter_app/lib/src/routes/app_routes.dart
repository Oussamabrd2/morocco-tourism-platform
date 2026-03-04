/// lib/app_routes.dart
// FIX: was importing flutter/widgets.dart — must be material.dart
import 'package:flutter/material.dart';
import '../views/login.dart';
import '../views/signup.dart';
import '../views/home.dart';
import '../views/create_post.dart';
import '../views/google_login.dart';
import '../views/welcome.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (_) => const WelcomeScreen(),
  '/welcome': (_) => const WelcomeScreen(),
  '/login': (_) => const LoginScreen(),
  '/signup': (_) => const SignupScreen(),
  '/home': (_) => const HomeScreen(),
  '/create': (_) => const CreatePostScreen(),
  '/google-login': (_) => const GoogleLoginPage(),
};
