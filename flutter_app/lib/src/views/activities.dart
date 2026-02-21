import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const String apiBase = 'http://192.168.0.164:8000';

class Activity {
  final int id;
  final String title;
  final String description;
  final String? location;
  final double? price;
  final int capacity;

  Activity({
    required this.id,
    required this.title,
    required this.description,
    this.location,
    this.price,
    this.capacity = 0,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as int,
      title: json['title'] ?? 'Activité',
      description: json['description'] ?? '',
      location: json['location']?['name'] as String?,
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : null,
      capacity: json['capacity'] ?? 0,
    );
  }
}

class ActivitiesView extends StatefulWidget {
  const ActivitiesView({super.key});

  @override
  State<ActivitiesView> createState() => _ActivitiesViewState();
}

class _ActivitiesViewState extends State<ActivitiesView> {
  late Future<List<Activity>> _activitiesFuture;

  @override
  void initState() {
    super.initState();
    _activitiesFuture = _fetchActivities();
  }

  Future<List<Activity>> _fetchActivities() async {
    try {
      final uri = Uri.parse('$apiBase/api/v1/activities');
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List activities = data['data'] is List ? data['data'] : [];
        return activities
            .map((e) => Activity.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Erreur: ${res.statusCode}');
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Activités & Expériences',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<Activity>>(
        future: _activitiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Erreur: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _activitiesFuture = _fetchActivities();
                      });
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final activities = snapshot.data ?? [];

          if (activities.isEmpty) {
            return const Center(
              child: Text(
                'Aucune activité trouvée',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: activities.length,
            itemBuilder: (context, index) => _buildActivityCard(activities[index]),
          );
        },
      ),
    );
  }

  Widget _buildActivityCard(Activity activity) {
    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: CircleAvatar(
          backgroundColor: Colors.orangeAccent.withAlpha(51),
          child: const Icon(Icons.tour, color: Colors.orangeAccent),
        ),
        title: Text(
          activity.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              activity.description,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (activity.location != null)
              Text(
                '📍 ${activity.location}',
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
          ],
        ),
        trailing: activity.price != null
            ? Text(
                '${activity.price!.toStringAsFixed(0)} DH',
                style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
        onTap: () {
          // TODO: Navigate to activity detail
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${activity.title} - ID: ${activity.id}')),
          );
        },
      ),
    );
  }
}
