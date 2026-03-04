class GoogleUser {
  final String name;
  final String email;
  final String? photoUrl;

  GoogleUser({required this.name, required this.email, this.photoUrl});
}

class GoogleAuthService {
  /// Returns the last signed-in user, or null if none.
  Future<GoogleUser?> getStoredUser() async => null;

  /// Returns the stored backend token (if any).
  Future<String?> getStoredToken() async => null;

  /// Perform a sign-in flow and return a backend token (for demonstration).
  Future<String> signIn() async {
    // TODO: implement actual Google sign-in logic
    throw UnimplementedError();
  }

  /// Sign out the current user and clear local state.
  Future<void> signOut() async {}
}
