import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/config/router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/auth_provider.dart';

class CounselorPendingView extends ConsumerStatefulWidget {
  const CounselorPendingView({super.key});

  @override
  ConsumerState<CounselorPendingView> createState() => _CounselorPendingViewState();
}

class _CounselorPendingViewState extends ConsumerState<CounselorPendingView> {
  bool _isChecking = false;

  Future<void> _checkVerificationStatus() async {
    setState(() => _isChecking = true);

    try {
      await ref.read(authProvider.notifier).refreshProfile();
      if (!mounted) return;

      final auth = ref.read(authProvider);
      if (auth.isVerified && auth.counselorStatus == 'approved') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selamat! Akun konselor kamu telah disetujui. Membuka dashboard...'),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 2),
          ),
        );
        const CounselorMainRoute().go(context);
      } else if (auth.counselorStatus == 'rejected') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mohon maaf, pengajuan konselor kamu belum dapat disetujui.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akunmu masih dalam proses peninjauan oleh tim admin.'),
            backgroundColor: Color(0xFFF59E0B),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memeriksa status: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon Illustration Container
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFEF3C7),
                        AppColors.wisteriaLightHover,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.18),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.hourglass_top_rounded,
                      size: 48,
                      color: Color(0xFFD97706),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Title
                Text(
                  'Akun Konselor Sedang Ditinjau',
                  style: AppTextStyles.heading1.copyWith(
                    color: AppColors.twilightDarker,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  'Pendaftaran akun Konselor Sebaya kamu sedang ditinjau oleh tim pengelola konseling Universitas Brawijaya untuk memastikan standar etika dan keamanan bimbingan mahasiswa.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.twilightNormal.withValues(alpha: 0.85),
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                // Detail Information Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.twilightNormal.withValues(alpha: 0.12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        label: 'Nama Terdaftar',
                        value: auth.username ?? 'Konselor Sebaya',
                      ),
                      const Divider(height: 20, thickness: 0.6),
                      _buildInfoRow(
                        label: 'Email Akun',
                        value: auth.email ?? '-',
                      ),
                      const Divider(height: 20, thickness: 0.6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Status Akun',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.twilightNormal.withValues(alpha: 0.7),
                              fontSize: 13,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFD97706),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  auth.counselorStatus == 'rejected' ? 'Ditolak' : 'Menunggu Verifikasi',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: const Color(0xFFB45309),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Button: Cek Status Verifikasi
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isChecking ? null : _checkVerificationStatus,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.twilightDarker,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: _isChecking
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.refresh_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Cek Status Verifikasi',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                // Button: Logout / Keluar
                TextButton(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) {
                      const LoginRoute().go(context);
                    }
                  },
                  child: Text(
                    'Keluar / Ganti Akun',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.twilightNormal.withValues(alpha: 0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.twilightNormal.withValues(alpha: 0.7),
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.twilightDarker,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
