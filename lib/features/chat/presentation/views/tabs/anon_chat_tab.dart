import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curhat_finder/app/config/router.dart';
import 'package:curhat_finder/core/theme/app_colors.dart';
import 'package:curhat_finder/core/theme/app_text_styles.dart';
import 'package:curhat_finder/features/chat/data/anon_chat_service.dart';
import 'package:curhat_finder/features/chat/domain/anon_chat_model.dart';
import 'package:curhat_finder/features/chat/presentation/providers/chat_list_provider.dart';

/// Tab Chat Anonim (Percakapan 1-on-1 Anonim Antar Mahasiswa)
class AnonChatTab extends ConsumerWidget {
  const AnonChatTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatListProvider);
    final activeSessionAsync = ref.watch(activeAnonSessionProvider);
    final activeSession = activeSessionAsync.value;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        // 1. Banner Sesi Anonim Aktif (Reconnection Card)
        if (activeSession != null) ...[
          _buildActiveSessionCard(context, ref, activeSession),
          const SizedBox(height: 20),
        ],

        // 2. Mode Cards
        _buildAnonOptionCard(
          ref: ref,
          state: state,
          index: 0,
          title: 'Cuma mau didengar',
          subtitle: 'Partnermu akan diminta mendengarkan tanpa nyaranin.',
          imagePath: 'assets/images/profile.png',
        ),
        const SizedBox(height: 16),
        _buildAnonOptionCard(
          ref: ref,
          state: state,
          index: 1,
          title: 'Mau dengar pendapat juga',
          subtitle: 'Partnermu boleh memberikan perspektif dan sarannya.',
          imagePath: 'assets/images/profile.png',
        ),
        const SizedBox(height: 24),

        // 3. Mulai mencari partner Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (state.selectedAnonType != null && activeSession == null)
                ? () async {
                    final mode = state.selectedAnonType == 1
                        ? 'Mau dengar pendapat juga'
                        : 'Cuma mau didengar';
                    await ChatAnonMatchingRoute(mode: mode).push(context);
                    ref.invalidate(activeAnonSessionProvider);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: (state.selectedAnonType != null && activeSession == null)
                  ? AppColors.twilightDarker
                  : Colors.grey[400],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              activeSession != null ? 'Selesaikan Sesi Aktif Terlebih Dahulu' : 'Mulai mencari partner',
              style: AppTextStyles.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 4. Banner Privasi & Keamanan Komunitas
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.twilightLight.withValues(alpha: 0.5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.shield_outlined, color: AppColors.twilightDarker, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Privasimu Terjaga Sepenuhnya',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.twilightDarker,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Identitas asli, nama, dan foto profilmu tidak akan pernah ditampilkan kepada partner obrolan.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.wisteriaNormalHover,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildActiveSessionCard(BuildContext context, WidgetRef ref, AnonSessionModel session) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2C3E50),
            Color(0xFF34495E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Glowing Active Indicator Dot
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Text(
                'Sesi Obrolan Anonim Berlangsung',
                style: AppTextStyles.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Kamu memiliki sesi obrolan yang belum selesai (${session.mode}). Ketuk tombol di bawah untuk melanjutkan pembicaraan.',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    await ref.read(anonChatServiceProvider).endSession(session.id);
                    ref.invalidate(activeAnonSessionProvider);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Text(
                    'Akhiri Sesi',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () async {
                    await ChatAnonRoomRoute(sessionId: session.id, mode: session.mode).push(context);
                    ref.invalidate(activeAnonSessionProvider);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2C3E50),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Text(
                    'Lanjutkan Chat',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: const Color(0xFF2C3E50),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnonOptionCard({
    required WidgetRef ref,
    required ChatListState state,
    required int index,
    required String title,
    required String subtitle,
    required String imagePath,
  }) {
    final isSelected = state.selectedAnonType == index;
    return GestureDetector(
      onTap: () => ref.read(chatListProvider.notifier).setAnonType(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lavenderBlush : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.twilightDarker : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Image.asset(
              imagePath,
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.heading1.copyWith(
                color: AppColors.twilightDarker,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.wisteriaNormalHover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
