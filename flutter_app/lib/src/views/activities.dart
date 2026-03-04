/// lib/views/activities.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/activity_model.dart';
import 'activity_detail.dart';
import 'create_activity.dart';

class ActivitiesView extends StatefulWidget {
  const ActivitiesView({super.key});
  @override
  State<ActivitiesView> createState() => _ActivitiesViewState();
}

class _ActivitiesViewState extends State<ActivitiesView> {
  late Future<List<ActivityModel>> _future;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _future = ApiService().fetchActivities();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final user = await AuthService().getUser();
    if (mounted) setState(() => _userRole = user?['role']?.toString());
  }

  Future<void> _onRefresh() async =>
      setState(() => _future = ApiService().fetchActivities());

  bool get _canCreate => _userRole == 'organizer' || _userRole == 'admin';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Activités & Expériences',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
      ),
      floatingActionButton: _canCreate
          ? FloatingActionButton(
              backgroundColor: Colors.orange,
              onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CreateActivityScreen()))
                  .then((_) => _onRefresh()),
              child: const Icon(Icons.add, color: Colors.black),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: Colors.orange,
        child: FutureBuilder<List<ActivityModel>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.orange));
            }
            if (snapshot.hasError) {
              return _errorState();
            }
            final activities = snapshot.data ?? [];
            if (activities.isEmpty) {
              return const Center(
                  child: Text('Aucune activité', style: TextStyle(color: Colors.grey)));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: activities.length,
              itemBuilder: (_, i) => _card(activities[i]),
            );
          },
        ),
      ),
    );
  }

  Widget _card(ActivityModel a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade900),
      ),
      child: InkWell(
        onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => ActivityDetailScreen(a.id)))
            .then((_) => _onRefresh()),
        borderRadius: BorderRadius.circular(15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15))),
            child: const Icon(Icons.terrain, color: Colors.orange, size: 40),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(a.title,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                if (a.price != null)
                  Text('${a.price!.toStringAsFixed(0)} DH',
                      style: const TextStyle(
                          color: Colors.orange, fontWeight: FontWeight.w900, fontSize: 16)),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.location_on_outlined, color: Colors.grey, size: 14),
                const SizedBox(width: 4),
                Text(a.locationName ?? 'Non spécifié',
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const Spacer(),
                const Icon(Icons.group_outlined, color: Colors.grey, size: 14),
                const SizedBox(width: 4),
                Text('${a.participantsCount}/${a.capacity ?? '∞'}',
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ]),
              if (a.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(a.description,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70)),
              ],
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _errorState() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.wifi_off, color: Colors.grey, size: 48),
      const SizedBox(height: 10),
      const Text('Impossible de charger les activités',
          style: TextStyle(color: Colors.white)),
      TextButton(
          onPressed: _onRefresh,
          child: const Text('Réessayer', style: TextStyle(color: Colors.orange))),
    ]),
  );
}
