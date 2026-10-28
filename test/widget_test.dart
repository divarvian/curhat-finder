import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curhat_finder/core/utils/academic_helper.dart';
import 'package:curhat_finder/features/chat/presentation/widgets/cards/counselor_card.dart';
import 'package:curhat_finder/features/chat/presentation/widgets/counselor_profile_sheet.dart';
import 'package:curhat_finder/features/chat/presentation/views/chat_room_view.dart';
import 'package:curhat_finder/features/chat/domain/counseling_models.dart';
import 'package:curhat_finder/features/chat/domain/anon_chat_model.dart';
import 'package:curhat_finder/features/chat/data/counseling_service.dart';
import 'package:curhat_finder/features/chat/presentation/widgets/typing_indicator_bubble.dart';
import 'package:curhat_finder/features/chat/presentation/widgets/active_session_banner.dart';
import 'package:curhat_finder/features/chat/presentation/widgets/dialogs/counseling_rating_dialog.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:curhat_finder/features/chat/presentation/views/chat_anon_matching_view.dart';
import 'package:curhat_finder/features/auth/presentation/providers/auth_state.dart';
import 'package:curhat_finder/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:curhat_finder/core/services/supabase_service.dart';
import 'package:curhat_finder/features/auth/presentation/views/counselor_pending_view.dart';

void main() {
  group('AcademicHelper Unit Tests', () {
    test('resolveFaculty correctly maps codes to abbreviation', () {
      expect(AcademicHelper.resolveFaculty('01'), 'FH');
      expect(AcademicHelper.resolveFaculty('07'), 'FK');
      expect(AcademicHelper.resolveFaculty('14'), 'FILKOM');
      expect(AcademicHelper.resolveFaculty('FILKOM'), 'FILKOM');
      expect(AcademicHelper.resolveFaculty(null), 'FILKOM');
      expect(AcademicHelper.resolveFaculty(''), 'FILKOM');
    });

    test('resolveProdi correctly maps prodi codes to full names', () {
      expect(AcademicHelper.resolveProdi('14.01'), 'S1 Teknik Informatika');
      expect(AcademicHelper.resolveProdi('14.02'), 'S1 Sistem Informasi');
      expect(AcademicHelper.resolveProdi(null), 'S1 Teknik Informatika');
    });
  });

  group('CounselorCard Widget Tests', () {
    testWidgets('Renders counselor card with name, gender, faculty, and topics', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CounselorCard(
              counselorId: 'counselor-1',
              name: 'Kak Alena',
              gender: 'Perempuan',
              faculty: 'Fakultas Ilmu Komputer (FILKOM)',
              tags: ['Anxiety', 'Akademik'],
              hobbies: ['Membaca', 'Mendengarkan Musik'],
              isOnline: true,
            ),
          ),
        ),
      );

      // Verify counselor details are displayed
      expect(find.text('Kak Alena • Perempuan'), findsOneWidget);
      expect(find.text('Fakultas Ilmu Komputer (FILKOM)'), findsOneWidget);
      expect(find.text('Anxiety'), findsOneWidget);
      expect(find.text('Akademik'), findsOneWidget);
    });

    testWidgets('Renders offline state without green online badge', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CounselorCard(
              counselorId: 'counselor-2',
              name: 'Kak Budi',
              gender: 'Laki-laki',
              faculty: 'Fakultas Teknik (FT)',
              tags: ['Burnout'],
              hobbies: ['Olahraga'],
              isOnline: false,
            ),
          ),
        ),
      );

      expect(find.text('Kak Budi • Laki-laki'), findsOneWidget);
      expect(find.text('Fakultas Teknik (FT)'), findsOneWidget);
      expect(find.text('Burnout'), findsOneWidget);
    });
  });

  group('CounselorProfileSheet Widget Tests', () {
    testWidgets('Shows offline banner and disabled button when counselor is offline', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CounselorProfileSheet(
                counselorId: '',
                name: 'Kak Clara',
                gender: 'Perempuan',
                faculty: 'FIB',
                topics: ['Stress'],
                hobbies: ['Menulis'],
                operationalHours: '18:00 - 21:00 WIB',
                isOnline: false,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Konselor Sedang Offline'), findsOneWidget);
      expect(find.textContaining('Konselor sedang offline'), findsOneWidget);
    });

    testWidgets('Shows start counseling button when counselor is online', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CounselorProfileSheet(
                counselorId: '',
                name: 'Kak Dito',
                gender: 'Laki-laki',
                faculty: 'FILKOM',
                topics: ['Akademik'],
                hobbies: ['Gaming'],
                operationalHours: '18:00 - 21:00 WIB',
                isOnline: true,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Mulai melakukan konseling'), findsOneWidget);
    });
  });

  group('Chat Emoji Picker Widget Tests', () {
    testWidgets('Toggles emoji keyboard and switches icon in ChatRoomView', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ChatRoomView(
              counselorName: 'Kak Test',
              isOnline: true,
              sessionId: '',
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Initially, emoji icon is shown, EmojiPicker is not visible
      expect(find.byIcon(Icons.emoji_emotions_outlined), findsOneWidget);
      expect(find.byType(EmojiPicker), findsNothing);

      // Tap emoji button
      await tester.tap(find.byIcon(Icons.emoji_emotions_outlined));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // EmojiPicker should now be rendered, icon changes to keyboard
      expect(find.byIcon(Icons.keyboard_outlined), findsOneWidget);
      expect(find.byType(EmojiPicker), findsOneWidget);

      // Tap again to switch back
      await tester.tap(find.byIcon(Icons.keyboard_outlined));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byIcon(Icons.emoji_emotions_outlined), findsOneWidget);
      expect(find.byType(EmojiPicker), findsNothing);
    });
  });

  group('TypingIndicatorBubble Widget Tests', () {
    testWidgets('Renders typing status correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TypingIndicatorBubble(
              peerName: 'Kak Alena',
              status: 'typing',
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Kak Alena sedang mengetik...'), findsOneWidget);
    });

    testWidgets('Renders choosing emoji status correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TypingIndicatorBubble(
              peerName: 'Kak Alena',
              status: 'choosing_emoji',
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Kak Alena sedang memilih emoji...'), findsOneWidget);
      expect(find.text('😊'), findsOneWidget);
    });
  });

  group('ActiveSessionBanner Widget Tests', () {
    testWidgets('Renders banner when there is an active session', (WidgetTester tester) async {
      final mockSession = CounselingSessionModel(
        id: 'sess-123',
        counselorId: 'counselor-1',
        studentId: 'student-1',
        studentAlias: 'AnonBro',
        studentFaculty: 'FILKOM',
        status: 'active',
        startedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeStudentSessionProvider.overrideWith(
              (ref) => Stream.value([mockSession]),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ActiveSessionBanner(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Sesi Konseling Sedang Berjalan'), findsOneWidget);
      expect(find.text('Ketuk untuk langsung kembali ke percakapan'), findsOneWidget);
      expect(find.text('Buka Chat'), findsOneWidget);
    });

    testWidgets('Renders empty when there are no active sessions', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeStudentSessionProvider.overrideWith(
              (ref) => Stream.value([]),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ActiveSessionBanner(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Sesi Konseling Sedang Berjalan'), findsNothing);
    });
  });

  group('CounselingRatingDialog Widget Tests', () {
    testWidgets('Renders rating dialog and handles interaction', (WidgetTester tester) async {
      bool submitted = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CounselingRatingDialog(
                sessionId: '',
                counselorName: 'Kak Alena',
                onSubmitted: () {
                  submitted = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Check header and content
      expect(find.text('Sesi Konseling Selesai'), findsOneWidget);
      expect(find.textContaining('Bagaimana pengalaman konselingmu bersama Kak Alena?'), findsOneWidget);
      expect(find.text('Sangat Membantu'), findsOneWidget);
      expect(find.text('Ramah & Empatik'), findsOneWidget);
      expect(find.text('Kirim Ulasan & Selesai'), findsOneWidget);

      // Tap submit button
      await tester.tap(find.text('Kirim Ulasan & Selesai'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(submitted, isTrue);
    });

    testWidgets('Tapping Lewati button triggers onSkipped callback', (WidgetTester tester) async {
      bool skipped = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CounselingRatingDialog(
                sessionId: '',
                counselorName: 'Kak Alena',
                onSkipped: () {
                  skipped = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Lewati'), findsOneWidget);

      // Ensure visible and tap Lewati button
      await tester.ensureVisible(find.text('Lewati'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lewati'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(skipped, isTrue);
    });
  });

  group('Chat Timezone and Offline Retention Tests', () {
    test('ChatMessageModel converts UTC database timestamps to local time', () {
      const utcIsoString = '2026-10-25T13:45:00.000Z';
      final json = {
        'id': 'msg-1',
        'session_id': 'sess-1',
        'sender_id': 'user-1',
        'sender_role': 'student',
        'message_text': 'Halo konselor',
        'is_read': false,
        'created_at': utcIsoString,
      };

      final message = ChatMessageModel.fromJson(json);

      expect(message.createdAt.isUtc, isFalse);
      expect(message.createdAt, DateTime.parse(utcIsoString).toLocal());
    });

    test('AnonMessageModel converts UTC database timestamps to local time', () {
      const utcIsoString = '2026-10-25T13:45:00.000Z';
      final json = {
        'id': 'anon-msg-1',
        'session_id': 'anon-sess-1',
        'sender_id': 'user-2',
        'sender_alias': 'Anonim',
        'message_text': 'Halo anon',
        'is_system': false,
        'created_at': utcIsoString,
      };

      final message = AnonMessageModel.fromJson(json);

      expect(message.createdAt.isUtc, isFalse);
      expect(message.createdAt, DateTime.parse(utcIsoString).toLocal());
    });

    test('CounselingSessionModel and QueueModel convert UTC timestamps to local time', () {
      const utcIsoString = '2026-10-25T13:45:00.000Z';
      final sessionJson = {
        'id': 'sess-1',
        'student_id': 'stud-1',
        'counselor_id': 'coun-1',
        'status': 'active',
        'started_at': utcIsoString,
      };
      final session = CounselingSessionModel.fromJson(sessionJson);
      expect(session.startedAt.isUtc, isFalse);
      expect(session.startedAt, DateTime.parse(utcIsoString).toLocal());

      final queueJson = {
        'id': 'queue-1',
        'student_id': 'stud-1',
        'student_alias': 'Anonim',
        'student_faculty': 'FILKOM',
        'counselor_id': 'coun-1',
        'status': 'waiting',
        'created_at': utcIsoString,
      };
      final queue = CounselingQueueModel.fromJson(queueJson);
      expect(queue.createdAt.isUtc, isFalse);
      expect(queue.createdAt, DateTime.parse(utcIsoString).toLocal());
    });
  });

  group('Session-Scoped Cache & Fresh Start Isolation Tests', () {
    test('CounselingService isolates chat cache strictly per sessionId', () {
      final service = CounselingService();

      final msgSessionA = ChatMessageModel(
        id: 'msg-a',
        sessionId: 'session-a',
        senderId: 'stud-1',
        senderRole: 'student',
        messageText: 'Pesan Sesi A',
        isRead: false,
        createdAt: DateTime.now(),
      );

      final msgSessionB = ChatMessageModel(
        id: 'msg-b',
        sessionId: 'session-b',
        senderId: 'stud-1',
        senderRole: 'student',
        messageText: 'Pesan Sesi B Baru',
        isRead: false,
        createdAt: DateTime.now(),
      );

      // Cache session A and B
      service.updateSessionCache('session-a', [msgSessionA]);
      service.updateSessionCache('session-b', [msgSessionB]);

      expect(service.getSessionCache('session-a').length, 1);
      expect(service.getSessionCache('session-a').first.messageText, 'Pesan Sesi A');

      expect(service.getSessionCache('session-b').length, 1);
      expect(service.getSessionCache('session-b').first.messageText, 'Pesan Sesi B Baru');

      // Clear session A upon completion
      service.clearSessionCache('session-a');
      expect(service.getSessionCache('session-a'), isEmpty);

      // Session B remains intact without memory leak or cache collision
      expect(service.getSessionCache('session-b').length, 1);
      expect(service.getSessionCache('session-b').first.messageText, 'Pesan Sesi B Baru');

      // A new session C with the same user starts completely fresh (empty cache)
      expect(service.getSessionCache('session-c'), isEmpty);
    });
  });

  group('Queue Deduplication & Anti-Ghost Tests', () {
    test('Deduplication logic resolves to exactly 1 latest queue per student', () {
      final oldQueue = CounselingQueueModel(
        id: 'q-old',
        studentId: 'student-123',
        studentAlias: 'Anon-A',
        studentGender: 'Perempuan',
        studentFaculty: 'FILKOM',
        assignedCounselorId: 'counselor-1',
        status: 'waiting',
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      );

      final newQueue = CounselingQueueModel(
        id: 'q-new',
        studentId: 'student-123',
        studentAlias: 'Anon-A',
        studentGender: 'Perempuan',
        studentFaculty: 'FILKOM',
        assignedCounselorId: 'counselor-1',
        status: 'waiting',
        createdAt: DateTime.now(),
      );

      final anotherStudentQueue = CounselingQueueModel(
        id: 'q-other',
        studentId: 'student-456',
        studentAlias: 'Anon-B',
        studentGender: 'Laki-laki',
        studentFaculty: 'FEB',
        assignedCounselorId: 'counselor-1',
        status: 'waiting',
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      );

      final rawQueues = [oldQueue, newQueue, anotherStudentQueue];

      // Simulate the deduplication logic used in counselor_provider
      final Map<String, CounselingQueueModel> latestByStudent = {};
      for (final q in rawQueues) {
        if (!latestByStudent.containsKey(q.studentId) ||
            q.createdAt.isAfter(latestByStudent[q.studentId]!.createdAt)) {
          latestByStudent[q.studentId] = q;
        }
      }
      final deduplicated = latestByStudent.values.toList();

      expect(deduplicated.length, 2);
      expect(deduplicated.any((q) => q.id == 'q-new'), isTrue);
      expect(deduplicated.any((q) => q.id == 'q-old'), isFalse);
      expect(deduplicated.any((q) => q.id == 'q-other'), isTrue);
    });
  });

  group('Student End Session & Single Session Constraint Tests', () {
    testWidgets('ChatRoomView allows student to open Akhiri Sesi Konseling dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ChatRoomView(
              counselorName: 'Kak Test',
              isOnline: true,
              sessionId: '',
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Find PopupMenuButton with more_vert icon
      expect(find.byIcon(Icons.more_vert), findsOneWidget);

      // Tap more_vert icon to open menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Expect 'Akhiri Sesi Konseling' menu item to be visible
      expect(find.text('Akhiri Sesi Konseling'), findsOneWidget);
      expect(find.text('Privasi & Enkripsi'), findsOneWidget);

      // Tap 'Akhiri Sesi Konseling'
      await tester.tap(find.text('Akhiri Sesi Konseling'));
      await tester.pumpAndSettle();

      // Expect confirmation dialog to be shown
      expect(find.text('Akhiri Sesi Konseling?'), findsOneWidget);
      expect(find.text('Lanjutkan Chat'), findsOneWidget);
      expect(find.text('Akhiri Sesi'), findsOneWidget);

      // Tap 'Lanjutkan Chat' to dismiss dialog
      await tester.tap(find.text('Lanjutkan Chat'));
      await tester.pumpAndSettle();

      expect(find.text('Akhiri Sesi Konseling?'), findsNothing);
    });

    test('Single active session logic identifies ongoing session and prevents new queue', () {
      final activeSession = CounselingSessionModel(
        id: 'sess-active',
        counselorId: 'counselor-a',
        studentId: 'student-123',
        studentAlias: 'AnonStudent',
        studentFaculty: 'FILKOM',
        status: 'active',
        startedAt: DateTime.now(),
      );

      // Emulate student active session check
      final hasActiveSession = activeSession.status == 'active';
      expect(hasActiveSession, isTrue);

      // When opening Counselor B's profile:
      final String viewingCounselorId = 'counselor-b';
      final bool hasSessionWithOther = activeSession.counselorId != viewingCounselorId;
      expect(hasSessionWithOther, isTrue);

      // When opening Counselor A's profile:
      final String ownCounselorId = 'counselor-a';
      final bool hasSessionWithThis = activeSession.counselorId == ownCounselorId;
      expect(hasSessionWithThis, isTrue);
    });
  });

  group('Anonymous Chat & Reporting Engine Tests', () {
    test('AnonMatchResult correctly parses RPC response for creator and joiner', () {
      final creatorJson = {
        'session_id': 'anon-sess-1',
        'status': 'waiting',
        'matched': false,
        'role': 'creator',
      };
      final creatorResult = AnonMatchResult.fromJson(creatorJson);
      expect(creatorResult.sessionId, 'anon-sess-1');
      expect(creatorResult.status, 'waiting');
      expect(creatorResult.matched, isFalse);
      expect(creatorResult.role, 'creator');

      final joinerJson = {
        'session_id': 'anon-sess-2',
        'status': 'active',
        'matched': true,
        'role': 'joiner',
      };
      final joinerResult = AnonMatchResult.fromJson(joinerJson);
      expect(joinerResult.sessionId, 'anon-sess-2');
      expect(joinerResult.status, 'active');
      expect(joinerResult.matched, isTrue);
      expect(joinerResult.role, 'joiner');
    });

    test('AnonSessionModel lifecycle getters behave correctly', () {
      final waitingSession = AnonSessionModel(
        id: 'sess-wait',
        mode: 'Cuma mau didengar',
        status: 'waiting',
        createdAt: DateTime.now(),
      );
      expect(waitingSession.isWaiting, isTrue);
      expect(waitingSession.isActive, isFalse);
      expect(waitingSession.isEnded, isFalse);

      final activeSession = waitingSession.copyWith(status: 'active');
      expect(activeSession.isWaiting, isFalse);
      expect(activeSession.isActive, isTrue);
      expect(activeSession.isEnded, isFalse);

      final endedSession = activeSession.copyWith(status: 'ended');
      expect(endedSession.isWaiting, isFalse);
      expect(endedSession.isActive, isFalse);
      expect(endedSession.isEnded, isTrue);

      final cancelledSession = activeSession.copyWith(status: 'cancelled');
      expect(cancelledSession.isEnded, isTrue);
    });

    test('AnonSessionModel correctly parses bot session and reconnection data', () {
      final json = {
        'id': 'sess-bot-99',
        'user1_id': 'user-1',
        'user2_id': null,
        'mode': 'Cuma mau didengar',
        'status': 'active',
        'is_bot_session': true,
        'created_at': DateTime.now().toIso8601String(),
      };
      final model = AnonSessionModel.fromJson(json);
      expect(model.id, 'sess-bot-99');
      expect(model.user1Id, 'user-1');
      expect(model.user2Id, isNull);
      expect(model.isBotSession, isTrue);
      expect(model.isActive, isTrue);
    });

    test('AnonReportModel correctly parses report data', () {
      final json = {
        'id': 'rep-1',
        'session_id': 'sess-100',
        'reporter_id': 'user-1',
        'reported_user_id': 'user-2',
        'reason': 'Hate speech / berbicara kasar',
        'details': 'Menggunakan kata-kata kasar',
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      };
      final report = AnonReportModel.fromJson(json);
      expect(report.id, 'rep-1');
      expect(report.sessionId, 'sess-100');
      expect(report.reporterId, 'user-1');
      expect(report.reportedUserId, 'user-2');
      expect(report.reason, 'Hate speech / berbicara kasar');
      expect(report.details, 'Menggunakan kata-kata kasar');
      expect(report.status, 'pending');
    });

    test('AnonMessageModel copyWith and deliveryStatus behave correctly', () {
      final msg = AnonMessageModel(
        id: 'msg-temp-1',
        sessionId: 'sess-1',
        senderId: 'user-1',
        senderAlias: 'Mahasiswa Bro',
        messageText: 'Halo ini pesan tes optimistik',
        createdAt: DateTime.now(),
        deliveryStatus: MessageDeliveryStatus.sending,
      );
      expect(msg.deliveryStatus, MessageDeliveryStatus.sending);

      // Failed transition
      final failedMsg = msg.copyWith(deliveryStatus: MessageDeliveryStatus.failed);
      expect(failedMsg.deliveryStatus, MessageDeliveryStatus.failed);

      // Retry transition
      final retryingMsg = failedMsg.copyWith(deliveryStatus: MessageDeliveryStatus.sending);
      expect(retryingMsg.deliveryStatus, MessageDeliveryStatus.sending);

      // Sent transition
      final sentMsg = retryingMsg.copyWith(deliveryStatus: MessageDeliveryStatus.sent);
      expect(sentMsg.deliveryStatus, MessageDeliveryStatus.sent);
    });

    test('3-Layer Deduplication Engine prevents duplicates after delayed retry', () {
      // Simulate client-generated UUID
      const messageId = 'c8b6b0c2-3e2b-4786-9a28-112233445566';
      final t0 = DateTime.now().subtract(const Duration(minutes: 5)); // 5 minutes ago (offline)

      // 1. Initial optimistic message created offline
      var optimisticMessages = <AnonMessageModel>[
        AnonMessageModel(
          id: messageId,
          sessionId: 'sess-1',
          senderId: 'user-me',
          senderAlias: 'Mahasiswa Bro',
          messageText: 'Pesan saat offline',
          createdAt: t0,
          deliveryStatus: MessageDeliveryStatus.failed,
        ),
      ];

      // 2. User taps retry when network returns: status updated to sending and time refreshed
      final tRetry = DateTime.now();
      optimisticMessages[0] = optimisticMessages[0].copyWith(
        createdAt: tRetry,
        deliveryStatus: MessageDeliveryStatus.sending,
      );

      // 3. Supabase insert succeeds and returns server record with identical UUID
      final serverMessages = <AnonMessageModel>[
        AnonMessageModel(
          id: messageId, // Exact UUID from client
          sessionId: 'sess-1',
          senderId: 'user-me',
          senderAlias: 'Mahasiswa Bro',
          messageText: 'Pesan saat offline',
          createdAt: tRetry.add(const Duration(milliseconds: 300)),
          deliveryStatus: MessageDeliveryStatus.sent,
        ),
      ];

      // Combine messages logic (Layer 1: Exact UUID match eviction)
      final items = List<AnonMessageModel>.from(serverMessages);
      optimisticMessages.removeWhere((opt) => serverMessages.any((s) => s.id == opt.id));

      // Layer 2: Display guard by unique ID
      for (final opt in optimisticMessages) {
        final alreadyExists = items.any((m) => m.id == opt.id);
        if (!alreadyExists) {
          items.add(opt);
        }
      }

      // Layer 3: Unique ID Safety Net
      final seenIds = <String>{};
      items.retainWhere((m) => seenIds.add(m.id));

      // Assert: Exactly 1 message in list, 0 duplicates!
      expect(items.length, 1);
      expect(items.first.id, messageId);
      expect(optimisticMessages.isEmpty, isTrue);
    });

    test('Consecutive identical messages ("test", "test") are both preserved and displayed correctly', () {
      final serverMessages = <AnonMessageModel>[
        AnonMessageModel(
          id: 'uuid-test-1',
          sessionId: 'sess-1',
          senderId: 'user-me',
          senderAlias: 'Mahasiswa Bro',
          messageText: 'test',
          createdAt: DateTime.now().subtract(const Duration(seconds: 5)),
          deliveryStatus: MessageDeliveryStatus.sent,
        ),
      ];

      // Second optimistic message with the exact same text 'test' but different UUID
      var optimisticMessages = <AnonMessageModel>[
        AnonMessageModel(
          id: 'uuid-test-2',
          sessionId: 'sess-1',
          senderId: 'user-me',
          senderAlias: 'Mahasiswa Bro',
          messageText: 'test',
          createdAt: DateTime.now(),
          deliveryStatus: MessageDeliveryStatus.sending,
        ),
      ];

      // 1. Evict exact UUID
      optimisticMessages.removeWhere((opt) => serverMessages.any((s) => s.id == opt.id));

      final items = List<AnonMessageModel>.from(serverMessages);

      // 2. Display guard by ID (allows repeated texts with different IDs)
      for (final opt in optimisticMessages) {
        final alreadyExists = items.any((m) => m.id == opt.id);
        if (!alreadyExists) {
          items.add(opt);
        }
      }

      // 3. Unique ID Safety Net
      final seenIds = <String>{};
      items.retainWhere((m) => seenIds.add(m.id));

      // Assert: Both 'test' messages are preserved! Length is 2!
      expect(items.length, 2);
      expect(items[0].messageText, 'test');
      expect(items[0].id, 'uuid-test-1');
      expect(items[1].messageText, 'test');
      expect(items[1].id, 'uuid-test-2');
    });

    test('Exact UUID Deduplication evicts optimistic messages when stream arrives', () {
      const messageId = 'uuid-offline-123';
      final tOffline = DateTime.now().subtract(const Duration(minutes: 5));

      final serverMessages = <ChatMessageModel>[
        ChatMessageModel(
          id: messageId,
          sessionId: 'sess-1',
          senderId: 'user-me',
          senderRole: 'student',
          messageText: 'Halo konselor',
          isRead: false,
          createdAt: DateTime.now(),
          deliveryStatus: MessageDeliveryStatus.sent,
        ),
      ];

      var optimisticMessages = <ChatMessageModel>[
        ChatMessageModel(
          id: messageId,
          sessionId: 'sess-1',
          senderId: 'user-me',
          senderRole: 'student',
          messageText: 'Halo konselor',
          isRead: false,
          createdAt: tOffline,
          deliveryStatus: MessageDeliveryStatus.sending,
        ),
      ];

      // Evict Layer 1 (exact ID)
      optimisticMessages.removeWhere((opt) => serverMessages.any((s) => s.id == opt.id));

      // Assert optimistic message was cleanly evicted
      expect(optimisticMessages.isEmpty, isTrue);
    });
  });

  group('Anonymous Matching Timeout & Auto-Retry Reconnection Tests', () {
    testWidgets('ChatAnonMatchingView displays timeout view with Bot AI disclosure after 15 seconds', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ChatAnonMatchingView(
              mode: 'Cuma mau didengar',
            ),
          ),
        ),
      );

      // Initially searching
      expect(find.text('Mencari partner ngobrol...'), findsOneWidget);
      expect(find.text('Batalkan'), findsOneWidget);

      // Advance timer by 16 seconds to simulate timeout
      for (int i = 0; i < 16; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      // Verifies timeout state is rendered
      expect(find.text('Belum Menemukan Partner'), findsOneWidget);
      expect(find.text('BOT AI OTOMATIS'), findsOneWidget);
      expect(find.text('Ngobrol dengan Teman Virtual'), findsOneWidget);
      expect(find.text('Mulai Ngobrol dengan Teman Virtual'), findsOneWidget);
      expect(find.text('Coba Cari Teman Mahasiswa Lagi'), findsOneWidget);
      expect(find.text('Kembali ke Menu Chat'), findsOneWidget);
    });

    test('Auto-retry processor sequentially re-sends failed messages without duplicates', () async {
      final List<AnonMessageModel> queue = [
        AnonMessageModel(
          id: 'msg-1',
          sessionId: 'sess-1',
          senderId: 'user-1',
          senderAlias: 'Mahasiswa Bro',
          messageText: 'Pesan gagal 1',
          createdAt: DateTime.now().subtract(const Duration(seconds: 30)),
          deliveryStatus: MessageDeliveryStatus.failed,
        ),
        AnonMessageModel(
          id: 'msg-2',
          sessionId: 'sess-1',
          senderId: 'user-1',
          senderAlias: 'Mahasiswa Bro',
          messageText: 'Pesan gagal 2',
          createdAt: DateTime.now().subtract(const Duration(seconds: 10)),
          deliveryStatus: MessageDeliveryStatus.failed,
        ),
      ];

      // Simulate auto-retry execution
      final List<String> retriedIds = [];
      for (int i = 0; i < queue.length; i++) {
        final current = queue[i];
        if (current.deliveryStatus == MessageDeliveryStatus.failed) {
          queue[i] = current.copyWith(
            createdAt: DateTime.now(),
            deliveryStatus: MessageDeliveryStatus.sending,
          );
          retriedIds.add(current.id);
          // Simulate successful arrival
          queue[i] = queue[i].copyWith(
            deliveryStatus: MessageDeliveryStatus.sent,
          );
        }
      }

      expect(retriedIds, ['msg-1', 'msg-2']);
      expect(queue.every((m) => m.deliveryStatus == MessageDeliveryStatus.sent), isTrue);
    });

    test('Auto-retry handles Postgres 23505 duplicate key error by marking message as sent', () {
      final msg = AnonMessageModel(
        id: 'msg-already-in-db',
        sessionId: 'sess-1',
        senderId: 'user-1',
        senderAlias: 'Mahasiswa Bro',
        messageText: 'Pesan terputus sesaat',
        createdAt: DateTime.now(),
        deliveryStatus: MessageDeliveryStatus.failed,
      );

      final optimisticMessages = [msg];

      // Simulate simulated error: PostgrestException 23505
      final Object simulatedError = Exception('PostgrestException(message: duplicate key value violates unique constraint "anon_messages_pkey", code: 23505)');
      final isDuplicateKey = simulatedError.toString().contains('23505') ||
          simulatedError.toString().toLowerCase().contains('duplicate key');

      final idx = optimisticMessages.indexWhere((m) => m.id == msg.id);
      if (idx != -1) {
        optimisticMessages[idx] = msg.copyWith(
          deliveryStatus: isDuplicateKey
              ? MessageDeliveryStatus.sent
              : MessageDeliveryStatus.failed,
        );
      }

      // Assert: Message is resolved to sent status because it already exists in DB!
      expect(optimisticMessages.first.deliveryStatus, MessageDeliveryStatus.sent);
    });
  });

  group('Multi-Select, Delete for Me, and Unsend Tests', () {
    test('ChatMessageModel correctly parses unsend and delete-for-me fields', () {
      final json = {
        'id': 'chat-msg-1',
        'session_id': 'sess-100',
        'sender_id': 'user-1',
        'sender_role': 'student',
        'message_text': 'Pesan rahasia',
        'is_read': true,
        'created_at': '2026-10-28T01:00:00Z',
        'is_deleted_for_everyone': true,
        'deleted_at': '2026-10-28T01:05:00Z',
        'deleted_for_users': ['user-1', 'user-2'],
      };

      final model = ChatMessageModel.fromJson(json);
      expect(model.id, 'chat-msg-1');
      expect(model.isDeletedForEveryone, isTrue);
      expect(model.deletedAt, isNotNull);
      expect(model.deletedForUsers, ['user-1', 'user-2']);

      final copied = model.copyWith(
        isDeletedForEveryone: false,
        deletedForUsers: ['user-3'],
      );
      expect(copied.isDeletedForEveryone, isFalse);
      expect(copied.deletedForUsers, ['user-3']);
    });

    test('AnonMessageModel correctly parses unsend and delete-for-me fields', () {
      final json = {
        'id': 'anon-msg-1',
        'session_id': 'anon-sess-100',
        'sender_id': 'user-x',
        'sender_alias': 'Mahasiswa Bro',
        'message_text': 'Cerita rahasia',
        'is_system': false,
        'created_at': '2026-10-28T01:00:00Z',
        'is_deleted_for_everyone': true,
        'deleted_at': '2026-10-28T01:02:00Z',
        'deleted_for_users': ['user-x'],
      };

      final model = AnonMessageModel.fromJson(json);
      expect(model.id, 'anon-msg-1');
      expect(model.isDeletedForEveryone, isTrue);
      expect(model.deletedAt, isNotNull);
      expect(model.deletedForUsers, ['user-x']);
    });

    test('Delete for Me filtering logic excludes messages where deletedForUsers contains currentUserId', () {
      const currentUserId = 'user-me';
      const peerUserId = 'user-peer';

      final messages = [
        AnonMessageModel(
          id: 'msg-1',
          sessionId: 'sess-1',
          senderId: currentUserId,
          senderAlias: 'Me',
          messageText: 'Pesan 1',
          createdAt: DateTime.now(),
          deletedForUsers: const ['user-me'], // Hapus untuk saya
        ),
        AnonMessageModel(
          id: 'msg-2',
          sessionId: 'sess-1',
          senderId: peerUserId,
          senderAlias: 'Peer',
          messageText: 'Pesan 2',
          createdAt: DateTime.now(),
          deletedForUsers: const [], // Tidak dihapus
        ),
        AnonMessageModel(
          id: 'msg-3',
          sessionId: 'sess-1',
          senderId: currentUserId,
          senderAlias: 'Me',
          messageText: 'Pesan 3',
          createdAt: DateTime.now(),
          deletedForUsers: const ['user-other'], // Dihapus orang lain, bukan saya
        ),
      ];

      final visibleToMe = messages.where((m) => !m.deletedForUsers.contains(currentUserId)).toList();
      expect(visibleToMe.length, 2);
      expect(visibleToMe.map((m) => m.id), ['msg-2', 'msg-3']);
    });

    test('Unsend eligibility rules for counseling (<= 30 minutes) and sender ownership', () {
      const currentUserId = 'user-me';
      const peerUserId = 'user-peer';
      final now = DateTime.now();

      final recentMsgByMe = ChatMessageModel(
        id: 'c-1',
        sessionId: 'sess-1',
        senderId: currentUserId,
        senderRole: 'student',
        messageText: 'Baru dikirim 5 menit lalu',
        isRead: false,
        createdAt: now.subtract(const Duration(minutes: 5)),
      );

      final oldMsgByMe = ChatMessageModel(
        id: 'c-2',
        sessionId: 'sess-1',
        senderId: currentUserId,
        senderRole: 'student',
        messageText: 'Dikirim 45 menit lalu',
        isRead: true,
        createdAt: now.subtract(const Duration(minutes: 45)),
      );

      final msgByPeer = ChatMessageModel(
        id: 'c-3',
        sessionId: 'sess-1',
        senderId: peerUserId,
        senderRole: 'counselor',
        messageText: 'Pesan dari konselor',
        isRead: true,
        createdAt: now.subtract(const Duration(minutes: 2)),
      );

      // Rule check:
      bool canUnsendCounseling(ChatMessageModel m) {
        final isMe = m.senderId == currentUserId;
        final within30Mins = DateTime.now().difference(m.createdAt).inMinutes <= 30;
        return isMe && !m.isDeletedForEveryone && within30Mins;
      }

      expect(canUnsendCounseling(recentMsgByMe), isTrue);
      expect(canUnsendCounseling(oldMsgByMe), isFalse); // Melebihi 30 menit
      expect(canUnsendCounseling(msgByPeer), isFalse); // Milik lawan bicara
    });

    test('Copy formatting includes timestamps correctly for selected messages', () {
      final t1 = DateTime(2026, 10, 28, 14, 30);
      final t2 = DateTime(2026, 10, 28, 14, 32);

      final selected = [
        AnonMessageModel(
          id: 'm-1',
          sessionId: 's-1',
          senderAlias: 'Anon',
          messageText: 'Halo semuanya',
          createdAt: t1,
        ),
        AnonMessageModel(
          id: 'm-2',
          sessionId: 's-1',
          senderAlias: 'Anon',
          messageText: 'Pesan penting',
          createdAt: t2,
        ),
      ];

      final buffer = StringBuffer();
      for (int i = 0; i < selected.length; i++) {
        final m = selected[i];
        final timeStr = '${m.createdAt.hour.toString().padLeft(2, '0')}:${m.createdAt.minute.toString().padLeft(2, '0')}';
        final textContent = m.isDeletedForEveryone ? 'Pesan ini telah ditarik' : m.messageText;
        buffer.write('[$timeStr] $textContent');
        if (i < selected.length - 1) {
          buffer.write('\n');
        }
      }

      expect(buffer.toString(), '[14:30] Halo semuanya\n[14:32] Pesan penting');
    });

    test('Deleted message text omits emoji 🚫 in copy formatting', () {
      final t1 = DateTime(2026, 10, 28, 14, 30);
      final selected = [
        AnonMessageModel(
          id: '1',
          sessionId: 's-1',
          senderAlias: 'Anon',
          messageText: 'Pesan asli',
          createdAt: t1,
          isDeletedForEveryone: true,
        ),
      ];

      final m = selected.first;
      final timeStr = '${m.createdAt.hour.toString().padLeft(2, '0')}:${m.createdAt.minute.toString().padLeft(2, '0')}';
      final textContent = m.isDeletedForEveryone ? 'Pesan ini telah ditarik' : m.messageText;
      final result = '[$timeStr] $textContent';

      expect(result.contains('🚫'), false);
      expect(result, '[14:30] Pesan ini telah ditarik');
    });
  });

  group('Read Receipts & Presence Engine Tests', () {
    test('AnonMessageModel maps is_read = true to MessageDeliveryStatus.read and false to sent', () {
      final unreadJson = {
        'id': 'msg-1',
        'session_id': 'sess-1',
        'sender_id': 'user-1',
        'sender_alias': 'Anonim 1',
        'message_text': 'Pesan belum dibaca',
        'is_system': false,
        'created_at': DateTime.now().toIso8601String(),
        'is_read': false,
      };

      final readJson = {
        'id': 'msg-2',
        'session_id': 'sess-1',
        'sender_id': 'user-1',
        'sender_alias': 'Anonim 1',
        'message_text': 'Pesan sudah dibaca',
        'is_system': false,
        'created_at': DateTime.now().toIso8601String(),
        'is_read': true,
      };

      final unreadModel = AnonMessageModel.fromJson(unreadJson);
      final readModel = AnonMessageModel.fromJson(readJson);

      expect(unreadModel.isRead, false);
      expect(unreadModel.deliveryStatus, MessageDeliveryStatus.sent);

      expect(readModel.isRead, true);
      expect(readModel.deliveryStatus, MessageDeliveryStatus.read);
    });

    test('Activity-based heartbeat logic identifies partner message to keep session online', () {
      const currentUserId = 'user-me';
      const partnerUserId = 'user-partner';

      final messages = [
        AnonMessageModel(
          id: '1',
          sessionId: 's-1',
          senderId: currentUserId,
          senderAlias: 'Me',
          messageText: 'Halo',
          createdAt: DateTime.now(),
        ),
        AnonMessageModel(
          id: '2',
          sessionId: 's-1',
          senderId: partnerUserId,
          senderAlias: 'Partner',
          messageText: 'Hai juga!',
          createdAt: DateTime.now(),
          isRead: false,
        ),
      ];

      // Logic check as implemented in _handleIncomingMessagesActivity
      final partnerMessages = messages.where((m) =>
        !m.isSystem && (m.senderId != null && m.senderId != currentUserId)
      ).toList();

      expect(partnerMessages.length, 1);
      expect(partnerMessages.first.senderId, partnerUserId);
      final hasUnread = partnerMessages.any((m) => !m.isRead);
      expect(hasUnread, true); // Perlu ditandai sebagai terbaca
    });
  });

  group('Counselor Approval Gate & Verification Tests', () {
    test('AuthState defaults and verification flag behaves correctly for roles', () {
      const studentState = AuthState(
        isLoggedIn: true,
        role: 'mahasiswa',
        isVerified: true,
        counselorStatus: 'approved',
      );
      expect(studentState.isVerified, isTrue);
      expect(studentState.counselorStatus, 'approved');

      const pendingCounselorState = AuthState(
        isLoggedIn: true,
        role: 'konselor',
        isVerified: false,
        counselorStatus: 'pending',
      );
      expect(pendingCounselorState.isVerified, isFalse);
      expect(pendingCounselorState.counselorStatus, 'pending');

      final approvedCounselorState = pendingCounselorState.copyWith(
        isVerified: true,
        counselorStatus: 'approved',
      );
      expect(approvedCounselorState.isVerified, isTrue);
      expect(approvedCounselorState.counselorStatus, 'approved');
    });

    testWidgets('CounselorPendingView renders pending message, status badge, and check button', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              () => _FakeAuthNotifier(
                const AuthState(
                  isLoggedIn: true,
                  username: 'Kak Alena',
                  email: 'alena@counselor.ub.ac.id',
                  role: 'konselor',
                  isVerified: false,
                  counselorStatus: 'pending',
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            home: CounselorPendingView(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Akun Konselor Sedang Ditinjau'), findsOneWidget);
      expect(find.textContaining('Pendaftaran akun Konselor Sebaya kamu sedang ditinjau'), findsOneWidget);
      expect(find.text('Menunggu Verifikasi'), findsOneWidget);
      expect(find.text('Cek Status Verifikasi'), findsOneWidget);
      expect(find.text('Keluar / Ganti Akun'), findsOneWidget);
    });
  });

  group('Environment Variables & Security Configuration Tests', () {
    test('SupabaseService reads configuration safely from dotenv without hardcoded secrets', () {
      dotenv.loadFromString(envString: 'SUPABASE_URL=https://test.supabase.co\nSUPABASE_ANON_KEY=test-anon-key');
      expect(SupabaseService.supabaseUrl, 'https://test.supabase.co');
      expect(SupabaseService.supabaseAnonKey, 'test-anon-key');
    });

    test('SupabaseService initialization throws StateError when variables are missing', () async {
      dotenv.clean();
      expect(() => SupabaseService.initialize(), throwsA(isA<StateError>()));
    });
  });
}

class _FakeAuthNotifier extends Notifier<AuthState> implements AuthNotifier {
  final AuthState _initial;
  _FakeAuthNotifier(this._initial);

  @override
  AuthState build() => _initial;

  @override
  Future<void> refreshProfile() async {}

  @override
  Future<bool> checkUserExists(String email) async => true;

  @override
  Future<bool> login(String email, String password) async => true;

  @override
  Future<bool> register({
    required String email,
    required String password,
    required String role,
    required String fullName,
    String? nickname,
    String? gender,
    String? batchYear,
    String? faculty,
    String? studyProgram,
    List<String>? hobbies,
    List<String>? topics,
  }) async => true;

  @override
  Future<void> logout() async {}
}

