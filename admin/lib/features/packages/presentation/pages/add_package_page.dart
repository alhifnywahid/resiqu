import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/scanner_sheet.dart';
import '../../../batches/presentation/controllers/batch_controller.dart';
import '../../../batches/domain/batch_model.dart';
import '../controllers/package_controller.dart';
import '../../data/package_repository.dart';

class AddPackagePage extends StatefulWidget {
  final String? initialResi;
  
  const AddPackagePage({
    super.key,
    this.initialResi,
  });

  @override
  State<AddPackagePage> createState() => _AddPackagePageState();
}

class _AddPackagePageState extends State<AddPackagePage> {
  final formKey = GlobalKey<FormState>();
  final resiCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final pCtrl = TextEditingController();
  final lCtrl = TextEditingController();
  final tCtrl = TextEditingController();
  String? selectedBatchId;
  bool showDimensions = false;
  List<String> recipientNames = [];
  
  late final PackageController controller;
  late final BatchController batchCtrl;

  @override
  void initState() {
    super.initState();
    controller = Get.find<PackageController>();
    batchCtrl = Get.find<BatchController>();
    
    // Support both constructor param and route arguments
    final rawArgs = Get.arguments;
    final args = rawArgs is Map<String, dynamic> ? rawArgs : null;
    final resi = widget.initialResi ?? (args?['resi'] is String ? args!['resi'] as String : null);
    if (resi != null) {
      resiCtrl.text = resi;
    }
    final recipientNameArg = args?['recipientName'] is String ? args!['recipientName'] as String : null;
    if (recipientNameArg != null && recipientNameArg.isNotEmpty) {
      nameCtrl.text = recipientNameArg;
    }
    
    // Load recipient name suggestions
    _loadRecipientNames();
  }

  Future<void> _loadRecipientNames() async {
    try {
      final names = await Get.find<PackageRepository>().getDistinctRecipientNames();
      if (mounted) setState(() => recipientNames = names);
    } catch (_) {}
  }

  @override
  void dispose() {
    resiCtrl.dispose();
    nameCtrl.dispose();
    pCtrl.dispose();
    lCtrl.dispose();
    tCtrl.dispose();
    super.dispose();
  }

  Map<String, double>? _parseDimensions() {
    if (!showDimensions) return null;
    final p = double.tryParse(pCtrl.text.trim());
    final l = double.tryParse(lCtrl.text.trim());
    final t = double.tryParse(tCtrl.text.trim());
    if (p == null || l == null || t == null) return null;
    return {'p': p, 'l': l, 't': t};
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
                const Text(
                  AppStrings.addPackage,
                  style: TextStyle(
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
                    // Scan Input
                    TextFormField(
                      controller: resiCtrl,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B), fontSize: 14),
                      decoration: InputDecoration(
                        labelText: AppStrings.marketplaceResi,
                        labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                        hintText: 'Contoh: SPX123...',
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
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Generate RSQ button
                            IconButton(
                              icon: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFEAB308), size: 20),
                              tooltip: 'Generate No Resi Otomatis',
                              onPressed: () {
                                const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
                                final rand = Random.secure();
                                final code = List.generate(8, (_) => chars[rand.nextInt(chars.length)]).join();
                                resiCtrl.text = 'RSQ$code';
                              },
                            ),
                            // QR Scanner button
                            IconButton(
                              icon: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF3B82F6), size: 20),
                              onPressed: () async {
                                final code = await showScannerSheet(context);
                                if (code != null && code.isNotEmpty) {
                                  resiCtrl.text = code;
                                }
                              },
                            ),
                          ],
                        ),
                        prefixIcon: const Icon(Icons.confirmation_number_rounded, color: Color(0xFF94A3B8), size: 20),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Resi wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    // Nama Penerima with Autocomplete
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return recipientNames.take(10);
                            }
                            final query = textEditingValue.text.toLowerCase();
                            return recipientNames.where(
                              (name) => name.toLowerCase().contains(query),
                            ).take(10);
                          },
                          onSelected: (String selected) {
                            nameCtrl.text = selected;
                          },
                          optionsMaxHeight: 200,
                          optionsViewOpenDirection: OptionsViewOpenDirection.down,
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 8,
                                shadowColor: Colors.black26,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: constraints.maxWidth,
                                  constraints: const BoxConstraints(maxHeight: 200),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: ListView.separated(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                                    itemBuilder: (context, index) {
                                      final option = options.elementAt(index);
                                      return ListTile(
                                        dense: true,
                                        visualDensity: VisualDensity.compact,
                                        leading: const Icon(Icons.person_outline_rounded, size: 18, color: Color(0xFF94A3B8)),
                                        title: Text(
                                          option,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                        onTap: () => onSelected(option),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                          fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
                            // Sync controllers
                            textController.text = nameCtrl.text;
                            textController.addListener(() {
                              if (nameCtrl.text != textController.text) {
                                nameCtrl.text = textController.text;
                              }
                            });
                            return TextFormField(
                              controller: textController,
                              focusNode: focusNode,
                              style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B), fontSize: 14),
                              decoration: InputDecoration(
                                labelText: AppStrings.recipientName,
                                labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                                hintText: 'Ketik untuk mencari atau tambah baru...',
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
                                prefixIcon: const Icon(Icons.person_rounded, color: Color(0xFF94A3B8), size: 20),
                                suffixIcon: recipientNames.isNotEmpty
                                    ? const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF94A3B8))
                                    : null,
                              ),
                              validator: (v) => v == null || v.isEmpty ? 'Nama penerima wajib diisi' : null,
                              onFieldSubmitted: (_) => onFieldSubmitted(),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Dimensions Toggle
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => setState(() => showDimensions = !showDimensions),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.straighten_rounded,
                                  color: showDimensions ? const Color(0xFF3B82F6) : const Color(0xFF94A3B8),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    AppStrings.addDimensions,
                                    style: TextStyle(
                                      color: showDimensions ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  'Opsional',
                                  style: TextStyle(
                                    color: const Color(0xFF94A3B8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                AnimatedRotation(
                                  turns: showDimensions ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    Icons.expand_more_rounded,
                                    color: showDimensions ? const Color(0xFF3B82F6) : const Color(0xFF94A3B8),
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Dimensions Fields
                    if (showDimensions)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(
                          children: [
                            Expanded(child: _buildDimensionField(pCtrl, AppStrings.dimensionP)),
                            const SizedBox(width: 8),
                            const Text('×', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 18, fontWeight: FontWeight.w700)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildDimensionField(lCtrl, AppStrings.dimensionL)),
                            const SizedBox(width: 8),
                            const Text('×', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 18, fontWeight: FontWeight.w700)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildDimensionField(tCtrl, AppStrings.dimensionT)),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    
                    Obx(() {
                      final openBatches = batchCtrl.batches.where((b) => b.status == BatchStatus.collecting).toList();
                      
                      return DropdownButtonFormField<String?>(
                        initialValue: selectedBatchId,
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B), fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Pilih Box (Opsional)',
                          labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
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
                          prefixIcon: const Icon(Icons.all_inbox_rounded, color: Color(0xFF94A3B8), size: 20),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('- Tidak dimasukkan box -', style: TextStyle(color: Color(0xFF64748B))),
                          ),
                          ...openBatches.map((b) => DropdownMenuItem(
                            value: b.id,
                            child: Text('${b.name} (${b.destinationCity})'),
                          )),
                        ],
                        onChanged: (v) => setState(() => selectedBatchId = v),
                      );
                    }),
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
                  child: Obx(
                    () => Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: const Color(0xFF3B82F6),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: controller.isLoading.value
                              ? null
                              : () async {
                                  if (formKey.currentState?.validate() != true) return;
                                  try {
                                    await controller.addPackage(
                                      trackingCode: resiCtrl.text.trim(),
                                      recipientName: nameCtrl.text.trim(),
                                      batchId: selectedBatchId,
                                      dimensions: _parseDimensions(),
                                    );
                                    Get.back();
                                    Get.snackbar(
                                      'Sukses',
                                      'Paket berhasil ditambahkan',
                                      backgroundColor: const Color(0xFF10B981),
                                      colorText: Colors.white,
                                      snackPosition: SnackPosition.BOTTOM,
                                      margin: const EdgeInsets.all(16),
                                    );
                                  } catch (e) {
                                    Get.snackbar(
                                      'Gagal Menyimpan',
                                      e.toString(),
                                      backgroundColor: const Color(0xFFEF4444),
                                      colorText: Colors.white,
                                      snackPosition: SnackPosition.BOTTOM,
                                      margin: const EdgeInsets.all(16),
                                    );
                                  }
                                },
                          child: Center(
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
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
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildDimensionField(TextEditingController ctrl, String label) {
    return TextFormField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B), fontSize: 14),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      ),
    );
  }

  Widget _buildPremiumField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
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
