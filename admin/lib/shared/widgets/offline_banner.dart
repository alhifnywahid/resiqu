import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/connectivity_service.dart';

/// Animated banner that slides down when device goes offline.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivity = Get.find<ConnectivityService>();

    return Obx(() {
      final offline = !connectivity.isOnline.value;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: offline ? 36 : 0,
        width: double.infinity,
        decoration: const BoxDecoration(color: Color(0xFFFF8C42)),
        clipBehavior: Clip.hardEdge,
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_rounded, size: 14, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Mode Offline - data tersimpan lokal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
