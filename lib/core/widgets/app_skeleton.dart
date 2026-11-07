import 'package:flutter/material.dart';

/// Reusable Shimmer Sweep Effect using pure Flutter Animation
class AppShimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const AppShimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFE8EDF5),
                Colors.white.withValues(alpha: 0.85),
                const Color(0xFFE8EDF5),
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(slidePercent: _animation.value),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

/// Generic rounded rectangle/circle skeleton box
class AppSkeleton extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final BoxShape shape;

  const AppSkeleton({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
    this.shape = BoxShape.rectangle,
  });

  const AppSkeleton.circle({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = 0,
        shape = BoxShape.circle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDF5),
        shape: shape,
        borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Skeleton Card matching InteractiveTipCard & Featured Tip in Beranda
class TipCardSkeleton extends StatelessWidget {
  final EdgeInsetsGeometry margin;

  const TipCardSkeleton({
    super.key,
    this.margin = const EdgeInsets.only(left: 24, right: 24, bottom: 16),
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        margin: margin,
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
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Badge & More Option
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppSkeleton(width: 140, height: 24, borderRadius: 100),
                AppSkeleton(width: 24, height: 24, borderRadius: 100),
              ],
            ),
            SizedBox(height: 14),

            // Title Skeleton
            AppSkeleton(width: double.infinity, height: 18, borderRadius: 6),
            SizedBox(height: 8),
            AppSkeleton(width: 200, height: 18, borderRadius: 6),
            SizedBox(height: 12),

            // Description Lines Skeleton
            AppSkeleton(width: double.infinity, height: 13, borderRadius: 4),
            SizedBox(height: 6),
            AppSkeleton(width: double.infinity, height: 13, borderRadius: 4),
            SizedBox(height: 6),
            AppSkeleton(width: 160, height: 13, borderRadius: 4),
            SizedBox(height: 18),

            // Bottom Actions (Like & Bookmark)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppSkeleton(width: 60, height: 20, borderRadius: 10),
                AppSkeleton(width: 70, height: 20, borderRadius: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton Card matching InteractiveRoomCard in RoomsTab
class RoomCardSkeleton extends StatelessWidget {
  final EdgeInsetsGeometry margin;

  const RoomCardSkeleton({
    super.key,
    this.margin = const EdgeInsets.only(bottom: 16),
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        margin: margin,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Avatar, Author, Faculty, Time
            Row(
              children: [
                AppSkeleton.circle(size: 40),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeleton(width: 110, height: 14, borderRadius: 4),
                    SizedBox(height: 6),
                    AppSkeleton(width: 80, height: 11, borderRadius: 4),
                  ],
                ),
                Spacer(),
                AppSkeleton(width: 50, height: 12, borderRadius: 4),
              ],
            ),
            SizedBox(height: 14),

            // Title & Content Preview
            AppSkeleton(width: double.infinity, height: 16, borderRadius: 6),
            SizedBox(height: 8),
            AppSkeleton(width: double.infinity, height: 12, borderRadius: 4),
            SizedBox(height: 6),
            AppSkeleton(width: 220, height: 12, borderRadius: 4),
            SizedBox(height: 16),

            // Bottom Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    AppSkeleton(width: 55, height: 20, borderRadius: 10),
                    SizedBox(width: 14),
                    AppSkeleton(width: 55, height: 20, borderRadius: 10),
                  ],
                ),
                AppSkeleton(width: 28, height: 20, borderRadius: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for Room Comments in RoomDetailView
class CommentCardSkeleton extends StatelessWidget {
  const CommentCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Comment Author & Time
            Row(
              children: [
                AppSkeleton.circle(size: 32),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeleton(width: 90, height: 12, borderRadius: 4),
                    SizedBox(height: 4),
                    AppSkeleton(width: 60, height: 10, borderRadius: 4),
                  ],
                ),
                Spacer(),
                AppSkeleton(width: 45, height: 10, borderRadius: 4),
              ],
            ),
            SizedBox(height: 12),

            // Comment Body Lines
            AppSkeleton(width: double.infinity, height: 12, borderRadius: 4),
            SizedBox(height: 6),
            AppSkeleton(width: 180, height: 12, borderRadius: 4),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for Jurnal Check-In / Sambat History in JurnalView
class JurnalHistorySkeleton extends StatelessWidget {
  const JurnalHistorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          children: [
            AppSkeleton.circle(size: 44),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeleton(width: 120, height: 14, borderRadius: 4),
                  SizedBox(height: 6),
                  AppSkeleton(width: double.infinity, height: 11, borderRadius: 4),
                ],
              ),
            ),
            SizedBox(width: 10),
            AppSkeleton(width: 40, height: 10, borderRadius: 4),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for Chat Message Bubbles in ChatRoomView, ChatAnonRoomView, CounselorChatRoomView
class ChatBubbleSkeleton extends StatelessWidget {
  final EdgeInsetsGeometry padding;

  const ChatBubbleSkeleton({
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: padding,
        children: [
          // 1. Incoming Message (Left)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const AppSkeleton.circle(size: 32),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                    bottomLeft: Radius.circular(4),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeleton(width: 180, height: 13, borderRadius: 4),
                    SizedBox(height: 6),
                    AppSkeleton(width: 130, height: 13, borderRadius: 4),
                    SizedBox(height: 6),
                    AppSkeleton(width: 45, height: 9, borderRadius: 4),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Outgoing Message (Right)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AppSkeleton(width: 190, height: 13, borderRadius: 4),
                    SizedBox(height: 6),
                    AppSkeleton(width: 110, height: 13, borderRadius: 4),
                    SizedBox(height: 6),
                    AppSkeleton(width: 40, height: 9, borderRadius: 4),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. Incoming Message Short (Left)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const AppSkeleton.circle(size: 32),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                    bottomLeft: Radius.circular(4),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeleton(width: 140, height: 13, borderRadius: 4),
                    SizedBox(height: 6),
                    AppSkeleton(width: 45, height: 9, borderRadius: 4),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 4. Outgoing Message Short (Right)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AppSkeleton(width: 120, height: 13, borderRadius: 4),
                    SizedBox(height: 6),
                    AppSkeleton(width: 40, height: 9, borderRadius: 4),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Skeleton for Counselor Cards in SupportBuddyTab
class CounselorCardSkeleton extends StatelessWidget {
  final EdgeInsetsGeometry margin;

  const CounselorCardSkeleton({
    super.key,
    this.margin = const EdgeInsets.only(bottom: 16),
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        margin: margin,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          children: [
            // Counselor Avatar
            AppSkeleton.circle(size: 48),
            SizedBox(width: 14),

            // Profile info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppSkeleton(width: 110, height: 15, borderRadius: 4),
                      SizedBox(width: 8),
                      AppSkeleton(width: 45, height: 14, borderRadius: 100),
                    ],
                  ),
                  SizedBox(height: 6),
                  AppSkeleton(width: 85, height: 12, borderRadius: 4),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      AppSkeleton(width: 60, height: 18, borderRadius: 100),
                      SizedBox(width: 6),
                      AppSkeleton(width: 55, height: 18, borderRadius: 100),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),

            // Chat Action Button
            AppSkeleton(width: 64, height: 36, borderRadius: 100),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for top greeting header in Beranda (Student & Counselor)
class HeaderGreetingSkeleton extends StatelessWidget {
  final double avatarSize;
  const HeaderGreetingSkeleton({super.key, this.avatarSize = 52});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeleton.circle(size: avatarSize),
          const SizedBox(height: 16),
          const AppSkeleton(width: 150, height: 22, borderRadius: 6),
          const SizedBox(height: 8),
          const AppSkeleton(width: 200, height: 13, borderRadius: 4),
        ],
      ),
    );
  }
}

/// Skeleton for Profile View (Student and Counselor)
class ProfileViewSkeleton extends StatelessWidget {
  final bool isCounselor;
  const ProfileViewSkeleton({super.key, this.isCounselor = false});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Avatar
            const AppSkeleton.circle(size: 110),
            const SizedBox(height: 16),
            // Name
            const AppSkeleton(width: 160, height: 22, borderRadius: 6),
            const SizedBox(height: 6),
            // Email
            const AppSkeleton(width: 190, height: 13, borderRadius: 4),
            const SizedBox(height: 12),
            // Role Pill
            const AppSkeleton(width: 90, height: 26, borderRadius: 20),
            const SizedBox(height: 24),

            // Account Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppSkeleton(width: 120, height: 16, borderRadius: 4),
                  const SizedBox(height: 20),
                  // Row 1
                  const Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            AppSkeleton(width: 60, height: 10, borderRadius: 4),
                            SizedBox(height: 6),
                            AppSkeleton(width: 90, height: 15, borderRadius: 4),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            AppSkeleton(width: 50, height: 10, borderRadius: 4),
                            SizedBox(height: 6),
                            AppSkeleton(width: 80, height: 15, borderRadius: 4),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Row 2
                  const Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            AppSkeleton(width: 60, height: 10, borderRadius: 4),
                            SizedBox(height: 6),
                            AppSkeleton(width: 70, height: 15, borderRadius: 4),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            AppSkeleton(width: 50, height: 10, borderRadius: 4),
                            SizedBox(height: 6),
                            AppSkeleton(width: 80, height: 15, borderRadius: 4),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (isCounselor) ...[
                    const SizedBox(height: 20),
                    const Center(
                      child: AppSkeleton(width: 100, height: 13, borderRadius: 4),
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppSkeleton(width: 75, height: 26, borderRadius: 16),
                        SizedBox(width: 8),
                        AppSkeleton(width: 85, height: 26, borderRadius: 16),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            if (isCounselor) ...[
              const SizedBox(height: 20),
              const CounselorStatsSkeleton(),
            ],

            const SizedBox(height: 24),
            // Logout button
            const AppSkeleton(width: double.infinity, height: 54, borderRadius: 24),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for Counselor Presence Status Card
class PresenceStatusCardSkeleton extends StatelessWidget {
  const PresenceStatusCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                AppSkeleton(width: 95, height: 12, borderRadius: 4),
                SizedBox(width: 6),
                AppSkeleton.circle(size: 8),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppSkeleton(width: 170, height: 18, borderRadius: 6),
                AppSkeleton(width: 48, height: 28, borderRadius: 16),
              ],
            ),
            SizedBox(height: 10),
            AppSkeleton(width: 220, height: 12, borderRadius: 4),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for 3 Counselor Stats Cards
class CounselorStatsSkeleton extends StatelessWidget {
  const CounselorStatsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Row(
        children: List.generate(3, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                left: index == 0 ? 0 : 5,
                right: index == 2 ? 0 : 5,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  AppSkeleton(width: 32, height: 20, borderRadius: 4),
                  SizedBox(height: 8),
                  AppSkeleton(width: 60, height: 10, borderRadius: 4),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Skeleton for Counselor Queue Card
class CounselorQueueCardSkeleton extends StatelessWidget {
  const CounselorQueueCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Column(
          children: [
            Row(
              children: [
                AppSkeleton.circle(size: 48),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSkeleton(width: 120, height: 15, borderRadius: 4),
                      SizedBox(height: 6),
                      AppSkeleton(width: 180, height: 12, borderRadius: 4),
                      SizedBox(height: 6),
                      AppSkeleton(width: 90, height: 11, borderRadius: 4),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: AppSkeleton(height: 38, borderRadius: 16),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: AppSkeleton(height: 38, borderRadius: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for Counselor Chat Session Item
class CounselorChatSessionSkeleton extends StatelessWidget {
  const CounselorChatSessionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          children: [
            AppSkeleton.circle(size: 52),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeleton(width: 130, height: 16, borderRadius: 4),
                  SizedBox(height: 6),
                  AppSkeleton(width: 170, height: 12, borderRadius: 4),
                  SizedBox(height: 6),
                  AppSkeleton(width: 95, height: 11, borderRadius: 4),
                ],
              ),
            ),
            SizedBox(width: 8),
            AppSkeleton(width: 64, height: 36, borderRadius: 16),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for Counselor Forum Thread Card
class CounselorForumCardSkeleton extends StatelessWidget {
  const CounselorForumCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppSkeleton(width: 70, height: 24, borderRadius: 100),
                AppSkeleton(width: 35, height: 14, borderRadius: 4),
              ],
            ),
            SizedBox(height: 12),
            AppSkeleton(width: 210, height: 16, borderRadius: 4),
            SizedBox(height: 8),
            AppSkeleton(width: double.infinity, height: 12, borderRadius: 4),
            SizedBox(height: 5),
            AppSkeleton(width: 250, height: 12, borderRadius: 4),
            SizedBox(height: 12),
            AppSkeleton(width: 140, height: 12, borderRadius: 4),
          ],
        ),
      ),
    );
  }
}

