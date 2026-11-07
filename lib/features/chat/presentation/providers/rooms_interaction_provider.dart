import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/room_service.dart';
import '../../domain/room_model.dart';

/// State yang menampung status interaksi Like dan Bookmark ruang curhat secara reaktif global
class RoomsInteractionState {
  final Set<String> likedRoomIds;
  final Set<String> initialLikedRoomIds;
  final Set<String> bookmarkedRoomIds;
  final Set<String> initialBookmarkedRoomIds;
  final List<RoomModel> optimisticRooms;
  final bool isInitialized;

  const RoomsInteractionState({
    this.likedRoomIds = const {},
    this.initialLikedRoomIds = const {},
    this.bookmarkedRoomIds = const {},
    this.initialBookmarkedRoomIds = const {},
    this.optimisticRooms = const [],
    this.isInitialized = false,
  });

  RoomsInteractionState copyWith({
    Set<String>? likedRoomIds,
    Set<String>? initialLikedRoomIds,
    Set<String>? bookmarkedRoomIds,
    Set<String>? initialBookmarkedRoomIds,
    List<RoomModel>? optimisticRooms,
    bool? isInitialized,
  }) {
    return RoomsInteractionState(
      likedRoomIds: likedRoomIds ?? this.likedRoomIds,
      initialLikedRoomIds: initialLikedRoomIds ?? this.initialLikedRoomIds,
      bookmarkedRoomIds: bookmarkedRoomIds ?? this.bookmarkedRoomIds,
      initialBookmarkedRoomIds: initialBookmarkedRoomIds ?? this.initialBookmarkedRoomIds,
      optimisticRooms: optimisticRooms ?? this.optimisticRooms,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class RoomsInteractionNotifier extends Notifier<RoomsInteractionState> {
  late final RoomService _roomService;
  final Set<String> _inFlightLikes = {};
  final Set<String> _inFlightBookmarks = {};
  final Map<String, int> _unlikedBaseCounts = {};
  final Map<String, int> _lastSeenBaseCount = {};

  @override
  RoomsInteractionState build() {
    _roomService = ref.watch(roomServiceProvider);
    Future.microtask(() => initInteractions());
    return const RoomsInteractionState();
  }

  /// Memuat interaksi like dan bookmark room pengguna dari Supabase
  Future<void> initInteractions() async {
    try {
      final likes = await _roomService.fetchUserRoomLikes();
      final bookmarks = await _roomService.fetchUserRoomBookmarks();
      state = state.copyWith(
        likedRoomIds: likes,
        initialLikedRoomIds: likes,
        bookmarkedRoomIds: bookmarks,
        initialBookmarkedRoomIds: bookmarks,
        isInitialized: true,
      );
    } catch (_) {
      state = state.copyWith(isInitialized: true);
    }
  }

  /// Mengembalikan apakah suatu room sudah disukai oleh user aktif
  bool isRoomLiked(String roomId) {
    return state.likedRoomIds.contains(roomId);
  }

  /// Mengembalikan apakah suatu room sudah disimpan oleh user aktif
  bool isRoomBookmarked(String roomId) {
    return state.bookmarkedRoomIds.contains(roomId);
  }

  /// Menambahkan room baru secara optimis ke daftar sebelum realtime stream server tiba
  void addOptimisticRoom(RoomModel room) {
    state = state.copyWith(
      optimisticRooms: [
        room,
        ...state.optimisticRooms.where((r) => r.id != room.id),
      ],
    );
  }

  /// Menghapus room optimis jika dibatalkan atau terjadi kegagalan
  void removeOptimisticRoom(String roomId) {
    state = state.copyWith(
      optimisticRooms: state.optimisticRooms.where((r) => r.id != roomId).toList(),
    );
  }

  /// Menghapus room milik pengguna aktif dan membersihkan state lokal
  Future<bool> deleteRoom(String roomId) async {
    final success = await _roomService.deleteRoom(roomId);
    if (success) {
      final updatedLiked = Set<String>.from(state.likedRoomIds)..remove(roomId);
      final updatedBookmarked = Set<String>.from(state.bookmarkedRoomIds)..remove(roomId);
      final updatedOptimistic = state.optimisticRooms.where((r) => r.id != roomId).toList();
      _unlikedBaseCounts.remove(roomId);
      _lastSeenBaseCount.remove(roomId);
      state = state.copyWith(
        likedRoomIds: updatedLiked,
        bookmarkedRoomIds: updatedBookmarked,
        optimisticRooms: updatedOptimistic,
      );
    }
    return success;
  }

  /// Menghitung likes count room dengan relative baseline terhadap interaksi pengguna.
  /// Mencegah double counting saat Realtime stream mengalirkan update trigger database.
  int getEffectiveLikesCount(String roomId, int baseCount) {
    final isLikedNow = state.likedRoomIds.contains(roomId);

    if (!_unlikedBaseCounts.containsKey(roomId)) {
      final wasInitiallyLiked = state.initialLikedRoomIds.contains(roomId);
      final u = wasInitiallyLiked ? (baseCount - 1) : baseCount;
      _unlikedBaseCounts[roomId] = u < 0 ? 0 : u;
      _lastSeenBaseCount[roomId] = baseCount;
    } else if (baseCount != _lastSeenBaseCount[roomId]) {
      _lastSeenBaseCount[roomId] = baseCount;
      final expectedServerCount = _unlikedBaseCounts[roomId]! + (isLikedNow ? 1 : 0);
      if (baseCount != expectedServerCount) {
        final newU = isLikedNow ? (baseCount - 1) : baseCount;
        _unlikedBaseCounts[roomId] = newU < 0 ? 0 : newU;
      }
    }

    final u = _unlikedBaseCounts[roomId]!;
    final effective = isLikedNow ? u + 1 : u;
    return effective < 0 ? 0 : effective;
  }

  /// Toggle Like pada Room dengan Optimistic UI dan Server Baseline Sync
  Future<bool> toggleLike(String roomId) async {
    if (_inFlightLikes.contains(roomId)) {
      return state.likedRoomIds.contains(roomId);
    }
    _inFlightLikes.add(roomId);

    final previousLiked = state.likedRoomIds.contains(roomId);
    final newLiked = !previousLiked;
    final newLikedSet = Set<String>.from(state.likedRoomIds);
    if (newLiked) {
      newLikedSet.add(roomId);
    } else {
      newLikedSet.remove(roomId);
    }

    // 1. Optimistic Update Seketika (0ms delay)
    state = state.copyWith(likedRoomIds: newLikedSet);

    // 2. Eksekusi Asynchronous ke Supabase
    try {
      final serverResult = await _roomService.toggleLikeRoom(roomId);
      final finalLiked = serverResult;

      final syncedLikedSet = Set<String>.from(state.likedRoomIds);
      if (finalLiked) {
        syncedLikedSet.add(roomId);
      } else {
        syncedLikedSet.remove(roomId);
      }

      state = state.copyWith(likedRoomIds: syncedLikedSet);
      return finalLiked;
    } catch (e) {
      // 3. Rollback otomatis
      final rollbackSet = Set<String>.from(state.likedRoomIds);
      if (previousLiked) {
        rollbackSet.add(roomId);
      } else {
        rollbackSet.remove(roomId);
      }
      state = state.copyWith(likedRoomIds: rollbackSet);
      return previousLiked;
    } finally {
      _inFlightLikes.remove(roomId);
    }
  }

  /// Toggle Bookmark pada Room dengan Optimistic UI dan Server Baseline Sync
  Future<bool> toggleBookmark(String roomId) async {
    if (_inFlightBookmarks.contains(roomId)) {
      return state.bookmarkedRoomIds.contains(roomId);
    }
    _inFlightBookmarks.add(roomId);

    final previousBookmarked = state.bookmarkedRoomIds.contains(roomId);
    final newBookmarked = !previousBookmarked;

    final newBookmarkSet = Set<String>.from(state.bookmarkedRoomIds);
    if (newBookmarked) {
      newBookmarkSet.add(roomId);
    } else {
      newBookmarkSet.remove(roomId);
    }

    // 1. Optimistic Update Seketika (0ms delay)
    state = state.copyWith(bookmarkedRoomIds: newBookmarkSet);

    // 2. Eksekusi Asynchronous ke Supabase
    try {
      final serverResult = await _roomService.toggleBookmarkRoom(roomId);
      final finalBookmarked = serverResult;

      final syncedBookmarkSet = Set<String>.from(state.bookmarkedRoomIds);
      final syncedInitialSet = Set<String>.from(state.initialBookmarkedRoomIds);

      if (finalBookmarked) {
        syncedBookmarkSet.add(roomId);
        syncedInitialSet.add(roomId);
      } else {
        syncedBookmarkSet.remove(roomId);
        syncedInitialSet.remove(roomId);
      }

      state = state.copyWith(
        bookmarkedRoomIds: syncedBookmarkSet,
        initialBookmarkedRoomIds: syncedInitialSet,
      );
      return finalBookmarked;
    } catch (e) {
      // 3. Rollback otomatis
      final rollbackSet = Set<String>.from(state.bookmarkedRoomIds);
      if (previousBookmarked) {
        rollbackSet.add(roomId);
      } else {
        rollbackSet.remove(roomId);
      }
      state = state.copyWith(bookmarkedRoomIds: rollbackSet);
      return previousBookmarked;
    } finally {
      _inFlightBookmarks.remove(roomId);
    }
  }
}

final roomsInteractionProvider =
    NotifierProvider<RoomsInteractionNotifier, RoomsInteractionState>(
  () => RoomsInteractionNotifier(),
);
