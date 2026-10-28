import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:curhat_finder/app/config/router.dart';
import 'package:curhat_finder/core/theme/app_colors.dart';
import 'package:curhat_finder/core/theme/app_text_styles.dart';
import 'package:curhat_finder/features/chat/domain/room_model.dart';
import 'package:curhat_finder/features/chat/presentation/providers/chat_list_provider.dart';
import 'package:curhat_finder/features/chat/presentation/widgets/cards/interactive_room_card.dart';
import 'package:curhat_finder/features/chat/presentation/widgets/dialogs/new_room_post_sheet.dart';

/// Tab Rooms Kampus (Diskusi & Curhat Anonim Komunitas Kampus)
class RoomsTab extends ConsumerWidget {
  final Stream<List<RoomModel>> Function(String? category) getRoomsStream;
  final Set<String> likedRoomIds;
  final Set<String> bookmarkedRoomIds;
  final void Function(String roomId, bool isLiked) onToggleLike;
  final void Function(String roomId, bool isBookmarked) onToggleBookmark;
  final void Function(String roomId, bool isLiked, bool isBookmarked) onDetailReturn;

  const RoomsTab({
    super.key,
    required this.getRoomsStream,
    required this.likedRoomIds,
    required this.bookmarkedRoomIds,
    required this.onToggleLike,
    required this.onToggleBookmark,
    required this.onDetailReturn,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatListProvider);

    String? categoryFilter;
    if (state.selectedSubCategory == 1) categoryFilter = 'Akademik';
    if (state.selectedSubCategory == 2) categoryFilter = 'Kesepian';
    if (state.selectedSubCategory == 3) categoryFilter = 'Keuangan';

    return Column(
      children: [
        // Input Box "Tulis curhatanmu..."
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GestureDetector(
            onTap: () => showNewRoomPostSheet(context, ref),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
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
                      color: AppColors.twilightNormal.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Realtime Rooms List
        Expanded(
          child: StreamBuilder<List<RoomModel>>(
            stream: getRoomsStream(categoryFilter),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final rooms = snapshot.data ?? [];

              if (rooms.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.forum_outlined,
                          size: 64,
                          color: AppColors.wisteriaNormal.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum Ada Curhatan',
                          style: AppTextStyles.heading2.copyWith(
                            color: AppColors.twilightDarker,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Jadilah mahasiswa pertama yang memulai obrolan di room ini!',
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

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  final isLiked = likedRoomIds.contains(room.id);
                  final isBookmarked = bookmarkedRoomIds.contains(room.id);

                  final updatedRoom = room.copyWith(
                    isLiked: isLiked,
                    isBookmarked: isBookmarked,
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: InteractiveRoomCard(
                      key: ValueKey(room.id),
                      room: updatedRoom,
                      initialIsLiked: isLiked,
                      initialIsBookmarked: isBookmarked,
                      onToggleLike: (roomId, newIsLiked) {
                        onToggleLike(roomId, newIsLiked);
                      },
                      onToggleBookmark: (roomId, newIsBookmarked) {
                        onToggleBookmark(roomId, newIsBookmarked);
                      },
                      onTap: (clickedRoom) async {
                        final result = await context.push<Map<String, dynamic>>(
                          RoomDetailRoute(roomId: clickedRoom.id).location,
                          extra: clickedRoom,
                        );
                        if (result != null) {
                          final roomId = result['roomId'] as String?;
                          final retIsLiked = result['isLiked'] as bool?;
                          final retIsBookmarked = result['isBookmarked'] as bool?;
                          if (roomId != null) {
                            onDetailReturn(
                              roomId,
                              retIsLiked ?? isLiked,
                              retIsBookmarked ?? isBookmarked,
                            );
                          }
                        }
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
