import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _startSplash();
  }

  void _startSplash() async {
    // Wait for the minimum animation duration (2.5 seconds)
    await Future.delayed(const Duration(milliseconds: 2500));
    
    final authController = Get.find<AuthController>();

    // If AuthController is still fetching from Firebase/Firestore, wait for it
    if (!authController.isInitialized.value) {
      Worker? worker;
      worker = ever(authController.isInitialized, (bool isInit) {
        if (isInit) {
          worker?.dispose();
          _route(authController);
        }
      });
    } else {
      _route(authController);
    }
  }

  void _route(AuthController authController) {
    if (authController.admin.value != null) {
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
