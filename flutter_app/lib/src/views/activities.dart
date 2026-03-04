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

  // Only organizer or admin see the create button
  bool get _canCreate =>
      _userRole == 'organizer' || _userRole == 'admin';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Activités & Expériences',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22),
        ),
      ),
      floatingActionButton: _canCreate
          ? FloatingActionButton.extended(
              backgroundColor: Colors.orange,
              icon: const Icon(Icons.add, color: Colors.black),
              label: const Text('Créer',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CreateActivityScreen()),
              ).then((_) => _onRefresh()),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: Colors.orange,
        child: FutureBuilder<List<ActivityModel>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.orange));
            }
            if (snapshot.hasError) {
              return _errorState(snapshot.error.toString());
            }
            final activities = snapshot.data ?? [];
            if (activities.isEmpty) {
              return const Center(
                child: Text('Aucune activité disponible',
                    style: TextStyle(color: Colors.grey)),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: activities.length,
              itemBuilder: (_, i) => _ActivityCard(
                activity: activities[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          ActivityDetailScreen(activities[i].id)),
                ).then((_) => _onRefresh()),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _errorState(String error) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.wifi_off, color: Colors.grey, size: 52),
            const SizedBox(height: 12),
            const Text('Impossible de charger les activités',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(error,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 3),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _onRefresh,
              icon: const Icon(Icons.refresh, color: Colors.black),
              label: const Text('Réessayer',
                  style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange),
            ),
          ]),
        ),
      );
}

// ── Activity Card widget ───────────────────────────────────────────────────

class _ActivityCard extends StatelessWidget {
  final ActivityModel activity;
  final VoidCallback onTap;

  const _ActivityCard({required this.activity, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final a = activity;
    final capacityText = a.capacity != null
        ? '${a.participantsCount}/${a.capacity}'
        : '${a.participantsCount}';

    final seatsText = a.seatsRemaining != null
        ? (a.isFull ? 'Complet' : '${a.seatsRemaining} places restantes')
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: a.isFull ? Colors.red.shade900 : Colors.grey.shade900),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header banner
          Container(
            height: 90,
            width: double.infinity,
            decoration: BoxDecoration(
              color: a.isFull
                  ? Colors.red.shade900.withOpacity(0.3)
                  : Colors.grey.shade900,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Stack(alignment: Alignment.center, children: [
              const Icon(Icons.terrain, color: Colors.orange, size: 40),
              if (a.isFull)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('COMPLET',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              if (a.userJoined)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade700,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('INSCRIT',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
            ]),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // Title + price
              Row(children: [
                Expanded(
                  child: Text(a.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold)),
                ),
                if (a.price != null && a.price! > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange.withOpacity(0.4)),
                    ),
                    child: Text(
                      '${a.price!.toStringAsFixed(0)} DH',
                      style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Gratuit',
                        style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ),
              ]),

              const SizedBox(height: 10),

              // Location + capacity
              Row(children: [
                const Icon(Icons.location_on_outlined,
                    color: Colors.grey, size: 14),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(a.locationName ?? 'Non spécifié',
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 13),
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.group_outlined,
                    color: Colors.grey, size: 14),
                const SizedBox(width: 4),
                Text(capacityText,
                    style: TextStyle(
                        color: a.isFull ? Colors.redAccent : Colors.grey,
                        fontSize: 13,
                        fontWeight: a.isFull
                            ? FontWeight.bold
                            : FontWeight.normal)),
              ]),

              // Seats remaining
              if (seatsText != null) ...[
                const SizedBox(height: 6),
                _SeatsBar(activity: a),
                const SizedBox(height: 4),
                Text(seatsText,
                    style: TextStyle(
                        color: a.isFull
                            ? Colors.redAccent
                            : Colors.grey.shade400,
                        fontSize: 11)),
              ],

              // Description
              if (a.description.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(a.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 13, height: 1.4)),
              ],
            ]),
          ),
        ]),
      ),
    );
  }
}

// ── Capacity progress bar ─────────────────────────────────────────────────

class _SeatsBar extends StatelessWidget {
  final ActivityModel activity;
  const _SeatsBar({required this.activity});

  @override
  Widget build(BuildContext context) {
    if (activity.capacity == null || activity.capacity == 0) {
      return const SizedBox.shrink();
    }
    final ratio = (activity.participantsCount / activity.capacity!).clamp(0.0, 1.0);
    final color = ratio >= 1.0
        ? Colors.red
        : ratio >= 0.75
            ? Colors.orange
            : Colors.green;

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: ratio,
        backgroundColor: Colors.grey.shade800,
        valueColor: AlwaysStoppedAnimation<Color>(color),
        minHeight: 5,
      ),
    );
  }
}
