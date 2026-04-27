import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../data/auth_repository.dart';
import '../../domain/admin_user.dart';

class AuthController extends GetxController {
  final AuthRepository _repo = Get.find<AuthRepository>();

  final Rx<AdminUser?> admin = Rx<AdminUser?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxBool isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    _repo.authStateChanges.listen((user) async {
      if (user == null) {
        admin.value = null;
        isInitialized.value = true;
        if (Get.currentRoute != AppRoutes.login && Get.currentRoute != AppRoutes.splash) {
          Get.offAllNamed(AppRoutes.login);
        }
      } else {
        // Restore existing session — check admin allowlist
        await _restoreSession(user);
        isInitialized.value = true;
      }
    });
  }

  Future<void> _restoreSession(User user) async {
    isLoading.value = true;
    try {
      final isAllowed = await _repo.isAllowedAdmin(user.email ?? '');
      if (isAllowed) {
        final firestoreName = await _repo.getAdminName(user.email ?? '');
        admin.value = AdminUser(
          uid: user.uid,
          email: user.email ?? '',
          displayName: firestoreName ?? user.displayName,
          photoUrl: user.photoURL,
        );
        if (Get.currentRoute == AppRoutes.login) {
          Get.offAllNamed(AppRoutes.dashboard);
        }
      } else {
        // Logged in with Google but not an allowed admin
        await _repo.signOut();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final user = await _repo.signInWithGoogle();
      if (user == null) {
        isLoading.value = false;
        return;
      }

      final isAllowed = await _repo.isAllowedAdmin(user.email);
      if (!isAllowed) {
        await _repo.signOut();
        errorMessage.value =
            'Akun ${user.email} tidak terdaftar sebagai admin.';
        isLoading.value = false;
        return;
      }

      final firestoreName = await _repo.getAdminName(user.email);
      admin.value = AdminUser(
        uid: user.uid,
        email: user.email,
        displayName: firestoreName ?? user.displayName,
        photoUrl: user.photoUrl,
      );
      Get.offAllNamed(AppRoutes.dashboard);
    } catch (e) {
      errorMessage.value = 'Gagal login: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    admin.value = null;
    Get.offAllNamed(AppRoutes.login);
  }

  String get adminEmail =>
      admin.value?.email ??
      FirebaseAuth.instance.currentUser?.email ??
      '';
  String get adminName => admin.value?.displayName ?? adminEmail;
}
