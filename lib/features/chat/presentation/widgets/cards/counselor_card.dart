import 'package:flutter/material.dart';
import 'package:curhat_finder/core/theme/app_colors.dart';
import 'package:curhat_finder/core/theme/app_text_styles.dart';
import '../counselor_profile_sheet.dart';

/// Widget Kartu Konselor Mandiri untuk Tab SupportBuddy
class CounselorCard extends StatelessWidget {
  final String counselorId;
  final String name;
  final String gender;
  final String faculty;
  final List<String> tags;
  final List<String> hobbies;
  final bool isOnline;

  const CounselorCard({
    super.key,
    this.counselorId = '',
    required this.name,
    required this.gender,
    required this.faculty,
    required this.tags,
    required this.hobbies,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => CounselorProfileSheet(
            counselorId: counselorId,
            name: name,
            gender: gender,
            faculty: faculty,
            topics: tags,
            hobbies: hobbies,
            operationalHours: 'Senin - Jum\'at, 18.00 - 21.00 WIB',
            isOnline: isOnline,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.twilightNormal, width: 2),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/profile.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (isOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent[400],
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$name • $gender',
                        style: AppTextStyles.heading2.copyWith(
                          color: AppColors.twilightDarker,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        faculty,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.wisteriaNormalHover,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.twilightDarker,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    tag,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
