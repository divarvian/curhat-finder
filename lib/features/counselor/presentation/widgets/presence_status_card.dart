import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class PresenceStatusCard extends StatelessWidget {
  final bool isOnline;
  final ValueChanged<bool> onToggle;

  const PresenceStatusCard({
    super.key,
    required this.isOnline,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris Status Kehadiran + Indikator Titik
          Row(
            children: [
              Text(
                'Status Kehadiran',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.twilightNormal.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOnline ? const Color(0xFF4CAF50) : const Color(0xFF9E9E9E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Baris Judul Status + Toggle Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isOnline ? 'Ready To Listen (Online)' : 'Not Available (Offline)',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.twilightDarker,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Transform.scale(
                scale: 0.9,
                child: CupertinoSwitch(
                  value: isOnline,
                  activeTrackColor: const Color(0xFFF88A8A),
                  onChanged: onToggle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Subtitle / Deskripsi
          Text(
            isOnline
                ? 'Mahasiswa dapat melihatmu di daftar pencarian'
                : 'Profilmu disembunyikan sementara dari antrean',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.wisteriaNormal,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
