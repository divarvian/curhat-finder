import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/config/router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/dialogs/logout_confirmation_dialog.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/academic_helper.dart';
import '../providers/counselor_provider.dart';
import '../../domain/counselor_model.dart';
import '../widgets/counselor_stats_row.dart';
import '../widgets/manage_topics_sheet.dart';

class CounselorProfileView extends ConsumerWidget {
  const CounselorProfileView({super.key});

  void _showManageTopicsSheet(BuildContext context, WidgetRef ref, List<String> currentTopics) {
    ManageTopicsSheet.show(
      context,
      currentTopics: currentTopics,
      onSave: (newTopics) => ref.read(counselorProvider.notifier).updateTopics(newTopics),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 20),
      child: SizedBox(
        height: 48,
        width: double.infinity,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Text(
              'Profil',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.twilightDarker,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Positioned(
              right: 0,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      context.push('/settings');
                    },
                    child: const Center(
                      child: Icon(
                        Icons.settings_rounded,
                        color: AppColors.wisteriaNormal,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counselorState = ref.watch(counselorProvider);
    final profile = counselorState.profile;

    if (counselorState.isLoading) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(context),
              const Expanded(child: ProfileViewSkeleton(isCounselor: true)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Header & Tombol Pengaturan
              _buildHeader(context),

              // 2. Avatar Maskot dengan Badge (+) - Interaktif Ganti Avatar
              GestureDetector(
                onTap: () => _showImagePickerOptions(context, ref),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFCEDED),
                        border: Border.all(
                          color: AppColors.twilightNormal.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: _buildAvatarImage(profile),
                      ),
                    ),
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.twilightDarker.withValues(alpha: 0.6),
                            width: 1.5,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.add,
                            size: 18,
                            color: AppColors.twilightDarker,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 3. Nama Konselor & Email Institusi
              Text(
                profile.name,
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.twilightDarker,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                profile.email,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.twilightNormal.withValues(alpha: 0.8),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),

              // 4. Badge "Konselor"
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE6E6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFF88A8A).withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  profile.role,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.twilightDarker,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 5. Kartu "Informasi Akun"
              // 5. Kartu "Informasi Akun" (Paritas 100% dengan Profil Mahasiswa)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32), // Sangat membulat identik mahasiswa
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Fakultas', AcademicHelper.resolveFaculty(profile.faculty)),
                    _buildDivider(),
                    _buildInfoRow('Prodi', AcademicHelper.resolveProdi(profile.studyProgram)),
                    _buildDivider(),
                    _buildInfoRow('Angkatan', profile.batchYear),
                    _buildDivider(),
                    _buildInfoRow('Gender', profile.gender),
                    _buildDivider(),

                    // Sub-seksi: Topik Keahlian (Bebas Garis Bawah, Kurasi Terpadu)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Topik Keahlian',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.wisteriaNormal,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => _showManageTopicsSheet(context, ref, profile.topics),
                                child: const Icon(
                                  Icons.edit_rounded,
                                  color: Color(0xFFF88A8A),
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Chips Topik Keahlian
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: profile.topics.map((topic) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFCE6E6),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFF88A8A).withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  topic,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.twilightDarker,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 12),

                          // Tombol Aksi "+ Kelola Keahlian"
                          InkWell(
                            onTap: () => _showManageTopicsSheet(context, ref, profile.topics),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.tune_rounded,
                                    size: 16,
                                    color: Color(0xFFF88A8A),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Kelola Keahlian',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: const Color(0xFFF88A8A),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 6. Baris 3 Kartu Statistik
              CounselorStatsRow(
                activeSessions: profile.activeSessions,
                totalHelped: profile.totalHelped,
                responseTime: profile.responseTime,
              ),

              const SizedBox(height: 24),

              // 7. Tombol "Keluar Akun" (Paritas 100% dengan Profil Mahasiswa)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE8E8),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () async {
                      final confirmed = await LogoutConfirmationDialog.show(context);
                      if (confirmed == true && context.mounted) {
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) {
                          const LoginRoute().go(context);
                        }
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.logout_rounded,
                            color: Color(0xFFF87171),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Keluar Akun',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: const Color(0xFFF87171),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 120), // Padding untuk Bottom Navigation Bar
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePickerOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.platinum,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ambil dari',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.twilightDarker,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildOptionButton(
                      icon: Icons.camera_alt_rounded,
                      label: 'Kamera',
                      onTap: () {
                        Navigator.pop(modalContext);
                        _pickImage(context, ref, ImageSource.camera);
                      },
                    ),
                    const SizedBox(width: 16),
                    _buildOptionButton(
                      icon: Icons.photo_library_rounded,
                      label: 'Galeri',
                      onTap: () {
                        Navigator.pop(modalContext);
                        _pickImage(context, ref, ImageSource.gallery);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarImage(CounselorProfile profile) {
    if (profile.localAvatarPath != null && !kIsWeb && File(profile.localAvatarPath!).existsSync()) {
      return Image.file(
        File(profile.localAvatarPath!),
        fit: BoxFit.cover,
        width: 110,
        height: 110,
      );
    }
    if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
      return Image.network(
        profile.avatarUrl!,
        fit: BoxFit.cover,
        width: 110,
        height: 110,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }
          return const AppShimmer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          );
        },
        errorBuilder: (_, _, _) => Image.asset(
          profile.avatarPath,
          fit: BoxFit.cover,
        ),
      );
    }
    if (profile.localAvatarPath != null && profile.localAvatarPath!.startsWith('http')) {
      return Image.network(
        profile.localAvatarPath!,
        fit: BoxFit.cover,
        width: 110,
        height: 110,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }
          return const AppShimmer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          );
        },
        errorBuilder: (_, _, _) => Image.asset(
          profile.avatarPath,
          fit: BoxFit.cover,
        ),
      );
    }
    return Image.asset(
      profile.avatarPath,
      fit: BoxFit.cover,
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.twilightNormal.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.twilightDarker,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.twilightDarker,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, WidgetRef ref, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      final success = await ref.read(counselorProvider.notifier).uploadAvatar(pickedFile);
      if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengunggah foto profil. Silakan coba lagi.'),
            backgroundColor: AppColors.redNormal,
          ),
        );
      }
    }
  }

  Widget _buildInfoRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        bottom: isLast ? 24 : 20,
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.wisteriaNormal,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.twilightDarker,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      width: double.infinity,
      color: AppColors.platinum,
    );
  }
}
