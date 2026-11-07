import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../domain/room_model.dart';

class RoomService {
  final SupabaseClient _supabase;

  RoomService({SupabaseClient? client})
      : _supabase = client ?? SupabaseService.client;

  /// Stream feed ruang curhat (rooms) dari Supabase Realtime dengan limit
  Stream<List<RoomModel>> streamRooms({String? category, int limit = 20}) {
    return _supabase
        .from('rooms')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(limit)
        .map((rows) {
          final list = rows.map((r) => RoomModel.fromJson(r)).toList();
          list.sort((a, b) {
            final cmp = b.createdAt.compareTo(a.createdAt);
            if (cmp != 0) return cmp;
            return b.id.compareTo(a.id);
          });
          if (category != null && category != 'Semua') {
            return list.where((r) => r.category.toLowerCase() == category.toLowerCase()).toList();
          }
          return list;
        });
  }

  /// Ambil data single room berdasarkan ID
  Future<RoomModel?> getRoom(String roomId) async {
    try {
      final res = await _supabase.from('rooms').select().eq('id', roomId).single();
      return RoomModel.fromJson(res);
    } catch (_) {
      return null;
    }
  }

  /// Membuat postingan room curhat baru
  Future<RoomModel?> createRoom({
    required String title,
    required String content,
    required String category,
    String? authorName,
    String? authorFaculty,
    String? authorGender,
    String? authorTag,
  }) async {
    final userId = _supabase.auth.currentUser?.id;

    final name = authorName ?? (authorTag != null ? (authorTag.contains(' • ') ? authorTag.split(' • ').first : authorTag) : 'Anonim');
    final faculty = authorFaculty ?? (authorTag != null && authorTag.contains(' • ') ? authorTag.split(' • ').last : 'FILKOM');
    final gender = authorGender ?? 'Laki-laki';

    final payload = <String, dynamic>{
      'title': title,
      'content': content,
      'category': category,
      'author_name': name,
      'author_faculty': faculty,
      'author_gender': gender,
      'likes_count': 0,
      'comments_count': 0,
      'bookmarks_count': 0,
    };
    if (userId != null) {
      payload['user_id'] = userId;
    }

    final response = await _supabase.from('rooms').insert(payload).select().single();
    return RoomModel.fromJson(response);
  }

  /// Menghapus postingan room curhat milik pengguna aktif
  Future<bool> deleteRoom(String roomId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      await _supabase.from('rooms').delete().eq('id', roomId).eq('user_id', userId);
      return true;
    } catch (_) {
      rethrow;
    }
  }

  /// Mengambil set ID room yang disukai pengguna saat ini
  Future<Set<String>> fetchUserRoomLikes() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return {};

    try {
      final rows = await _supabase.from('room_likes').select('room_id').eq('user_id', userId);
      return (rows as List).map((r) => r['room_id'].toString()).toSet();
    } catch (_) {
      return {};
    }
  }

  /// Mengambil set ID room yang disimpan/bookmark oleh pengguna saat ini
  Future<Set<String>> fetchUserRoomBookmarks() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return {};

    try {
      final rows = await _supabase.from('room_bookmarks').select('room_id').eq('user_id', userId);
      return (rows as List).map((r) => r['room_id'].toString()).toSet();
    } catch (_) {
      return {};
    }
  }

  /// Toggle suka / tidak suka pada sebuah room curhat
  Future<bool> toggleLikeRoom(String roomId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      final existing = await _supabase
          .from('room_likes')
          .select()
          .eq('user_id', userId)
          .eq('room_id', roomId)
          .maybeSingle();

      if (existing != null) {
        await _supabase.from('room_likes').delete().eq('user_id', userId).eq('room_id', roomId);
        return false;
      } else {
        await _supabase.from('room_likes').insert({
          'user_id': userId,
          'room_id': roomId,
        });
        return true;
      }
    } catch (_) {
      return false;
    }
  }

  /// Toggle simpan / bookmark pada sebuah room curhat
  Future<bool> toggleBookmarkRoom(String roomId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      final existing = await _supabase
          .from('room_bookmarks')
          .select()
          .eq('user_id', userId)
          .eq('room_id', roomId)
          .maybeSingle();

      if (existing != null) {
        await _supabase.from('room_bookmarks').delete().eq('user_id', userId).eq('room_id', roomId);
        return false;
      } else {
        await _supabase.from('room_bookmarks').insert({
          'user_id': userId,
          'room_id': roomId,
        });
        return true;
      }
    } catch (_) {
      return false;
    }
  }

  /// Stream komentar realtime untuk sebuah room
  Stream<List<RoomCommentModel>> streamComments(String roomId) {
    return _supabase
        .from('room_comments')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at', ascending: true)
        .map((rows) {
          final list = rows.map((r) => RoomCommentModel.fromJson(r)).toList();
          list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          return list;
        });
  }

  /// Mengirim komentar baru ke dalam room
  Future<void> addComment({
    required String roomId,
    required String content,
    String? authorName,
    String? authorFaculty,
    String? authorRole,
    String? authorTag,
  }) async {
    final userId = _supabase.auth.currentUser?.id;

    final name = authorName ?? (authorTag != null ? (authorTag.contains(' • ') ? authorTag.split(' • ').first : authorTag) : 'Teman Kampus');
    final faculty = authorFaculty ?? (authorTag != null && authorTag.contains(' • ') ? authorTag.split(' • ').last : 'FILKOM');
    final role = authorRole ?? (authorTag != null && authorTag.toLowerCase().contains('konselor') ? 'konselor' : 'mahasiswa');

    final payload = <String, dynamic>{
      'room_id': roomId,
      'content': content,
      'author_name': name,
      'author_faculty': faculty,
      'author_role': role,
      'likes_count': 0,
    };
    if (userId != null) {
      payload['user_id'] = userId;
    }

    await _supabase.from('room_comments').insert(payload);
  }
}

final roomServiceProvider = Provider<RoomService>((ref) {
  return RoomService();
});
