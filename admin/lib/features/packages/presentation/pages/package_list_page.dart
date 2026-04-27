import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/package_status.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/export_service.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/scanner_sheet.dart';
import '../../../../shared/widgets/export_filter_sheet.dart';
import '../controllers/package_controller.dart';
import '../../domain/package_model.dart';

class PackageListPage extends StatefulWidget {
  const PackageListPage({super.key});

  @override
  State<PackageListPage> createState() => _PackageListPageState();
}

class _PackageListPageState extends State<PackageListPage> {
  final searchCtrl = TextEditingController();
  late final PackageController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<PackageController>();
    
    // Listen for QR scan results to populate search input
    ever(controller.pendingSearchText, (String? text) {
      if (text != null && text.isNotEmpty) {
        searchCtrl.text = text;
        controller.searchPackages(text);
        controller.pendingSearchText.value = null;
      }
    });
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

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
              onTap: () => Get.toNamed(AppRoutes.addPackage),
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
                  'Daftar Paket',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                Row(
                  children: [
                    // Export button
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => ExportFilterSheet(
                            onExport: (status, startDate, endDate, format) async {
                              var pkgs = controller.packages;
                              if (status != null) {
                                pkgs = pkgs.where((p) => p.currentStatus == status).toList();
                              }
                              if (startDate != null && endDate != null) {
                                pkgs = pkgs.where((p) {
                                  final date = p.createdAt;
                                  return date.isAfter(startDate.subtract(const Duration(days: 1))) && 
                                         date.isBefore(endDate.add(const Duration(days: 1)));
                                }).toList();
                              }
                              if (pkgs.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Tidak ada data yang cocok dengan filter')),
                                );
                                return;
                              }
                              if (format == 'excel') {
                                ExportService.exportToExcel(pkgs, context);
                              } else {
                                ExportService.exportToPdf(pkgs, context);
                              }
                            },
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.file_download_outlined, color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Filter button
                    GestureDetector(
                      onTap: () => _showFilterSheet(context),
                      child: Obx(() {
                        final hasFilter = controller.selectedStatusFilter.value != null || controller.viewMode.value == 'perName';
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
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Obx(() {
                  // Listen to searchQuery to rebuild when cleared programmatically
                  final _ = controller.searchQuery.value;
                  return TextField(
                    controller: searchCtrl,
                    onChanged: (value) {
                      controller.searchPackages(value);
                    },
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: AppStrings.searchPackage,
                      hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 15,
                      ),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 22),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Clear button
                          if (searchCtrl.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8), size: 20),
                              onPressed: () {
                                searchCtrl.clear();
                                controller.searchPackages('');
                                setState(() {});
                              },
                            ),
                          // Scanner button
                          IconButton(
                            icon: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF3B82F6), size: 22),
                            onPressed: () async {
                              final code = await showScannerSheet(context);
                              if (code != null && code.isNotEmpty) {
                                searchCtrl.text = code;
                                controller.searchPackages(code);
                                setState(() {});
                              }
                            },
                          ),
                        ],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  );
                }),
              ),
            ),
          ),

          // ── Active Filter Indicator ──
          Obx(() {
            final filter = controller.selectedStatusFilter.value;
            if (filter == null) return const SizedBox.shrink();
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
                        'Filter: ${filter.label}',
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

          // ── Package List or Grouped Name List ──
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -30),
              child: Obx(() {
                final isGrouped = controller.viewMode.value == 'perName';
                if (isGrouped) {
                  return _buildGroupedNameView();
                }
                final pkgs = controller.filteredPackages;
                if (controller.isLoading.value && pkgs.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                    ),
                  );
                }
                if (pkgs.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                itemCount: pkgs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (ctx, index) {
                  final pkg = pkgs[index];
                  return _buildPackageCard(pkg);
                },
              );
            }),
            ),
          ),
        ],
      ),
    ));
  }

  void _showFilterSheet(BuildContext context) {
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

            // ── Tampilan Section ──
            const Text('Tampilan', style: TextStyle(color: Color(0xFF1E293B), fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            const SizedBox(height: 6),
            const Text('Pilih cara menampilkan daftar paket.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.4)),
            const SizedBox(height: 12),
            Obx(() {
              final mode = controller.viewMode.value;
              return Row(
                children: [
                  Expanded(
                    child: _FilterOption(
                      label: 'Per Paket',
                      icon: Icons.inventory_2_rounded,
                      isSelected: mode == 'perPackage',
                      onTap: () {
                        controller.viewMode.value = 'perPackage';
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _FilterOption(
                      label: 'Per Nama',
                      icon: Icons.people_rounded,
                      isSelected: mode == 'perName',
                      onTap: () {
                        controller.viewMode.value = 'perName';
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 24),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 20),

            // ── Filter Status Section ──
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
            const Text('Pilih status paket untuk memfilter daftar.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.4)),
            const SizedBox(height: 20),
            Obx(() {
              final current = controller.selectedStatusFilter.value;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _FilterOption(
                    label: 'Semua',
                    icon: Icons.all_inclusive_rounded,
                    isSelected: current == null,
                    onTap: () {
                      controller.selectedStatusFilter.value = null;
                      Navigator.pop(context);
                    },
                  ),
                  ...PackageStatus.values.map((status) => _FilterOption(
                    label: status.label,
                    icon: _statusIcon(status),
                    isSelected: current == status,
                    onTap: () {
                      controller.selectedStatusFilter.value = status;
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

  Widget _buildPackageCard(PackageModel pkg) {
    return GestureDetector(
      onTap: () {
        controller.loadPackageDetail(pkg.id);
        Get.toNamed(AppRoutes.packageDetail, arguments: pkg.id);
      },
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
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.qr_code_rounded, size: 14, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      pkg.trackingCode,
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Transform.scale(
                    scale: 0.85,
                    alignment: Alignment.centerRight,
                    child: StatusBadge(status: pkg.currentStatus),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.person_rounded, size: 14, color: Color(0xFF3B82F6)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pkg.recipientName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (pkg.dimensionsLabel != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.straighten_rounded, size: 12, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 4),
                    Text(
                      pkg.dimensionsLabel!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupedNameView() {
    final grouped = controller.groupedByName;
    if (grouped.isEmpty) {
      return _buildEmptyState();
    }
    final entries = grouped.entries.toList();
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, index) {
        final name = entries[index].key;
        final pkgs = entries[index].value;
        final count = pkgs.length;
        return GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.packagesByName, arguments: name),
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
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Avatar circle with initials
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color((name.hashCode * 0x123456) | 0xFF000000).withValues(alpha: 0.15),
                          const Color(0xFFEFF6FF),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Name + count
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$count paket',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Add button
                  GestureDetector(
                    onTap: () => Get.toNamed(
                      AppRoutes.addPackage,
                      arguments: {'recipientName': name},
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add_rounded, size: 18, color: Color(0xFF3B82F6)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFFCBD5E1)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _statusIcon(PackageStatus status) {
    return switch (status) {
      PackageStatus.received => Icons.inbox_rounded,
      PackageStatus.inBox => Icons.inventory_2_rounded,
      PackageStatus.inTransit => Icons.local_shipping_rounded,
      PackageStatus.arrived => Icons.location_on_rounded,
      PackageStatus.completed => Icons.check_circle_rounded,
      PackageStatus.issue => Icons.warning_rounded,
    };
  }

  Widget _buildEmptyState() {
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
              Icons.inbox_rounded,
              size: 64,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            controller.searchQuery.value.isNotEmpty ? 'Tidak ditemukan' : 'Belum ada paket',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.searchQuery.value.isNotEmpty
                ? 'Coba kata kunci lain'
                : 'Tekan ikon + untuk menambahkan paket baru',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterOption({required this.label, required this.icon, required this.isSelected, required this.onTap});

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
