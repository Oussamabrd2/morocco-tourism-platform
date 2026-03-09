/// lib/models/travel_plan_model.dart

class TravelPlace {
  final int id;
  final String nom;
  final String ville;
  final String categorie;
  final double latitude;
  final double longitude;
  final double duree;

  const TravelPlace({
    required this.id,
    required this.nom,
    required this.ville,
    required this.categorie,
    required this.latitude,
    required this.longitude,
    required this.duree,
  });

  factory TravelPlace.fromJson(Map<String, dynamic> json) => TravelPlace(
        id:        json['id'] as int,
        nom:       json['nom'] as String,
        ville:     json['ville'] as String,
        categorie: json['categorie'] as String,
        latitude:  (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        duree:     (json['duree'] as num?)?.toDouble() ?? 1.0,
      );
}

class TravelPlan {
  final String ville;
  final int days;
  final int totalPlaces;
  /// key = "day_1", "day_2", ...
  final Map<String, List<TravelPlace>> plan;

  const TravelPlan({
    required this.ville,
    required this.days,
    required this.totalPlaces,
    required this.plan,
  });

  factory TravelPlan.fromJson(Map<String, dynamic> json) {
    final rawPlan = json['plan'] as Map<String, dynamic>;
    final plan = rawPlan.map((key, value) => MapEntry(
          key,
          (value as List<dynamic>)
              .map((p) => TravelPlace.fromJson(p as Map<String, dynamic>))
              .toList(),
        ));

    return TravelPlan(
      ville:       json['ville'] as String,
      days:        json['days'] as int,
      totalPlaces: json['total_places'] as int,
      plan:        plan,
    );
  }

  /// Returns days sorted: day_1, day_2, ...
  List<MapEntry<String, List<TravelPlace>>> get sortedDays {
    final entries = plan.entries.toList();
    entries.sort((a, b) {
      final numA = int.tryParse(a.key.replaceAll('day_', '')) ?? 0;
      final numB = int.tryParse(b.key.replaceAll('day_', '')) ?? 0;
      return numA.compareTo(numB);
    });
    return entries;
  }
}
