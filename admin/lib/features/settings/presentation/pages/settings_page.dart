import 'package:dice_bear/dice_bear.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../core/utils/app_alerts.dart';
import '../controllers/settings_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final controller = Get.find<SettingsController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // ── Header: Current User + Logout ──
          _buildHeader(context, auth),

          // ── Content: Admin List ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Section Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Daftar Admin',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showAddAdminModal(context, controller),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.person_add_rounded, size: 16, color: Colors.white),
                                SizedBox(width: 6),
                                Text(
                                  'Tambah',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Admin Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Obx(() {
                      if (controller.adminList.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                          ),
                          child: const Center(
                            child: Text(
                              'Memuat daftar admin...',
                              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: controller.adminList
                            .where((admin) => admin['email'] != auth.adminEmail)
                            .map((admin) {
                          final email = admin['email'] ?? '';
                          final name = admin['name'] ?? '';
                          final displayName = name.isNotEmpty ? name : email.split('@').first;

                          return _AdminCard(
                            name: displayName,
                            email: email,
                            onEdit: () => _showEditAdminModal(context, controller, email, name),
                            onDelete: () => _confirmDeleteAdmin(context, controller, email, displayName),
                          );
                        }).toList(),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────
  // HEADER
  // ───────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, AuthController auth) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 24,
        right: 24,
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
          // Top row: Title + Logout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'User',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              GestureDetector(
                onTap: () => _confirmLogout(context, auth),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.logout_rounded, size: 16, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'Keluar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Current user info
          Obx(() => Row(
                children: [
                  _DiceBearAvatar(seed: auth.adminEmail, size: 52, borderColor: Colors.white),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.adminName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            auth.adminEmail,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────
  // LOGOUT DIALOG
  // ───────────────────────────────────────────────
  void _confirmLogout(BuildContext context, AuthController auth) {
    AppAlerts.confirmSheet(
      context: context,
      title: 'Keluar?',
      description: 'Anda akan keluar dari akun admin. Lanjutkan?',
      confirmLabel: 'Keluar',
      confirmColor: const Color(0xFFEF4444),
      icon: Icons.logout_rounded,
      iconColor: const Color(0xFFEF4444),
      onConfirm: () async {
        await auth.signOut();
      },
    );
  }

  // ───────────────────────────────────────────────
  // ADD ADMIN MODAL
  // ───────────────────────────────────────────────
  void _showAddAdminModal(BuildContext context, SettingsController controller) {
    final emailCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    FocusManager.instance.primaryFocus?.unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tambah Admin Baru',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Masukkan nama dan email akun Google yang akan diberikan akses admin.',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),
              const SizedBox(height: 20),

              // Name input
              _buildTextField(nameCtrl, 'Nama', 'Contoh: Farid Irmawan', Icons.person_outline_rounded,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null),
              const SizedBox(height: 14),

              // Email input
              _buildTextField(emailCtrl, 'Email Google', 'contoh@gmail.com', Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                if (v == null || v.isEmpty) return 'Email wajib diisi';
                if (!GetUtils.isEmail(v)) return 'Format email tidak valid';
                return null;
              }),
              const SizedBox(height: 20),

              // Submit button
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () {
                              if (formKey.currentState!.validate()) {
                                controller.addAdmin(
                                  emailCtrl.text.trim(),
                                  nameCtrl.text.trim(),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Simpan Admin',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────
  // EDIT ADMIN MODAL
  // ───────────────────────────────────────────────
  void _showEditAdminModal(BuildContext context, SettingsController controller, String email, String name) {
    final emailCtrl = TextEditingController(text: email);
    final nameCtrl = TextEditingController(text: name);
    final formKey = GlobalKey<FormState>();

    FocusManager.instance.primaryFocus?.unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Admin',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Perbarui nama atau email admin.',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),
              const SizedBox(height: 20),

              _buildTextField(nameCtrl, 'Nama', 'Contoh: Farid Irmawan', Icons.person_outline_rounded,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null),
              const SizedBox(height: 14),

              _buildTextField(emailCtrl, 'Email Google', 'contoh@gmail.com', Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                if (v == null || v.isEmpty) return 'Email wajib diisi';
                if (!GetUtils.isEmail(v)) return 'Format email tidak valid';
                return null;
              }),
              const SizedBox(height: 20),

              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () {
                              if (formKey.currentState!.validate()) {
                                controller.updateAdmin(
                                  email,
                                  newEmail: emailCtrl.text.trim(),
                                  newName: nameCtrl.text.trim(),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Simpan Perubahan',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────
  // DELETE CONFIRM
  // ───────────────────────────────────────────────
  void _confirmDeleteAdmin(BuildContext context, SettingsController controller, String email, String name) {
    AppAlerts.confirmSheet(
      context: context,
      title: 'Hapus Admin?',
      description: 'Admin "$name" ($email) akan dihapus dari sistem.\nTindakan ini tidak dapat dibatalkan.',
      confirmLabel: 'Hapus',
      confirmColor: const Color(0xFFEF4444),
      icon: Icons.delete_rounded,
      iconColor: const Color(0xFFEF4444),
      onConfirm: () async {
        await controller.deleteAdmin(email);
      },
    );
  }

  // ───────────────────────────────────────────────
  // SHARED TEXT FIELD
  // ───────────────────────────────────────────────
  Widget _buildTextField(
    TextEditingController ctrl,
    String label,
    String hint,
    IconData icon, {
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF94A3B8)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
        ),
      ),
      textCapitalization: textCapitalization,
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}

// ══════════════════════════════════════════════════
// DICEBEAR AVATAR WIDGET
// ══════════════════════════════════════════════════
class _DiceBearAvatar extends StatelessWidget {
  final String seed;
  final double size;
  final Color? borderColor;

  const _DiceBearAvatar({
    required this.seed,
    this.size = 44,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final request = DiceBearRequest(
      style: DiceBearStyle.adventurer,
      coreOptions: DiceBearCoreOptions(seed: seed),
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFEFF6FF),
        border: borderColor != null
            ? Border.all(color: borderColor!.withValues(alpha: 0.3), width: 2)
            : null,
      ),
      child: ClipOval(
        child: request.toImage(
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholderBuilder: (_) => Center(
            child: Text(
              seed.isNotEmpty ? seed[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: size * 0.38,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════
// ADMIN CARD
// ══════════════════════════════════════════════════
class _AdminCard extends StatelessWidget {
  final String name;
  final String email;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminCard({
    required this.name,
    required this.email,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
        ),
      ),
      child: Row(
        children: [
          // DiceBear Avatar
          _DiceBearAvatar(seed: email, size: 44),
          const SizedBox(width: 14),
          // Name + Email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  email,
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
          // 3-dot menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF94A3B8), size: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            color: Colors.white,
            elevation: 8,
            shadowColor: Colors.black26,
            offset: const Offset(0, 40),
            onSelected: (value) {
              if (value == 'edit') onEdit();
              if (value == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.edit_rounded, size: 16, color: Color(0xFF3B82F6)),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Edit Admin',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.delete_rounded, size: 16, color: Color(0xFFEF4444)),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Hapus Admin',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
