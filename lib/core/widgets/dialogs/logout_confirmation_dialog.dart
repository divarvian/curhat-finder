import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Dialog konfirmasi keluar akun kanonikal sesuai Figma Overlay Out.png
class LogoutConfirmationDialog extends StatelessWidget {
  final VoidCallback? onConfirmLogout;

  const LogoutConfirmationDialog({super.key, this.onConfirmLogout});

  static Future<bool?> show(BuildContext context, {VoidCallback? onConfirmLogout}) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => LogoutConfirmationDialog(
        onConfirmLogout: onConfirmLogout,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: AppColors.platinum,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Maskot Milo dengan tanda silang (Overlay Out.png)
              Image.asset(
                'assets/images/mascot_leave.png',
                width: 130,
                height: 100,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),

              // Judul
              Text(
                'Keluar Akun?',
                textAlign: TextAlign.center,
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.twilightDarker,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Apakah kamu yakin ingin keluar? Sesi dan riwayatmu akan tetap tersimpan saat kamu masuk kembali.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.wisteriaNormalHover,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Tombol Aksi: Keluar (Kiri) & Batal (Kanan)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (onConfirmLogout != null) {
                          onConfirmLogout!();
                        }
                        Navigator.of(context).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF87171),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Keluar',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.twilightDarker,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Batal',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
