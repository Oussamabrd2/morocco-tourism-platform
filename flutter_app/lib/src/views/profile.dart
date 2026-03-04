import 'package:flutter/material.dart';
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

  Future<Map<String, dynamic>> _loadUser() async {
    try {
      // Essayer d'abord d'obtenir le token
      final token = await AuthService().getToken();
      if (token == null) {
        throw Exception('Aucun token d\'authentification trouvé');
      }

      // Essayer d'appeler l'API avec le token
      return await ApiService().getCurrentUser();
    } catch (e) {
      // Si l'appel API échoue, essayer avec le cache local
      final cached = await AuthService().getUser();
      if (cached != null) {
        return cached;
      }
      
      // Si tout échoue, afficher un message d'erreur plus clair
      throw Exception('Impossible de charger les informations utilisateur. Veuillez vous reconnecter.');
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _userFuture = _loadUser();
    });
  }

  Future<void> _editProfile() async {
    final user = await _userFuture;
    if (!mounted) return;
    final nameController = TextEditingController(text: user['name']?.toString() ?? '');
    final emailController = TextEditingController(text: user['email']?.toString() ?? '');
    final bioController = TextEditingController(text: user['bio']?.toString() ?? '');

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Modifier le profil",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDeco("Nom"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDeco("Email"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bioController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDeco("Bio"),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, {
                  'name': nameController.text.trim(),
                  'email': emailController.text.trim(),
                  'bio': bioController.text.trim(),
                }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Enregistrer", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );

    if (result != null) {
      try {
        // Mettre à jour l'utilisateur via l'API
        final updatedUser = await ApiService().updateUser(result);
        
        // Mettre à jour le cache local avec les nouvelles données
        final token = await AuthService().getToken();
        if (token != null) {
          await AuthService().saveToken(token, updatedUser);
        }
        
        // Rafraîchir l'affichage
        _refresh();
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil mis à jour")),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: $e")),
        );
      }
    }
  }

  InputDecoration _inputDeco(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF121212),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Déconnexion', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Êtes-vous sûr de vouloir vous déconnecter?',
          style: TextStyle(color: Colors.white70),
        ),
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

    if (confirmed ?? false) {
      await AuthService().logout();
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Mon Profil', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _editProfile,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          }
          if (snapshot.hasError) {
            final errorMessage = snapshot.error.toString();
            final isAuthError = errorMessage.contains('token') || 
                               errorMessage.contains('authentification') || 
                               errorMessage.contains('reconnecter');

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
                  TextButton(
                    onPressed: _refresh,
                    child: const Text('Réessayer', style: TextStyle(color: Colors.orange)),
                  ),
                  if (isAuthError) ...[
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        AuthService().logout();
                        if (mounted) Navigator.pushReplacementNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        'Se reconnecter',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }
          final user = snapshot.data ?? {};
          final name = user['name']?.toString().trim() ?? 'Utilisateur';
          final email = user['email']?.toString() ?? '';
          final bio = user['bio']?.toString() ?? '';
          final role = user['role']?.toString() ?? 'user';
          final avatar = user['avatar_url'] as String?;
          final postsCount = (user['posts_count'] is int)
              ? user['posts_count'] as int
              : int.tryParse(user['posts_count']?.toString() ?? '0') ?? 0;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: avatar != null && avatar.toString().isNotEmpty
                      ? NetworkImage(avatar.toString())
                      : null,
                  backgroundColor: Colors.orange,
                  child: avatar == null || avatar.toString().isEmpty
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  email,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(80),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (bio.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      bio,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      postsCount == 0 ? 'Sans post' : '$postsCount',
                      'Posts',
                    ),
                    _buildStatItem('0', 'Abonnés'),
                    _buildStatItem('0', 'Lieux visités'),
                  ],
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade800,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: _logout,
                      child: const Text(
                        'Se déconnecter',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String value, String label) => Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      );
}
