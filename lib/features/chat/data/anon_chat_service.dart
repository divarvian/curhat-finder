import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../domain/anon_chat_model.dart';

class AnonChatService {
  final SupabaseClient? client;

  AnonChatService({this.client});

  SupabaseClient get _supabase {
    if (client != null) return client!;
    final c = SupabaseService.maybeClient;
    if (c != null) return c;
    throw StateError('Supabase is not initialized');
  }

  /// Mencari atau membuat sesi obrolan anonim secara atomik melalui Supabase RPC
  Future<AnonMatchResult> joinMatchmaking({
    required String mode,
    required String userAlias,
  }) async {
    try {
      final res = await _supabase.rpc('match_anon_peer', params: {
        'p_mode': mode,
      });

      if (res is Map<String, dynamic>) {
        return AnonMatchResult.fromJson(res);
      }
      final map = Map<String, dynamic>.from(res as Map);
      return AnonMatchResult.fromJson(map);
    } catch (e) {
      // Fallback jika terjadi kendala RPC (misal koneksi offline)
      return const AnonMatchResult(
        sessionId: 'local-session',
        status: 'active',
        matched: false,
        role: 'creator',
      );
    }
  }

  /// Membatalkan antrean matchmaking yang sedang menunggu
  Future<void> cancelMatchmaking(String sessionId) async {
    if (sessionId.isEmpty || sessionId == 'local-session') return;
    try {
      await _supabase.rpc('cancel_anon_match', params: {
        'p_session_id': sessionId,
      });
    } catch (_) {
      try {
        await _supabase.from('anon_chat_sessions').update({
          'status': 'cancelled',
          'ended_at': DateTime.now().toIso8601String(),
        }).eq('id', sessionId);
      } catch (_) {}
    }
  }

  /// Mengaktifkan mode companion jika tidak ada teman dalam beberapa detik
  Future<void> enableCompanionFallback(String sessionId, String mode) async {
    if (sessionId.isEmpty || sessionId == 'local-session') return;
    try {
      await _supabase.rpc('enable_anon_companion_fallback', params: {
        'p_session_id': sessionId,
        'p_mode': mode,
      });
    } catch (_) {
      // Fallback manual update
      try {
        await _supabase.from('anon_chat_sessions').update({
          'is_bot_session': true,
          'status': 'active',
        }).eq('id', sessionId);

        final promptText = mode.contains('didengar')
            ? 'Teman pendengar hadir untukmu. Aku di sini untuk mendengarkan semua ceritamu tanpa menghakimi 🤍'
            : 'Teman curhatmu siap bertukar pikiran. Ceritakan apa yang ada di benakmu, kita cari solusi bareng-bareng ya 🌿';

        await _supabase.from('anon_messages').insert({
          'session_id': sessionId,
          'sender_alias': 'Teman Anonim',
          'message_text': promptText,
          'is_system': false,
        });
      } catch (_) {}
    }
  }

  /// Mengambil sesi anonim yang sedang aktif milik pengguna saat ini (Reconnection)
  Future<AnonSessionModel?> getActiveSessionForUser() async {
    try {
      final res = await _supabase.rpc('get_active_anon_session');
      if (res == null) return null;
      if (res is Map<String, dynamic>) {
        return AnonSessionModel.fromJson(res);
      }
      final map = Map<String, dynamic>.from(res as Map);
      return AnonSessionModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  /// Stream perubahan status dan data sesi anonim secara realtime
  Stream<AnonSessionModel?> streamSession(String sessionId) {
    if (sessionId.isEmpty || sessionId == 'local-session') {
      return const Stream.empty();
    }
    return _supabase
        .from('anon_chat_sessions')
        .stream(primaryKey: ['id'])
        .eq('id', sessionId)
        .map((rows) {
          if (rows.isEmpty) return null;
          return AnonSessionModel.fromJson(rows.first);
        });
  }

  /// Mengambil data sesi satu kali
  Future<AnonSessionModel?> getSession(String sessionId) async {
    if (sessionId.isEmpty || sessionId == 'local-session') return null;
    try {
      final data = await _supabase
          .from('anon_chat_sessions')
          .select()
          .eq('id', sessionId)
          .maybeSingle();
      if (data == null) return null;
      return AnonSessionModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  /// Stream pesan percakapan realtime anonim
  Stream<List<AnonMessageModel>> streamMessages(String sessionId) {
    if (sessionId.isEmpty || sessionId == 'local-session') {
      return const Stream.empty();
    }
    return _supabase
        .from('anon_messages')
        .stream(primaryKey: ['id'])
        .eq('session_id', sessionId)
        .order('created_at', ascending: true)
        .map((rows) => rows.map((r) => AnonMessageModel.fromJson(r)).toList());
  }

  /// Mengirim pesan anonim
  Future<AnonMessageModel?> sendMessage({
    required String sessionId,
    required String messageText,
    required String senderAlias,
    bool isBotSession = false,
    String mode = 'Cuma mau didengar',
    String? messageId,
  }) async {
    final currentUserId = _supabase.auth.currentUser?.id;

    if (sessionId.isNotEmpty && sessionId != 'local-session') {
      final insertData = <String, dynamic>{
        'session_id': sessionId,
        'sender_id': currentUserId,
        'sender_alias': senderAlias,
        'message_text': messageText,
        'is_system': false,
        'is_read': false,
      };
      if (messageId != null) {
        insertData['id'] = messageId;
      }
      final res = await _supabase.from('anon_messages').insert(insertData).select().maybeSingle();
      if (res != null) {
        return AnonMessageModel.fromJson(res);
      }
      return null;
    }

    // Jika bot session lokal tanpa server, balas secara otomatis
    if (isBotSession && (sessionId.isEmpty || sessionId == 'local-session')) {
      _triggerCompanionReply(sessionId, messageText, mode);
    }
    return null;
  }

  void _triggerCompanionReply(String sessionId, String userText, String mode) {
    Future.delayed(const Duration(milliseconds: 1800), () async {
      try {
        final repliesListen = [
          'Aku paham banget apa yang kamu rasain. Pasti berat ya menghadapi situasi seperti itu...',
          'Terima kasih sudah berani terbuka dan cerita ke aku. Kamu gak sendirian kok, aku setia mendengarkan.',
          'Nafas dalam-dalam dulu ya... Luapkan aja semuanya di sini tanpa rasa cemas.',
          'Wajar banget kamu merasa begitu. Setiap emosi dan perasaanmu itu valid.',
          'Aku di sini menyimak ceritamu. Lanjutin aja kalau itu bikin hatimu lebih lega 🤍',
          'Terkadang dunia terasa terlalu bising ya... Di ruang ini kamu boleh rehat sejenak dan jadi dirimu sendiri.',
          'Peluk hangat dari jauh untukmu. Ceritakan apa pun yang masih mengganjal di hatimu ya.',
        ];

        final repliesAdvice = [
          'Dari sudut pandangku, kamu sudah berjuang luar biasa sejauh ini. Mungkin kamu bisa coba istirahat sejenak dulu?',
          'Kondisi ini memang menantang, tapi jangan ragu buat ambil langkah kecil satu per satu ya.',
          'Menurutku, penting buat kamu prioritaskan ketenangan pikiranmu dulu sebelum mikirin ekspektasi orang lain.',
          'Kalau aku di posisimu, mungkin aku bakal coba komunikasikan ini pelan-pelan ke orang terdekat. Kamu pasti bisa melaluinya!',
          'Keren banget kamu punya kesadaran reflektif seperti ini. Satu solusi yang bisa dicoba adalah beri jeda untuk dirimu hari ini.',
          'Jangan terlalu keras pada dirimu sendiri ya. Apa kira-kira hal paling sederhana yang bisa bikin kamu merasa lebih baik sekarang?',
          'Cobalah fokus ke hal-hal yang berada di kendalimu dulu. Satu masalah pada satu waktu, kamu punya kekuatan buat melewatinya!',
        ];

        final pool = mode.contains('didengar') ? repliesListen : repliesAdvice;
        final selectedReply = pool[Random().nextInt(pool.length)];

        if (sessionId.isNotEmpty && sessionId != 'local-session') {
          await _supabase.from('anon_messages').insert({
            'session_id': sessionId,
            'sender_alias': 'Teman Anonim',
            'message_text': selectedReply,
            'is_system': false,
          });
        }
      } catch (_) {}
    });
  }

  /// Menandai semua pesan partner dalam sesi anonim sebagai terbaca (Read Receipts)
  Future<void> markMessagesAsRead(String sessionId) async {
    if (sessionId.isEmpty || sessionId == 'local-session') return;
    try {
      await _supabase.rpc('mark_anon_messages_as_read', params: {
        'p_session_id': sessionId,
      });
    } catch (_) {
      try {
        final currentUserId = _supabase.auth.currentUser?.id;
        final filter = _supabase
            .from('anon_messages')
            .update({'is_read': true})
            .eq('session_id', sessionId)
            .eq('is_read', false);
        if (currentUserId != null) {
          await filter.neq('sender_id', currentUserId);
        } else {
          await filter;
        }
      } catch (_) {}
    }
  }

  /// Mengakhiri sesi anonim
  Future<void> endSession(String sessionId) async {
    if (sessionId.isEmpty || sessionId == 'local-session') return;
    try {
      await _supabase.from('anon_chat_sessions').update({
        'status': 'ended',
        'ended_at': DateTime.now().toIso8601String(),
      }).eq('id', sessionId);
    } catch (_) {}
  }

  /// Menghapus pesan hanya untuk diri sendiri (Delete for Me)
  Future<void> deleteMessagesForMe(List<String> messageIds) async {
    if (messageIds.isEmpty) return;
    try {
      await _supabase.rpc('delete_messages_for_me', params: {
        'p_message_ids': messageIds,
        'p_is_anon': true,
      });
    } catch (_) {
      try {
        final currentUserId = _supabase.auth.currentUser?.id;
        if (currentUserId != null) {
          for (final id in messageIds) {
            final msg = await _supabase
                .from('anon_messages')
                .select('deleted_for_users')
                .eq('id', id)
                .maybeSingle();
            if (msg != null) {
              final rawList = msg['deleted_for_users'] as List<dynamic>?;
              final list = rawList?.map((e) => e.toString()).toList() ?? [];
              if (!list.contains(currentUserId)) {
                list.add(currentUserId);
                await _supabase
                    .from('anon_messages')
                    .update({'deleted_for_users': list})
                    .eq('id', id);
              }
            }
          }
        }
      } catch (_) {}
    }
  }

  /// Menarik pesan untuk semua orang (Delete for Everyone / Unsend)
  Future<void> unsendMessagesForEveryone(List<String> messageIds) async {
    if (messageIds.isEmpty) return;
    try {
      await _supabase.rpc('unsend_messages_for_everyone', params: {
        'p_message_ids': messageIds,
        'p_is_anon': true,
      });
    } catch (_) {
      try {
        final currentUserId = _supabase.auth.currentUser?.id;
        final filter = _supabase
            .from('anon_messages')
            .update({
              'is_deleted_for_everyone': true,
              'deleted_at': DateTime.now().toIso8601String(),
            })
            .inFilter('id', messageIds);
        if (currentUserId != null) {
          await filter.eq('sender_id', currentUserId);
        } else {
          await filter;
        }
      } catch (_) {}
    }
  }

  /// Melaporkan sesi anonim melalui RPC submit_anon_report
  Future<bool> submitReport({
    required String sessionId,
    required String reason,
    String? details,
  }) async {
    if (sessionId.isEmpty || sessionId == 'local-session') return true;
    try {
      final res = await _supabase.rpc('submit_anon_report', params: {
        'p_session_id': sessionId,
        'p_reason': reason,
        'p_details': details,
      });
      return res != null;
    } catch (_) {
      try {
        final currentUserId = _supabase.auth.currentUser?.id;
        if (currentUserId != null) {
          await _supabase.from('anon_reports').insert({
            'session_id': sessionId,
            'reporter_id': currentUserId,
            'reason': reason,
            'details': details,
          });
          await endSession(sessionId);
          return true;
        }
      } catch (_) {}
      return false;
    }
  }

  /// Channel status realtime untuk typing, emoji indicator, dan Presence
  RealtimeChannel createChatStatusChannel(String sessionId) {
    return _supabase.channel('anon_status_$sessionId');
  }

  /// Lacak kehadiran pengguna secara realtime (Presence)
  void trackPresence({
    required RealtimeChannel channel,
    required String userId,
    required String presenceState, // 'online', 'in_background'
  }) {
    try {
      channel.track({
        'user_id': userId,
        'presence_state': presenceState,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  /// Broadcast ephemeral status pengguna ('typing', 'choosing_emoji', 'idle')
  void broadcastUserStatus({
    required RealtimeChannel channel,
    required String senderId,
    required String status,
  }) {
    channel.sendBroadcastMessage(
      event: 'user_status',
      payload: {
        'sender_id': senderId,
        'status': status,
      },
    );
  }
}

final anonChatServiceProvider = Provider<AnonChatService>((ref) {
  return AnonChatService();
});

/// Provider sesi anonim aktif saat ini (untuk Reconnection Card di UI)
final activeAnonSessionProvider = FutureProvider.autoDispose<AnonSessionModel?>((ref) async {
  final service = ref.watch(anonChatServiceProvider);
  return service.getActiveSessionForUser();
});
