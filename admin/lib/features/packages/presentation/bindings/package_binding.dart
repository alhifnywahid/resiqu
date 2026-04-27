import 'package:get/get.dart';

import '../../data/package_repository.dart';
import '../controllers/package_controller.dart';

class PackageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PackageRepository>(() => PackageRepository());
    Get.lazyPut<PackageController>(() => PackageController());
  }
}
