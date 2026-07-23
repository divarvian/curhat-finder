import 'package:flutter/material.dart';
import '../../../../app/config/router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class CounselorProfileSheet extends StatelessWidget {
  final String name;
  final String gender;
  final String faculty;
  final List<String> topics;
  final List<String> hobbies;
  final String operationalHours;
  final bool isOnline;

  const CounselorProfileSheet({
    super.key,
    required this.name,
    required this.gender,
    required this.faculty,
    required this.topics,
    required this.hobbies,
    required this.operationalHours,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: AppColors.platinum, // Warna abu-abu kebiruan pucat
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          
          // Avatar
          Stack(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.twilightNormal, width: 3),
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
                  right: 4,
                  bottom: 4,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent[400],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Identitas
          Text(
            '$name • $gender',
            style: AppTextStyles.heading1.copyWith(
              color: AppColors.twilightDarker,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.lavenderBlush,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              faculty,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.twilightDarker,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Topik Keahlian
          Text(
            'Topik Keahlian',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.twilightDarker,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: topics.map((topic) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.twilightDarker,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  topic,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          
          // Hobi & Minat
          Text(
            'Hobi & Minat',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.twilightDarker,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: hobbies.map((hobi) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.twilightDarker,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  hobi,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          
          // Jam Operasional
          Text(
            'Jam Operasional',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.twilightDarker,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            operationalHours,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.twilightDarker,
            ),
          ),
          const SizedBox(height: 32),
          
          // CTA Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Tutup modal
                ChatRoomRoute(counselorName: name, isOnline: isOnline).push(context); // Navigasi ke chat room
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.twilightDarker,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                'Mulai melakukan konseling',
                style: AppTextStyles.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
