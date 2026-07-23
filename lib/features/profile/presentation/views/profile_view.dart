import 'dart:io';
import 'package:flutter/foundation.dart'; // Tambahkan untuk kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/profile_provider.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: Colors.transparent, // Background mengikuti scaffold utama
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header & Settings Button
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Text(
                        'Profil',
                        style: AppTextStyles.heading1.copyWith(
                          color: AppColors.twilightDarker,
                          fontSize: 24,
                        ),
                      ),
                    Positioned(
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () {
                            // TODO: Navigasi ke halaman pengaturan
                          },
                          icon: const Icon(
                            Icons.settings_rounded,
                            color: AppColors.twilightNormal,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                ),
              ),

              // Avatar Profile
              GestureDetector(
                onTap: () {
                  _showImagePickerOptions(context, ref);
                },
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.wisteriaLightHover, // Biru pudar
                        border: Border.all(
                          color: AppColors.twilightDarker,
                          width: 1.5,
                        ),
                      ),
                      child: ClipOval(
                        child: user.localAvatarPath != null
                            ? (kIsWeb
                                ? Image.network(
                                    user.localAvatarPath!,
                                    fit: BoxFit.cover,
                                    width: 120,
                                    height: 120,
                                  )
                                : Image.file(
                                    File(user.localAvatarPath!),
                                    fit: BoxFit.cover, // Cover supaya gambar dari hp bisa menuhin lingkaran
                                    width: 120,
                                    height: 120,
                                  ))
                            : Image.asset(
                                user.avatarPath,
                                fit: BoxFit.contain, // Contain karena maskot mungkin ukurannya beda
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.twilightNormal.withValues(alpha: 0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: AppColors.twilightDarker,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // User Info (Name, Role, Email)
              Text(
                user.name,
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.twilightDarker,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.wisteriaNormalHover, // Muted Periwinkle
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  user.role,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.twilightDarker,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                user.email,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.twilightDarker.withValues(alpha: 0.8),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 32),

              // Account Info Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Informasi Akun',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.twilightDarker,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.edit_rounded,
                    color: AppColors.twilightDarker,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Account Info Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32), // Sangat membulat
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
                    _buildInfoRow('Fakultas', user.faculty),
                    _buildDivider(),
                    _buildInfoRow('Prodi', user.studyProgram),
                    _buildDivider(),
                    _buildInfoRow('Angkatan', user.batchYear),
                    _buildDivider(),
                    _buildInfoRow('Gender', user.gender),
                    _buildDivider(),
                    _buildInfoRow('Hobi', user.hobby, isLast: true),
                  ],
                ),
              ),
              
              const SizedBox(height: 100), // Spasi navigasi bawah
            ],
          ),
        ),
      ),
    );
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
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.twilightNormal.withValues(alpha: 0.8),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.twilightDarker,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.twilightNormal.withValues(alpha: 0.15),
    );
  }

  void _showImagePickerOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.platinum, // Sesuai warna abu-abu kebiruan terang
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
                      Navigator.pop(context);
                      _pickImage(ref, ImageSource.camera);
                    },
                  ),
                  const SizedBox(width: 16),
                  _buildOptionButton(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ref, ImageSource.gallery);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16), // Tambahan spasi agar tidak terlalu mepet bawah
            ],
          ),
          ),
        );
      },
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
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(WidgetRef ref, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      ref.read(profileProvider.notifier).updateAvatar(pickedFile.path);
    }
  }
}
