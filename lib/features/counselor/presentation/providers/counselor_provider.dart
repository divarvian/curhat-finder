import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/academic_helper.dart';
import '../../../chat/data/counseling_service.dart';
import '../../../chat/domain/counseling_models.dart';
import '../../domain/counselor_model.dart';

class CounselorState {
  final CounselorProfile profile;
  final List<CounselorChatSession> sessions;
  final List<CounselingQueueModel> queues;
  final List<CounselingSessionModel> activeSessions;
  final Map<String, List<CounselorChatMessage>> messages;
  final int currentNavIndex;
  final bool isLoading;

  const CounselorState({
    this.profile = CounselorProfile.empty,
    this.sessions = const [],
    this.queues = const [],
    this.activeSessions = const [],
    this.messages = const {},
    this.currentNavIndex = 0,
    this.isLoading = true,
  });

  CounselorState copyWith({
    CounselorProfile? profile,
    List<CounselorChatSession>? sessions,
    List<CounselingQueueModel>? queues,
    List<CounselingSessionModel>? activeSessions,
    Map<String, List<CounselorChatMessage>>? messages,
    int? currentNavIndex,
    bool? isLoading,
  }) {
    return CounselorState(
      profile: profile ?? this.profile,
      sessions: sessions ?? this.sessions,
      queues: queues ?? this.queues,
      activeSessions: activeSessions ?? this.activeSessions,
      messages: messages ?? this.messages,
      currentNavIndex: currentNavIndex ?? this.currentNavIndex,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CounselorNotifier extends Notifier<CounselorState> {
  StreamSubscription? _queueSub;
  StreamSubscription? _sessionSub;
  late final CounselingService _counselingService;

  @override
  CounselorState build() {
    _counselingService = ref.watch(counselingServiceProvider);

    ref.onDispose(() {
      _queueSub?.cancel();
      _sessionSub?.cancel();
      _counselingService.leaveCounselorPresence();
    });

    // Jalankan sinkronisasi Supabase setelah inisialisasi state awal
    Future.microtask(() => initializeSupabaseSync());

    return const CounselorState(
      profile: CounselorProfile.empty,
      sessions: [],
      messages: {},
      currentNavIndex: 0,
      isLoading: true,
    );
  }

  Future<void> initializeSupabaseSync() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) {
      state = state.copyWith(isLoading: false);
      return;
    }

    try {
      // 1. Muat data awal (Profil, Sesi Aktif, & Antrean Masuk) secara paralel (SNAPSHOT AWAL)
      final Future<dynamic> profileFuture = SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      final Future<dynamic> sessionsFuture = SupabaseService.client
          .from('counseling_sessions')
          .select()
          .eq('counselor_id', userId)
          .eq('status', 'active');

      final Future<dynamic> queuesFuture = SupabaseService.client
          .from('counseling_queues')
          .select()
          .eq('assigned_counselor_id', userId)
          .eq('status', 'waiting')
          .order('created_at', ascending: false);

      final results = await Future.wait<dynamic>([profileFuture, sessionsFuture, queuesFuture]);
      final data = results[0] as Map<String, dynamic>?;
      final rawSessions = results[1] as List<dynamic>? ?? [];
      final rawQueues = results[2] as List<dynamic>? ?? [];

      CounselorProfile updatedProfile = state.profile;

      if (data != null) {
        final rawFaculty = (data['faculty'] as String?) ?? state.profile.faculty;
        final rawProdi = (data['study_program'] as String?) ?? state.profile.studyProgram;
        final resolvedFaculty = AcademicHelper.resolveFaculty(rawFaculty);
        final resolvedProdi = AcademicHelper.resolveProdi(rawProdi);

        final rawFullName = data['full_name'] as String?;
        final rawNickname = data['nickname'] as String?;
        final metaName = SupabaseService.currentUser?.userMetadata?['full_name'] as String?;
        final counselorName = (rawFullName != null && rawFullName.trim().isNotEmpty)
            ? rawFullName.trim()
            : ((rawNickname != null && rawNickname.trim().isNotEmpty)
                ? rawNickname.trim()
                : ((metaName != null && metaName.trim().isNotEmpty)
                    ? metaName.trim()
                    : state.profile.name));

        final topicsList = (data['topics'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? state.profile.topics;
        updatedProfile = state.profile.copyWith(
          name: counselorName,
          email: SupabaseService.currentUser?.email ?? state.profile.email,
          faculty: resolvedFaculty,
          studyProgram: resolvedProdi,
          batchYear: data['batch_year'] ?? state.profile.batchYear,
          gender: data['gender'] ?? state.profile.gender,
          isOnline: data['is_online'] as bool? ?? state.profile.isOnline,
          activeSessions: rawSessions.length,
          totalHelped: data['total_helped_count'] as int? ?? state.profile.totalHelped,
          responseTime: data['avg_response_time'] as String? ?? state.profile.responseTime,
          topics: topicsList,
          avatarUrl: data['avatar_url'] as String?,
          localAvatarPath: null,
        );

        if (updatedProfile.isOnline) {
          _counselingService.joinCounselorPresence(userId);
        }

        // Auto-migrasi ke Supabase jika sebelumnya tersimpan kode numerik
        if (resolvedFaculty != rawFaculty || resolvedProdi != rawProdi) {
          SupabaseService.client.from('profiles').update({
            'faculty': resolvedFaculty,
            'study_program': resolvedProdi,
          }).eq('id', userId);
        }
      }

      // Parsing sesi aktif awal
      final initialSessions = rawSessions
          .map((s) => CounselingSessionModel.fromJson(s as Map<String, dynamic>))
          .toList();
      final initialMappedSessions = initialSessions.map((s) {
        return CounselorChatSession(
          id: s.id,
          studentName: s.studentAlias,
          studentGender: 'Mahasiswa',
          studentFaculty: s.studentFaculty,
          statusDescription: 'Sesi Bimbingan Aktif Berjalan..',
          isOnline: true,
          lastMessage: 'Sesi aktif',
          lastMessageTime: 'Sekarang',
        );
      }).toList();

      // Parsing antrean awal dengan deduplikasi
      final initialQueuesList = rawQueues
          .map((q) => CounselingQueueModel.fromJson(q as Map<String, dynamic>))
          .toList();
      final Map<String, CounselingQueueModel> latestByStudent = {};
      for (final q in initialQueuesList) {
        if (!latestByStudent.containsKey(q.studentId) ||
            q.createdAt.isAfter(latestByStudent[q.studentId]!.createdAt)) {
          latestByStudent[q.studentId] = q;
        }
      }

      // 2. Set state awal secara atomik dengan data riil (ZERO-FLICKER & ZERO-BLINK)
      state = state.copyWith(
        profile: updatedProfile.copyWith(activeSessions: initialSessions.length),
        activeSessions: initialSessions,
        sessions: initialMappedSessions,
        queues: latestByStudent.values.toList(),
        isLoading: false,
      );

      // 3. Pasang Stream Realtime untuk pembaruan kontinu
      _queueSub?.cancel();
      _queueSub = _counselingService.streamPendingQueuesForCounselor(userId).listen((queues) {
        final Map<String, CounselingQueueModel> streamLatest = {};
        for (final q in queues) {
          if (!streamLatest.containsKey(q.studentId) ||
              q.createdAt.isAfter(streamLatest[q.studentId]!.createdAt)) {
            streamLatest[q.studentId] = q;
          }
        }
        state = state.copyWith(queues: streamLatest.values.toList());
      });

      _sessionSub?.cancel();
      _sessionSub = _counselingService.streamActiveSessionsForCounselor(userId).listen((sessions) {
        final mapped = sessions.map((s) {
          return CounselorChatSession(
            id: s.id,
            studentName: s.studentAlias,
            studentGender: 'Mahasiswa',
            studentFaculty: s.studentFaculty,
            statusDescription: 'Sesi Bimbingan Aktif Berjalan..',
            isOnline: true,
            lastMessage: 'Sesi aktif',
            lastMessageTime: 'Sekarang',
          );
        }).toList();

        state = state.copyWith(
          activeSessions: sessions,
          sessions: mapped,
          profile: state.profile.copyWith(activeSessions: sessions.length),
        );
      });
    } catch (e, st) {
      debugPrint('Counselor initializeSupabaseSync error: $e\n$st');
      state = state.copyWith(isLoading: false);
    }
  }

  void reset() {
    _queueSub?.cancel();
    _sessionSub?.cancel();
    _counselingService.leaveCounselorPresence();
    state = const CounselorState(
      profile: CounselorProfile.empty,
      sessions: [],
      messages: {},
      currentNavIndex: 0,
      isLoading: false,
    );
  }

  void toggleOnlineStatus() async {
    final newStatus = !state.profile.isOnline;
    final updatedProfile = state.profile.copyWith(isOnline: newStatus);
    state = state.copyWith(profile: updatedProfile);

    final userId = SupabaseService.currentUserId;
    if (userId != null) {
      await _counselingService.updateOnlineStatus(userId, newStatus);
      if (newStatus) {
        _counselingService.joinCounselorPresence(userId);
      } else {
        await _counselingService.leaveCounselorPresence();
      }
    }
  }

  void setNavIndex(int index) {
    state = state.copyWith(currentNavIndex: index);
  }

  final Set<String> _processingQueueIds = {};

  bool isQueueProcessing(String queueId) => _processingQueueIds.contains(queueId);

  Future<CounselingSessionModel?> acceptQueue(CounselingQueueModel queue) async {
    if (_processingQueueIds.contains(queue.id)) return null;
    _processingQueueIds.add(queue.id);

    final counselorId = SupabaseService.currentUserId ?? 'counselor-demo';
    try {
      final newSession = await _counselingService.acceptQueue(
        queueId: queue.id,
        counselorId: counselorId,
        studentId: queue.studentId,
        studentAlias: queue.studentAlias,
        studentFaculty: queue.studentFaculty,
      );

      // Hapus queue dari daftar lokal
      final updatedQueues = state.queues.where((q) => q.id != queue.id).toList();
      state = state.copyWith(
        queues: updatedQueues,
        activeSessions: [...state.activeSessions, newSession],
        profile: state.profile.copyWith(activeSessions: state.profile.activeSessions + 1),
      );

      return newSession;
    } catch (_) {
      // Fallback jika database belum ada
      final fallbackSession = CounselingSessionModel(
        id: queue.id,
        studentId: queue.studentId,
        counselorId: counselorId,
        studentAlias: queue.studentAlias,
        studentFaculty: queue.studentFaculty,
        status: 'active',
        startedAt: DateTime.now(),
      );
      final updatedQueues = state.queues.where((q) => q.id != queue.id).toList();
      state = state.copyWith(
        queues: updatedQueues,
        activeSessions: [...state.activeSessions, fallbackSession],
      );
      return fallbackSession;
    } finally {
      _processingQueueIds.remove(queue.id);
    }
  }

  Future<void> rejectQueue(String queueId) async {
    if (_processingQueueIds.contains(queueId)) return;
    _processingQueueIds.add(queueId);

    try {
      await _counselingService.rejectQueue(queueId);
    } catch (_) {} finally {
      _processingQueueIds.remove(queueId);
    }
    final updatedQueues = state.queues.where((q) => q.id != queueId).toList();
    state = state.copyWith(queues: updatedQueues);
  }

  Future<bool> endSession(String sessionId) async {
    final counselorId = SupabaseService.currentUserId ?? 'counselor-demo';
    bool didComplete = false;
    try {
      didComplete = await _counselingService.endSession(sessionId, counselorId);
    } catch (_) {}

    final updatedActive = state.activeSessions.where((s) => s.id != sessionId).toList();
    final updatedSessions = state.sessions.where((s) => s.id != sessionId).toList();
    state = state.copyWith(
      activeSessions: updatedActive,
      sessions: updatedSessions,
      profile: state.profile.copyWith(
        activeSessions: (state.profile.activeSessions - 1).clamp(0, 999),
        totalHelped: didComplete ? state.profile.totalHelped + 1 : state.profile.totalHelped,
      ),
    );
    return didComplete;
  }

  void addTopic(String topic) async {
    final trimmed = topic.trim();
    if (trimmed.isEmpty || state.profile.topics.contains(trimmed)) return;

    final previousTopics = state.profile.topics;
    final updatedTopics = [...state.profile.topics, trimmed];
    state = state.copyWith(
      profile: state.profile.copyWith(topics: updatedTopics),
    );

    final userId = SupabaseService.currentUserId;
    if (userId != null) {
      try {
        await SupabaseService.client
            .from('profiles')
            .update({'topics': updatedTopics})
            .eq('id', userId);
      } catch (_) {
        state = state.copyWith(
          profile: state.profile.copyWith(topics: previousTopics),
        );
      }
    }
  }

  void updateTopics(List<String> newTopics) async {
    final sanitized = newTopics.map((t) => t.trim()).where((t) => t.isNotEmpty).toSet().toList();
    if (sanitized.isEmpty) return;

    final previousTopics = state.profile.topics;
    state = state.copyWith(
      profile: state.profile.copyWith(topics: sanitized),
    );

    final userId = SupabaseService.currentUserId;
    if (userId != null) {
      try {
        await SupabaseService.client
            .from('profiles')
            .update({'topics': sanitized})
            .eq('id', userId);
      } catch (_) {
        state = state.copyWith(
          profile: state.profile.copyWith(topics: previousTopics),
        );
      }
    }
  }

  void removeTopic(String topic) async {
    final previousTopics = state.profile.topics;
    final updatedTopics = state.profile.topics.where((t) => t != topic).toList();
    state = state.copyWith(
      profile: state.profile.copyWith(topics: updatedTopics),
    );

    final userId = SupabaseService.currentUserId;
    if (userId != null) {
      try {
        await SupabaseService.client
            .from('profiles')
            .update({'topics': updatedTopics})
            .eq('id', userId);
      } catch (_) {
        state = state.copyWith(
          profile: state.profile.copyWith(topics: previousTopics),
        );
      }
    }
  }

  void sendMessage(String sessionId, String text) async {
    if (text.trim().isEmpty) return;

    final userId = SupabaseService.currentUserId;
    if (userId != null) {
      try {
        await _counselingService.sendMessage(
          sessionId: sessionId,
          senderId: userId,
          senderRole: 'counselor',
          messageText: text.trim(),
        );
      } catch (_) {}
    }

    final sessionMessages = List<CounselorChatMessage>.from(
      state.messages[sessionId] ?? [],
    );
    sessionMessages.removeWhere((m) => m.isTyping);
    sessionMessages.add(
      CounselorChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text.trim(),
        isMe: true,
        timestamp: 'Sekarang',
      ),
    );

    final updatedMessages = Map<String, List<CounselorChatMessage>>.from(state.messages);
    updatedMessages[sessionId] = sessionMessages;
    state = state.copyWith(messages: updatedMessages);
  }

  Future<void> updateProfile(CounselorProfile newProfile) async {
    state = state.copyWith(profile: newProfile);
    final userId = SupabaseService.currentUserId;
    if (userId != null) {
      try {
        await SupabaseService.client.from('profiles').update({
          'nickname': newProfile.name,
          'faculty': AcademicHelper.resolveFaculty(newProfile.faculty),
          'study_program': AcademicHelper.resolveProdi(newProfile.studyProgram),
          'batch_year': newProfile.batchYear,
          'gender': newProfile.gender,
          'topics': newProfile.topics,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', userId);
      } catch (_) {}
    }
  }

  Future<bool> uploadAvatar(XFile file) async {
    final userId = SupabaseService.currentUserId;
    final previousProfile = state.profile;
    final oldAvatarUrl = state.profile.avatarUrl;

    // 1. Optimistic Update: langsung pakai path file lokal di HP agar instan
    state = state.copyWith(
      profile: state.profile.copyWith(localAvatarPath: file.path),
    );

    if (userId != null) {
      try {
        final storage = StorageService();
        final publicUrl = await storage.uploadAvatar(file: file, userId: userId);
        if (publicUrl != null) {
          // 2. Bersihkan cache in-memory jika ada avatar lama
          if (oldAvatarUrl != null && oldAvatarUrl.isNotEmpty) {
            PaintingBinding.instance.imageCache.evict(NetworkImage(oldAvatarUrl));
          }

          // 3. Simpan avatarUrl baru untuk sinkronisasi server, namun tetap pertahankan
          // localAvatarPath agar sesi aktif ini tidak men-download ulang via internet (ZERO-FLICKER)
          state = state.copyWith(
            profile: state.profile.copyWith(
              avatarUrl: publicUrl,
              localAvatarPath: file.path,
            ),
          );
          return true;
        } else {
          state = state.copyWith(profile: previousProfile);
          return false;
        }
      } catch (e) {
        debugPrint('CounselorNotifier.uploadAvatar error: $e');
        state = state.copyWith(profile: previousProfile);
        return false;
      }
    }
    return true;
  }
}

final counselorProvider = NotifierProvider<CounselorNotifier, CounselorState>(() {
  return CounselorNotifier();
});
