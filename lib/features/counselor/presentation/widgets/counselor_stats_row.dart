import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class CounselorStatsRow extends StatelessWidget {
  final int activeSessions;
  final int totalHelped;
  final String responseTime;

  const CounselorStatsRow({
    super.key,
    required this.activeSessions,
    required this.totalHelped,
    required this.responseTime,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.chat_bubble_rounded,
            value: '$activeSessions',
            label: 'Sesi aktif',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.favorite_rounded,
            value: '$totalHelped',
            label: 'Total dibantu',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.access_time_filled_rounded,
            value: responseTime,
            label: 'Waktu respon',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: const Color(0xFFF88A8A), // Coral pink dari mockup
            size: 28,
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTextStyles.heading1.copyWith(
              color: AppColors.twilightDarker,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.twilightNormal.withValues(alpha: 0.8),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
