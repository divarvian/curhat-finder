import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';

class RoleView extends StatefulWidget {
  const RoleView({super.key});

  @override
  State<RoleView> createState() => _RoleViewState();
}

class _RoleViewState extends State<RoleView> {
  // Menyimpan role yang dipilih. 0 untuk Mahasiswa, 1 untuk Konselor, null jika belum memilih.
  int? _selectedRole;

  void _handleMasuk() {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih peran kamu terlebih dahulu!'),
          backgroundColor: AppColors.wisteriaNormal,
        ),
      );
      return;
    }
    
    // Logika setelah role dipilih. Arahkan ke wizard registrasi profil
    context.push('/register', extra: _selectedRole);
  }

  Widget _buildRoleCard({
    required int index,
    required String title,
    required IconData icon,
    required bool isSelected,
  }) {
    final bool isKonselor = index == 1;
    
    // Warna Teks & Ikon
    final Color contentColor = isKonselor ? Colors.white : AppColors.twilightDarker;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isSelected ? 0.15 : 0.05),
            blurRadius: 15,
            spreadRadius: isSelected ? 2 : 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: isKonselor ? null : const Color(0xFFFCEEED),
            gradient: isKonselor
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.twilightDark,
                      AppColors.wisteriaNormalHover,
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(24),
            border: isSelected 
                ? Border.all(color: isKonselor ? Colors.white : AppColors.twilightDarker, width: 2) 
                : Border.all(color: Colors.transparent, width: 2),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            splashColor: Colors.black.withOpacity(0.1),
            highlightColor: Colors.black.withOpacity(0.05),
            onTap: () {
              setState(() {
                _selectedRole = index;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 40,
                    color: contentColor,
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.heading2.copyWith(
                        color: contentColor,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Latar Belakang Glowing
        Positioned.fill(
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: AppColors.background,
            body: Stack(
              children: [
                Positioned(
                  top: -150,
                  left: -50,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                    child: Container(
                      width: 350,
                      height: 350,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFFB6C1), // Soft Pink Glow
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -100,
                  left: -100,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.wisteriaNormal, // Periwinkle Blue Glow
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Konten Utama
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                // Custom Header dengan padding kiri 24 (24 + 8 padding InkWell = 32px visual alignment)
                Padding(
                  padding: const EdgeInsets.only(left: 24.0, right: 32.0),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/login');
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.arrow_back_ios_new, color: AppColors.twilightDarker, size: 22),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Role',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.twilightDarker,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 30), // 32 (kanan) + 30 = 62px = 24 (kiri) + 38 (lebar tombol). Membuat teks benar-benar di tengah layar.
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),
                        Text(
                          'Kamu disini sebagai?',
                          style: AppTextStyles.heading2.copyWith(
                            color: AppColors.twilightDarker,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -1,
                          ),
                        ),
                  const SizedBox(height: 8),
                  Text(
                    'Pilih peran kamu!!',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.twilightNormal,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Pilihan Mahasiswa
                  _buildRoleCard(
                    index: 0,
                    title: 'Aku Mahasiswa',
                    icon: Icons.school_outlined,
                    isSelected: _selectedRole == 0,
                  ),

                  // Pilihan Konselor
                  _buildRoleCard(
                    index: 1,
                    title: 'Aku Konselor',
                    icon: Icons.badge_outlined, // Icon mirip name tag/doctor
                    isSelected: _selectedRole == 1,
                  ),

                  const Spacer(),

                  // Tombol Masuk
                  Container(
                    margin: const EdgeInsets.only(bottom: 32),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7D1D4), // Soft kemerahan
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: _handleMasuk,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(
                            child: Text(
                              'Masuk',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.twilightDarker,
                                fontWeight: FontWeight.w500,
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
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
