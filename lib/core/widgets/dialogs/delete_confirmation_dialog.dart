import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Dialog konfirmasi penghapusan konten kanonikal berbasis maskot Milo
class DeleteConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onConfirmDelete;

  const DeleteConfirmationDialog({
    super.key,
    this.title = 'Hapus Konten Ini?',
    this.message = 'Konten yang sudah dihapus tidak dapat dipulihkan kembali. Apakah kamu yakin?',
    this.onConfirmDelete,
  });

  static Future<bool?> show(
    BuildContext context, {
    String title = 'Hapus Konten Ini?',
    String message = 'Konten yang sudah dihapus tidak dapat dipulihkan kembali. Apakah kamu yakin?',
    VoidCallback? onConfirmDelete,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => DeleteConfirmationDialog(
        title: title,
        message: message,
        onConfirmDelete: onConfirmDelete,
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
              // Maskot Milo dengan tanda silang
              Image.asset(
                'assets/images/mascot_leave.png',
                width: 130,
                height: 100,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),

              // Judul
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.twilightDarker,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 8),

              // Pesan Konfirmasi
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.wisteriaNormalHover,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Tombol Aksi: Hapus (Kiri) & Batal (Kanan)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (onConfirmDelete != null) {
                          onConfirmDelete!();
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
                        'Hapus',
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
