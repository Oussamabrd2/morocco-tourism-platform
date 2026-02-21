import 'user.dart';

class Post {
  final int id;
  final User user;
  final String? title;
  final String? body;

  Post({required this.id, required this.user, this.title, this.body});

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json['id'],
    user: User.fromJson(json['user']),
    title: json['title'],
    body: json['body'],
  );
}
