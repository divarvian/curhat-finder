import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/config/router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/academic_helper.dart';
import '../providers/counselor_provider.dart';
import '../widgets/counselor_stats_row.dart';

class CounselorProfileView extends ConsumerWidget {
  const CounselorProfileView({super.key});

  void _showAddTopicDialog(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Tambah Topik Keahlian',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.twilightDarker,
              fontSize: 18,
            ),
          ),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Contoh: Burnout, Hubungan...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.wisteriaNormal,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFF88A8A)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFF88A8A), width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Batal',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.wisteriaNormal),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF88A8A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final topic = textController.text.trim();
                if (topic.isNotEmpty) {
                  ref.read(counselorProvider.notifier).addTopic(topic);
                  Navigator.of(dialogContext).pop();
                }
              },
              child: Text(
                'Tambah',
                style: AppTextStyles.labelMedium.copyWith(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counselorState = ref.watch(counselorProvider);
    final profile = counselorState.profile;

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
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 20),
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
              ),

              // 2. Avatar Maskot dengan Badge (+)
              Stack(
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
                      child: Image.asset(
                        profile.avatarPath,
                        fit: BoxFit.cover,
                      ),
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Kartu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Informasi Akun',
                          style: AppTextStyles.heading3.copyWith(
                            color: AppColors.twilightDarker,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(
                          Icons.edit_outlined,
                          color: Color(0xFFF88A8A),
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Grid Informasi Akademik (2 Kolom x 2 Baris)
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem('Fakultas', AcademicHelper.resolveFaculty(profile.faculty)),
                        ),
                        Expanded(
                          child: _buildInfoItem('Prodi', AcademicHelper.resolveProdi(profile.studyProgram)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem('Angkatan', profile.batchYear),
                        ),
                        Expanded(
                          child: _buildInfoItem('Gender', profile.gender),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Sub-seksi: Topik Keahlian
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Topik Keahlian',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.twilightDarker,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Chips Topik
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 10,
                            runSpacing: 10,
                            children: profile.topics.map((topic) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFAD4D4),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      topic,
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.twilightDarker,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () => ref.read(counselorProvider.notifier).removeTopic(topic),
                                      child: const Icon(
                                        Icons.close,
                                        size: 14,
                                        color: AppColors.twilightDarker,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 14),

                          // Tombol "+ Tambah Topik"
                          InkWell(
                            onTap: () => _showAddTopicDialog(context, ref),
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
                                    Icons.add,
                                    size: 18,
                                    color: AppColors.twilightDarker,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Tambah Topik',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.twilightDarker,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
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

              // 7. Tombol "Keluar Akun"
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFFCEDED),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      ref.read(authProvider.notifier).logout();
                      const LoginRoute().go(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18.0),
                      child: Center(
                        child: Text(
                          'Keluar Akun',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: const Color(0xFFF88A8A),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.wisteriaNormal,
            fontSize: 12,
            decoration: TextDecoration.underline,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.twilightDarker,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
