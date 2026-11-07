import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../domain/tip_model.dart';

class CommunityService {
  final SupabaseClient? client;

  CommunityService({this.client});

  SupabaseClient? get _supabase => client ?? SupabaseService.maybeClient;

  // ==========================================
  // TIPS SECTION
  // ==========================================

  /// Stream tips dari tabel tips dengan filter kategori opsional dan limit batasan
  Stream<List<TipModel>> streamTips({String? category, int limit = 20}) {
    final client = _supabase;
    if (client == null) return const Stream.empty();

    return client
        .from('tips')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(limit)
        .map((rows) {
          final list = rows.map((r) => TipModel.fromJson(r)).toList();
          list.sort((a, b) {
            final cmp = b.createdAt.compareTo(a.createdAt);
            if (cmp != 0) return cmp;
            return b.id.compareTo(a.id);
          });
          if (category != null && category != 'Semua') {
            return list.where((item) => item.category.toLowerCase() == category.toLowerCase()).toList();
          }
          return list;
        });
  }

  /// Membuat tips baru dari pengguna
  Future<TipModel?> createTip({
    String? title,
    required String content,
    String category = 'Self-care',
    String? authorName,
    String? authorFaculty,
    String? authorGender,
  }) async {
    final client = _supabase;
    if (client == null) return null;

    final userId = client.auth.currentUser?.id;

    final trimmedTitle = title?.trim();
    final trimmedContent = content.trim();

    final payload = <String, dynamic>{
      'user_id': userId,
      'author_name': authorName ?? 'Anon',
      'author_faculty': authorFaculty ?? 'FILKOM',
      'author_gender': authorGender ?? 'Laki-laki',
      'category': category,
      'likes_count': 0,
      'bookmarks_count': 0,
    };

    if (trimmedTitle != null && trimmedTitle.isNotEmpty) {
      payload['title'] = trimmedTitle;
      payload['content'] = trimmedContent;
    } else {
      payload['content'] = trimmedContent;
    }

    try {
      final response = await client.from('tips').insert(payload).select().single();
      return TipModel.fromJson(response);
    } catch (_) {
      // Fallback jika database belum dimigrasikan dengan kolom title
      if (trimmedTitle != null && trimmedTitle.isNotEmpty && payload.containsKey('title')) {
        payload.remove('title');
        payload['content'] = '$trimmedTitle\n\n$trimmedContent';
        final fallbackResponse = await client.from('tips').insert(payload).select().single();
        return TipModel.fromJson(fallbackResponse);
      }
      rethrow;
    }
  }

  /// Menghapus tips milik pengguna aktif
  Future<bool> deleteTip(String tipId) async {
    final client = _supabase;
    if (client == null) return false;

    final userId = client.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      await client.from('tips').delete().eq('id', tipId).eq('user_id', userId);
      return true;
    } catch (_) {
      rethrow;
    }
  }

  /// Toggle suka/like pada tips
  Future<bool?> toggleLikeTip(String tipId) async {
    final client = _supabase;
    if (client == null) return null;

    final userId = client.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final existing = await client
          .from('tip_likes')
          .select()
          .eq('user_id', userId)
          .eq('tip_id', tipId)
          .maybeSingle();

      if (existing != null) {
        await client.from('tip_likes').delete().eq('user_id', userId).eq('tip_id', tipId);
        return false; // unliked
      } else {
        await client.from('tip_likes').insert({'user_id': userId, 'tip_id': tipId});
        return true; // liked
      }
    } catch (_) {
      return null;
    }
  }

  /// Toggle simpan/bookmark pada tips
  Future<bool?> toggleBookmarkTip(String tipId) async {
    final client = _supabase;
    if (client == null) return null;

    final userId = client.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final existing = await client
          .from('tip_bookmarks')
          .select()
          .eq('user_id', userId)
          .eq('tip_id', tipId)
          .maybeSingle();

      if (existing != null) {
        await client.from('tip_bookmarks').delete().eq('user_id', userId).eq('tip_id', tipId);
        return false; // unbookmarked
      } else {
        await client.from('tip_bookmarks').insert({'user_id': userId, 'tip_id': tipId});
        return true; // bookmarked
      }
    } catch (_) {
      return null;
    }
  }

  /// Mengambil set ID tips yang sudah di-like oleh pengguna aktif
  Future<Set<String>> fetchUserLikedTips() async {
    final client = _supabase;
    if (client == null) return {};

    final userId = client.auth.currentUser?.id;
    if (userId == null) return {};

    try {
      final rows = await client.from('tip_likes').select('tip_id').eq('user_id', userId);
      return (rows as List).map((r) => r['tip_id'].toString()).toSet();
    } catch (_) {
      return {};
    }
  }

  /// Mengambil set ID tips yang sudah di-bookmark oleh pengguna aktif
  Future<Set<String>> fetchUserBookmarkedTips() async {
    final client = _supabase;
    if (client == null) return {};

    final userId = client.auth.currentUser?.id;
    if (userId == null) return {};

    try {
      final rows = await client.from('tip_bookmarks').select('tip_id').eq('user_id', userId);
      return (rows as List).map((r) => r['tip_id'].toString()).toSet();
    } catch (_) {
      return {};
    }
  }

  // ==========================================
  // PRIVATE SAMBATS SECTION (ISOLATED)
  // ==========================================

  /// Menyimpan catatan curhat privat ke tabel terisolasi user_private_sambats
  Future<Map<String, dynamic>?> createPrivateSambat({
    required String content,
    String moodTag = 'Sambat',
  }) async {
    final client = _supabase;
    if (client == null) return null;

    final userId = client.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await client.from('user_private_sambats').insert({
      'user_id': userId,
      'content': content,
      'mood_tag': moodTag,
    }).select().single();

    return response;
  }

  /// Mengambil daftar riwayat sambat privat milik pengguna saat ini
  Future<List<Map<String, dynamic>>> fetchUserPrivateSambats() async {
    final client = _supabase;
    if (client == null) return [];

    final userId = client.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await client
          .from('user_private_sambats')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      return [];
    }
  }

  // ==========================================
  // JOURNALS SECTION
  // ==========================================

  /// Menyimpan entri perasaan harian (Mood check-in) ke tabel journals
  Future<void> createJournal({
    required int moodIndex,
    String? moodNote,
  }) async {
    final client = _supabase;
    if (client == null) return;

    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    await client.from('journals').insert({
      'user_id': userId,
      'mood_index': moodIndex,
      'mood_note': moodNote,
      'entry_date': DateTime.now().toIso8601String().substring(0, 10),
    });
  }

  /// Mengambil daftar riwayat check-in jurnal milik pengguna saat ini
  Future<List<Map<String, dynamic>>> fetchUserJournals() async {
    final client = _supabase;
    if (client == null) return [];

    final userId = client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await client
        .from('journals')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}

final communityServiceProvider = Provider<CommunityService>((ref) {
  return CommunityService();
});
