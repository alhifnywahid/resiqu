import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';
import '../../core/utils/app_alerts.dart';

class BatchExportFilterSheet extends StatefulWidget {
  final Future<void> Function(
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String format,
  ) onExport;

  const BatchExportFilterSheet({
    super.key,
    required this.onExport,
  });

  @override
  State<BatchExportFilterSheet> createState() => _BatchExportFilterSheetState();
}

class _BatchExportFilterSheetState extends State<BatchExportFilterSheet> {
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedFormat = 'excel';
  bool _isExporting = false;

  void _pickDateRange() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final initialRange = (_startDate != null && _endDate != null)
        ? PickerDateRange(_startDate, _endDate)
        : null;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        PickerDateRange? selectedRange = initialRange;
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Pilih Rentang Tanggal Export',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SfDateRangePicker(
                    selectionMode: DateRangePickerSelectionMode.range,
                    initialSelectedRange: initialRange,
                    maxDate: DateTime(2030),
                    startRangeSelectionColor: const Color(0xFF3B82F6),
                    endRangeSelectionColor: const Color(0xFF3B82F6),
                    rangeSelectionColor: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    todayHighlightColor: const Color(0xFF3B82F6),
                    selectionTextStyle: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                    rangeTextStyle: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
                    onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                      if (args.value is PickerDateRange) {
                        selectedRange = args.value;
                      }
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (selectedRange?.startDate != null) {
                            setState(() {
                              _startDate = selectedRange!.startDate;
                              _endDate = selectedRange!.endDate ?? selectedRange!.startDate;
                            });
                          }
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text('Simpan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusMap = {
      'open': 'Terbuka',
      'dispatched': 'Dikirim',
      'arrived': 'Tiba di Tujuan',
    };

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
              child: DropdownButton<String?>(
                value: _selectedStatus,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8)),
                hint: const Text('Semua Status', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15)),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Semua Status', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
                  ...statusMap.entries.map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                      )),
                ],
                onChanged: (val) {
                  setState(() => _selectedStatus = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Filter Rentang Tanggal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickDateRange,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_rounded, color: Color(0xFF94A3B8), size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _startDate == null
                          ? 'Pilih Rentang Tanggal (Opsional)'
                          : '${DateFormat('dd MMM yyyy').format(_startDate!)} - ${DateFormat('dd MMM yyyy').format(_endDate!)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: _startDate == null ? FontWeight.w400 : FontWeight.w600,
                        color: _startDate == null ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  if (_startDate != null)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _startDate = null;
                          _endDate = null;
                        });
                      },
                      child: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8), size: 20),
                    ),
                ],
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
                      await widget.onExport(_selectedStatus, _startDate, _endDate, _selectedFormat);
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
