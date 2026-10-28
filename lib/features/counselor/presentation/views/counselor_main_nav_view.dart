import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/counselor_provider.dart';
import 'counselor_beranda_view.dart';
import 'counselor_chat_list_view.dart';
import 'counselor_forum_view.dart';
import 'counselor_creator_view.dart';
import 'counselor_profile_view.dart';

class CounselorMainNavView extends ConsumerWidget {
  const CounselorMainNavView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counselorState = ref.watch(counselorProvider);
    final currentIndex = counselorState.currentNavIndex;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        extendBody: true,
        backgroundColor: AppColors.platinum,
        body: IndexedStack(
          index: currentIndex,
          children: const [
            CounselorBerandaView(),
            CounselorChatListView(),
            CounselorForumView(),
            CounselorCreatorView(),
            CounselorProfileView(),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigationBar(ref, currentIndex),
      ),
    );
  }

  Widget _buildBottomNavigationBar(WidgetRef ref, int currentIndex) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(
                ref: ref,
                currentIndex: currentIndex,
                icon: Icons.home_rounded,
                unselectedIcon: Icons.home_outlined,
                label: 'Beranda',
                index: 0,
              ),
              _buildNavItem(
                ref: ref,
                currentIndex: currentIndex,
                icon: Icons.chat_bubble_rounded,
                unselectedIcon: Icons.chat_bubble_outline_rounded,
                label: 'Chat',
                index: 1,
              ),
              _buildNavItem(
                ref: ref,
                currentIndex: currentIndex,
                icon: Icons.feed_rounded,
                unselectedIcon: Icons.feed_outlined,
                label: 'Forum',
                index: 2,
              ),
              _buildNavItem(
                ref: ref,
                currentIndex: currentIndex,
                icon: Icons.draw_rounded,
                unselectedIcon: Icons.draw_outlined,
                label: 'Creator',
                index: 3,
              ),
              _buildNavItem(
                ref: ref,
                currentIndex: currentIndex,
                icon: Icons.person_rounded,
                unselectedIcon: Icons.person_outline_rounded,
                label: 'Profil',
                index: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required WidgetRef ref,
    required int currentIndex,
    required IconData icon,
    required IconData unselectedIcon,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;
    // Aksen warna navbar konselor: Coral Pink untuk aktif, soft rose untuk inaktif
    final color = isSelected
        ? const Color(0xFFF88A8A)
        : const Color(0xFFF88A8A).withValues(alpha: 0.45);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(counselorProvider.notifier).setNavIndex(index);
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 30,
              child: AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child: Icon(
                  isSelected ? icon : unselectedIcon,
                  size: 26,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 16,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                style: AppTextStyles.labelSmall.copyWith(
                  color: color,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: isSelected ? 11 : 10,
                ),
                child: Center(
                  child: Text(label),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
