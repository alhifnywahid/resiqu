import 'package:get/get.dart';

import '../../../../features/packages/data/package_repository.dart';
import '../../../../features/batches/data/batch_repository.dart';
import '../../../../core/constants/package_status.dart';

class DashboardController extends GetxController {
  final PackageRepository _repo = Get.find<PackageRepository>();
  final BatchRepository _batchRepo = Get.find<BatchRepository>();

  final RxMap<String, int> statusCounts = <String, int>{}.obs;
  final RxInt totalBatches = 0.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadCounts();
  }

  Future<void> loadCounts() async {
    isLoading.value = true;
    try {
      final counts = await _repo.getStatusCounts();
      statusCounts.value = counts;

      final batchesCount = await _batchRepo.getBatchesCount();
      totalBatches.value = batchesCount;
    } finally {
      isLoading.value = false;
    }
  }

  int get totalPackages => statusCounts.values.fold(0, (a, b) => a + b);

  int get arrived =>
      statusCounts[PackageStatus.arrived.value] ?? 0;

  int get inTransit =>
      statusCounts[PackageStatus.inTransit.value] ?? 0;
}
