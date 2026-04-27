class AdminUser {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;

  const AdminUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
  });
}
