import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/config/router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/counselor_provider.dart';
import '../widgets/anonymous_avatar.dart';

class CounselorChatListView extends ConsumerWidget {
  const CounselorChatListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counselorState = ref.watch(counselorProvider);
    final sessions = counselorState.sessions;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar Header Bersih
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 20),
              child: Center(
                child: Text(
                  'Chat',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.twilightDarker,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Daftar Sesi Chat Mahasiswa
            Expanded(
              child: sessions.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada sesi chat aktif',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.wisteriaNormal,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      itemCount: sessions.length,
                      itemBuilder: (context, index) {
                        final session = sessions[index];
                        return _buildSessionCard(context, session);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, dynamic session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
      child: Row(
        children: [
          // Avatar Anonim
          const AnonymousAvatar(
            size: 52,
            isOnline: true,
            showBadge: false,
          ),
          const SizedBox(width: 14),

          // Detail Sesi Mahasiswa
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${session.studentName} • ${session.studentGender}',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.twilightDarker,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  session.statusDescription,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.twilightNormal.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  session.studentFaculty,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: const Color(0xFFF88A8A),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Tombol Aksi "Buka"
          Material(
            color: const Color(0xFFFAD4D4), // Soft coral background
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                CounselorChatRoomRoute(
                  sessionId: session.id,
                  studentTitle: '${session.studentName} - ${session.studentFaculty}',
                ).push(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Text(
                  'Buka',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.twilightDarker,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
