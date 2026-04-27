import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../auth/data/auth_repository.dart';

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
      Get.snackbar(
        'Error',
        'Format email tidak valid',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    if (adminList.any((a) => a['email'] == email)) {
      Get.snackbar(
        'Info',
        'Email sudah terdaftar sebagai admin',
        backgroundColor: Colors.blue.shade100,
        colorText: Colors.blue.shade900,
      );
      return;
    }

    isLoading.value = true;
    try {
      await _authRepo.addAdmin(email, name: name);
      Get.back(); // Close modal
      Get.snackbar(
        'Sukses',
        'Admin berhasil ditambahkan',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menambahkan admin',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
