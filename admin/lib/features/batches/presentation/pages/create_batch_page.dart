import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../domain/batch_model.dart';
import '../controllers/batch_controller.dart';
import '../../../../core/utils/app_alerts.dart';

class CreateBatchPage extends StatefulWidget {
  const CreateBatchPage({super.key});

  @override
  State<CreateBatchPage> createState() => _CreateBatchPageState();
}

class _CreateBatchPageState extends State<CreateBatchPage> {
  final nameCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  
  DateTime? startDate;
  DateTime? expiryDate;
  bool isDateLocked = false;
  
  late final BatchController controller;
  final _dateFormat = DateFormat('dd MMMM yyyy', 'id');
  BatchModel? batchToEdit;

  @override
  void initState() {
    super.initState();
    controller = Get.find<BatchController>();
    
    final args = Get.arguments;
    if (args is Map<String, dynamic> && args['batchToEdit'] is BatchModel) {
      batchToEdit = args['batchToEdit'] as BatchModel;
      nameCtrl.text = batchToEdit!.name;
      cityCtrl.text = batchToEdit!.destinationCity;
      startDate = batchToEdit!.startDate;
      expiryDate = batchToEdit!.expiryDate;
      // Lock dates if batch is already dispatched or arrived
      isDateLocked = batchToEdit!.status != BatchStatus.collecting;
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final initialRange = (startDate != null && expiryDate != null)
        ? PickerDateRange(startDate, expiryDate)
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
                  'Pilih Rentang Waktu Box',
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
                    minDate: today,
                    maxDate: DateTime(2030),
                    startRangeSelectionColor: const Color(0xFF3B82F6),
                    endRangeSelectionColor: const Color(0xFF3B82F6),
                    rangeSelectionColor: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    todayHighlightColor: const Color(0xFF3B82F6),
                    selectionTextStyle: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                    rangeTextStyle: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
                    headerStyle: const DateRangePickerHeaderStyle(
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (selectedRange?.startDate != null && selectedRange?.endDate != null) {
                            setState(() {
                              startDate = selectedRange!.startDate;
                              expiryDate = selectedRange!.endDate;
                            });
                          }
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Simpan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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
    final topPadding = MediaQuery.of(context).padding.top;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            // ── Premium Gradient Header ──
            Container(
              width: double.infinity,
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
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            child: Row(
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
                Text(
                  batchToEdit != null ? 'Edit Kontainer' : 'Buat Box Baru',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          // ── Form Body ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildPremiumField(
                      controller: nameCtrl,
                      label: 'Nama box / kontainer',
                      hint: 'Contoh: Kontainer 1',
                      icon: Icons.all_inbox_rounded,
                      validator: (v) => v == null || v.isEmpty ? 'Nama box / kontainer wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildPremiumField(
                      controller: cityCtrl,
                      label: 'Kota Tujuan',
                      hint: 'Contoh: Sorong',
                      icon: Icons.location_city_rounded,
                      validator: (v) => v == null || v.isEmpty ? 'Kota tujuan wajib diisi' : null,
                    ),
                    const SizedBox(height: 24),

                    // Date Range Section
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 10),
                      child: Text(
                        'Rentang Waktu Box',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    _buildDateRangeField(),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom Action Bar ──
          Container(
            padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => Get.back(),
                        child: const Center(
                          child: Text(
                            'Batal',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: Obx(() => Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: !controller.isLoading.value
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFFE2E8F0),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: controller.isLoading.value
                            ? null
                            : () {
                                if (formKey.currentState?.validate() != true) return;
                                if (startDate != null && expiryDate == null) {
                                  AppAlerts.info('Tanggal kadaluarsa wajib diisi jika tanggal mulai sudah dipilih');
                                  return;
                                }
                                if (batchToEdit != null) {
                                  controller.updateBatch(
                                    id: batchToEdit!.id,
                                    name: nameCtrl.text.trim(),
                                    destinationCity: cityCtrl.text.trim(),
                                    startDate: startDate,
                                    expiryDate: expiryDate,
                                  );
                                } else {
                                  controller.createBatch(
                                    name: nameCtrl.text.trim(),
                                    destinationCity: cityCtrl.text.trim(),
                                    startDate: startDate,
                                    expiryDate: expiryDate,
                                  );
                                }
                              },
                        child: Center(
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                )
                              : const Text(
                                  'Simpan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  )),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildDateRangeField() {
    final hasDate = startDate != null && expiryDate != null;
    final text = hasDate 
        ? '${_dateFormat.format(startDate!)} - ${_dateFormat.format(expiryDate!)}'
        : 'Pilih rentang waktu (Mulai - Berakhir)';

    return GestureDetector(
      onTap: isDateLocked ? null : _pickDateRange,
      child: Opacity(
        opacity: isDateLocked ? 0.6 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: isDateLocked ? const Color(0xFFF1F5F9) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFCBD5E1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isDateLocked ? Icons.lock_rounded : Icons.date_range_rounded,
                  color: isDateLocked ? const Color(0xFF94A3B8) : const Color(0xFF3B82F6),
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDateLocked ? 'Rentang Waktu Box (Terkunci)' : 'Rentang Waktu Box',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      text,
                      style: TextStyle(
                        color: hasDate ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isDateLocked)
                const Icon(Icons.lock_outline_rounded, color: Color(0xFF94A3B8), size: 20)
              else if (hasDate)
                GestureDetector(
                  onTap: () => setState(() {
                    startDate = null;
                    expiryDate = null;
                  }),
                  child: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8), size: 20),
                )
              else
                const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B), fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
      ),
    );
  }
}
