import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_alerts.dart';
import '../../../../core/constants/package_status.dart';
import '../../../batches/presentation/controllers/batch_controller.dart';
import '../../domain/package_model.dart';

class ExportFilterByNameSheet extends StatefulWidget {
  final List<PackageModel> packages;
  final Future<void> Function(
    PackageStatus? status,
    String? batchId,
    String format,
  ) onExport;

  const ExportFilterByNameSheet({
    super.key,
    required this.packages,
    required this.onExport,
  });

  @override
  State<ExportFilterByNameSheet> createState() => _ExportFilterByNameSheetState();
}

class _ExportFilterByNameSheetState extends State<ExportFilterByNameSheet> {
  PackageStatus? _selectedStatus;
  String? _selectedBatchId;
  String _selectedFormat = 'excel';
  bool _isExporting = false;

  late final List<PackageStatus> _availableStatuses;
  late final List<String> _availableBatchIds;

  @override
  void initState() {
    super.initState();
    _availableStatuses = widget.packages
        .map((p) => p.currentStatus)
        .toSet()
        .toList();
    _availableBatchIds = widget.packages
        .map((p) => p.batchId)
        .where((id) => id != null && id.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Opsi Unduh / Export',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Format Dokumen', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFormatOption('excel', 'Excel', Icons.table_chart_rounded, const Color(0xFF10B981)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFormatOption('pdf', 'PDF', Icons.picture_as_pdf_rounded, const Color(0xFFEF4444)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Filter Status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<PackageStatus?>(
                value: _selectedStatus,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8)),
                hint: const Text('Semua Status', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15)),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Semua Status', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
                  ..._availableStatuses.map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                      )),
                ],
                onChanged: (val) {
                  setState(() => _selectedStatus = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Filter Kontainer / Box', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: DropdownButtonHideUnderline(
              child: GetBuilder<BatchController>(
                builder: (batchController) {
                  final batches = batchController.batches
                      .where((b) => _availableBatchIds.contains(b.id))
                      .toList();
                  return DropdownButton<String?>(
                    value: _selectedBatchId,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8)),
                    hint: const Text('Semua Kontainer', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15)),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Semua Kontainer', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
                      ...batches.map((b) => DropdownMenuItem(
                            value: b.id,
                            child: Text(b.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                          )),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedBatchId = val);
                    },
                  );
                }
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isExporting
                ? null
                : () async {
                    final nav = Navigator.of(context);
                    setState(() => _isExporting = true);
                    try {
                      await widget.onExport(_selectedStatus, _selectedBatchId, _selectedFormat);
                      nav.pop();
                    } catch (e) {
                      AppAlerts.error('Gagal export: $e', title: 'Export Gagal');
                    } finally {
                      if (mounted) setState(() => _isExporting = false);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: _isExporting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download_rounded, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Unduh Sekarang', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatOption(String value, String label, IconData icon, Color iconColor) {
    final isSelected = _selectedFormat == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFormat = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
          border: Border.all(color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0), width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF64748B), fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
