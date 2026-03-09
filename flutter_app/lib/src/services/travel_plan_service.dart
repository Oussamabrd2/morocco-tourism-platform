/// lib/services/travel_plan_service.dart
import 'dart:convert';
import '../models/travel_plan_model.dart';
import 'api_service.dart';

class TravelPlanService {
  static final TravelPlanService _instance = TravelPlanService._internal();
  factory TravelPlanService() => _instance;
  TravelPlanService._internal();

  /// Fetches a travel plan from Laravel.
  /// GET /api/v1/travel-plan?ville=Marrakech&days=3
  Future<TravelPlan> generate({
    required String ville,
    required int days,
  }) async {
    final response = await ApiService().get(
      'travel-plan?ville=${Uri.encodeComponent(ville)}&days=$days',
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return TravelPlan.fromJson(body);
    }

    if (response.statusCode == 404) {
      throw Exception(body['message'] ?? 'Aucun lieu trouvé pour cette ville');
    }

    throw Exception(body['message'] ?? 'Erreur lors de la génération du plan');
  }
}
