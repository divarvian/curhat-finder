import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Tambahan untuk SVG
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../zen/views/zen_modal.dart';
import '../../chat/views/chat_list_view.dart';
import '../../jurnal/views/jurnal_view.dart';
import '../../beranda/views/beranda_view.dart';
import '../../pulse/views/pulse_view.dart';
import '../../profile/views/profile_view.dart';
import '../providers/main_nav_provider.dart';

class MainNavView extends ConsumerWidget {
  const MainNavView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(mainNavProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        extendBody: true, // Agar background halaman (seperti Jurnal) tembus ke sudut lengkung navbar
        backgroundColor: const Color(0xFFF2F6F9),
        body: IndexedStack(
          index: currentIndex,
          children: [
            const BerandaView(),
            const ChatListView(),
            const JurnalView(),
            const PulseView(),
            const ProfileView(),
          ],
        ),
      
      floatingActionButton: currentIndex == 0 ? _buildCustomFAB(context) : null,
      bottomNavigationBar: _buildBottomNavigationBar(ref, currentIndex),
      ),
    );
  }

  Widget _buildCustomFAB(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      margin: const EdgeInsets.only(bottom: 8, right: 8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.wisteriaNormalHover,
            AppColors.twilightDark,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.twilightDark.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            showGeneralDialog(
              context: context,
              barrierDismissible: false, // Must tap X to close
              barrierColor: Colors.black54,
              transitionDuration: const Duration(milliseconds: 300),
              pageBuilder: (context, animation, secondaryAnimation) {
                return const ZenModal();
              },
              transitionBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: child,
                  ),
                );
              },
            );
          },
          child: const Icon(
            Icons.air, // Placeholder ikon tiupan angin
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(WidgetRef ref, int currentIndex) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
              _buildNavItem(ref: ref, currentIndex: currentIndex, iconPath: 'assets/images/nav/home.svg', label: 'Beranda', index: 0),
              _buildNavItem(ref: ref, currentIndex: currentIndex, iconPath: 'assets/images/nav/chat.svg', label: 'Chat', index: 1),
              _buildNavItem(ref: ref, currentIndex: currentIndex, iconPath: 'assets/images/nav/journal.svg', label: 'Jurnal', index: 2),
              _buildNavItem(ref: ref, currentIndex: currentIndex, iconPath: 'assets/images/nav/pulse.svg', label: 'Pulse', index: 3),
              _buildNavItem(ref: ref, currentIndex: currentIndex, iconPath: 'assets/images/nav/profile.svg', label: 'Profil', index: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required WidgetRef ref, required int currentIndex, required String iconPath, required String label, required int index}) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.twilightDarker : AppColors.wisteriaNormal;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(mainNavProvider.notifier).setIndex(index);
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 32, // Fixed tinggi maksimum agar navbar tidak membesar-mengecil
              child: AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child: SvgPicture.asset(
                  iconPath,
                  width: 26,
                  height: 26,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 16, // Fixed tinggi teks agar navbar tidak lompat
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
