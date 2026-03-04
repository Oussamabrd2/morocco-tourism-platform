/// lib/models/location_model.dart
class LocationModel {
  final int id;
  final String name;
  final String description;
  final String? imageUrl;
  final double averageRating;
  final int reviewsCount;
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? country;

  LocationModel({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.averageRating,
    this.reviewsCount = 0,
    this.latitude,
    this.longitude,
    this.city,
    this.country,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0,
      reviewsCount: (json['reviews_count'] as int?) ?? 0,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      city: json['city'] as String?,
      country: json['country'] as String?,
    );
  }
}
