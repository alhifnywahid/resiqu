import 'package:get/get.dart';

import '../../../auth/data/auth_repository.dart';
import '../../../../core/utils/app_alerts.dart';

class SettingsController extends GetxController {
  final AuthRepository _authRepo = Get.find<AuthRepository>();

  final RxList<Map<String, String>> adminList = <Map<String, String>>[].obs;
  final RxBool isLoading = false.obs;

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
}
