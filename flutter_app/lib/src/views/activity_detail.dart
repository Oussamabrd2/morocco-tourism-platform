/// lib/views/activity_detail.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/activity_model.dart';

class ActivityDetailScreen extends StatefulWidget {
  final int activityId;
  const ActivityDetailScreen(this.activityId, {super.key});
  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  late Future<ActivityModel> _future;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _future = ApiService().fetchActivity(widget.activityId);
  }

  void _reload() => setState(() => _future = ApiService().fetchActivity(widget.activityId));

  Future<void> _join() async {
    final token = await AuthService().getToken();
    if (token == null) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ApiService().joinActivity(widget.activityId);
      if (!mounted) return;
      _reload();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vous avez rejoint l\'activité !'),
              backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString().replaceFirst('Exception: ', '')}')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _cancel() async {
    setState(() => _isLoading = true);
    try {
      // FIX: now calls DELETE via cancelActivity
      await ApiService().cancelActivity(widget.activityId);
      if (!mounted) return;
      _reload();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Participation annulée')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          title: const Text('Détails', style: TextStyle(color: Colors.white))),
      body: FutureBuilder<ActivityModel>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('Erreur: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
                TextButton(
                    onPressed: _reload,
                    child: const Text('Réessayer', style: TextStyle(color: Colors.orange))),
              ]),
            );
          }
          final a = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a.title,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              if (a.organizerName != null) ...[
                const SizedBox(height: 6),
                Text('Par ${a.organizerName}', style: const TextStyle(color: Colors.grey)),
              ],
              const SizedBox(height: 16),
              if (a.description.isNotEmpty)
                Text(a.description,
                    style: const TextStyle(color: Colors.white70, height: 1.5)),
              const SizedBox(height: 20),
              _infoRow(Icons.location_on, a.locationName ?? 'Non spécifié'),
              const SizedBox(height: 8),
              _infoRow(Icons.group,
                  '${a.participantsCount} participants${a.capacity != null ? ' / ${a.capacity} max' : ''}'),
              if (a.price != null) ...[
                const SizedBox(height: 8),
                _infoRow(Icons.payments, '${a.price!.toStringAsFixed(0)} DH',
                    valueColor: Colors.orange),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : (a.userJoined ? _cancel : _join),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: a.userJoined ? Colors.red.shade800 : Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 24, width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(a.userJoined ? 'Annuler participation' : 'Rejoindre',
                          style: TextStyle(
                              color: a.userJoined ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold)),
                ),
              ),
            ]),
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, {Color? valueColor}) => Row(children: [
    Icon(icon, color: Colors.orange, size: 20),
    const SizedBox(width: 8),
    Text(text, style: TextStyle(color: valueColor ?? Colors.white)),
  ]);
}
