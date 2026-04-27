import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/services/connectivity_service.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bindings/auth_binding.dart';
import 'features/splash/presentation/bindings/splash_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Reduce Firestore's aggressive connection retry when offline
  // This prevents main thread blocking from DNS resolution failures
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  await initializeDateFormatting('id', null);

  // Initialize connectivity monitoring
  Get.put(ConnectivityService(), permanent: true);

  runApp(const ResiquAdminApp());
}

class ResiquAdminApp extends StatelessWidget {
  const ResiquAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ResiQu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      initialBinding: BindingsBuilder(() {
        AuthBinding().dependencies();
        SplashBinding().dependencies();
      }),
      getPages: AppPages.pages,
      unknownRoute: GetPage(
        name: '/not-found',
        page: () => const _NotFoundPage(),
      ),
    );
  }
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Halaman tidak ditemukan',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
