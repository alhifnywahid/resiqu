import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/app_alerts.dart';
import '../../domain/batch_model.dart';
import '../controllers/batch_controller.dart';

class BatchListPage extends GetView<BatchController> {
  const BatchListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFF8FAFC),
        floatingActionButton: Container(
          margin: const EdgeInsets.only(bottom: 85, right: 0),
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF1E3A8A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Get.toNamed(AppRoutes.createBatch),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
            ),
          ),
        ),
        body: Column(
          children: [
            // ── Premium Gradient Header ──
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                left: 24,
                right: 24,
                bottom: 50,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Box Pengiriman',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Row(
                    children: [

                      // Filter button
                      GestureDetector(
                        onTap: () => _showFilterSheet(context),
                        child: Obx(() {
                          final hasFilter = controller.selectedStatusFilter.value != null;
                          return Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: hasFilter ? 0.3 : 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
                              ),
                              if (hasFilter)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFBBF24),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Floating Search Bar ──
            Transform.translate(
              offset: const Offset(0, -32),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: controller.searchBatches,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Cari nama box atau kota tujuan...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 15,
                      ),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 22),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
              ),
            ),

            // ── Active Filter Indicator ──
            Obx(() {
              final filter = controller.selectedStatusFilter.value;
              if (filter == null) return const SizedBox.shrink();
              final statusMap = {
                'open': 'Terbuka',
                'dispatched': 'Dikirim',
                'arrived': 'Tiba di Tujuan',
              };
              return Transform.translate(
                offset: const Offset(0, -16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.filter_alt_rounded, size: 14, color: Color(0xFF3B82F6)),
                        const SizedBox(width: 6),
                        Text(
                          'Filter: ${statusMap[filter] ?? filter}',
                          style: const TextStyle(color: Color(0xFF1E40AF), fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => controller.selectedStatusFilter.value = null,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded, size: 14, color: Color(0xFF3B82F6)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            // ── Box List ──
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -30),
                child: Obx(() {
                final list = controller.filteredBatches;
                if (list.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView.separated(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                  itemCount: list.length,
                  separatorBuilder: (context, i) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final batch = list[i];
                    return _BoxCard(
                      batch: batch,
                      onTap: () => Get.toNamed(
                        AppRoutes.batchDetail,
                        arguments: batch,
                      ),
                      onDispatch: () => _confirmDispatch(context, batch),
                    );
                  },
                );
              }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.widgets_outlined,
              size: 64,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada box',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tekan ikon + untuk membuat box baru',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final statusMap = {
      'open': ('Terbuka', Icons.lock_open_rounded),
      'dispatched': ('Dikirim', Icons.local_shipping_rounded),
      'arrived': ('Tiba di Tujuan', Icons.check_circle_rounded),
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48, height: 5,
                decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2.5)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Filter Status', style: TextStyle(color: Color(0xFF1E293B), fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                Obx(() {
                  if (controller.selectedStatusFilter.value == null) return const SizedBox.shrink();
                  return GestureDetector(
                    onTap: () {
                      controller.selectedStatusFilter.value = null;
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Reset', style: TextStyle(color: Color(0xFFEF4444), fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 6),
            const Text('Pilih status box untuk memfilter daftar.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.4)),
            const SizedBox(height: 20),
            Obx(() {
              final current = controller.selectedStatusFilter.value;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _BatchFilterOption(
                    label: 'Semua',
                    icon: Icons.all_inclusive_rounded,
                    isSelected: current == null,
                    onTap: () {
                      controller.selectedStatusFilter.value = null;
                      Navigator.pop(context);
                    },
                  ),
                  ...statusMap.entries.map((e) => _BatchFilterOption(
                    label: e.value.$1,
                    icon: e.value.$2,
                    isSelected: current == e.key,
                    onTap: () {
                      controller.selectedStatusFilter.value = e.key;
                      Navigator.pop(context);
                    },
                  )),
                ],
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _confirmDispatch(BuildContext context, BatchModel batch) {
    if (batch.status != BatchStatus.collecting) return;
    AppAlerts.confirmSheet(
      context: context,
      title: 'Kirim Box?',
      description: 'Box "${batch.name}" akan dikirim.\nStatus ${batch.packageIds.length} paket akan berubah ke "Dalam Perjalanan".',
      confirmLabel: 'Kirim Sekarang',
      icon: Icons.local_shipping_rounded,
      onConfirm: () {
        controller.dispatchBatch(batch);
      },
    );
  }
}

class _BoxCard extends StatelessWidget {
  final BatchModel batch;
  final VoidCallback onTap;
  final VoidCallback onDispatch;

  const _BoxCard({required this.batch, required this.onTap, required this.onDispatch});

  static const _statusColors = {
    BatchStatus.collecting: Color(0xFF3B82F6),
    BatchStatus.dispatched: Color(0xFFFF8C42),
    BatchStatus.arrived: Color(0xFF11998E),
  };

  static final _dateFormat = DateFormat('dd MMM', 'id');
  static final _dateFormatYear = DateFormat('dd MMM yyyy', 'id');

  @override
  Widget build(BuildContext context) {
    final isExpired = batch.isExpired && batch.status == BatchStatus.collecting;
    final color = isExpired ? const Color(0xFFEF4444) : (_statusColors[batch.status] ?? Colors.grey);

    return GestureDetector(
      onTap: onTap,
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF94A3B8).withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isExpired ? const Color(0xFFEF4444).withValues(alpha: 0.3) : const Color(0xFFF1F5F9),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Box Name & Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    batch.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: color.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    batch.statusLabel,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Row 2: Destination City
            Row(
              children: [
                const Icon(Icons.flight_takeoff_rounded, size: 14, color: Color(0xFF94A3B8)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    batch.destinationCity,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // Row 2.5: Date Range
            if (batch.startDate != null || batch.expiryDate != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.date_range_rounded,
                    size: 14,
                    color: isExpired ? const Color(0xFFEF4444) : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _buildDateRangeText(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isExpired ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                    ),
                  ),
                  if (isExpired) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'EXPIRED',
                        style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
            
            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: const Color(0xFFF1F5F9)),
            ),

            // Row 3: Package Count & Button
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.all_inbox_rounded, size: 14, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${batch.packageIds.length} Paket',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
                if (batch.status == BatchStatus.collecting)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: onDispatch,
                    child: const Text('Kirim Box', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
    );
  }
  String _buildDateRangeText() {
    final start = batch.startDate;
    final expiry = batch.expiryDate;

    if (start != null && expiry != null) {
      // Same year? Omit year from start date
      if (start.year == expiry.year) {
        return '${_dateFormat.format(start)} - ${_dateFormatYear.format(expiry)}';
      }
      return '${_dateFormatYear.format(start)} - ${_dateFormatYear.format(expiry)}';
    } else if (start != null) {
      return 'Mulai: ${_dateFormatYear.format(start)}';
    } else if (expiry != null) {
      return 'Kadaluarsa: ${_dateFormatYear.format(expiry)}';
    }
    return '';
  }
}

class _BatchFilterOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _BatchFilterOption({required this.label, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF64748B)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? const Color(0xFF1E40AF) : const Color(0xFF334155),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF3B82F6)),
            ],
          ],
        ),
      ),
    );
  }
}
