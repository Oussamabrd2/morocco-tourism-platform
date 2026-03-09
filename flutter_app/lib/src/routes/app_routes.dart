/// lib/app_routes.dart
import 'package:flutter/material.dart';
import '../views/login.dart';
import '../views/signup.dart';
import '../views/home.dart';
import '../views/create_post.dart';
import '../views/google_login.dart';
import '../views/welcome.dart';

final Map<String, WidgetBuilder> appRoutes = {
  // NB: '/' n'est plus ici — SplashScreen est défini comme `home:` dans main.dart
  '/welcome':      (_) => const WelcomeScreen(),
  '/login':        (_) => const LoginScreen(),
  '/signup':       (_) => const SignupScreen(),
  '/home':         (_) => const HomeScreen(),
  '/create':       (_) => const CreatePostScreen(),
  '/google-login': (_) => const GoogleLoginPage(),
};
