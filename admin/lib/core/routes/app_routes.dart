import 'package:get/get.dart';

import '../../features/auth/presentation/bindings/auth_binding.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/batches/presentation/pages/batch_detail_page.dart';
import '../../features/batches/presentation/pages/create_batch_page.dart';
import '../../features/packages/presentation/pages/add_package_page.dart';
import '../../features/packages/presentation/pages/package_detail_page.dart';
import '../../features/packages/presentation/pages/packages_by_name_page.dart';
import '../../features/packages/presentation/bindings/package_binding.dart';
import '../../features/batches/presentation/bindings/batch_binding.dart';
import '../../features/splash/presentation/bindings/splash_binding.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../shared/widgets/main_shell.dart';

abstract class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const shell = '/shell';    // Main app shell (home after login)
  static const dashboard = '/shell'; // Alias — auth redirects here
  static const packageDetail = '/packages/detail';
  static const addPackage = '/packages/add';
  static const createBatch = '/batches/create';
  static const batchDetail = '/batches/detail';
  static const packagesByName = '/packages/by-name';
}

abstract class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.shell,
      page: () => const MainShell(),
      binding: MainShellBinding(),
    ),
    GetPage(
      name: AppRoutes.packageDetail,
      page: () => const PackageDetailPage(),
      binding: PackageBinding(),
    ),
    GetPage(
      name: AppRoutes.addPackage,
      page: () => const AddPackagePage(),
      binding: PackageBinding(),
    ),
    GetPage(
      name: AppRoutes.createBatch,
      page: () => const CreateBatchPage(),
      binding: BatchBinding(),
    ),
    GetPage(
      name: AppRoutes.batchDetail,
      page: () => const BatchDetailPage(),
      binding: BatchBinding(),
    ),
    GetPage(
      name: AppRoutes.packagesByName,
      page: () => const PackagesByNamePage(),
      binding: PackageBinding(),
    ),
  ];
}
