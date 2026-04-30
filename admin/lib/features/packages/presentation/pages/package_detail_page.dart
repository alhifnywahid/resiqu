import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/package_status.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/export_service.dart';
import '../../../../core/utils/app_alerts.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../batches/presentation/controllers/batch_controller.dart';
import '../../../batches/domain/batch_model.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/package_controller.dart';

class PackageDetailPage extends GetView<PackageController> {
  const PackageDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Obx(() {
        final pkg = controller.selectedPackage.value;
        if (pkg == null) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
        }

        final double topPadding = MediaQuery.of(context).padding.top;
        final double headerHeight = topPadding + 100.0;

        return Stack(
          children: [
            // SCROLLABLE BODY
            Positioned.fill(
              child: ListView(
                padding: EdgeInsets.fromLTRB(20, headerHeight + 8, 20, 40),
                children: [
                    // Status Action Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Status Terkini',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                StatusBadge(status: pkg.currentStatus),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Info Details Card
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 12),
                      child: Text(
                        'Informasi Penerima',
                        style: TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _DetailRow(icon: Icons.receipt_long_rounded, label: 'Nomor Resi', value: pkg.trackingCode),
                          const Divider(height: 24, color: Color(0xFFF1F5F9)),
                          _DetailRow(icon: Icons.person_rounded, label: 'Nama Penerima', value: pkg.recipientName),
                          
                          if (pkg.recipientPhone.isNotEmpty) ...[
                            const Divider(height: 24, color: Color(0xFFF1F5F9)),
                            _DetailRow(icon: Icons.phone_rounded, label: 'Nomor HP', value: pkg.recipientPhone),
                          ],
                          
                          if (pkg.dimensionsLabel != null) ...[
                            const Divider(height: 24, color: Color(0xFFF1F5F9)),
                            _DetailRow(icon: Icons.straighten_rounded, label: AppStrings.dimensions, value: pkg.dimensionsLabel!),
                          ],

                          const Divider(height: 24, color: Color(0xFFF1F5F9)),
                          if (pkg.batchId != null) ...[
                            _DetailRow(
                              icon: Icons.inventory_2_rounded,
                              label: 'Kontainer / Box',
                              value: Get.isRegistered<BatchController>() 
                                ? (Get.find<BatchController>().batches.firstWhereOrNull((b) => b.id == pkg.batchId)?.name ?? pkg.batchId!) 
                                : pkg.batchId!,
                            ),
                          ] else ...[
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.inventory_2_rounded, size: 18, color: Color(0xFF64748B)),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Kontainer / Box', style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Belum dimasukkan ke box',
                                        style: TextStyle(
                                          color: const Color(0xFF94A3B8),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _showBatchSelectionSheet(context, pkg.id),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.add_box_rounded, size: 22, color: Color(0xFF3B82F6)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Status History Timeline
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 16),
                      child: Text(
                        'Riwayat Perjalanan',
                        style: TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Obx(() {
                      if (controller.statusHistory.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Text('Belum ada riwayat tercatat.', style: TextStyle(color: Color(0xFF94A3B8))),
                          ),
                        );
                      }
                      
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: controller.statusHistory.length,
                        itemBuilder: (context, index) {
                          final h = controller.statusHistory[index];
                          final status = PackageStatus.fromValue(h.status);
                          final isFirst = index == 0;
                          final isLast = index == controller.statusHistory.length - 1;

                          return IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Timeline line & dot
                                SizedBox(
                                  width: 40,
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 2,
                                        height: 20,
                                        color: isFirst ? Colors.transparent : const Color(0xFFE2E8F0),
                                      ),
                                      Container(
                                        width: 14,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: isFirst ? const Color(0xFF3B82F6) : const Color(0xFFCBD5E1),
                                          shape: BoxShape.circle,
                                          border: isFirst ? Border.all(color: const Color(0xFFBFDBFE), width: 3) : null,
                                          boxShadow: isFirst ? [
                                            BoxShadow(
                                              color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                                              blurRadius: 10,
                                              spreadRadius: 3,
                                            )
                                          ] : null,
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          width: 2,
                                          color: isLast ? Colors.transparent : const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Content
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 24),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: isFirst ? Colors.white : const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isFirst ? const Color(0xFF3B82F6).withValues(alpha: 0.2) : const Color(0xFFE2E8F0),
                                          width: 1,
                                        ),
                                        boxShadow: isFirst ? [
                                          BoxShadow(
                                            color: const Color(0xFF3B82F6).withValues(alpha: 0.05),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          )
                                        ] : [],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              StatusBadge(status: status),
                                              Text(
                                                DateFormatter.timeAgo(h.timestamp),
                                                style: const TextStyle(
                                                  color: Color(0xFF94A3B8),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (h.note.isNotEmpty) ...[
                                            const SizedBox(height: 12),
                                            Text(
                                              h.note,
                                              style: TextStyle(
                                                color: isFirst ? const Color(0xFF1E293B) : const Color(0xFF475569),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Icon(Icons.person_rounded, size: 14, color: isFirst ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                                              const SizedBox(width: 6),
                                              Builder(
                                                builder: (context) {
                                                  // Look up admin name from SettingsController
                                                  String displayUser = h.updatedBy.split('@').first;
                                                  if (Get.isRegistered<SettingsController>()) {
                                                    final admins = Get.find<SettingsController>().adminList;
                                                    final match = admins.firstWhereOrNull((a) => a['email'] == h.updatedBy);
                                                    if (match != null && match['name']!.isNotEmpty) {
                                                      displayUser = match['name']!;
                                                    }
                                                  }
                                                  return Text(
                                                    displayUser,
                                                    style: TextStyle(
                                                      color: isFirst ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  );
                                                }
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }),
                  ],
                ),
              ),

              // FIXED HEADER
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    top: topPadding + 16,
                    left: 20,
                    right: 20,
                    bottom: 24,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(36),
                      bottomRight: Radius.circular(36),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'Detail Paket',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          // Actions button
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
                                _showEditPackageSheet(context, pkg);
                              } else if (value == 'delete') {
                                _confirmDeletePackage(context, pkg);
                              } else if (value == 'export') {
                                _showExportFormatSheet(context, pkg);
                              }
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_rounded, color: const Color(0xFFEAB308), size: 20),
                                    const SizedBox(width: 12),
                                    const Text('Edit Paket', style: TextStyle(fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              const PopupMenuDivider(),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline_rounded, color: const Color(0xFFEF4444), size: 20),
                                    const SizedBox(width: 12),
                                    const Text('Hapus Paket', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFEF4444))),
                                  ],
                                ),
                              ),
                              const PopupMenuDivider(),
                              PopupMenuItem(
                                value: 'export',
                                child: Row(
                                  children: [
                                    Icon(Icons.file_download_outlined, color: const Color(0xFF3B82F6), size: 20),
                                    const SizedBox(width: 12),
                                    const Text('Export Paket', style: TextStyle(fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
      }),
    );
  }

  void _showExportFormatSheet(BuildContext context, dynamic pkg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Pilih Format Export',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        ExportService.exportToExcel([pkg], context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.table_chart_rounded, color: Color(0xFF10B981), size: 32),
                            SizedBox(height: 8),
                            Text(
                              'Excel (.xlsx)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        ExportService.exportToPdf([pkg], context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFEF4444), size: 32),
                            SizedBox(height: 8),
                            Text(
                              'PDF (.pdf)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditPackageSheet(BuildContext context, dynamic pkg) {
    final resiCtrl = TextEditingController(text: pkg.trackingCode);
    final nameCtrl = TextEditingController(text: pkg.recipientName);
    final pCtrl = TextEditingController(text: pkg.dimensions?['p']?.toString() ?? '');
    final lCtrl = TextEditingController(text: pkg.dimensions?['l']?.toString() ?? '');
    final tCtrl = TextEditingController(text: pkg.dimensions?['t']?.toString() ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Edit Paket',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: resiCtrl,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Nomor Resi',
                      prefixIcon: const Icon(Icons.receipt_long_rounded, size: 20, color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5)),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameCtrl,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Nama Penerima',
                      prefixIcon: const Icon(Icons.person_rounded, size: 20, color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5)),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 20),
                  const Text('Ukuran (opsional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildDimField(pCtrl, 'P')),
                      const SizedBox(width: 8),
                      const Text('×', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
                      const SizedBox(width: 8),
                      Expanded(child: _buildDimField(lCtrl, 'L')),
                      const SizedBox(width: 8),
                      const Text('×', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
                      const SizedBox(width: 8),
                      Expanded(child: _buildDimField(tCtrl, 'T')),
                      const SizedBox(width: 8),
                      const Text('cm', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
                    ],
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState?.validate() != true) return;
                        Map<String, double>? dims;
                        final p = double.tryParse(pCtrl.text);
                        final l = double.tryParse(lCtrl.text);
                        final t = double.tryParse(tCtrl.text);
                        if (p != null && l != null && t != null) {
                          dims = {'p': p, 'l': l, 't': t};
                        }
                        Navigator.pop(context);
                        try {
                          await controller.updatePackage(
                            id: pkg.id,
                            trackingCode: resiCtrl.text.trim(),
                            recipientName: nameCtrl.text.trim(),
                            batchId: pkg.batchId,
                            dimensions: dims,
                          );
                          AppAlerts.success('Paket berhasil diperbarui');
                        } catch (e) {
                          final msg = e.toString().replaceFirst('Exception: ', '');
                          AppAlerts.error(msg, title: 'Gagal');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text('Simpan Perubahan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDimField(TextEditingController ctrl, String label) {
    return TextFormField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      ),
    );
  }

  void _confirmDeletePackage(BuildContext context, dynamic pkg) {
    AppAlerts.confirmSheet(
      context: context,
      title: 'Hapus Paket',
      description: 'Yakin ingin menghapus paket "${pkg.trackingCode}"? Data riwayat juga akan dihapus dan tidak dapat dikembalikan.',
      confirmLabel: 'Hapus',
      confirmColor: const Color(0xFFEF4444),
      icon: Icons.delete_outline_rounded,
      iconColor: const Color(0xFFEF4444),
      onConfirm: () async {
        try {
          // If package is in a batch, remove from batch's packageIds
          if (pkg.batchId != null && pkg.batchId!.isNotEmpty) {
            await FirebaseFirestore.instance.collection('batches').doc(pkg.batchId).update({
              'packageIds': FieldValue.arrayRemove([pkg.id]),
            });
          }
          await controller.deletePackage(pkg.id);
          // Navigate back FIRST, then show success alert
          Get.back();
          Future.delayed(const Duration(milliseconds: 200), () {
            AppAlerts.success('Paket berhasil dihapus');
          });
        } catch (e) {
          AppAlerts.error(e.toString(), title: 'Gagal Menghapus');
        }
      },
    );
  }

  void _showBatchSelectionSheet(BuildContext context, String packageId) {
    String? selectedBatchId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) {
          final batchCtrl = Get.find<BatchController>();

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.55,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Obx(() {
              final openBatches = batchCtrl.batches
                  .where((b) => b.status == BatchStatus.collecting && !b.isExpired)
                  .toList();
              
              return Column(
                mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Pilih Kontainer / Box',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Masukkan paket ini ke salah satu box yang masih terbuka.',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 20),
                if (openBatches.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 40, color: const Color(0xFFCBD5E1)),
                          const SizedBox(height: 12),
                          const Text(
                            'Belum ada box terbuka',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: openBatches.length,
                      itemBuilder: (_, i) {
                        final batch = openBatches[i];
                        final isSelected = selectedBatchId == batch.id;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
                              width: isSelected ? 2 : 1,
                            ),
                            color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => setState(() => selectedBatchId = batch.id),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isSelected ? const Color(0xFF3B82F6).withValues(alpha: 0.15) : const Color(0xFFF1F5F9),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.inventory_2_rounded,
                                        size: 20,
                                        color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF64748B),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            batch.name,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                              color: isSelected ? const Color(0xFF1E40AF) : const Color(0xFF334155),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${batch.destinationCity} · ${batch.packageIds.length} paket',
                                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(Icons.check_circle_rounded, color: Color(0xFF3B82F6), size: 24),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.pop(ctx),
                            child: const Center(
                              child: Text(
                                'Batal',
                                style: TextStyle(color: Color(0xFF64748B), fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: selectedBatchId == null ? const Color(0xFFCBD5E1) : const Color(0xFF3B82F6),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: selectedBatchId == null
                                ? null
                                : () async {
                                    Navigator.pop(ctx);
                                    await _assignPackageToBatch(packageId, selectedBatchId!);
                                  },
                            child: const Center(
                              child: Text(
                                'Simpan',
                                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
            }),
          );
        },
      ),
    );
  }

  Future<void> _assignPackageToBatch(String packageId, String batchId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final authCtrl = Get.find<AuthController>();
      final email = authCtrl.adminEmail;
      if (email.isEmpty) {
        throw Exception('Sesi admin tidak valid atau email kosong.');
      }

      final batch = firestore.batch();
      final packageRef = firestore.collection('packages').doc(packageId);
      batch.update(packageRef, {
        'batchId': batchId,
        'currentStatus': PackageStatus.inBox.value,
        'updatedBy': email, // Exact match with token
        'updatedAt': FieldValue.serverTimestamp(),
      });
      batch.update(firestore.collection('batches').doc(batchId), {
        'packageIds': FieldValue.arrayUnion([packageId]),
      });
      batch.set(packageRef.collection('statusHistory').doc(), {
        'status': PackageStatus.inBox.value,
        'note': 'Paket dimasukkan ke dalam kontainer/box',
        'updatedBy': email,
        'timestamp': FieldValue.serverTimestamp(),
      });
      await batch.commit();

      AppAlerts.success('Paket dimasukkan ke box');

      // Refresh the package
      controller.loadPackageDetail(packageId);
    } catch (e) {
      AppAlerts.error('Tidak dapat memasukkan paket: $e', title: 'Gagal');
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF64748B)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
