/// lib/views/activity_detail.dart
library activity_detail;

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

  void _reload() =>
      setState(() => _future = ApiService().fetchActivity(widget.activityId));

  // ── Join ──────────────────────────────────────────────────────────────────

  Future<void> _join() async {
    // Redirect to login if not authenticated
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
      _showSnack('Vous avez rejoint l\'activité !', Colors.green);
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString().replaceFirst('Exception: ', ''), Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Cancel ────────────────────────────────────────────────────────────────

  Future<void> _cancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Annuler la participation ?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir annuler votre participation ?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Non', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Oui, annuler',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      await ApiService().cancelActivity(widget.activityId);
      if (!mounted) return;
      _reload();
      _showSnack('Participation annulée', null);
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString().replaceFirst('Exception: ', ''), Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, Color? bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: bg ?? const Color(0xFF1A1A1A),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Détails', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<ActivityModel>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }
          if (snapshot.hasError) {
            return _errorState(snapshot.error.toString());
          }
          return _buildContent(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildContent(ActivityModel a) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero banner
          _HeroBanner(activity: a),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  a.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                if (a.organizerName != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        color: Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Organisé par ${a.organizerName}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 20),

                // Info cards
                _InfoGrid(activity: a),

                const SizedBox(height: 20),

                // Capacity bar
                if (a.capacity != null) ...[
                  _CapacitySection(activity: a),
                  const SizedBox(height: 20),
                ],

                // Description
                if (a.description.isNotEmpty) ...[
                  const Text(
                    'À propos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    a.description,
                    style: const TextStyle(
                      color: Colors.white70,
                      height: 1.6,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Action button
                _ActionButton(
                  activity: a,
                  isLoading: _isLoading,
                  onJoin: _join,
                  onCancel: _cancel,
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorState(String error) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, color: Colors.grey, size: 52),
        const SizedBox(height: 12),
        Text(
          'Erreur: $error',
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _reload,
          child: const Text(
            'Réessayer',
            style: TextStyle(color: Colors.orange),
          ),
        ),
      ],
    ),
  );
}

// ── Hero Banner ───────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final ActivityModel activity;
  const _HeroBanner({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      color: activity.isFull
          ? Colors.red.shade900.withValues(alpha: 0.25)
          : Colors.grey.shade900,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.terrain, color: Colors.orange, size: 80),
          if (activity.isFull)
            Positioned.fill(
              child: Container(
                color: Colors.black45,
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade700,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'ACTIVITÉ COMPLÈTE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          if (activity.userJoined)
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade700,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Inscrit',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Info Grid ─────────────────────────────────────────────────────────────

class _InfoGrid extends StatelessWidget {
  final ActivityModel activity;
  const _InfoGrid({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        if (activity.locationName != null)
          _InfoChip(
            icon: Icons.location_on,
            label: activity.locationName!,
            color: Colors.orange,
          ),
        _InfoChip(
          icon: Icons.group,
          label: activity.capacity != null
              ? '${activity.participantsCount} / ${activity.capacity}'
              : '${activity.participantsCount} participants',
          color: activity.isFull ? Colors.red : Colors.blue,
        ),
        if (activity.price != null)
          _InfoChip(
            icon: Icons.payments,
            label: activity.price! > 0
                ? '${activity.price!.toStringAsFixed(0)} DH'
                : 'Gratuit',
            color: activity.price! > 0 ? Colors.orange : Colors.green,
          ),
        if (activity.startAt != null)
          _InfoChip(
            icon: Icons.calendar_today,
            label: _formatDate(activity.startAt!),
            color: Colors.purple,
          ),
      ],
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Capacity Section ──────────────────────────────────────────────────────

class _CapacitySection extends StatelessWidget {
  final ActivityModel activity;
  const _CapacitySection({required this.activity});

  @override
  Widget build(BuildContext context) {
    final ratio = (activity.participantsCount / activity.capacity!).clamp(
      0.0,
      1.0,
    );
    final barColor = ratio >= 1.0
        ? Colors.red
        : ratio >= 0.75
        ? Colors.orange
        : Colors.green;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Participants',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              activity.isFull
                  ? 'Complet'
                  : '${activity.seatsRemaining} place${(activity.seatsRemaining ?? 0) > 1 ? 's' : ''} restante${(activity.seatsRemaining ?? 0) > 1 ? 's' : ''}',
              style: TextStyle(
                color: activity.isFull ? Colors.redAccent : Colors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: Colors.grey.shade800,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${activity.participantsCount} / ${activity.capacity} participants',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}

// ── Action Button ─────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final ActivityModel activity;
  final bool isLoading;
  final VoidCallback onJoin;
  final VoidCallback onCancel;

  const _ActionButton({
    required this.activity,
    required this.isLoading,
    required this.onJoin,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    // Already joined → show cancel button
    if (activity.userJoined) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: isLoading ? null : onCancel,
          icon: isLoading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.cancel_outlined, color: Colors.white),
          label: const Text(
            'Annuler ma participation',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade800,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    // Activity full and user not joined → disabled button
    if (activity.isFull) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.block, color: Colors.white54),
          label: const Text(
            'Activité complète',
            style: TextStyle(color: Colors.white54),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade800,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    // Available → join button
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onJoin,
        icon: isLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.how_to_reg, color: Colors.black),
        label: const Text(
          'Participer',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
