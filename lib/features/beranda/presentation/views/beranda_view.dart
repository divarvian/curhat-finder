import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/presentation/widgets/active_session_banner.dart';
import '../../../main_nav/presentation/providers/main_nav_provider.dart';
import '../../../profile/domain/user_profile_model.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../data/community_service.dart';
import '../../domain/tip_model.dart';
import '../providers/tips_interaction_provider.dart';
import '../widgets/dialogs/create_tip_sheet.dart';

class BerandaView extends ConsumerStatefulWidget {
  const BerandaView({super.key});

  @override
  ConsumerState<BerandaView> createState() => _BerandaViewState();
}

class _BerandaViewState extends ConsumerState<BerandaView> {
  Stream<List<TipModel>>? _tipsStream;

  @override
  void initState() {
    super.initState();
    _tipsStream = ref.read(communityServiceProvider).streamTips();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final profileUser = ref.watch(profileProvider);
    final isProfileLoading = profileUser.isLoading || (authState.isLoggedIn && authState.username == null);
    final displayName = authState.username ?? (profileUser.name.isNotEmpty ? profileUser.name : 'Teman');

    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        // Top Section (Header Background + Header Content + Floating Banner)
        SliverToBoxAdapter(
          child: _buildTopSection(displayName, profileUser, isProfileLoading),
        ),

        // Active Counseling Session Banner (Floating jika ada sesi aktif)
        const SliverToBoxAdapter(
          child: ActiveSessionBanner(
            margin: EdgeInsets.fromLTRB(24, 0, 24, 16),
          ),
        ),

        // Input Section ("Bagikan Tips dan Saran Kamu")
        SliverToBoxAdapter(
          child: _buildInputSection(),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),

        // Seksi Tips Hari Ini (Sesuai Homepage FIX.png)
        SliverToBoxAdapter(
          child: _buildTipsHariIniSection(),
        ),

        // Spasi bawah agar tidak tertutup FAB / Nav Bar
        const SliverToBoxAdapter(
          child: SizedBox(height: 120),
        ),
      ],
    );
  }

  Widget _buildTopSection(String displayName, UserProfile user, bool isLoading) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 1. Latar Belakang Pink melengkung
        Container(
          height: 260,
          decoration: const BoxDecoration(
            color: AppColors.lavenderBlush,
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

        // 2. Karakter Mascot
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

        // 3. Konten Header dan Banner
        Column(
          children: [
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
                          ? const HeaderGreetingSkeleton(avatarSize: 52)
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.twilightNormal, width: 2),
                                  ),
                                  child: ClipOval(
                                    child: _buildAvatarImage(user),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Halo $displayName,\nada apa hari ini?',
                                  style: AppTextStyles.heading1.copyWith(
                                    color: AppColors.twilightDarker,
                                    fontSize: 22,
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Yuk, luangin waktu buat dirimu sendiri.',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.wisteriaDark,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(width: 130),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildFloatingBanner(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ],
    );
  }

  Widget _buildFloatingBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.twilightDark,
            AppColors.wisteriaNormalHover,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.twilightDark.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -30,
            bottom: -20,
            child: Transform.scale(
              scaleX: -1,
              child: Icon(
                Icons.volunteer_activism,
                size: 100,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lagi pingin ditemenin?',
                style: AppTextStyles.heading2.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ngobrol bareng peer support yang siap dengerin.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(mainNavProvider.notifier).setIndex(1);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.twilightDarker,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Cari Temen Ngobrol',
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bagikan Tips dan Saran Kamu',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.twilightDarker,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
            elevation: 0,
            child: InkWell(
              onTap: () => CreateTipSheet.show(context),
              borderRadius: BorderRadius.circular(100),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.twilightDarker,
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Berikan tips dan saranmu untuk teman teman...',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.twilightNormal.withValues(alpha: 0.75),
                          fontSize: 12.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsHariIniSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
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
            Text(
              'Tips Hari Ini',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.twilightDarker,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Baca tips yang kami rekomendasikan hari ini',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.twilightNormal.withValues(alpha: 0.8),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),

            // Featured Card Rekomendasi Hari Ini (Sesuai Homepage FIX.png)
            StreamBuilder<List<TipModel>>(
              stream: _tipsStream,
              builder: (context, snapshot) {
                // Tampilkan Skeleton jika data masih dimuat dari server
                if (snapshot.connectionState == ConnectionState.waiting && (!snapshot.hasData || (snapshot.data ?? []).isEmpty)) {
                  return const TipCardSkeleton(margin: EdgeInsets.zero);
                }

                final tips = snapshot.data ?? [];
                final featuredTip = tips.isNotEmpty ? tips.first : null;

                if (featuredTip == null) {
                  return const TipCardSkeleton(margin: EdgeInsets.zero);
                }

                final interactionState = ref.watch(tipsInteractionProvider);
                final interactionNotifier = ref.read(tipsInteractionProvider.notifier);

                final isLiked = interactionState.likedTipIds.contains(featuredTip.id);
                final isBookmarked = interactionState.bookmarkedTipIds.contains(featuredTip.id);
                final likes = interactionNotifier.getEffectiveLikesCount(featuredTip.id, featuredTip.likesCount);

                final authorTag = '${featuredTip.authorName} • ${featuredTip.category}';
                final title = featuredTip.displayTitle;
                final body = featuredTip.displayDescription;

                return Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () {
                      context.push('/tip_detail', extra: featuredTip);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBF9F8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.twilightLight.withValues(alpha: 0.6),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.lavenderBlush,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              authorTag,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.twilightDarker,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            title,
                            style: AppTextStyles.heading3.copyWith(
                              color: AppColors.twilightDarker,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            body,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.twilightDarker.withValues(alpha: 0.85),
                              height: 1.45,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Tombol Like Interaktif Langsung di Beranda
                              InkWell(
                                onTap: () {
                                  ref.read(tipsInteractionProvider.notifier).toggleLike(featuredTip.id);
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                        color: isLiked ? Colors.redAccent : AppColors.wisteriaDarkHover,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '$likes',
                                        style: AppTextStyles.labelSmall.copyWith(
                                          color: isLiked ? Colors.redAccent : AppColors.wisteriaDarkHover,
                                          fontSize: 12,
                                          fontWeight: isLiked ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Tombol Bookmark Interaktif Langsung di Beranda
                              InkWell(
                                onTap: () {
                                  ref.read(tipsInteractionProvider.notifier).toggleBookmark(featuredTip.id);
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                        color: isBookmarked ? AppColors.sunshineYellow : AppColors.wisteriaDarkHover,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        isBookmarked ? 'Tersimpan' : 'Simpan',
                                        style: AppTextStyles.labelSmall.copyWith(
                                          color: isBookmarked ? AppColors.sunshineYellow : AppColors.wisteriaDarkHover,
                                          fontSize: 12,
                                          fontWeight: isBookmarked ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Tombol "Jelajahi Lebih Banyak Tips ->"
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  context.push('/tips');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.twilightDarker,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Jelajahi Lebih Banyak Tips',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarImage(UserProfile user) {
    if (user.localAvatarPath != null && !kIsWeb && File(user.localAvatarPath!).existsSync()) {
      return Image.file(
        File(user.localAvatarPath!),
        fit: BoxFit.cover,
        width: 52,
        height: 52,
      );
    }
    if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
      return Image.network(
        user.avatarUrl!,
        fit: BoxFit.cover,
        width: 52,
        height: 52,
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
          user.avatarPath,
          fit: BoxFit.cover,
        ),
      );
    }
    if (user.localAvatarPath != null && user.localAvatarPath!.startsWith('http')) {
      return Image.network(
        user.localAvatarPath!,
        fit: BoxFit.cover,
        width: 52,
        height: 52,
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
          user.avatarPath,
          fit: BoxFit.cover,
        ),
      );
    }
    return Image.asset(
      user.avatarPath.isNotEmpty ? user.avatarPath : 'assets/images/profile.png',
      fit: BoxFit.cover,
    );
  }
}

