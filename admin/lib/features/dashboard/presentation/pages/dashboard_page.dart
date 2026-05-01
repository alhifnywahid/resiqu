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
          _buildHeader(context),

          // ── Dashboard Content ──
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -28),
              child: RefreshIndicator(
                onRefresh: controller.loadCounts,
                color: const Color(0xFF3B82F6),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      // ── Summary Cards Row ──
                      _buildSummaryRow(),
                      const SizedBox(height: 16),

                      // ── Delivery Rate Card ──
                      _buildDeliveryRateCard(),
                      const SizedBox(height: 16),

                      // ── Package Status Breakdown ──
                      _buildSectionTitle('Status Paket'),
                      const SizedBox(height: 10),
                      _buildPackageStatusGrid(),
                      const SizedBox(height: 20),

                      // ── Box/Kontainer Status ──
                      _buildSectionTitle('Kontainer / Box'),
                      const SizedBox(height: 10),
                      _buildBatchStatusRow(),
                      const SizedBox(height: 20),


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

  // ══════════════════════════════════════════════════
  // HEADER
  // ══════════════════════════════════════════════════
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 24,
        right: 24,
        bottom: 48,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Rekapitulasi logistik harian',
                    style: TextStyle(
                      color: Color(0xFF93C5FD),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => controller.loadCounts(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════
  // SUMMARY CARDS ROW (Total Paket + Total Box)
  // ══════════════════════════════════════════════════
  Widget _buildSummaryRow() {
    return Row(
      children: [
        Expanded(
          child: _GlassStatCard(
            label: 'Total Paket',
            value: controller.totalPackages.toString(),
            icon: Icons.inventory_2_rounded,
            gradient: const [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GlassStatCard(
            label: 'Total Box',
            value: controller.totalBatches.value.toString(),
            icon: Icons.widgets_rounded,
            gradient: const [Color(0xFF059669), Color(0xFF047857)],
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════
  // DELIVERY RATE CARD
  // ══════════════════════════════════════════════════
  Widget _buildDeliveryRateCard() {
    final rate = controller.deliveryRate;
    final arrived = controller.arrived;
    final total = controller.totalPackages;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Progress Ring
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(
                    value: rate / 100,
                    strokeWidth: 6,
                    strokeCap: StrokeCap.round,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      rate >= 75
                          ? const Color(0xFF10B981)
                          : rate >= 40
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFFEF4444),
                    ),
                  ),
                ),
                Text(
                  '${rate.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tingkat Keberhasilan',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$arrived dari $total paket telah tiba di tujuan',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════
  // PACKAGE STATUS GRID (4 mini cards)
  // ══════════════════════════════════════════════════
  Widget _buildPackageStatusGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MiniStatCard(
                label: 'Transit',
                count: controller.transit,
                icon: Icons.warehouse_rounded,
                color: const Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniStatCard(
                label: 'Dalam Box',
                count: controller.inBox,
                icon: Icons.inbox_rounded,
                color: const Color(0xFF8B5CF6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MiniStatCard(
                label: 'Dalam Perjalanan',
                count: controller.inTransit,
                icon: Icons.flight_takeoff_rounded,
                color: const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniStatCard(
                label: 'Tiba di Tujuan',
                count: controller.arrived,
                icon: Icons.check_circle_rounded,
                color: const Color(0xFF10B981),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════
  // BATCH STATUS ROW (3 mini cards)
  // ══════════════════════════════════════════════════
  Widget _buildBatchStatusRow() {
    return Row(
      children: [
        Expanded(
          child: _MiniStatCard(
            label: 'Terbuka',
            count: controller.batchCollecting,
            icon: Icons.lock_open_rounded,
            color: const Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStatCard(
            label: 'Dikirim',
            count: controller.batchDispatched,
            icon: Icons.local_shipping_rounded,
            color: const Color(0xFFFF8C42),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStatCard(
            label: 'Tiba',
            count: controller.batchArrived,
            icon: Icons.done_all_rounded,
            color: const Color(0xFF10B981),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════
  // SECTION TITLE
  // ══════════════════════════════════════════════════
  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1E293B),
          letterSpacing: -0.3,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════
// GLASS STAT CARD (Big summary cards)
// ══════════════════════════════════════════════════
class _GlassStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final List<Color> gradient;

  const _GlassStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -6,
            bottom: -6,
            child: Icon(icon, size: 64, color: Colors.white.withValues(alpha: 0.12)),
          ),
          Positioned(
            right: 30,
            top: -15,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
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

// ══════════════════════════════════════════════════
// MINI STAT CARD (Status breakdown cards)
// ══════════════════════════════════════════════════
class _MiniStatCard extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color color;

  const _MiniStatCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 10),
              Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF94A3B8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
