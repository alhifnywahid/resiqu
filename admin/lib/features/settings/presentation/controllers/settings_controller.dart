import 'package:get/get.dart';

import '../../../auth/data/auth_repository.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../core/utils/app_alerts.dart';

class SettingsController extends GetxController {
  final AuthRepository _authRepo = Get.find<AuthRepository>();

  final RxList<Map<String, String>> adminList = <Map<String, String>>[].obs;
  final RxBool isLoading = false.obs;

  String get _currentEmail => Get.find<AuthController>().adminEmail;

  @override
  void onInit() {
    super.onInit();
    _listenToAdmins();
  }

  void _listenToAdmins() {
    _authRepo.getAdmins().listen((list) {
      adminList.value = list;
    });
  }

  Future<void> addAdmin(String email, String name) async {
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      AppAlerts.error('Format email tidak valid');
      return;
    }

    if (!email.toLowerCase().endsWith('@gmail.com')) {
      AppAlerts.error('Hanya email @gmail.com yang diperbolehkan');
      return;
    }

    if (adminList.any((a) => a['email'] == email)) {
      AppAlerts.info('Email sudah terdaftar sebagai admin');
      return;
    }

    isLoading.value = true;
    try {
      await _authRepo.addAdmin(email, name: name);
      Get.back(); // Close modal
      AppAlerts.success('Admin berhasil ditambahkan');
    } catch (e) {
      AppAlerts.error('Gagal menambahkan admin');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateAdmin(String oldEmail, {required String newEmail, required String newName}) async {
    if (newEmail.isEmpty || !GetUtils.isEmail(newEmail)) {
      AppAlerts.error('Format email tidak valid');
      return;
    }

    if (!newEmail.toLowerCase().endsWith('@gmail.com')) {
      AppAlerts.error('Hanya email @gmail.com yang diperbolehkan');
      return;
    }

    // Check if new email already taken (by someone else)
    if (oldEmail != newEmail && adminList.any((a) => a['email'] == newEmail)) {
      AppAlerts.info('Email sudah digunakan admin lain');
      return;
    }

    isLoading.value = true;
    try {
      await _authRepo.updateAdmin(oldEmail, newEmail: newEmail, newName: newName);
      Get.back();
      AppAlerts.success('Admin berhasil diperbarui');
    } catch (e) {
      AppAlerts.error('Gagal memperbarui admin');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAdmin(String email) async {
    if (email == _currentEmail) {
      AppAlerts.error('Tidak bisa menghapus akun sendiri');
      return;
    }

    isLoading.value = true;
    try {
      await _authRepo.deleteAdmin(email);
      AppAlerts.success('Admin berhasil dihapus');
    } catch (e) {
      AppAlerts.error('Gagal menghapus admin');
    } finally {
      isLoading.value = false;
    }
  }
}
