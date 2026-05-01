import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/package_status.dart';
import '../../../../core/utils/app_alerts.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../packages/domain/package_model.dart';
import '../../../packages/data/package_repository.dart';
import '../../data/batch_repository.dart';
import '../../domain/batch_model.dart';

class BatchController extends GetxController {
  static const _filterKey = 'batch_status_filter';

  final BatchRepository _batchRepo = Get.find<BatchRepository>();
  final PackageRepository _pkgRepo = Get.find<PackageRepository>();

  final RxList<BatchModel> batches = <BatchModel>[].obs;
  final RxList<PackageModel> availablePackages = <PackageModel>[].obs;
  final RxList<String> selectedPackageIds = <String>[].obs;
  final RxString searchQuery = ''.obs;
  final RxnString selectedStatusFilter = RxnString();
  
  List<BatchModel> get filteredBatches {
    var result = batches.toList();
    if (selectedStatusFilter.value != null) {
      result = result.where((b) => b.status.value == selectedStatusFilter.value).toList();
    }
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((b) =>
        b.name.toLowerCase().contains(query) ||
        b.destinationCity.toLowerCase().contains(query)
      ).toList();
    }
    return result;
  }

  void searchBatches(String query) {
    searchQuery.value = query;
  }
  final Rx<BatchModel?> selectedBatch = Rx<BatchModel?>(null);
  final RxBool isLoading = false.obs;

  String get _adminEmail => Get.find<AuthController>().adminEmail;

  @override
  void onInit() {
    super.onInit();
    _listenToBatches();
    _loadSavedFilter();
    ever(selectedStatusFilter, _saveFilter);
  }

  Future<void> _loadSavedFilter() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_filterKey);
    if (saved != null) {
      selectedStatusFilter.value = saved;
    }
  }

  void _saveFilter(String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(_filterKey);
    } else {
      await prefs.setString(_filterKey, value);
    }
  }

  void _listenToBatches() {
    _batchRepo.getBatchesStream().listen((list) {
      batches.value = list;
    });
  }

  Future<void> loadAvailablePackages() async {
    isLoading.value = true;
    try {
      // Packages that are not yet in a batch (batchId == null or received/waiting)
      final all = await _pkgRepo.searchPackages('');
      availablePackages.value = all
          .where((p) =>
              (p.batchId == null || p.batchId!.isEmpty) &&
              p.currentStatus == PackageStatus.transit)
          .toList();
    } catch (e) {
      AppAlerts.error('Gagal memuat paket: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void togglePackageSelection(String packageId) {
    if (selectedPackageIds.contains(packageId)) {
      selectedPackageIds.remove(packageId);
    } else {
      selectedPackageIds.add(packageId);
    }
  }

  Future<void> createBatch({
    required String name,
    required String destinationCity,
    DateTime? startDate,
    DateTime? expiryDate,
  }) async {
    isLoading.value = true;
    try {
      await _batchRepo.createBatch(
        name: name,
        destinationCity: destinationCity,
        packageIds: [],
        adminEmail: _adminEmail,
        startDate: startDate,
        expiryDate: expiryDate,
      );
      Get.back();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateBatch({
    required String id,
    required String name,
    required String destinationCity,
    DateTime? startDate,
    DateTime? expiryDate,
  }) async {
    isLoading.value = true;
    try {
      await _batchRepo.updateBatch(
        id: id,
        name: name,
        destinationCity: destinationCity,
        adminEmail: _adminEmail,
        startDate: startDate,
        expiryDate: expiryDate,
      );
      Get.back();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addPackagesToBatch(String batchId, List<String> packageIds) async {
    isLoading.value = true;
    try {
      final email = _adminEmail;
      if (email.isEmpty) {
        throw Exception('Sesi admin tidak valid atau email kosong.');
      }
      
      await _batchRepo.addPackagesToBatch(
        batchId: batchId,
        packageIds: packageIds.toList(),
        adminEmail: email, // EXACT MATCH with token
      );
      return true;
    } catch (e) {
      AppAlerts.error('Gagal menambahkan paket: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> dispatchBatch(BatchModel batch) async {
    isLoading.value = true;
    try {
      await _batchRepo.dispatchBatch(
        batchId: batch.id,
        packageIds: batch.packageIds,
        adminEmail: _adminEmail,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> arriveBatch(BatchModel batch) async {
    isLoading.value = true;
    try {
      await _batchRepo.arriveBatch(
        batchId: batch.id,
        packageIds: batch.packageIds,
        adminEmail: _adminEmail,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> removePackageFromBatch(String batchId, String packageId) async {
    isLoading.value = true;
    try {
      await _batchRepo.removePackageFromBatch(
        batchId: batchId,
        packageId: packageId,
        adminEmail: _adminEmail,
      );
      return true;
    } catch (e) {
      AppAlerts.error('Gagal mengeluarkan paket: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
