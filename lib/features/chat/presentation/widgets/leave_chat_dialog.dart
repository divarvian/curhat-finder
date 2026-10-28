import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class LeaveChatDialog extends StatelessWidget {
  final VoidCallback? onConfirmLeave;

  const LeaveChatDialog({super.key, this.onConfirmLeave});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: AppColors.platinum, // Sangat light grey/blue
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
          children: [
            // Mascot dengan tanda silang
            Image.asset(
              'assets/images/profile.png', // Fallback
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 24),
            
            // Judul
            Text(
              'Apakah kamu yakin?',
              style: AppTextStyles.heading1.copyWith(
                color: AppColors.twilightDarker,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 8),
            
            // Subtitle
            Text(
              'Setelah kamu keluar, kamu tidak akan bisa membuka chat ini lagi.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.wisteriaNormalHover,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            
            // Tombol-tombol
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (onConfirmLeave != null) {
                        onConfirmLeave!();
                      }
                      context.pop(); // Tutup dialog
                      context.pop(); // Keluar dari chat room
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.redNormal, // Pink/Red pastel
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Tinggalkan chat',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.pop(); // Tutup dialog saja
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
                      'Kembali ke chat',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
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
