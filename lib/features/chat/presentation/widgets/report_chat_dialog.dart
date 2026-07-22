import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ReportChatDialog extends StatefulWidget {
  const ReportChatDialog({super.key});

  @override
  State<ReportChatDialog> createState() => _ReportChatDialogState();
}

class _ReportChatDialogState extends State<ReportChatDialog> {
  String? _selectedReason;
  
  final List<String> _reasons = [
    'Hate speech/berbicara kasar',
    'Doxing/pembocoran identitas',
    'Spam/promosi',
    'Saran berbahaya/menyesatkan',
    'Konten self-harm',
    'Lainnya',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: AppColors.platinum,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Mascot
                Image.asset(
                  'assets/images/profile.png', // Fallback
                  width: 80,
                  height: 80,
                ),
                const SizedBox(height: 16),
                
                // Judul
                Text(
                  'Laporkan',
                  style: AppTextStyles.heading1.copyWith(
                    color: AppColors.twilightDarker,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 4),
                
                Text(
                  'Target : Anonim',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.wisteriaNormalHover,
                  ),
                ),
                const SizedBox(height: 4),
                
                Text(
                  'Pilih alasan agar tim moderasi bisa meninjau',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.wisteriaNormalHover,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Pilihan Radio Button
                ..._reasons.map((reason) => _buildRadioOption(reason)),
                
                const SizedBox(height: 32),
                
                // Tombol Kirim
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedReason != null
                        ? () {
                            context.pop(); // Tutup setelah submit
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Laporan terkirim')),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedReason != null ? Colors.grey[600] : Colors.grey[400],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Kirim Laporan',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ),
          
          // Tombol Close X di sudut kanan atas
          Positioned(
            right: 16,
            top: 16,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: const Icon(
                Icons.close,
                color: AppColors.twilightDarker,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String title) {
    final isSelected = _selectedReason == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedReason = title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.twilightLight.withValues(alpha: 0.5), // Soft greyish background
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.twilightDarker,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.twilightDarker,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.twilightDarker,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
