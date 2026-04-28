import 'dart:async';

import 'package:get/get.dart';

import '../../../../core/constants/package_status.dart';
import '../../data/package_repository.dart';
import '../../domain/package_model.dart';
import '../../domain/status_history_model.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class PackageController extends GetxController {
  final PackageRepository _repo = Get.find<PackageRepository>();
  StreamSubscription? _packagesSub;
  StreamSubscription? _historySub;

  final RxList<PackageModel> _allPackages = <PackageModel>[].obs;
  final RxList<StatusHistoryModel> statusHistory = <StatusHistoryModel>[].obs;
  final Rx<PackageModel?> selectedPackage = Rx<PackageModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxnString pendingSearchText = RxnString();
  final Rx<PackageStatus?> selectedStatusFilter = Rx<PackageStatus?>(null);

  List<PackageModel> get filteredPackages {
    var result = _allPackages.toList();
    if (selectedStatusFilter.value != null) {
      result = result.where((pkg) => pkg.currentStatus == selectedStatusFilter.value).toList();
    }
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      result = result.where((pkg) =>
        pkg.recipientName.toLowerCase().contains(q) ||
        pkg.trackingCode.toLowerCase().contains(q)
      ).toList();
    }
    return result;
  }

  /// Expose for UI binding
  List<PackageModel> get packages => filteredPackages;

  /// Group packages by recipientName for "Per Nama" view
  Map<String, List<PackageModel>> get groupedByName {
    final pkgs = filteredPackages;
    final map = <String, List<PackageModel>>{};
    for (final pkg in pkgs) {
      final name = pkg.recipientName.isEmpty ? '(Tanpa Nama)' : pkg.recipientName;
      map.putIfAbsent(name, () => []).add(pkg);
    }
    // Sort by name alphabetically
    final sorted = Map.fromEntries(
      map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    return sorted;
  }

  @override
  void onInit() {
    super.onInit();
    _listenToPackages();
  }

  void _listenToPackages() {
    _packagesSub?.cancel();
    _packagesSub = _repo.getPackagesStream().listen((list) {
      _allPackages.value = list;
    });
  }

  String get _adminEmail => Get.find<AuthController>().adminEmail;

  Future<String> addPackage({
    required String trackingCode,
    required String recipientName,
    String? batchId,
    Map<String, double>? dimensions,
  }) async {
    isLoading.value = true;
    try {
      final result = await _repo.addPackage(
        trackingCode: trackingCode,
        recipientName: recipientName,
        adminEmail: _adminEmail,
        batchId: batchId,
        dimensions: dimensions,
      );
      return result;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePackage({
    required String id,
    required String trackingCode,
    required String recipientName,
    String? batchId,
    Map<String, double>? dimensions,
  }) async {
    isLoading.value = true;
    try {
      await _repo.updatePackage(
        id: id,
        trackingCode: trackingCode,
        recipientName: recipientName,
        adminEmail: _adminEmail,
        batchId: batchId,
        dimensions: dimensions,
      );
      if (selectedPackage.value?.id == id) {
        await loadPackageDetail(id); // reload detail if currently viewed
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePackage(String id) async {
    isLoading.value = true;
    try {
      await _repo.deletePackage(id);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadPackageDetail(String packageId) async {
    isLoading.value = true;
    try {
      selectedPackage.value = await _repo.getPackageById(packageId);
      _historySub?.cancel();
      _historySub = _repo.getStatusHistory(packageId).listen((history) {
        statusHistory.value = history;
      });
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _packagesSub?.cancel();
    _historySub?.cancel();
    super.onClose();
  }

  void searchPackages(String query) {
    searchQuery.value = query;
  }

  Future<bool> checkPackageExists(String code) async {
    return await _repo.checkTrackingCodeExists(code);
  }
}
