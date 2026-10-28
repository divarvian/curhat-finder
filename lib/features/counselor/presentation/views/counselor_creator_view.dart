import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class CounselorCreatorView extends StatelessWidget {
  const CounselorCreatorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Header Bersih
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 20),
              child: Center(
                child: Text(
                  'Creator Studio',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.twilightDarker,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Konten Creator
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.draw_outlined,
                          size: 48,
                          color: Color(0xFFF88A8A),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Creator Studio',
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.twilightDarker,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Buat dan publikasikan artikel, tips relaksasi, serta konten psikoedukasi untuk membantu mahasiswa.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.wisteriaNormal,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
