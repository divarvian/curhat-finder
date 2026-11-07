import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curhat_finder/core/constants/app_categories.dart';
import 'package:curhat_finder/core/theme/app_colors.dart';
import 'package:curhat_finder/core/theme/app_text_styles.dart';
import 'package:curhat_finder/core/utils/academic_helper.dart';
import 'package:curhat_finder/core/widgets/app_pill.dart';
import 'package:curhat_finder/features/chat/data/counseling_service.dart';
import 'package:curhat_finder/features/chat/data/room_service.dart';
import 'package:curhat_finder/features/chat/domain/room_model.dart';
import 'package:curhat_finder/features/chat/presentation/providers/chat_list_provider.dart';
import 'tabs/anon_chat_tab.dart';
import 'tabs/rooms_tab.dart';
import 'tabs/support_buddy_tab.dart';

class ChatListView extends ConsumerStatefulWidget {
  const ChatListView({super.key});

  @override
  ConsumerState<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends ConsumerState<ChatListView> {
  Set<String> _likedRoomIds = {};
  Set<String> _bookmarkedRoomIds = {};
  Stream<List<RoomModel>>? _roomsStream;
  String? _cachedRoomCategory;
  bool _isRoomsStreamInitialized = false;
  Stream<List<Map<String, dynamic>>>? _counselorsStream;

  @override
  void initState() {
    super.initState();
    _loadUserRoomInteractions();
  }

  void _loadUserRoomInteractions() async {
    final roomService = ref.read(roomServiceProvider);
    try {
      final likes = await roomService.fetchUserRoomLikes();
      final bookmarks = await roomService.fetchUserRoomBookmarks();
      if (mounted) {
        setState(() {
          _likedRoomIds = likes;
          _bookmarkedRoomIds = bookmarks;
        });
      }
    } catch (_) {}
  }

  Stream<List<RoomModel>> _getRoomsStream(String? category) {
    if (!_isRoomsStreamInitialized || _cachedRoomCategory != category) {
      _cachedRoomCategory = category;
      _isRoomsStreamInitialized = true;
      _roomsStream = ref.read(roomServiceProvider).streamRooms(category: category);
    }
    return _roomsStream!;
  }

  Stream<List<Map<String, dynamic>>> _getCounselorsStream() {
    _counselorsStream ??= ref.read(counselingServiceProvider).streamCounselors();
    return _counselorsStream!;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header Bar
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 20),
              child: Center(
                child: Text(
                  'Ruang Cerita',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.twilightDarker,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Tab Utama (SupportBuddy, Rooms, Chat Anon)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildMainCategoryChip(ref, state, 'SupportBuddy', 0),
                    const SizedBox(width: 8),
                    _buildMainCategoryChip(ref, state, 'Rooms', 1),
                    const SizedBox(width: 8),
                    _buildMainCategoryChip(ref, state, 'Chat Anon', 2),
                  ],
                ),
              ),
            ),

            // Sub Kategori Filter Chips
            if (state.selectedMainCategory != 2) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: state.selectedMainCategory == 0
                        ? AcademicHelper.supportBuddyFilterOptions.length
                        : AppCategories.roomFilterCategories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final label = state.selectedMainCategory == 0
                          ? AcademicHelper.supportBuddyFilterOptions[index]
                          : AppCategories.roomFilterCategories[index];
                      return _buildSubCategoryChip(ref, state, label, index);
                    },
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Konten Tab Terpilih
            Expanded(
              child: state.selectedMainCategory == 0
                  ? SupportBuddyTab(
                      counselorsStream: _getCounselorsStream(),
                    )
                  : state.selectedMainCategory == 1
                      ? RoomsTab(
                          getRoomsStream: _getRoomsStream,
                          likedRoomIds: _likedRoomIds,
                          bookmarkedRoomIds: _bookmarkedRoomIds,
                          onToggleLike: (roomId, newIsLiked) {
                            setState(() {
                              if (newIsLiked) {
                                _likedRoomIds.add(roomId);
                              } else {
                                _likedRoomIds.remove(roomId);
                              }
                            });
                            ref.read(roomServiceProvider).toggleLikeRoom(roomId);
                          },
                          onToggleBookmark: (roomId, newIsBookmarked) {
                            setState(() {
                              if (newIsBookmarked) {
                                _bookmarkedRoomIds.add(roomId);
                              } else {
                                _bookmarkedRoomIds.remove(roomId);
                              }
                            });
                            ref.read(roomServiceProvider).toggleBookmarkRoom(roomId);
                          },
                          onDetailReturn: (roomId, retIsLiked, retIsBookmarked) {
                            setState(() {
                              if (retIsLiked) {
                                _likedRoomIds.add(roomId);
                              } else {
                                _likedRoomIds.remove(roomId);
                              }
                              if (retIsBookmarked) {
                                _bookmarkedRoomIds.add(roomId);
                              } else {
                                _bookmarkedRoomIds.remove(roomId);
                              }
                            });
                          },
                        )
                      : const AnonChatTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCategoryChip(WidgetRef ref, ChatListState state, String label, int index) {
    final isSelected = state.selectedMainCategory == index;
    return AppPill(
      label: label,
      isSelected: isSelected,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      onTap: () => ref.read(chatListProvider.notifier).setMainCategory(index),
    );
  }

  Widget _buildSubCategoryChip(WidgetRef ref, ChatListState state, String label, int index) {
    final isSelected = state.selectedSubCategory == index;
    return AppPill(
      label: label,
      isSelected: isSelected,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: () => ref.read(chatListProvider.notifier).setSubCategory(index),
    );
  }
}
