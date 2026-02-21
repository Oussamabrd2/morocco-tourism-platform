import 'package:flutter/widgets.dart';
import '../views/login.dart';
import '../views/signup.dart';
import '../views/home.dart';
import '../views/create_post.dart';
import '../views/google_login.dart';

final routes = <String, WidgetBuilder>{
  '/login': (c) => LoginScreen(),
  '/signup': (c) => SignupScreen(),
  '/home': (c) => HomeScreen(),
  '/create': (c) => CreatePostScreen(),
  '/google-login': (c) => GoogleLoginPage(),
};
