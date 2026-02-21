import 'package:flutter/material.dart';

class PostDetailScreen extends StatelessWidget {
  final int postId;
  const PostDetailScreen(this.postId, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Post')),
      body: Center(child: Text('Détails du post #$postId')),
    );
  }
}
