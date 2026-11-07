import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/config/router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../domain/counselor_model.dart';
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
            _buildTopSection(profile.name, profile, counselorState.isLoading),

            // 2. Konten Utama Beranda
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  if (counselorState.isLoading) ...[
                    const PresenceStatusCardSkeleton(),
                    const SizedBox(height: 20),
                    const CounselorStatsSkeleton(),
                  ] else ...[
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
                  ],

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

  Widget _buildTopSection(String name, CounselorProfile profile, bool isLoading) {
    // Format nama: hapus emoji jika ada untuk greeting, atau gunakan nama panggilan
    final displayName = name.replaceAll('💖', '').trim();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 1. Latar Belakang Lengkung Halus
        Container(
          height: 260,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.counselorHeaderBg, // Soft Pink Kemerahan
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

        // 2. Karakter Maskot Menempel di Ujung Kanan (100% Identik dengan Mahasiswa)
        Positioned(
          right: -10,
          top: 45,
          child: SizedBox(
            width: 200,
            child: Image.asset(
              'assets/images/mascot.png',
              fit: BoxFit.contain,
            ),
          ),
        ),

        // 3. Konten Teks dan Avatar
        SafeArea(
          bottom: false,
          left: false,
          right: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: isLoading
                      ? const HeaderGreetingSkeleton(avatarSize: 48)
                      : Column(
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
                                    child: _buildAvatarImage(profile),
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
                const SizedBox(width: 140),
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

        if (counselorState.isLoading) ...[
          const CounselorQueueCardSkeleton(),
          const SizedBox(height: 16),
          const CounselorQueueCardSkeleton(),
        ] else if (queues.isEmpty)
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
                          onPressed: counselorNotifier.isQueueProcessing(queue.id)
                              ? null
                              : () async {
                                  final session = await counselorNotifier.acceptQueue(queue);
                                  if (session != null && context.mounted) {
                                    CounselorChatRoomRoute(
                                      sessionId: session.id,
                                      studentTitle: '${queue.studentAlias} - ${queue.studentFaculty}',
                                    ).push(context);
                                  }
                                },
                          child: counselorNotifier.isQueueProcessing(queue.id)
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
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
                        onPressed: counselorNotifier.isQueueProcessing(queue.id)
                            ? null
                            : () => counselorNotifier.rejectQueue(queue.id),
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

  Widget _buildAvatarImage(CounselorProfile profile) {
    if (profile.localAvatarPath != null && !kIsWeb && File(profile.localAvatarPath!).existsSync()) {
      return Image.file(
        File(profile.localAvatarPath!),
        fit: BoxFit.cover,
        width: 48,
        height: 48,
      );
    }
    if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
      return Image.network(
        profile.avatarUrl!,
        fit: BoxFit.cover,
        width: 48,
        height: 48,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }
          return const AppShimmer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          );
        },
        errorBuilder: (_, _, _) => Image.asset(
          profile.avatarPath,
          fit: BoxFit.cover,
        ),
      );
    }
    if (profile.localAvatarPath != null && profile.localAvatarPath!.startsWith('http')) {
      return Image.network(
        profile.localAvatarPath!,
        fit: BoxFit.cover,
        width: 48,
        height: 48,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }
          return const AppShimmer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          );
        },
        errorBuilder: (_, _, _) => Image.asset(
          profile.avatarPath,
          fit: BoxFit.cover,
        ),
      );
    }
    return Image.asset(
      profile.avatarPath.isNotEmpty ? profile.avatarPath : 'assets/images/mascot.png',
      fit: BoxFit.cover,
    );
  }
}
