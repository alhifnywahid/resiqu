import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/batches/data/batch_repository.dart';
import '../../features/batches/presentation/controllers/batch_controller.dart';
import '../../features/batches/presentation/pages/batch_list_page.dart';
import '../../features/dashboard/presentation/controllers/dashboard_controller.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../core/routes/app_routes.dart';
import '../../features/packages/data/package_repository.dart';
import '../../features/packages/presentation/controllers/package_controller.dart';
import '../../features/packages/presentation/pages/package_list_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/controllers/settings_controller.dart';
import '../../shared/widgets/scanner_sheet.dart';
import 'offline_banner.dart';
import 'premium_nav_bar.dart';

class ShellController extends GetxController {
  final RxInt currentIndex = 0.obs;
  // Track which pages have been visited (for lazy building)
  final visitedPages = <int>{0}.obs; // Dashboard built by default

  void changePage(int index) {
    visitedPages.add(index);
    currentIndex.value = index;
  }
}

class MainShell extends GetView<ShellController> {
  const MainShell({super.key});

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const DashboardPage();
      case 1:
        return const PackageListPage();
      case 3:
        return const BatchListPage();
      case 4:
        return const SettingsPage();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      extendBody: true,
      // Lazy page loading: only builds pages when first visited
      // Unlike IndexedStack which builds ALL 4 pages + controllers at once
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: Obx(() {
              final idx = controller.currentIndex.value == 2
                  ? 0
                  : controller.currentIndex.value;
              return _buildPage(idx);
            }),
          ),
        ],
      ),
      floatingActionButton: _ScanFab(onTap: () => _openScanner(context)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Obx(
        () => PremiumNavBar(
          selectedIndex: controller.currentIndex.value,
          onItemTapped: (index) {
            if (index != 2) controller.changePage(index);
          },
        ),
      ),
    );
  }

  void _openScanner(BuildContext context) async {
    final code = await showScannerSheet(context);
    if (code != null && code.isNotEmpty) {
      final controller = Get.find<PackageController>();

      // Smart Context-Aware Routing
      final exists = await controller.checkPackageExists(code);

      if (exists) {
        // Data found: populate search input and navigate to packages tab
        controller.pendingSearchText.value = code;
        Get.find<ShellController>().changePage(1);
      } else {
        // Unrecognized data: go straight to Add Package and auto-fill barcode
        Get.find<ShellController>().changePage(1);
        Get.toNamed(AppRoutes.addPackage, arguments: {'resi': code});
      }
    }
  }
}

/// Gradient FAB for the scan action - used as Scaffold.floatingActionButton.
class _ScanFab extends StatelessWidget {
  final VoidCallback onTap;
  const _ScanFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8B7FFF), Color(0xFF4A90E2)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.5),
              blurRadius: 16,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.qr_code_scanner_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }
}

class MainShellBinding extends Bindings {
  @override
  void dependencies() {
    // Shell
    Get.lazyPut(() => ShellController(), fenix: true);
    // Repositories (shared)
    Get.lazyPut(() => AuthRepository(), fenix: true);
    Get.lazyPut(() => PackageRepository(), fenix: true);
    Get.lazyPut(() => BatchRepository(), fenix: true);
    // Controllers
    Get.lazyPut(() => AuthController(), fenix: true);
    Get.lazyPut(() => DashboardController(), fenix: true);
    Get.lazyPut(() => PackageController(), fenix: true);
    Get.lazyPut(() => BatchController(), fenix: true);
    Get.lazyPut(() => SettingsController(), fenix: true);
  }
}
