/// lib/models/post_model.dart
/// Single Post model — replaces the duplicate in post.dart and api_service.dart

const String _apiBase = 'http://192.168.0.164:8000/api/v1';

class PostModel {
  final int id;
  final String title;
  final String body;
  final String? imageUrl;
  final String userName;
  final String? userAvatarUrl;
  final String? locationName;
  final double averageRating;
  final String createdAt;

  PostModel({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.userName,
    this.userAvatarUrl,
    this.locationName,
    this.averageRating = 0,
    this.createdAt = '',
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final loc  = json['location'] as Map<String, dynamic>?;
    String? img = json['image_url'] as String?;
    if (img != null && img.isNotEmpty && !img.startsWith('http')) {
      img = '$_apiBase$img';
    }
    return PostModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      imageUrl: img,
      userName: user?['name'] as String? ?? 'Inconnu',
      userAvatarUrl: user?['avatar_url'] as String?,
      locationName: loc?['name'] as String?,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0,
      createdAt: _formatDate(json['created_at'] as String?),
    );
  }

  static String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final dt = DateTime.tryParse(iso);
    return dt != null ? '${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')}/${dt.year}' : '';
  }
}
