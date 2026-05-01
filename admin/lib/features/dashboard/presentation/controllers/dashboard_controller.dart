import 'package:get/get.dart';

import '../../../../features/packages/data/package_repository.dart';
import '../../../../features/batches/data/batch_repository.dart';
import '../../../../core/constants/package_status.dart';

class DashboardController extends GetxController {
  final PackageRepository _repo = Get.find<PackageRepository>();
  final BatchRepository _batchRepo = Get.find<BatchRepository>();

  final RxMap<String, int> statusCounts = <String, int>{}.obs;
  final RxMap<String, int> batchStatusCounts = <String, int>{}.obs;
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
      final results = await Future.wait([
        _repo.getStatusCounts(),
        _batchRepo.getBatchesCount(),
        _batchRepo.getBatchStatusCounts(),
      ]);

      statusCounts.value = results[0] as Map<String, int>;
      totalBatches.value = results[1] as int;
      batchStatusCounts.value = results[2] as Map<String, int>;
    } finally {
      isLoading.value = false;
    }
  }

  int get totalPackages => statusCounts.values.fold(0, (a, b) => a + b);

  int countByStatus(PackageStatus status) =>
      statusCounts[status.value] ?? 0;

  int get arrived => countByStatus(PackageStatus.arrived);
  int get inTransit => countByStatus(PackageStatus.inTransit);
  int get inBox => countByStatus(PackageStatus.inBox);
  int get transit => countByStatus(PackageStatus.transit);

  int get batchCollecting => batchStatusCounts['collecting'] ?? 0;
  int get batchDispatched => batchStatusCounts['dispatched'] ?? 0;
  int get batchArrived => batchStatusCounts['arrived'] ?? 0;

  double get deliveryRate =>
      totalPackages > 0 ? (arrived / totalPackages) * 100 : 0;
}
