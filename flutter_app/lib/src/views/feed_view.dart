/// lib/views/feed_view.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/post_model.dart';
import 'create_post.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key});
  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  late Future<List<PostModel>> _futurePosts;

  @override
  void initState() {
    super.initState();
    _futurePosts = ApiService().fetchPosts();
  }

  Future<void> _onRefresh() async =>
      setState(() => _futurePosts = ApiService().fetchPosts());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Ziarat Feed',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
        actions: [IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {})],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePostScreen()))
            .then((_) => _onRefresh()),
        child: const Icon(Icons.add_a_photo, color: Colors.black),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: Colors.orange,
        backgroundColor: const Color(0xFF1A1A1A),
        child: FutureBuilder<List<PostModel>>(
          future: _futurePosts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.orange));
            }
            if (snapshot.hasError) {
              return _errorState();
            }
            final posts = snapshot.data ?? [];
            if (posts.isEmpty) {
              return const Center(child: Text('Aucun post', style: TextStyle(color: Colors.grey)));
            }
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (_, i) => _postCard(posts[i]),
            );
          },
        ),
      ),
    );
  }

  Widget _postCard(PostModel post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: const Color(0xFF121212),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              CircleAvatar(
                backgroundColor: Colors.orange,
                backgroundImage: (post.userAvatarUrl?.isNotEmpty == true)
                    ? NetworkImage(post.userAvatarUrl!) : null,
                child: (post.userAvatarUrl?.isNotEmpty != true)
                    ? Text(post.userName.isNotEmpty ? post.userName[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.black))
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(post.userName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(post.createdAt, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ])),
            ]),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(post.title,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
              if (post.locationName != null)
                Text(post.locationName!,
                    style: const TextStyle(color: Colors.orange, fontSize: 12)),
              const SizedBox(height: 4),
              Text(post.body,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  maxLines: 4, overflow: TextOverflow.ellipsis),
            ]),
          ),
          if (post.imageUrl?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Image.network(
                post.imageUrl!,
                width: double.infinity, fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : Container(height: 200, color: const Color(0xFF1A1A1A),
                        child: const Center(child: CircularProgressIndicator(color: Colors.orange))),
                errorBuilder: (_, __, ___) => Container(height: 200, color: const Color(0xFF1A1A1A),
                    child: const Icon(Icons.broken_image, color: Colors.grey, size: 50)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              const Icon(Icons.star, color: Colors.orange, size: 18),
              const SizedBox(width: 4),
              Text('${post.averageRating.toStringAsFixed(1)}/5',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _errorState() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('Erreur de connexion', style: TextStyle(color: Colors.white)),
      TextButton(
          onPressed: _onRefresh,
          child: const Text('Réessayer', style: TextStyle(color: Colors.orange))),
    ]),
  );
}
