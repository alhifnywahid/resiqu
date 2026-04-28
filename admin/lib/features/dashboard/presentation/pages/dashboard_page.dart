import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/dashboard_controller.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // ── Premium Dark Header ──
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 24,
              right: 24,
              bottom: 40,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)], // Premium Blue
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Rekapitulasi logistik harian Anda',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // ── Dashboard Cards ──
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: RefreshIndicator(
                onRefresh: controller.loadCounts,
                color: const Color(0xFF3B82F6),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    physics:
                        const AlwaysScrollableScrollPhysics(), // Ensures RefreshIndicator works even if not full
                    children: [
                      _PremiumStatCard(
                        label: 'Total Paket',
                        value: controller.totalPackages.toString(),
                        icon: Icons.local_shipping_rounded,
                        gradient: const [
                          Color(0xFF4F46E5),
                          Color(0xFF7C3AED),
                        ], // Indigo to Violet
                      ),
                      const SizedBox(height: 12),
                      _PremiumStatCard(
                        label: 'Paket Tiba di Tujuan',
                        value: controller.arrived.toString(),
                        icon: Icons.flight_land_rounded,
                        gradient: const [
                          Color(0xFFE11D48),
                          Color(0xFFBE123C),
                        ], // Rose to Rose darkest
                      ),
                      const SizedBox(height: 12),
                      _PremiumStatCard(
                        label: 'Dalam Pengiriman',
                        value: controller.inTransit.toString(),
                        icon: Icons.flight_takeoff_rounded,
                        gradient: const [
                          Color(0xFF0284C7),
                          Color(0xFF1D4ED8),
                        ], // Light Blue to Blue
                      ),
                      const SizedBox(height: 12),
                      _PremiumStatCard(
                        label: 'Total Box / Kontainer',
                        value: controller.totalBatches.value.toString(),
                        icon: Icons.widgets_rounded,
                        gradient: const [
                          Color(0xFF059669),
                          Color(0xFF047857),
                        ], // Deep Emerald
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final List<Color> gradient;

  const _PremiumStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ── Watermark icon ──
          Positioned(
            right: -8,
            bottom: -10,
            child: Icon(
              icon,
              size: 80,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          // ── Decorative circle ──
          Positioned(
            right: 40,
            top: -20,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          // ── Content ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 16),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
