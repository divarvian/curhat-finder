import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_list_provider.dart';
import '../widgets/counselor_profile_sheet.dart';

class ChatListView extends ConsumerWidget {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatListProvider);
    return Scaffold(
      backgroundColor: Colors.transparent, // Background mengikuti Dashboard
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                children: [
                  Text(
                    'Chat',
                    style: AppTextStyles.heading1.copyWith(
                      color: AppColors.twilightDarker,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pilih cara cerita yang paling nyaman buat kamu.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.twilightDarker,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Main Category Chips
            SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildMainCategoryChip(ref, state, 'SupportBuddy', 0),
                  const SizedBox(width: 12),
                  _buildMainCategoryChip(ref, state, 'Rooms', 1),
                  const SizedBox(width: 12),
                  _buildMainCategoryChip(ref, state, 'Chat Anon', 2),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Sub Category Chips or Chat Anon Header
            if (state.selectedMainCategory != 2)
              SizedBox(
                height: 32,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: state.selectedMainCategory == 0
                      ? [
                          _buildSubCategoryChip(ref, state, 'Available Sekarang', 0),
                          const SizedBox(width: 8),
                          _buildSubCategoryChip(ref, state, 'FILKOM', 1),
                          const SizedBox(width: 8),
                          _buildSubCategoryChip(ref, state, 'FIB', 2),
                          const SizedBox(width: 8),
                          _buildSubCategoryChip(ref, state, 'FT', 3),
                          const SizedBox(width: 8),
                          _buildSubCategoryChip(ref, state, 'FBiPK', 4),
                          const SizedBox(width: 8),
                          _buildSubCategoryChip(ref, state, 'FK', 5),
                        ]
                      : [
                          _buildSubCategoryChip(ref, state, 'Semua', 0),
                          const SizedBox(width: 8),
                          _buildSubCategoryChip(ref, state, 'Akademik', 1),
                          const SizedBox(width: 8),
                          _buildSubCategoryChip(ref, state, 'Kesepian', 2),
                          const SizedBox(width: 8),
                          _buildSubCategoryChip(ref, state, 'Keuangan', 3),
                        ],
                ),
              )
            else
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.twilightDarker,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'Pilih tipe tanggapan yang kamu inginkan',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Main Content (Search Bar & List)
            Expanded(
              child: state.selectedMainCategory == 0
                  ? _buildSupportBuddyContent(context)
                  : state.selectedMainCategory == 1
                      ? _buildRoomsContent(context)
                      : _buildChatAnonContent(context, ref, state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportBuddyContent(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari nama konselor atau fakultas...',
                hintStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.twilightNormal.withOpacity(0.6),
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.twilightNormal,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Counselor List
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              _buildCounselorCard(
                context: context,
                name: 'Kak Dodo',
                gender: 'Laki-laki',
                faculty: 'Fakultas Ilmu Komputer (FILKOM)',
                tags: ['Burnout', 'Overhelmed', 'Anxiety'],
                hobbies: ['Sepak Bola', 'Memasak', 'Olahraga'],
                isOnline: true,
              ),
              const SizedBox(height: 16),
              _buildCounselorCard(
                context: context,
                name: 'Kak Leo',
                gender: 'Laki-laki',
                faculty: 'Fakultas Ilmu Komputer (FILKOM)',
                tags: ['Keuangan', 'Hubungan'],
                hobbies: ['Membaca', 'Gaming'],
                isOnline: false,
              ),
              const SizedBox(height: 16),
              _buildCounselorCard(
                context: context,
                name: 'Kak Tifa',
                gender: 'Perempuan',
                faculty: 'Fakultas Ilmu Komputer (FILKOM)',
                tags: ['Hilang Arah', 'Hubungan', 'Keluarga'],
                hobbies: ['Melukis', 'Musik'],
                isOnline: false,
              ),
              const SizedBox(height: 100), // Spasi bawah untuk NavBar
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoomsContent(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        // Input Box "Tulis curhatanmu..."
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.twilightDarker,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Tulis curhatanmu...',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.twilightNormal.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Room Cards
        _buildRoomCard(
          context: context,
          authorTag: 'Laki-laki • FILKOM',
          categoryTag: 'Kesepian',
          content: 'hidup udah agak mantap tapi ada aja postingan #mykisah yang bikin aku ngetik when yah kan aku juga mw',
          likes: '99999',
          comments: '99999',
          isLiked: true,
        ),
        const SizedBox(height: 16),
        _buildRoomCard(
          context: context,
          authorTag: 'Laki-laki • FILKOM',
          categoryTag: 'Kesepian',
          content: 'ternyata yang paling sakit bukan kalah, tapi sadar kalau gak akan ada lagi "Di kesempatan berikutnya" buat dia.',
          likes: '777777',
          comments: '99999',
          isLiked: true,
        ),
        const SizedBox(height: 16),
        _buildRoomCard(
          context: context,
          authorTag: 'Laki-laki • FILKOM',
          categoryTag: 'Akademi',
          content: 'hidup udah agak mantap tapi ada aja dosen yang bikin IP aku ngetik duh gusti kan aku juga mw 4',
          likes: '99999',
          comments: '99999',
          isLiked: true,
        ),
        const SizedBox(height: 16),
        _buildRoomCard(
          context: context,
          authorTag: 'Perempuan • FILKOM',
          categoryTag: 'Keuangan',
          content: 'duh gusti, apa sih sekarang apa apa mahal. mo beli ini itu abis buat makan doang',
          likes: '99999',
          comments: '99999',
          isLiked: false,
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildChatAnonContent(BuildContext context, WidgetRef ref, ChatListState state) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        _buildAnonOptionCard(
          ref: ref,
          state: state,
          index: 0,
          title: 'Cuma mau didengar',
          subtitle: 'Partnermu akan diminta mendengarkan tanpa nyaranin.',
          imagePath: 'assets/images/profile.png', // Fallback, since we don't have mascot assets
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
        
        // Mulai mencari partner Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: state.selectedAnonType != null
                ? () {
                    context.push('/chat_anon_matching');
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: state.selectedAnonType != null ? AppColors.twilightDarker : Colors.grey[400],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              'Mulai mencari partner',
              style: AppTextStyles.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 100),
      ],
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
          color: isSelected ? const Color(0xFFFDE8E9) : Colors.white, // Highlight pink if selected
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.twilightDarker : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
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

  Widget _buildMainCategoryChip(WidgetRef ref, ChatListState state, String label, int index) {
    final isSelected = state.selectedMainCategory == index;
    return GestureDetector(
      onTap: () => ref.read(chatListProvider.notifier).setMainCategory(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFDE8E9) : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? const Color(0xFFE2A6A6) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? AppColors.twilightDarker : AppColors.twilightDark,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSubCategoryChip(WidgetRef ref, ChatListState state, String label, int index) {
    final isSelected = state.selectedSubCategory == index;
    return GestureDetector(
      onTap: () => ref.read(chatListProvider.notifier).setSubCategory(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFDE8E9) : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? const Color(0xFFE2A6A6) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? AppColors.twilightDarker : AppColors.twilightDark,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCounselorCard({
    required BuildContext context,
    required String name,
    required String gender,
    required String faculty,
    required List<String> tags,
    required List<String> hobbies,
    required bool isOnline,
  }) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => CounselorProfileSheet(
            name: name,
            gender: gender,
            faculty: faculty,
            topics: tags,
            hobbies: hobbies,
            operationalHours: 'Senin - Jum\'at, 18.00 - 21.00 WIB',
            isOnline: isOnline,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.twilightNormal, width: 2),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/profile.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (isOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent[400],
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$name • $gender',
                        style: AppTextStyles.heading2.copyWith(
                          color: AppColors.twilightDarker,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        faculty,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.wisteriaNormalHover,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.twilightDarker,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    tag,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard({
    required BuildContext context,
    required String authorTag,
    required String categoryTag,
    required String content,
    required String likes,
    required String comments,
    required bool isLiked,
  }) {
    return GestureDetector(
      onTap: () => context.push('/room_detail'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (Tags & More Options)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE8E9), // Pink pastel background
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        authorTag,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.twilightDarker,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFFDE8E9), width: 1.5), // Pink pastel border
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        categoryTag,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.twilightDarker,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.more_horiz,
                  color: AppColors.wisteriaNormalHover,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Content
            Text(
              content,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.twilightDarker,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            
            // Footer (Likes, Comments, Bookmark)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.redAccent : AppColors.wisteriaNormalHover,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      likes,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isLiked ? Colors.redAccent : AppColors.wisteriaNormalHover,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.chat_bubble_outline,
                      color: AppColors.wisteriaNormalHover,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      comments,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.wisteriaNormalHover,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.bookmark,
                      color: Color(0xFFFFC107), // Yellow/Gold
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Simpan',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: const Color(0xFFFFC107), // Yellow/Gold
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
