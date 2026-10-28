import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../domain/counseling_models.dart';

class CounselingService {
  final SupabaseClient? client;

  CounselingService({this.client});

  SupabaseClient get _supabase {
    if (client != null) return client!;
    final c = SupabaseService.maybeClient;
    if (c != null) return c;
    throw StateError('Supabase is not initialized');
  }

  // In-memory cache pesan obrolan per session_id (Session-Scoped Cache)
  final Map<String, List<ChatMessageModel>> _sessionChatCache = {};

  List<ChatMessageModel> getSessionCache(String sessionId) {
    if (sessionId.isEmpty) return const [];
    final list = _sessionChatCache[sessionId];
    return list != null ? List<ChatMessageModel>.from(list) : const [];
  }

  void updateSessionCache(String sessionId, List<ChatMessageModel> messages) {
    if (sessionId.isNotEmpty) {
      _sessionChatCache[sessionId] = List<ChatMessageModel>.from(messages);
    }
  }

  void clearSessionCache(String sessionId) {
    _sessionChatCache.remove(sessionId);
  }

  /// Stream daftar konselor dari database profiles
  Stream<List<Map<String, dynamic>>> streamCounselors() {
    return _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('role', 'konselor');
  }

  /// Toggle status kehadiran (Ready To Listen) konselor
  Future<void> updateOnlineStatus(String userId, bool isOnline) async {
    try {
      await _supabase.from('profiles').update({
        'is_online': isOnline,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (_) {}
  }

  /// Mahasiswa mengajukan sesi konseling ke antrean
  Future<CounselingQueueModel> requestCounseling({
    required String studentId,
    required String counselorId,
    required String studentAlias,
    required String studentGender,
    required String studentFaculty,
    String? preferredTopic,
  }) async {
    // 0. Batasan Sesi Tunggal Mahasiswa: Cek apakah mahasiswa masih memiliki sesi aktif yang berjalan
    if (studentId.isNotEmpty && studentId != 'student-demo') {
      try {
        final activeSessions = await _supabase
            .from('counseling_sessions')
            .select('id, counselor_id')
            .eq('student_id', studentId)
            .eq('status', 'active')
            .limit(1);

        if (activeSessions.isNotEmpty) {
          throw Exception(
            'Kamu masih memiliki sesi konseling aktif yang sedang berjalan. '
            'Selesaikan sesi tersebut terlebih dahulu sebelum memulai sesi konseling baru.',
          );
        }
      } catch (e) {
        if (e.toString().contains('masih memiliki sesi')) rethrow;
      }
    }

    // 1. Validasi: pastikan konselor online jika konselor terdaftar di database
    if (counselorId.isNotEmpty && counselorId != 'counselor-demo') {
      try {
        final counselorData = await _supabase
            .from('profiles')
            .select('is_online')
            .eq('id', counselorId)
            .maybeSingle();

        final isOnline = counselorData?['is_online'] as bool? ?? false;
        if (!isOnline) {
          throw Exception('Konselor saat ini sedang offline dan tidak menerima antrean baru.');
        }
      } catch (e) {
        if (e.toString().contains('offline')) rethrow;
      }
    }

    // 2. Cek apakah sudah ada antrean berstatus waiting untuk mahasiswa ini dengan konselor ini
    try {
      final existingQueue = await _supabase
          .from('counseling_queues')
          .select()
          .eq('student_id', studentId)
          .eq('assigned_counselor_id', counselorId)
          .eq('status', 'waiting')
          .maybeSingle();

      if (existingQueue != null) {
        return CounselingQueueModel.fromJson(existingQueue);
      }
    } catch (_) {}

    // 3. Batalkan antrean waiting yang lain dari mahasiswa ini untuk mencegah duplikasi/zombie
    try {
      await _supabase
          .from('counseling_queues')
          .update({
            'status': 'cancelled',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('student_id', studentId)
          .eq('status', 'waiting');
    } catch (_) {}

    final response = await _supabase.from('counseling_queues').insert({
      'student_id': studentId,
      'assigned_counselor_id': counselorId,
      'student_alias': studentAlias,
      'student_gender': studentGender,
      'student_faculty': studentFaculty,
      'preferred_topic': preferredTopic,
      'status': 'waiting',
    }).select().single();

    return CounselingQueueModel.fromJson(response);
  }

  /// Mengambil sesi konseling aktif mahasiswa saat ini (jika ada) terlepas dari konselornya
  Future<CounselingSessionModel?> getActiveSessionForStudent(String studentId) async {
    try {
      final rows = await _supabase
          .from('counseling_sessions')
          .select()
          .eq('student_id', studentId)
          .eq('status', 'active')
          .order('started_at', ascending: false)
          .limit(1);

      if (rows.isNotEmpty) {
        return CounselingSessionModel.fromJson(rows.first);
      }
    } catch (_) {}
    return null;
  }

  /// Memeriksa apakah mahasiswa sudah memiliki sesi aktif dengan konselor tertentu
  Future<CounselingSessionModel?> getActiveSession({
    required String studentId,
    required String counselorId,
  }) async {
    try {
      final rows = await _supabase
          .from('counseling_sessions')
          .select()
          .eq('student_id', studentId)
          .eq('counselor_id', counselorId)
          .eq('status', 'active')
          .order('started_at', ascending: false)
          .limit(1);

      if (rows.isNotEmpty) {
        return CounselingSessionModel.fromJson(rows.first);
      }
    } catch (_) {}
    return null;
  }

  /// Mahasiswa membatalkan antrean konseling di database
  Future<void> cancelQueue(String queueId) async {
    try {
      await _supabase.from('counseling_queues').update({
        'status': 'cancelled',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', queueId);
    } catch (_) {}
  }

  /// Mendengarkan update status antrean mahasiswa tertentu secara realtime
  Stream<List<Map<String, dynamic>>> streamStudentQueue(String studentId) {
    return _supabase
        .from('counseling_queues')
        .stream(primaryKey: ['id'])
        .eq('student_id', studentId);
  }

  /// Mendengarkan antrean masuk untuk konselor (status = 'waiting')
  /// Catatan Arsitektur: Filter stream di Supabase Realtime menggunakan primary/foreign key tetap
  /// (assigned_counselor_id), BUKAN kolom status dinamis (status='waiting').
  /// Ini menjamin event UPDATE saat antrean diterima/dibatalkan tidak hilang dan baris langsung ter-evict.
  Stream<List<CounselingQueueModel>> streamPendingQueuesForCounselor(String counselorId) {
    if (counselorId.isEmpty || counselorId == 'counselor-demo') {
      return _supabase
          .from('counseling_queues')
          .stream(primaryKey: ['id'])
          .map((rows) {
        return rows
            .where((row) =>
                row['status'] == 'waiting' &&
                (row['assigned_counselor_id'] == null ||
                    row['assigned_counselor_id'] == counselorId))
            .map((row) => CounselingQueueModel.fromJson(row))
            .toList();
      });
    }

    return _supabase
        .from('counseling_queues')
        .stream(primaryKey: ['id'])
        .eq('assigned_counselor_id', counselorId)
        .map((rows) {
      return rows
          .where((row) => row['status'] == 'waiting')
          .map((row) => CounselingQueueModel.fromJson(row))
          .toList();
    });
  }

  /// Konselor menerima antrean secara atomik (Anti-Race Condition via RPC Supabase)
  Future<CounselingSessionModel> acceptQueue({
    required String queueId,
    required String counselorId,
    required String studentId,
    required String studentAlias,
    required String studentFaculty,
  }) async {
    try {
      final rpcResult = await _supabase.rpc('accept_counseling_queue', params: {
        'p_queue_id': queueId,
        'p_counselor_id': counselorId,
      });

      if (rpcResult != null && rpcResult is Map<String, dynamic>) {
        return CounselingSessionModel.fromJson(rpcResult);
      }
    } catch (_) {}

    // Fallback aman:
    // 1. Cek sesi aktif yang sudah ada
    final existing = await getActiveSession(studentId: studentId, counselorId: counselorId);
    if (existing != null) {
      await _supabase.from('counseling_queues').update({
        'status': 'accepted',
        'session_id': existing.id,
        'assigned_counselor_id': counselorId,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', queueId);
      return existing;
    }

    // 2. Buat sesi bimbingan aktif
    final sessionData = await _supabase.from('counseling_sessions').insert({
      'queue_id': queueId,
      'student_id': studentId,
      'counselor_id': counselorId,
      'student_alias': studentAlias,
      'student_faculty': studentFaculty,
      'status': 'active',
      'started_at': DateTime.now().toIso8601String(),
    }).select().single();

    // 3. Update antrean bersama session_id
    await _supabase.from('counseling_queues').update({
      'status': 'accepted',
      'session_id': sessionData['id'],
      'assigned_counselor_id': counselorId,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', queueId);

    // 4. Update metrik konselor (active_sessions_count)
    try {
      final profile = await _supabase.from('profiles').select('active_sessions_count').eq('id', counselorId).single();
      final currentActive = (profile['active_sessions_count'] as int? ?? 0) + 1;
      await _supabase.from('profiles').update({'active_sessions_count': currentActive}).eq('id', counselorId);
    } catch (_) {}

    return CounselingSessionModel.fromJson(sessionData);
  }

  /// Mengambil ID sesi aktif berdasarkan ID antrean
  Future<String?> getSessionIdByQueueId(String queueId) async {
    try {
      // Cek kolom session_id di counseling_queues terlebih dahulu (langsung & atomik)
      final queueRow = await _supabase
          .from('counseling_queues')
          .select('session_id')
          .eq('id', queueId)
          .maybeSingle();

      if (queueRow != null && queueRow['session_id'] != null) {
        return queueRow['session_id'] as String;
      }

      final rows = await _supabase
          .from('counseling_sessions')
          .select('id')
          .eq('queue_id', queueId)
          .limit(1);
      if (rows.isNotEmpty) {
        return rows.first['id'] as String;
      }
    } catch (_) {}
    return null;
  }

  /// Konselor menolak antrean
  Future<void> rejectQueue(String queueId) async {
    await _supabase.from('counseling_queues').update({
      'status': 'cancelled',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', queueId);
  }

  /// Mendengarkan sesi konseling aktif untuk konselor
  Stream<List<CounselingSessionModel>> streamActiveSessionsForCounselor(String counselorId) {
    return _supabase
        .from('counseling_sessions')
        .stream(primaryKey: ['id'])
        .eq('counselor_id', counselorId)
        .map((rows) {
      return rows
          .where((row) => row['status'] == 'active')
          .map((row) => CounselingSessionModel.fromJson(row))
          .toList();
    });
  }

  /// Mendengarkan sesi aktif untuk mahasiswa
  Stream<List<CounselingSessionModel>> streamActiveSessionsForStudent(String studentId) {
    return _supabase
        .from('counseling_sessions')
        .stream(primaryKey: ['id'])
        .eq('student_id', studentId)
        .map((rows) {
      return rows
          .where((row) => row['status'] == 'active')
          .map((row) => CounselingSessionModel.fromJson(row))
          .toList();
    });
  }

  /// Mengakhiri sesi konseling secara aman, idempotent, dan bebas race condition
  /// Dapat dipanggil oleh konselor maupun oleh mahasiswa (Student-Initiated Termination)
  Future<bool> endSession(String sessionId, [String counselorId = '']) async {
    // 1. Bersihkan session-scoped cache untuk sesi ini
    clearSessionCache(sessionId);

    if (sessionId.isEmpty) return false;

    // 2. Atomic & Idempotent Update: hanya update jika status saat ini masih 'active'
    try {
      final updatedRows = await _supabase
          .from('counseling_sessions')
          .update({
            'status': 'completed',
            'ended_at': DateTime.now().toIso8601String(),
          })
          .eq('id', sessionId)
          .eq('status', 'active')
          .select('id, counselor_id');

      // Jika tidak ada baris yang ter-update, artinya sesi SUDAH completed sebelumnya!
      // Jangan tambahkan metrik total_helped_count lagi untuk mencegah penggandaan/numpuk.
      if (updatedRows.isEmpty) {
        return false;
      }

      final effectiveCounselorId = counselorId.isNotEmpty
          ? counselorId
          : (updatedRows.first['counselor_id'] as String? ?? '');

      // 3. Sinkronisasikan status antrean terkait menjadi 'completed'
      try {
        await _supabase
            .from('counseling_queues')
            .update({
              'status': 'completed',
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('session_id', sessionId);
      } catch (_) {}

      // 4. Perbarui metrik total_helped_count (+1) dan active_sessions_count (-1)
      if (effectiveCounselorId.isNotEmpty) {
        try {
          final profile = await _supabase
              .from('profiles')
              .select('active_sessions_count, total_helped_count')
              .eq('id', effectiveCounselorId)
              .single();
          final currentActive = ((profile['active_sessions_count'] as int? ?? 1) - 1).clamp(0, 9999);
          final currentHelped = (profile['total_helped_count'] as int? ?? 0) + 1;

          await _supabase.from('profiles').update({
            'active_sessions_count': currentActive,
            'total_helped_count': currentHelped,
          }).eq('id', effectiveCounselorId);
        } catch (_) {}
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  /// Stream pesan percakapan realtime untuk sebuah sesi
  Stream<List<ChatMessageModel>> streamMessages(String sessionId) {
    return _supabase
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('session_id', sessionId)
        .order('created_at', ascending: true)
        .map((rows) => rows.map((r) => ChatMessageModel.fromJson(r)).toList());
  }

  /// Mengirim pesan dalam sesi percakapan
  Future<ChatMessageModel> sendMessage({
    required String sessionId,
    required String senderId,
    required String senderRole, // 'student' or 'counselor'
    required String messageText,
    String? messageId,
  }) async {
    final payload = <String, dynamic>{
      'session_id': sessionId,
      'sender_id': senderId,
      'sender_role': senderRole,
      'message_text': messageText,
      'is_read': false,
    };
    if (messageId != null) {
      payload['id'] = messageId;
    }
    final inserted = await _supabase.from('chat_messages').insert(payload).select().single();
    return ChatMessageModel.fromJson(inserted);
  }

  /// Menandai pesan yang diterima sebagai telah dibaca
  Future<void> markMessagesAsRead({
    required String sessionId,
    required String peerRole,
  }) async {
    try {
      await _supabase
          .from('chat_messages')
          .update({'is_read': true})
          .eq('session_id', sessionId)
          .eq('sender_role', peerRole)
          .eq('is_read', false);
    } catch (_) {}
  }

  /// Menghapus pesan hanya untuk diri sendiri (Delete for Me)
  Future<void> deleteMessagesForMe(List<String> messageIds) async {
    if (messageIds.isEmpty) return;
    try {
      await _supabase.rpc('delete_messages_for_me', params: {
        'p_message_ids': messageIds,
        'p_is_anon': false,
      });
    } catch (_) {
      try {
        final currentUserId = _supabase.auth.currentUser?.id;
        if (currentUserId != null) {
          for (final id in messageIds) {
            final msg = await _supabase
                .from('chat_messages')
                .select('deleted_for_users')
                .eq('id', id)
                .maybeSingle();
            if (msg != null) {
              final rawList = msg['deleted_for_users'] as List<dynamic>?;
              final list = rawList?.map((e) => e.toString()).toList() ?? [];
              if (!list.contains(currentUserId)) {
                list.add(currentUserId);
                await _supabase
                    .from('chat_messages')
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
        'p_is_anon': false,
      });
    } catch (_) {
      try {
        final currentUserId = _supabase.auth.currentUser?.id;
        if (currentUserId != null) {
          await _supabase
              .from('chat_messages')
              .update({
                'is_deleted_for_everyone': true,
                'deleted_at': DateTime.now().toIso8601String(),
              })
              .inFilter('id', messageIds)
              .eq('sender_id', currentUserId);
        }
      } catch (_) {}
    }
  }

  /// Mengambil profil konselor berdasarkan counselorId
  Future<Map<String, dynamic>?> fetchCounselorProfile(String counselorId) async {
    try {
      final res = await _supabase
          .from('profiles')
          .select('id, full_name, nickname, avatar_url, faculty, is_online')
          .eq('id', counselorId)
          .maybeSingle();
      return res;
    } catch (_) {
      return null;
    }
  }

  RealtimeChannel? _presenceChannel;

  /// Konselor bergabung ke presence channel untuk menandai online secara realtime
  void joinCounselorPresence(String counselorId) {
    if (_presenceChannel != null) {
      _presenceChannel?.untrack();
      _supabase.removeChannel(_presenceChannel!);
    }
    _presenceChannel = _supabase.channel('online_counselors');
    _presenceChannel?.subscribe((status, [error]) async {
      if (status == RealtimeSubscribeStatus.subscribed) {
        await _presenceChannel?.track({
          'counselor_id': counselorId,
          'online_at': DateTime.now().toIso8601String(),
        });
      }
    });
  }

  /// Konselor keluar dari presence channel
  Future<void> leaveCounselorPresence() async {
    if (_presenceChannel != null) {
      try {
        await _presenceChannel?.untrack();
        await _supabase.removeChannel(_presenceChannel!);
      } catch (_) {}
      _presenceChannel = null;
    }
  }

  /// Mendengarkan update presence konselor online secara realtime
  RealtimeChannel listenOnlineCounselorsPresence(void Function(Set<String> onlineIds) onSync) {
    final channel = _supabase.channel('online_counselors');
    channel.onPresenceSync((_) {
      final state = channel.presenceState();
      final ids = <String>{};
      for (final singleState in state) {
        for (final p in singleState.presences) {
          final id = p.payload['counselor_id'] as String?;
          if (id != null && id.isNotEmpty) {
            ids.add(id);
          }
        }
      }
      onSync(ids);
    }).subscribe();
    return channel;
  }

  /// Stream perubahan status sesi konseling tunggal
  Stream<CounselingSessionModel?> streamSession(String sessionId) {
    return _supabase
        .from('counseling_sessions')
        .stream(primaryKey: ['id'])
        .eq('id', sessionId)
        .map((rows) {
      if (rows.isEmpty) return null;
      return CounselingSessionModel.fromJson(rows.first);
    });
  }

  /// Mahasiswa mengirimkan rating dan ulasan untuk sesi konseling yang telah selesai
  Future<void> submitSessionRating({
    required String sessionId,
    required int rating,
    String? reviewNote,
    List<String>? reviewTags,
  }) async {
    await _supabase.from('counseling_sessions').update({
      'rating': rating,
      'review_note': reviewNote,
      'review_tags': reviewTags,
    }).eq('id', sessionId);
  }

  /// Inisialisasi Realtime Broadcast Channel untuk pertukaran status pengetikan
  RealtimeChannel createChatStatusChannel(String sessionId) {
    return _supabase.channel('chat_status_$sessionId');
  }

  /// Memancarkan status pengetikan pengguna ('typing', 'choosing_emoji', 'idle')
  Future<void> broadcastUserStatus({
    required RealtimeChannel channel,
    required String senderId,
    required String status,
  }) async {
    try {
      await channel.sendBroadcastMessage(
        event: 'user_status',
        payload: {
          'sender_id': senderId,
          'status': status,
        },
      );
    } catch (_) {}
  }
}

final counselingServiceProvider = Provider<CounselingService>((ref) {
  return CounselingService();
});

final activeStudentSessionProvider = StreamProvider.autoDispose<List<CounselingSessionModel>>((ref) {
  final userId = SupabaseService.currentUserId;
  if (userId == null) return const Stream.empty();
  return ref.watch(counselingServiceProvider).streamActiveSessionsForStudent(userId);
});
