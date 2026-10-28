import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/config/router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/counselor_provider.dart';
import '../widgets/presence_status_card.dart';
import '../widgets/counselor_stats_row.dart';
import '../widgets/anonymous_avatar.dart';

class CounselorBerandaView extends ConsumerWidget {
  const CounselorBerandaView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counselorState = ref.watch(counselorProvider);
    final counselorNotifier = ref.read(counselorProvider.notifier);
    final profile = counselorState.profile;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header Section (Salam, Avatar, & Maskot)
            _buildTopSection(profile.name),

            // 2. Konten Utama Beranda
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  // Status Kehadiran
                  PresenceStatusCard(
                    isOnline: profile.isOnline,
                    onToggle: (value) {
                      counselorNotifier.toggleOnlineStatus();
                    },
                  ),

                  const SizedBox(height: 20),

                  // 3 Kartu Statistik
                  CounselorStatsRow(
                    activeSessions: profile.activeSessions,
                    totalHelped: profile.totalHelped,
                    responseTime: profile.responseTime,
                  ),

                  const SizedBox(height: 32),

                  // Seksi Antrean Masuk Mahasiswa
                  _buildQueueSection(context, counselorState, counselorNotifier),

                  const SizedBox(height: 120), // Padding bawah untuk Bottom Nav
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection(String name) {
    // Format nama: hapus emoji jika ada untuk greeting, atau gunakan nama panggilan
    final displayName = name.replaceAll('💖', '').trim();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Latar Belakang Lengkung Halus
        Container(
          height: 230,
          decoration: const BoxDecoration(
            color: Color(0xFFFCEDED), // Soft Pink Kemerahan
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            child: Transform.scale(
              scale: 1.5,
              child: Image.asset(
                'assets/images/pattern.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ),

        // Karakter Maskot di Kanan Atas
        Positioned(
          right: -10,
          top: 35,
          child: SizedBox(
            width: 190,
            child: Image.asset(
              'assets/images/mascot.png',
              fit: BoxFit.contain,
            ),
          ),
        ),

        // Konten Teks dan Avatar
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 120, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Konselor Kecil dengan Badge Hati
                Stack(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFFF88A8A),
                          width: 1.5,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/mascot.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite,
                          size: 14,
                          color: Color(0xFFF88A8A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Greeting Teks
                Text(
                  'Halo $displayName,\nada apa hari ini?',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.twilightDarker,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Yuk, luangin waktu buat dirimu sendiri.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.twilightNormal.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQueueSection(
    BuildContext context,
    CounselorState counselorState,
    CounselorNotifier counselorNotifier,
  ) {
    final queues = counselorState.queues;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Judul dengan Underline
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Antrean Masuk Mahasiswa',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.twilightDarker,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (queues.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF88A8A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${queues.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Container(
              height: 2,
              width: double.infinity,
              color: AppColors.twilightDarker.withValues(alpha: 0.2),
            ),
          ],
        ),

        const SizedBox(height: 20),

        if (queues.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 36.0),
              child: Text(
                'Belum Ada Antrean',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.wisteriaNormal.withValues(alpha: 0.8),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
        else
          ...queues.map((queue) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const AnonymousAvatar(
                        size: 46,
                        isOnline: true,
                        showBadge: false,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${queue.studentAlias} • ${queue.studentGender}',
                              style: AppTextStyles.heading3.copyWith(
                                color: AppColors.twilightDarker,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              queue.studentFaculty,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: const Color(0xFFF88A8A),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (queue.preferredTopic != null && queue.preferredTopic!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCE6E6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            queue.preferredTopic!,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: const Color(0xFFF88A8A),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF88A8A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: () async {
                            final session = await counselorNotifier.acceptQueue(queue);
                            if (session != null && context.mounted) {
                              CounselorChatRoomRoute(
                                sessionId: session.id,
                                studentTitle: '${queue.studentAlias} - ${queue.studentFaculty}',
                              ).push(context);
                            }
                          },
                          child: const Text(
                            'Terima Sesi',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.twilightNormal,
                          side: BorderSide(color: AppColors.twilightNormal.withValues(alpha: 0.3)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        ),
                        onPressed: () => counselorNotifier.rejectQueue(queue.id),
                        child: const Text('Tolak', style: TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
