import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/community_service.dart';

/// State yang menampung status interaksi Like dan Bookmark secara reaktif global
class TipsInteractionState {
  final Set<String> likedTipIds;
  final Set<String> initialLikedTipIds;
  final Set<String> bookmarkedTipIds;
  final Map<String, int> likesCountDeltas;
  final bool isInitialized;

  const TipsInteractionState({
    this.likedTipIds = const {},
    this.initialLikedTipIds = const {},
    this.bookmarkedTipIds = const {},
    this.likesCountDeltas = const {},
    this.isInitialized = false,
  });

  TipsInteractionState copyWith({
    Set<String>? likedTipIds,
    Set<String>? initialLikedTipIds,
    Set<String>? bookmarkedTipIds,
    Map<String, int>? likesCountDeltas,
    bool? isInitialized,
  }) {
    return TipsInteractionState(
      likedTipIds: likedTipIds ?? this.likedTipIds,
      initialLikedTipIds: initialLikedTipIds ?? this.initialLikedTipIds,
      bookmarkedTipIds: bookmarkedTipIds ?? this.bookmarkedTipIds,
      likesCountDeltas: likesCountDeltas ?? this.likesCountDeltas,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class TipsInteractionNotifier extends Notifier<TipsInteractionState> {
  late final CommunityService _communityService;
  final Set<String> _inFlightLikes = {};
  final Set<String> _inFlightBookmarks = {};
  final Map<String, int> _unlikedBaseCounts = {};
  final Map<String, int> _lastSeenBaseCount = {};

  @override
  TipsInteractionState build() {
    _communityService = ref.watch(communityServiceProvider);
    // Jalankan inisialisasi awal sekali saat provider pertama kali di-read/watch
    Future.microtask(() => initInteractions());
    return const TipsInteractionState();
  }

  /// Memuat interaksi like dan bookmark pengguna dari backend Supabase
  Future<void> initInteractions() async {
    try {
      final likes = await _communityService.fetchUserLikedTips();
      final bookmarks = await _communityService.fetchUserBookmarkedTips();
      state = state.copyWith(
        likedTipIds: likes,
        initialLikedTipIds: likes,
        bookmarkedTipIds: bookmarks,
        isInitialized: true,
      );
    } catch (_) {
      state = state.copyWith(isInitialized: true);
    }
  }

  /// Mengembalikan apakah suatu tips sudah disukai oleh user aktif
  bool isTipLiked(String tipId) {
    return state.likedTipIds.contains(tipId);
  }

  /// Mengembalikan apakah suatu tips sudah disimpan oleh user aktif
  bool isTipBookmarked(String tipId) {
    return state.bookmarkedTipIds.contains(tipId);
  }

  /// Menghapus tips milik pengguna dan membersihkan referensi lokal
  Future<bool> deleteTip(String tipId) async {
    final success = await _communityService.deleteTip(tipId);
    if (success) {
      final updatedLiked = Set<String>.from(state.likedTipIds)..remove(tipId);
      final updatedBookmarked = Set<String>.from(state.bookmarkedTipIds)..remove(tipId);
      _unlikedBaseCounts.remove(tipId);
      _lastSeenBaseCount.remove(tipId);
      state = state.copyWith(
        likedTipIds: updatedLiked,
        bookmarkedTipIds: updatedBookmarked,
      );
    }
    return success;
  }

  /// Menghitung likes count dengan relative baseline terhadap interaksi pengguna.
  /// Menjamin tidak terjadi double-counting (+2 / 0) saat trigger database & Realtime stream tiba.
  int getEffectiveLikesCount(String tipId, int baseCount) {
    final isLikedNow = state.likedTipIds.contains(tipId);

    if (!_unlikedBaseCounts.containsKey(tipId)) {
      final wasInitiallyLiked = state.initialLikedTipIds.contains(tipId);
      final u = wasInitiallyLiked ? (baseCount - 1) : baseCount;
      _unlikedBaseCounts[tipId] = u < 0 ? 0 : u;
      _lastSeenBaseCount[tipId] = baseCount;
    } else if (baseCount != _lastSeenBaseCount[tipId]) {
      _lastSeenBaseCount[tipId] = baseCount;
      final expectedServerCount = _unlikedBaseCounts[tipId]! + (isLikedNow ? 1 : 0);
      if (baseCount != expectedServerCount) {
        // Pembaruan dari pengguna lain di komunitas
        final newU = isLikedNow ? (baseCount - 1) : baseCount;
        _unlikedBaseCounts[tipId] = newU < 0 ? 0 : newU;
      }
    }

    final u = _unlikedBaseCounts[tipId]!;
    final effective = isLikedNow ? u + 1 : u;
    return effective < 0 ? 0 : effective;
  }

  /// Toggle Like dengan Optimistic UI, In-Flight Mutex Lock, dan Server Baseline Sync
  Future<bool> toggleLike(String tipId) async {
    // Cegah race condition jika pengguna melakukan spamming tap pada tip yang sama
    if (_inFlightLikes.contains(tipId)) {
      return state.likedTipIds.contains(tipId);
    }
    _inFlightLikes.add(tipId);

    final previousLiked = state.likedTipIds.contains(tipId);
    final newLiked = !previousLiked;
    final newLikedSet = Set<String>.from(state.likedTipIds);
    if (newLiked) {
      newLikedSet.add(tipId);
    } else {
      newLikedSet.remove(tipId);
    }

    // 1. Optimistic Update Seketika (0ms delay)
    state = state.copyWith(likedTipIds: newLikedSet);

    // 2. Eksekusi Asynchronous ke Supabase
    try {
      final serverResult = await _communityService.toggleLikeTip(tipId);
      final finalLiked = serverResult ?? newLiked;

      final syncedLikedSet = Set<String>.from(state.likedTipIds);
      if (finalLiked) {
        syncedLikedSet.add(tipId);
      } else {
        syncedLikedSet.remove(tipId);
      }

      state = state.copyWith(likedTipIds: syncedLikedSet);
      return finalLiked;
    } catch (e) {
      // 3. Rollback otomatis bila terjadi error network/database
      final rollbackSet = Set<String>.from(state.likedTipIds);
      if (previousLiked) {
        rollbackSet.add(tipId);
      } else {
        rollbackSet.remove(tipId);
      }
      state = state.copyWith(likedTipIds: rollbackSet);
      return previousLiked;
    } finally {
      _inFlightLikes.remove(tipId);
    }
  }

  /// Toggle Bookmark dengan Optimistic UI dan In-Flight Mutex Lock
  Future<bool> toggleBookmark(String tipId) async {
    if (_inFlightBookmarks.contains(tipId)) {
      return state.bookmarkedTipIds.contains(tipId);
    }
    _inFlightBookmarks.add(tipId);

    final previousBookmarked = state.bookmarkedTipIds.contains(tipId);
    final newBookmarked = !previousBookmarked;

    final newBookmarkSet = Set<String>.from(state.bookmarkedTipIds);
    if (newBookmarked) {
      newBookmarkSet.add(tipId);
    } else {
      newBookmarkSet.remove(tipId);
    }

    // 1. Optimistic Update Seketika (0ms delay)
    state = state.copyWith(bookmarkedTipIds: newBookmarkSet);

    // 2. Eksekusi Asynchronous ke Supabase
    try {
      final serverResult = await _communityService.toggleBookmarkTip(tipId);
      if (serverResult != null && serverResult != newBookmarked) {
        final syncedSet = Set<String>.from(state.bookmarkedTipIds);
        if (serverResult) {
          syncedSet.add(tipId);
        } else {
          syncedSet.remove(tipId);
        }
        state = state.copyWith(bookmarkedTipIds: syncedSet);
      }
      return serverResult ?? newBookmarked;
    } catch (e) {
      // 3. Rollback otomatis
      final rollbackSet = Set<String>.from(state.bookmarkedTipIds);
      if (previousBookmarked) {
        rollbackSet.add(tipId);
      } else {
        rollbackSet.remove(tipId);
      }
      state = state.copyWith(bookmarkedTipIds: rollbackSet);
      return previousBookmarked;
    } finally {
      _inFlightBookmarks.remove(tipId);
    }
  }
}

final tipsInteractionProvider =
    NotifierProvider<TipsInteractionNotifier, TipsInteractionState>(
  () => TipsInteractionNotifier(),
);
