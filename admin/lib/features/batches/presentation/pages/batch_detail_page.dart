import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/export_service.dart';
import '../../../../core/utils/app_alerts.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../packages/domain/package_model.dart';
import '../../../packages/data/package_repository.dart';
import '../../data/batch_repository.dart';
import '../../domain/batch_model.dart';
import '../controllers/batch_controller.dart';
import '../../../packages/presentation/controllers/package_controller.dart';

class BatchDetailPage extends StatefulWidget {
  const BatchDetailPage({super.key});

  @override
  State<BatchDetailPage> createState() => _BatchDetailPageState();
}

class _BatchDetailPageState extends State<BatchDetailPage> {
  final BatchController _batchCtrl = Get.find<BatchController>();
  final PackageRepository _pkgRepo = Get.find<PackageRepository>();

  late BatchModel batch;
  List<PackageModel> packages = [];
  bool isLoadingPackages = true;
  String creatorName = '';

  static final _dateFormat = DateFormat('dd MMM yyyy', 'id');
  static const _statusColors = {
    BatchStatus.collecting: Color(0xFF3B82F6),
    BatchStatus.dispatched: Color(0xFFFF8C42),
    BatchStatus.arrived: Color(0xFF11998E),
  };

  @override
  void initState() {
    super.initState();
    batch = Get.arguments as BatchModel;
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    setState(() => isLoadingPackages = true);
    try {
      final updatedBatch = await Get.find<BatchRepository>().getBatchById(batch.id);
      if (updatedBatch != null) {
        batch = updatedBatch;
      }
      if (batch.packageIds.isEmpty) {
        packages = [];
      } else {
        packages = await _pkgRepo.getPackagesByIds(batch.packageIds);
      }
      
      try {
        final adminDoc = await FirebaseFirestore.instance.collection('admins').doc(batch.createdBy).get();
        if (adminDoc.exists) {
          creatorName = adminDoc.data()?['name'] ?? batch.createdBy.split('@').first;
        } else {
          creatorName = batch.createdBy.split('@').first;
        }
      } catch (_) {
        creatorName = batch.createdBy.split('@').first;
      }
    } catch (_) {
      packages = [];
      creatorName = batch.createdBy.split('@').first;
    }
    if (mounted) setState(() => isLoadingPackages = false);
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = batch.isExpired && batch.status == BatchStatus.collecting;
    final color = isExpired
        ? const Color(0xFFEF4444)
        : (_statusColors[batch.status] ?? Colors.grey);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // ── Header ──
          _buildHeader(context, color, isExpired),
          // ── Content ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildCombinedInfoSection(color, isExpired),
                  const SizedBox(height: 24),
                  _buildPackageSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget? _buildBottomActions() {
    if (batch.status != BatchStatus.collecting && batch.status != BatchStatus.dispatched) {
      return null;
    }
    
    final isCollecting = batch.status == BatchStatus.collecting;
    
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => isCollecting ? _confirmDispatch(context) : _confirmArrive(context),
        icon: Icon(isCollecting ? Icons.send_rounded : Icons.flight_land_rounded, color: Colors.white),
        label: Text(
          isCollecting ? 'Kirim Box' : 'Konfirmasi Tiba di Tujuan',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isCollecting ? const Color(0xFF3B82F6) : const Color(0xFF11998E),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────
  // HEADER
  // ───────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, Color color, bool isExpired) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nav row
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      batch.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 20),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                offset: const Offset(0, 48),
                onSelected: (value) {
                  if (value == 'edit') {
                    Get.toNamed(AppRoutes.createBatch, arguments: {'batchToEdit': batch})?.then((_) => _loadPackages());
                  } else if (value == 'export') {
                    final sorted = List<PackageModel>.from(packages)
                      ..sort((a, b) => a.recipientName.toLowerCase().compareTo(b.recipientName.toLowerCase()));
                    ExportService.exportToExcel(sorted, context);
                  }
                },
                itemBuilder: (_) => [
                  if (batch.status == BatchStatus.collecting)
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded, color: const Color(0xFFEAB308), size: 20),
                          const SizedBox(width: 12),
                          const Text('Edit Kontainer', style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  if (batch.status == BatchStatus.collecting)
                    const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'export',
                    child: Row(
                      children: [
                        Icon(Icons.table_chart_rounded, color: const Color(0xFF10B981), size: 20),
                        const SizedBox(width: 12),
                        const Text('Export (Urut Nama)', style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────
  // COMBINED INFO SECTION
  // ───────────────────────────────────────────────
  Widget _buildCombinedInfoSection(Color color, bool isExpired) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _InfoTile(
              icon: Icons.lens_rounded,
              iconColor: color,
              label: 'Status',
              value: batch.statusLabel,
              valueColor: color,
              isStatus: true,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),
            _InfoTile(
              icon: Icons.inventory_2_outlined,
              iconColor: const Color(0xFF3B82F6),
              label: 'Nama Kontainer',
              value: batch.name,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),
            _InfoTile(
              icon: Icons.pin_drop_outlined,
              iconColor: const Color(0xFFF59E0B),
              label: 'Kota Tujuan',
              value: batch.destinationCity,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),
            _InfoTile(
              icon: Icons.date_range_rounded,
              iconColor: const Color(0xFF10B981),
              label: 'Rentang Waktu',
              value: (batch.startDate != null && batch.expiryDate != null)
                  ? '${_dateFormat.format(batch.startDate!)} - ${_dateFormat.format(batch.expiryDate!)}'
                  : 'Tidak ada batas waktu',
              valueColor: isExpired ? const Color(0xFFEF4444) : null,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),
            _InfoTile(
              icon: Icons.access_time_rounded,
              iconColor: const Color(0xFF8B5CF6),
              label: 'Dibuat Pada',
              value: _dateFormat.format(batch.createdAt),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),
            _InfoTile(
              icon: Icons.person_outline_rounded,
              iconColor: const Color(0xFF0EA5E9),
              label: 'Dibuat Oleh',
              value: creatorName.isEmpty ? 'Loading...' : creatorName,
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────
  // PACKAGE LIST SECTION
  // ───────────────────────────────────────────────
  Widget _buildPackageSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Daftar Paket',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${batch.packageIds.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                  ),
                ],
              ),
              if (batch.status == BatchStatus.collecting)
                SizedBox(
                  height: 32,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddPackagesSheet(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Tambah', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          // Content
          if (isLoadingPackages)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: const CircularProgressIndicator(
                color: Color(0xFF3B82F6),
                strokeWidth: 2.5,
              ),
            )
          else if (packages.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.inbox_rounded, size: 36, color: Color(0xFFCBD5E1)),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Belum ada paket',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tambahkan paket melalui halaman paket',
                    style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...packages.map((pkg) => _PackageCard(
                  pkg: pkg,
                  onTap: () {
                    Get.find<PackageController>().loadPackageDetail(pkg.id);
                    Get.toNamed(AppRoutes.packageDetail, arguments: pkg.id);
                  },
                )),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────
  // DISPATCH DIALOG
  // ───────────────────────────────────────────────
  void _confirmDispatch(BuildContext context) {
    if (batch.status != BatchStatus.collecting) return;
    AppAlerts.confirmSheet(
      context: context,
      title: 'Kirim Box?',
      description: 'Box "${batch.name}" akan dikirim ke ${batch.destinationCity}.\nStatus ${batch.packageIds.length} paket akan berubah ke "Dalam Perjalanan".',
      confirmLabel: 'Kirim Sekarang',
      icon: Icons.local_shipping_rounded,
      onConfirm: () async {
        await _batchCtrl.dispatchBatch(batch);
        await _loadPackages();
      },
    );
  }

  void _confirmArrive(BuildContext context) {
    if (batch.status != BatchStatus.dispatched) return;
    AppAlerts.confirmSheet(
      context: context,
      title: 'Box Tiba di Tujuan?',
      description: 'Box "${batch.name}" telah tiba di ${batch.destinationCity}.\nStatus ${batch.packageIds.length} paket akan berubah ke "Tiba di Tujuan".',
      confirmLabel: 'Konfirmasi Tiba',
      confirmColor: const Color(0xFF11998E),
      icon: Icons.flight_land_rounded,
      iconColor: const Color(0xFF11998E),
      onConfirm: () async {
        await _batchCtrl.arriveBatch(batch);
        await _loadPackages();
      },
    );
  }

  void _showAddPackagesSheet(BuildContext context) {
    _batchCtrl.loadAvailablePackages();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'Tambah Paket',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  if (_batchCtrl.isLoading.value) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
                  }
                  
                  final packages = _batchCtrl.availablePackages;
                  final selectedIds = _batchCtrl.selectedPackageIds.toSet(); // force GetX to track this

                  if (packages.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada paket yang tersedia', style: TextStyle(color: Color(0xFF94A3B8))),
                    );
                  }

                  final allSelected = selectedIds.length == packages.length;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${selectedIds.length} terpilih dari ${packages.length}',
                              style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                if (allSelected) {
                                  _batchCtrl.selectedPackageIds.clear();
                                } else {
                                  _batchCtrl.selectedPackageIds.assignAll(packages.map((p) => p.id));
                                }
                              },
                              icon: Icon(
                                allSelected ? Icons.deselect_rounded : Icons.select_all_rounded,
                                size: 18,
                              ),
                              label: Text(allSelected ? 'Batal Semua' : 'Pilih Semua'),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF3B82F6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: packages.length,
                          itemBuilder: (context, index) {
                            final pkg = packages[index];
                            final isSelected = selectedIds.contains(pkg.id);
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                                border: Border.all(color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                onTap: () => _batchCtrl.togglePackageSelection(pkg.id),
                                leading: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
                                    border: Border.all(color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFCBD5E1), width: 1.5),
                                  ),
                                  child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                                ),
                                title: Text(pkg.trackingCode, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                                subtitle: Text(pkg.recipientName, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, -5)),
                  ],
                ),
                child: Obx(() {
                  final selectedCount = _batchCtrl.selectedPackageIds.length;
                  return ElevatedButton(
                    onPressed: selectedCount == 0 || _batchCtrl.isLoading.value
                        ? null
                        : () async {
                            final success = await _batchCtrl.addPackagesToBatch(batch.id, _batchCtrl.selectedPackageIds);
                            if (success) {
                              _batchCtrl.selectedPackageIds.clear();
                              Get.back();
                              _loadPackages();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _batchCtrl.isLoading.value
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : Text('Tambah $selectedCount Paket', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════
// REUSABLE WIDGETS
// ══════════════════════════════════════════════════



class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final Color? valueColor;
  final bool isStatus;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.valueColor,
    this.isStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (iconColor ?? const Color(0xFF94A3B8)).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: iconColor ?? const Color(0xFF94A3B8)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 4),
              isStatus
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (valueColor ?? const Color(0xFF1E293B)).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: valueColor ?? const Color(0xFF1E293B),
                        ),
                      ),
                    )
                  : Text(
                      value,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: valueColor ?? const Color(0xFF1E293B),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PackageCard extends StatelessWidget {
  final PackageModel pkg;
  final VoidCallback onTap;

  const _PackageCard({required this.pkg, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.inventory_2_rounded, size: 20, color: Color(0xFF64748B)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pkg.recipientName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    pkg.trackingCode,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF94A3B8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            StatusBadge(status: pkg.currentStatus),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }
}
