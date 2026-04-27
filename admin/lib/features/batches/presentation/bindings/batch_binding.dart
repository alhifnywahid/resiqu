import 'package:get/get.dart';

import '../../../packages/data/package_repository.dart';
import '../../data/batch_repository.dart';
import '../controllers/batch_controller.dart';

class BatchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BatchRepository>(() => BatchRepository());
    Get.lazyPut<PackageRepository>(() => PackageRepository());
    Get.lazyPut<BatchController>(() => BatchController());
  }
}
