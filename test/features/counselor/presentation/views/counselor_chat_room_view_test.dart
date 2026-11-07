import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curhat_finder/features/counselor/domain/counselor_model.dart';
import 'package:curhat_finder/features/counselor/presentation/providers/counselor_provider.dart';
import 'package:curhat_finder/features/counselor/presentation/views/counselor_chat_room_view.dart';
import '../../../../helpers/fake_notifiers.dart';

void main() {
  group('CounselorChatRoomView Parity Widget Tests', () {
    testWidgets('CounselorChatRoomView displays messages and retract indicator for retracted messages', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            counselorProvider.overrideWith(() => FakeCounselorNotifier(
                  CounselorState(
                    isLoading: false,
                    profile: const CounselorProfile(
                      name: 'Konselor Test',
                      email: 'test@ub.ac.id',
                      faculty: 'FILKOM',
                      studyProgram: 'TIF',
                      batchYear: '2022',
                      gender: 'Laki-laki',
                      role: 'Konselor',
                      avatarPath: 'assets/images/mascot.png',
                      topics: ['Stres'],
                      isOnline: true,
                      activeSessions: 1,
                      totalHelped: 10,
                      responseTime: '1m',
                    ),
                    sessions: const [],
                    messages: {
                      'session-1': [
                        const CounselorChatMessage(
                          id: 'msg-1',
                          text: 'Pesan normal dari konselor',
                          isMe: true,
                          timestamp: '10:00',
                        ),
                        const CounselorChatMessage(
                          id: 'msg-2',
                          text: 'Curhatan mahasiswa',
                          isMe: false,
                          timestamp: '10:01',
                          isDeletedForEveryone: true,
                        ),
                      ],
                    },
                  ),
                )),
          ],
          child: const MaterialApp(
            home: CounselorChatRoomView(
              sessionId: 'session-1',
              studentTitle: 'Anonym - FILKOM',
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Pesan normal dari konselor'), findsOneWidget);
      expect(find.text('Pesan ini telah ditarik'), findsOneWidget);
      expect(find.byIcon(Icons.block_rounded), findsOneWidget);
    });

    testWidgets('CounselorChatRoomView long-press enters selection mode and allows copy & delete modal', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            counselorProvider.overrideWith(() => FakeCounselorNotifier(
                  CounselorState(
                    isLoading: false,
                    profile: const CounselorProfile(
                      name: 'Konselor Test',
                      email: 'test@ub.ac.id',
                      faculty: 'FILKOM',
                      studyProgram: 'TIF',
                      batchYear: '2022',
                      gender: 'Laki-laki',
                      role: 'Konselor',
                      avatarPath: 'assets/images/mascot.png',
                      topics: ['Stres'],
                      isOnline: true,
                      activeSessions: 1,
                      totalHelped: 10,
                      responseTime: '1m',
                    ),
                    sessions: const [],
                    messages: {
                      'session-1': [
                        CounselorChatMessage(
                          id: 'msg-1',
                          text: 'Halo ini pesan saya',
                          isMe: true,
                          timestamp: '10:00',
                          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
                        ),
                      ],
                    },
                  ),
                )),
          ],
          child: const MaterialApp(
            home: CounselorChatRoomView(
              sessionId: 'session-1',
              studentTitle: 'Anonym - FILKOM',
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Initially regular AppBar is shown
      expect(find.text('Anonym - FILKOM'), findsOneWidget);
      expect(find.byIcon(Icons.copy_rounded), findsNothing);

      // Long press on message to enter selection mode
      await tester.longPress(find.text('Halo ini pesan saya'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Contextual Action Bar should now be displayed
      expect(find.text('1 dipilih'), findsOneWidget);
      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);

      // Test copy action
      await tester.tap(find.byIcon(Icons.copy_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // SnackBar shows copy feedback and selection is cleared
      expect(find.text('Teks pesan disalin ke papan klip'), findsOneWidget);
      expect(find.text('1 dipilih'), findsNothing);

      // Long press again to test delete modal
      await tester.longPress(find.text('Halo ini pesan saya'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('1 dipilih'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();

      // Modal bottom sheet appears with both delete options (<30m)
      expect(find.text('Hapus Pesan (1)'), findsOneWidget);
      expect(find.text('Tarik untuk Semua Orang'), findsOneWidget);
      expect(find.text('Hapus untuk Saya'), findsOneWidget);

      // Tap 'Hapus untuk Saya'
      await tester.tap(find.text('Hapus untuk Saya'));
      await tester.pump();
      expect(find.text('Halo ini pesan saya'), findsNothing);

      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Pesan berhasil dihapus untuk Anda'), findsOneWidget);
      await tester.pumpAndSettle();
    });
  });
}
