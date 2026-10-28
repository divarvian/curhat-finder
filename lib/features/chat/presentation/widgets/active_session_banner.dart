import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/counseling_service.dart';
import '../views/chat_room_view.dart';

class ActiveSessionBanner extends ConsumerWidget {
  final EdgeInsetsGeometry? margin;

  const ActiveSessionBanner({
    super.key,
    this.margin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSessionsAsync = ref.watch(activeStudentSessionProvider);

    return activeSessionsAsync.when(
      data: (sessions) {
        if (sessions.isEmpty) return const SizedBox.shrink();
        final session = sessions.first;

        return FutureBuilder<Map<String, dynamic>?>(
          future: ref.read(counselingServiceProvider).fetchCounselorProfile(session.counselorId),
          builder: (context, profileSnapshot) {
            final counselorData = profileSnapshot.data;
            final counselorName = counselorData?['full_name'] as String? ??
                counselorData?['nickname'] as String? ??
                'Konselor Sebaya';
            final isOnline = counselorData?['is_online'] as bool? ?? true;

            return Container(
              margin: margin ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChatRoomView(
                          counselorName: counselorName,
                          isOnline: isOnline,
                          sessionId: session.id,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        // Glowing Green Active Dot
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.greenAccent.withValues(alpha: 0.3),
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
                        const SizedBox(width: 12),

                        // Title & Description
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                counselorName != 'Konselor Sebaya'
                                    ? 'Sesi Konseling: $counselorName'
                                    : 'Sesi Konseling Sedang Berjalan',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Ketuk untuk langsung kembali ke percakapan',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // CTA Button Capsule
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.wisteriaNormal,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Buka Chat',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 13),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
    );
  }
}
