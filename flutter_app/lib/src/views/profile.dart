/// lib/views/profile_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late Future<Map<String, dynamic>> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _loadUser();
  }

  // ── Data Loading ───────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> _loadUser() async {
    try {
      // Try fresh from API first
      final data = await ApiService().getCurrentUser();
      // Keep local cache in sync
      await AuthService().updateCachedUser(data);
      return data;
    } catch (_) {
      // Fallback to local cache (offline / 401)
      final cached = await AuthService().getUser();
      if (cached != null) return cached;
      throw Exception('Impossible de charger le profil. Veuillez vous reconnecter.');
    }
  }

  void _reload() => setState(() => _userFuture = _loadUser());

  // ── Avatar picker ──────────────────────────────────────────────────────────

  Future<void> _pickAndUploadAvatar() async {
    final picked = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.orangeAccent),
            title: const Text('Galerie', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.orangeAccent),
            title: const Text('Appareil photo', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );

    if (picked == null) return;

    final image = await ImagePicker().pickImage(
      source: picked,
      imageQuality: 80,
      maxWidth: 600,
    );
    if (image == null) return;

    try {
      await ApiService().uploadAvatar(File(image.path));
      _reload();
      if (!mounted) return;
      _showSnack('Photo de profil mise à jour ✓', Colors.green);
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString().replaceFirst('Exception: ', ''), Colors.red);
    }
  }

  // ── Edit profile bottom sheet ──────────────────────────────────────────────

  Future<void> _editProfile(Map<String, dynamic> user) async {
    final nameCtrl = TextEditingController(text: user['name']?.toString() ?? '');
    final bioCtrl  = TextEditingController(text: user['bio']?.toString() ?? '');

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: const Color(0xFF111111),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Handle
          Center(
            child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 20),

          const Text('Modifier le profil',
              style: TextStyle(
                  color: Colors.white, fontSize: 20,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 24),

          _label('Nom'),
          const SizedBox(height: 6),
          _field(nameCtrl, 'Votre nom complet'),
          const SizedBox(height: 16),

          _label('Biographie'),
          const SizedBox(height: 6),
          _field(bioCtrl, 'Parlez de vous...', maxLines: 3),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Navigator.pop(ctx, {
                'name': nameCtrl.text.trim(),
                'bio':  bioCtrl.text.trim(),
              }),
              child: const Text('Enregistrer',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            ),
          ),
        ]),
      ),
    );

    nameCtrl.dispose();
    bioCtrl.dispose();

    if (result == null || result['name']!.isEmpty) return;

    try {
      final updated = await ApiService().updateUser(result);
      await AuthService().updateCachedUser(updated);
      _reload();
      if (!mounted) return;
      _showSnack('Profil mis à jour ✓', Colors.green);
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString().replaceFirst('Exception: ', ''), Colors.red);
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Déconnexion',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Oui', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await AuthService().logout();
    if (mounted) Navigator.pushReplacementNamed(context, '/welcome');
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600,
          letterSpacing: .5));

  Widget _field(TextEditingController c, String hint, {int maxLines = 1}) =>
      TextField(
        controller: c,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24),
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade800),
              borderRadius: BorderRadius.circular(12)),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.orangeAccent),
              borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
      );

  // ── Category icon helper ───────────────────────────────────────────────────

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':      return Colors.redAccent;
      case 'organizer':  return Colors.blueAccent;
      default:           return Colors.orangeAccent;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final d = DateTime.parse(dateStr);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return dateStr;
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userFuture,
        builder: (context, snapshot) {

          // ── Loading ──────────────────────────────────────────────────────
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(color: Colors.orangeAccent),
              ),
            );
          }

          // ── Error ────────────────────────────────────────────────────────
          if (snapshot.hasError) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      snapshot.error.toString().replaceFirst('Exception: ', ''),
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _reload,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Réessayer'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          foregroundColor: Colors.black),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _logout,
                      child: const Text('Se reconnecter',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  ]),
                ),
              ),
            );
          }

          // ── Success ──────────────────────────────────────────────────────
          final user       = snapshot.data!;
          final name       = (user['name']?.toString().trim().isNotEmpty == true)
                              ? user['name'].toString().trim()
                              : 'Utilisateur';
          final email      = user['email']?.toString() ?? '';
          final bio        = user['bio']?.toString() ?? '';
          final role       = user['role']?.toString() ?? 'user';
          final avatarUrl  = user['avatar_url'] as String?;
          final gender     = user['gender']?.toString() ?? '';
          final birthDate  = _formatDate(user['birth_date']?.toString());
          final age        = user['age'];
          final postsCount = (user['posts_count'] as num?)?.toInt() ?? 0;
          final createdAt  = _formatDate(user['created_at']?.toString());
          final roleColor  = _roleColor(role);

          // Avatar initial letter
          final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
          final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

          return CustomScrollView(
            slivers: [

              // ── SliverAppBar ─────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: Colors.black,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF1A0A00), Colors.black],
                      ),
                    ),
                    child: Stack(children: [
                      // Decorative circle
                      Positioned(
                        top: -30, right: -30,
                        child: Container(
                          width: 140, height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.orange.withOpacity(0.06),
                          ),
                        ),
                      ),
                      // Avatar + name
                      Positioned.fill(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            GestureDetector(
                              onTap: _pickAndUploadAvatar,
                              child: Stack(children: [
                                CircleAvatar(
                                  radius: 46,
                                  backgroundColor: Colors.orange.withOpacity(0.2),
                                  backgroundImage:
                                      hasAvatar ? NetworkImage(avatarUrl!) : null,
                                  child: hasAvatar
                                      ? null
                                      : Text(initial,
                                          style: const TextStyle(
                                              color: Colors.orangeAccent,
                                              fontSize: 36,
                                              fontWeight: FontWeight.w800)),
                                ),
                                Positioned(
                                  bottom: 0, right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                        color: Colors.orangeAccent,
                                        shape: BoxShape.circle),
                                    child: const Icon(Icons.camera_alt,
                                        color: Colors.black, size: 14),
                                  ),
                                ),
                              ]),
                            ),
                            const SizedBox(height: 10),
                            Text(name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
                actions: [
                  IconButton(
                    tooltip: 'Modifier le profil',
                    icon: const Icon(Icons.edit_outlined, color: Colors.white),
                    onPressed: () => _editProfile(user),
                  ),
                ],
              ),

              // ── Body content ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Email + Role badge
                      Center(
                        child: Column(children: [
                          const SizedBox(height: 8),
                          Text(email,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 13)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                              color: roleColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: roleColor.withOpacity(0.3)),
                            ),
                            child: Text(role.toUpperCase(),
                                style: TextStyle(
                                    color: roleColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1)),
                          ),
                        ]),
                      ),

                      const SizedBox(height: 24),

                      // ── Posts count card ──────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 18, horizontal: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F0F0F),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF1E1E1E)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.photo_library_outlined,
                                color: Colors.orangeAccent, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              postsCount == 0
                                  ? 'Aucune publication'
                                  : '$postsCount publication${postsCount > 1 ? "s" : ""}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Info cards section ────────────────────────────
                      _sectionTitle('Informations'),
                      const SizedBox(height: 12),

                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F0F0F),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF1E1E1E)),
                        ),
                        child: Column(children: [

                          if (bio.isNotEmpty) ...[
                            _infoRow(
                              icon: Icons.info_outline,
                              label: 'Biographie',
                              value: bio,
                            ),
                            _divider(),
                          ],

                          if (gender.isNotEmpty) ...[
                            _infoRow(
                              icon: Icons.person_outline,
                              label: 'Genre',
                              value: _genderLabel(gender),
                            ),
                            _divider(),
                          ],

                          if (birthDate.isNotEmpty) ...[
                            _infoRow(
                              icon: Icons.cake_outlined,
                              label: 'Date de naissance',
                              value: age != null
                                  ? '$birthDate  ($age ans)'
                                  : birthDate,
                            ),
                            _divider(),
                          ],

                          if (createdAt.isNotEmpty)
                            _infoRow(
                              icon: Icons.calendar_today_outlined,
                              label: 'Membre depuis',
                              value: createdAt,
                            ),

                        ]),
                      ),

                      const SizedBox(height: 32),

                      // ── Logout button ─────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                                color: Colors.red.withOpacity(0.5)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: const Icon(Icons.logout,
                              color: Colors.redAccent, size: 18),
                          label: const Text('Se déconnecter',
                              style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w700)),
                          onPressed: _logout,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── UI sub-widgets ─────────────────────────────────────────────────────────

  Widget _sectionTitle(String text) => Text(text,
      style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1));

  Widget _divider() => Divider(
      height: 1, thickness: 1, color: Colors.white.withOpacity(0.05),
      indent: 56);

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: Colors.orangeAccent, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(label,
                  style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(color: Colors.white, fontSize: 14)),
            ]),
          ),
        ]),
      );

  String _genderLabel(String g) {
    switch (g) {
      case 'Man':               return 'Homme';
      case 'Woman':             return 'Femme';
      case 'Non-binary':        return 'Non-binaire';
      case 'Prefer not to say': return 'Non renseigné';
      default:                  return g;
    }
  }
}