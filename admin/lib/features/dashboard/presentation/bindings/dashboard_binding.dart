import 'package:get/get.dart';

import '../../../../features/packages/data/package_repository.dart';
import '../controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PackageRepository>(() => PackageRepository());
    Get.lazyPut<DashboardController>(() => DashboardController());
  }
}
