/// lib/models/activity_model.dart
class ActivityModel {
  final int id;
  final String title;
  final String description;
  final String? locationName;
  final String? organizerName;
  final int? capacity;
  final double? price;
  final int participantsCount;
  final bool userJoined;
  final String? startAt;
  final String? endAt;

  ActivityModel({
    required this.id,
    required this.title,
    required this.description,
    this.locationName,
    this.organizerName,
    this.capacity,
    this.price,
    this.participantsCount = 0,
    this.userJoined = false,
    this.startAt,
    this.endAt,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    final loc = json['location'] as Map<String, dynamic>?;
    final org = json['organizer'] as Map<String, dynamic>?;
    return ActivityModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      locationName: loc?['name'] as String?,
      organizerName: org?['name'] as String?,
      capacity: json['capacity'] as int?,
      price: (json['price'] as num?)?.toDouble(),
      participantsCount: (json['participants_count'] as int?) ?? 0,
      userJoined: json['user_joined'] as bool? ?? false,
      startAt: json['start_at'] as String?,
      endAt: json['end_at'] as String?,
    );
  }

  bool get isFull => capacity != null && participantsCount >= capacity!;

  int get seatsRemaining =>
      capacity != null ? capacity! - participantsCount : 0;
}
