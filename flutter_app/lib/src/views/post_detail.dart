/// lib/views/post_detail.dart
/// FIX: was an empty shell — now fetches and displays the full post
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/post_model.dart';

class PostDetailScreen extends StatefulWidget {
  final int postId;
  const PostDetailScreen(this.postId, {super.key});
  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late Future<PostModel> _future;

  @override
  void initState() {
    super.initState();
    // fetchPosts returns a list; for detail we fetch all and find by id
    // Ideally backend has GET /posts/{id} — if not, this fallback works
    _future = _fetchPost();
  }

  Future<PostModel> _fetchPost() async {
    final posts = await ApiService().fetchPosts();
    return posts.firstWhere((p) => p.id == widget.postId,
        orElse: () => throw Exception('Post introuvable'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Post', style: TextStyle(color: Colors.white))),
      body: FutureBuilder<PostModel>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}',
                style: const TextStyle(color: Colors.white)));
          }
          final post = snapshot.data!;
          return SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (post.imageUrl?.isNotEmpty == true)
                Image.network(post.imageUrl!, width: double.infinity,
                    fit: BoxFit.cover, height: 250),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(post.title,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(children: [
                    CircleAvatar(
                      radius: 16, backgroundColor: Colors.orange,
                      child: Text(post.userName[0].toUpperCase(),
                          style: const TextStyle(color: Colors.black, fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    Text(post.userName, style: const TextStyle(color: Colors.grey)),
                    const Spacer(),
                    Text(post.createdAt, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ]),
                  const SizedBox(height: 16),
                  Text(post.body, style: const TextStyle(color: Colors.white70, height: 1.6)),
                  const SizedBox(height: 16),
                  Row(children: [
                    const Icon(Icons.star, color: Colors.orange, size: 18),
                    const SizedBox(width: 4),
                    Text('${post.averageRating.toStringAsFixed(1)}/5',
                        style: const TextStyle(color: Colors.white)),
                  ]),
                ]),
              ),
            ]),
          );
        },
      ),
    );
  }
}
