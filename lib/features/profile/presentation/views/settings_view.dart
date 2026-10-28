import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  bool _chatNotifications = true;
  bool _sessionReminders = true;
  bool _isLoading = false;

  Future<void> _showChangePasswordDialog() async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return _ChangePasswordDialog(
          onSavePassword: (newPassword) async {
            try {
              await SupabaseService.client.auth.updateUser(
                UserAttributes(password: newPassword),
              );
              if (mounted) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kata sandi berhasil diperbarui!'),
                    backgroundColor: Color(0xFF4CAF50),
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal memperbarui kata sandi: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        );
      },
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Kode Etik & Syarat Layanan',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.twilightDarker,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bimbingan Konseling Universitas Brawijaya:',
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '1. Asas Kerahasiaan: Percakapan konseling bersifat rahasia dan tidak dibagikan kepada pihak ketiga tanpa persetujuan, kecuali terindikasi ancaman keselamatan jiwa/krisis akut.\n'
                  '2. Konseling Sebaya: Konselor sebaya adalah mahasiswa terlatih di bawah supervisi tim pembina dosen/psikolog kampus.\n'
                  '3. Batasan Kasus: Masalah klinis berat akan dirujuk ke Rumah Sakit UB atau ULTKSP.\n'
                  '4. Saling Menghormati: Tidak mentoleransi ujaran kebencian, pelecehan seksual, maupun diskriminasi SARA.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.twilightNormal, height: 1.5),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Kebijakan Privasi',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.twilightDarker,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              'Aplikasi Curhat Finder berkomitmen melindungi data pribadi seluruh sivitas akademika Universitas Brawijaya:\n\n'
              '• Anonimitas: Pengguna dapat memilih mode anonim untuk menyembunyikan identitas asli saat berdiskusi di forum publik atau ruang curhat spontan.\n'
              '• Data Enkripsi: Seluruh transmisi data dilindungi protokol TLS/SSL dan enkripsi di tingkat database Supabase.\n'
              '• Hak Pengguna: Anda memiliki kendali penuh untuk menarik pesan (unsend) dan menghapus akun beserta data riwayat secara permanen kapan saja.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.twilightNormal, height: 1.5),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteAccountDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Hapus Akun Permanen?',
            style: AppTextStyles.heading3.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Tindakan ini tidak dapat dibatalkan. Seluruh profil, riwayat curhat, dan sesi bimbingan Anda akan dihapus secara permanen dari sistem.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.twilightNormal, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Ya, Hapus Akun', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final userId = SupabaseService.client.auth.currentUser?.id;
        if (userId != null) {
          // Hapus profil di database
          await SupabaseService.client.from('profiles').delete().eq('id', userId);
        }
        await ref.read(authProvider.notifier).logout();
        if (mounted) {
          context.go('/login');
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Akun Anda telah berhasil dihapus.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus akun: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showLogoutDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Keluar dari Akun',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.twilightDarker,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.wisteriaNormalHover,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Keluar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.twilightDarker, size: 20),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          'Pengaturan Akun',
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.twilightDarker,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.wisteriaNormalHover),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // SECTION 1: KEAMANAN
                _buildSectionHeader('Keamanan Akun'),
                _buildCard([
                  ListTile(
                    leading: const Icon(Icons.lock_outline_rounded, color: AppColors.wisteriaNormalHover),
                    title: const Text('Ubah Kata Sandi', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Perbarui kata sandi login Anda'),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.wisteriaNormal),
                    onTap: _showChangePasswordDialog,
                  ),
                ]),

                const SizedBox(height: 20),

                // SECTION 2: PREFERENSI & NOTIFIKASI
                _buildSectionHeader('Preferensi & Notifikasi'),
                _buildCard([
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_none_rounded, color: AppColors.wisteriaNormalHover),
                    title: const Text('Notifikasi Pesan Chat', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Terima pemberitahuan saat ada pesan masuk'),
                    activeThumbColor: AppColors.wisteriaNormalHover,
                    value: _chatNotifications,
                    onChanged: (val) => setState(() => _chatNotifications = val),
                  ),
                  const Divider(height: 1, indent: 56),
                  SwitchListTile(
                    secondary: const Icon(Icons.alarm_rounded, color: AppColors.wisteriaNormalHover),
                    title: const Text('Pengingat Sesi Bimbingan', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Pengingat waktu sebelum sesi konseling dimulai'),
                    activeThumbColor: AppColors.wisteriaNormalHover,
                    value: _sessionReminders,
                    onChanged: (val) => setState(() => _sessionReminders = val),
                  ),
                ]),

                const SizedBox(height: 20),

                // SECTION 3: LEGALITAS & KAMPUS
                _buildSectionHeader('Ketentuan & Privasi'),
                _buildCard([
                  ListTile(
                    leading: const Icon(Icons.menu_book_outlined, color: AppColors.wisteriaNormalHover),
                    title: const Text('Syarat & Kode Etik Konseling', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Panduan kerahasiaan & etika bimbingan UB'),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.wisteriaNormal),
                    onTap: _showTermsDialog,
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.wisteriaNormalHover),
                    title: const Text('Kebijakan Privasi Data', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Pelindungan informasi dan mode anonim'),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.wisteriaNormal),
                    onTap: _showPrivacyPolicyDialog,
                  ),
                ]),

                const SizedBox(height: 20),

                // SECTION 4: MANAJEMEN AKUN / DANGER ZONE
                _buildSectionHeader('Tindakan Akun'),
                _buildCard([
                  ListTile(
                    leading: const Icon(Icons.logout_rounded, color: AppColors.twilightDarker),
                    title: const Text('Keluar dari Akun', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Akhiri sesi login di perangkat ini'),
                    onTap: _showLogoutDialog,
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                    title: const Text(
                      'Hapus Akun & Data Pribadi',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
                    ),
                    subtitle: const Text('Hapus permanen akun sesuai kebijakan Google Play'),
                    onTap: _showDeleteAccountDialog,
                  ),
                ]),

                const SizedBox(height: 40),
                Center(
                  child: Text(
                    'Curhat Finder v1.0.0 (UB Edition)\nBuild 2026.10',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.twilightNormal.withValues(alpha: 0.6),
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.wisteriaNormal,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  final Future<void> Function(String newPassword) onSavePassword;

  const _ChangePasswordDialog({required this.onSavePassword});

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmController;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _confirmController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSaving = true);
      final newPassword = _passwordController.text;
      await widget.onSavePassword(newPassword);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Ubah Kata Sandi',
        style: AppTextStyles.heading3.copyWith(
          color: AppColors.twilightDarker,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Masukkan kata sandi baru untuk akun Anda (minimal 6 karakter).',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.wisteriaNormal),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Kata Sandi Baru',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Kata sandi minimal 6 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Kata Sandi',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Konfirmasi kata sandi tidak cocok';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Batal',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.wisteriaNormal),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.wisteriaNormalHover,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _isSaving ? null : _handleSubmit,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Simpan', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

