import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_categories.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/academic_helper.dart';
import '../../../../core/widgets/app_pill.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../chat/data/room_service.dart';
import '../../../chat/domain/room_model.dart';
import '../../../chat/presentation/views/room_detail_view.dart';
import '../widgets/anonymous_avatar.dart';

class CounselorForumView extends ConsumerStatefulWidget {
  const CounselorForumView({super.key});

  @override
  ConsumerState<CounselorForumView> createState() => _CounselorForumViewState();
}

class _CounselorForumViewState extends ConsumerState<CounselorForumView> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = AppCategories.roomFilterCategories;

  List<Map<String, String>> _computeTopFacultyIssues(List<RoomModel> rooms) {
    if (rooms.isEmpty) {
      return const [
        {
          'rank': '1',
          'faculty': 'Ilmu Komputer',
          'topic': 'Akademik',
          'percentage': '58%',
        },
        {
          'rank': '2',
          'faculty': 'Teknik',
          'topic': 'Keuangan',
          'percentage': '58%',
        },
        {
          'rank': '3',
          'faculty': 'Ekonomi Bisnis',
          'topic': 'Keluarga',
          'percentage': '58%',
        },
      ];
    }

    final Map<String, List<RoomModel>> roomsByFaculty = {};
    for (final room in rooms) {
      final faculty = AcademicHelper.resolveFaculty(room.authorFaculty);
      roomsByFaculty.putIfAbsent(faculty, () => []).add(room);
    }

    final sortedFaculties = roomsByFaculty.keys.toList()
      ..sort((a, b) => roomsByFaculty[b]!.length.compareTo(roomsByFaculty[a]!.length));

    final List<Map<String, String>> result = [];
    int rank = 1;

    for (final faculty in sortedFaculties.take(3)) {
      final facultyRooms = roomsByFaculty[faculty]!;
      final Map<String, int> topicCounts = {};
      for (final r in facultyRooms) {
        topicCounts[r.category] = (topicCounts[r.category] ?? 0) + 1;
      }

      String topTopic = 'Akademik';
      int maxCount = 0;
      topicCounts.forEach((topic, count) {
        if (count > maxCount) {
          maxCount = count;
          topTopic = topic;
        }
      });

      final percentage = ((maxCount / facultyRooms.length) * 100).round();

      result.add({
        'rank': '$rank',
        'faculty': faculty,
        'topic': topTopic,
        'percentage': '$percentage%',
      });
      rank++;
    }

    if (result.length < 3) {
      final defaults = [
        {
          'rank': '1',
          'faculty': 'Ilmu Komputer',
          'topic': 'Akademik',
          'percentage': '58%',
        },
        {
          'rank': '2',
          'faculty': 'Teknik',
          'topic': 'Keuangan',
          'percentage': '58%',
        },
        {
          'rank': '3',
          'faculty': 'Ekonomi Bisnis',
          'topic': 'Keluarga',
          'percentage': '58%',
        },
      ];
      for (int i = result.length; i < 3; i++) {
        result.add({
          'rank': '${i + 1}',
          'faculty': defaults[i]['faculty']!,
          'topic': defaults[i]['topic']!,
          'percentage': defaults[i]['percentage']!,
        });
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final roomService = ref.watch(roomServiceProvider);
    final filter = _filters[_selectedFilterIndex];
    final categoryFilter = filter == 'Semua' ? null : filter;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: StreamBuilder<List<RoomModel>>(
          stream: roomService.streamRooms(category: categoryFilter),
          builder: (context, snapshot) {
            final isLoading = snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData;
            final rooms = snapshot.data ?? [];
            final topIssues = _computeTopFacultyIssues(rooms);

            return CustomScrollView(
              slivers: [
                // 1. Header Forum
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Forum',
                          style: AppTextStyles.heading2.copyWith(
                            color: AppColors.twilightDarker,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pantau dinamika curhat mahasiswa dan tren isu kesehatan mental kampus.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.wisteriaNormal,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. Section: Top Isu Per Fakultas 🔥 (Dinamis dari Data Rooms)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 16),
                    child: _buildTopIssuesLeaderboard(topIssues),
                  ),
                ),

                // 3. Horizontal Category Filter Chips
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildFilterChips(),
                  ),
                ),

                // 4. Daftar Curhat Mahasiswa (Monitoring & Pembimbingan)
                if (isLoading)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => const CounselorForumCardSkeleton(),
                        childCount: 3,
                      ),
                    ),
                  )
                else if (rooms.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 15,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.forum_outlined,
                                size: 44,
                                color: Color(0xFFF88A8A),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum Ada Curhat',
                              style: AppTextStyles.heading3.copyWith(
                                color: AppColors.twilightDarker,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Belum ada curhat mahasiswa di kategori ini.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.wisteriaNormal,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 100,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final room = rooms[index];
                          return _buildRoomCard(room);
                        },
                        childCount: rooms.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopIssuesLeaderboard(List<Map<String, String>> issues) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                'Top Isu Per Fakultas 🔥',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.twilightDarker,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE6E6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Tren',
                  style: TextStyle(
                    color: Color(0xFFF88A8A),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: issues.take(3).map((item) => _buildTopIssueCard(item)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTopIssueCard(Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      child: Row(
        children: [
          _buildRankBadge(item['rank']!),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              item['faculty']!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.twilightDarker,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item['topic']!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.twilightNormal.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFFCE6E6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              item['percentage']!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFF88A8A),
                fontWeight: FontWeight.bold,
                fontSize: 11,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(String rank) {
    Color bgColor;
    Color textColor;
    Border? border;

    switch (rank) {
      case '1':
        bgColor = const Color(0xFFF88A8A);
        textColor = Colors.white;
        break;
      case '2':
        bgColor = const Color(0xFFFFD2D2);
        textColor = AppColors.twilightDarker;
        break;
      case '3':
        bgColor = const Color(0xFFFFECEC);
        textColor = AppColors.twilightDarker;
        border = Border.all(color: const Color(0xFFFFD2D2));
        break;
      default:
        bgColor = AppColors.platinum;
        textColor = AppColors.twilightDarker;
    }

    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: border,
      ),
      child: Text(
        rank,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: textColor,
          fontSize: 15,
          height: 1.0,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedFilterIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedFilterIndex = index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFA8A8) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFFA8A8).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: Text(
                _filters[index],
                textAlign: TextAlign.center,
                strutStyle: const StrutStyle(
                  forceStrutHeight: true,
                  height: 1.0,
                ),
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.twilightDarker,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                  height: 1.0,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoomCard(RoomModel room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => RoomDetailView(
                  roomId: room.id,
                  room: room,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Author + Kategori Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const AnonymousAvatar(size: 38, showBadge: false),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${room.authorName} • ${room.authorFaculty}',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.twilightDarker,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              _formatTimeAgo(room.createdAt),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.wisteriaNormal,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    AppPill(
                      label: room.category,
                      backgroundColor: const Color(0xFFFCE6E6),
                      textColor: const Color(0xFFF88A8A),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      borderRadius: 10,
                      borderWidth: 0,
                      borderColor: Colors.transparent,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  room.title,
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.twilightDarker,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),

                // Content Preview
                Text(
                  room.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.twilightNormal,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),

                // Footer Bar (Komentar & Likes)
                Row(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 16,
                          color: Color(0xFFF88A8A),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${room.commentsCount} Tanggapan',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.twilightDarker,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.favorite_outline_rounded,
                          size: 16,
                          color: AppColors.wisteriaNormal,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${room.likesCount}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.wisteriaNormal,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      'Beri Tanggapan Konselor →',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: const Color(0xFFF88A8A),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m yang lalu';
    if (diff.inHours < 24) return '${diff.inHours}j yang lalu';
    return '${diff.inDays}h yang lalu';
  }
}
