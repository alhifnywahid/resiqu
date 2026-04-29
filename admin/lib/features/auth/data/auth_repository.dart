import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../domain/admin_user.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Safely get a single document: tries server first, falls back to cache.
  Future<DocumentSnapshot> _safeGetDoc(DocumentReference ref) async {
    try {
      return await ref.get(const GetOptions(source: Source.serverAndCache));
    } catch (_) {
      return await ref.get(const GetOptions(source: Source.cache));
    }
  }

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<AdminUser?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) return null;

    return AdminUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  Future<bool> isAllowedAdmin(String email) async {
    final doc = await _safeGetDoc(_firestore.collection('admins').doc(email));
    return doc.exists;
  }

  Future<String?> getAdminName(String email) async {
    final doc = await _safeGetDoc(_firestore.collection('admins').doc(email));
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>?;
    return (data?['name'] as String?)?.isNotEmpty == true ? data!['name'] as String : null;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Stream<List<Map<String, String>>> getAdmins() {
    return _firestore.collection('admins').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'email': doc.id,
          'name': (data['name'] as String?) ?? '',
        };
      }).toList();
    });
  }

  Future<void> addAdmin(String email, {String name = ''}) async {
    await _firestore.collection('admins').doc(email).set({
      'name': name,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }
}
