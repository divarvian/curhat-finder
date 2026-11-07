import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:curhat_finder/features/chat/presentation/widgets/leave_chat_dialog.dart';
import 'package:curhat_finder/features/chat/presentation/widgets/report_chat_dialog.dart';
import 'package:curhat_finder/features/chat/presentation/widgets/dialogs/counseling_rating_dialog.dart';

void main() {
  group('Chat Dialogs & Mascot Parity Tests', () {
    testWidgets('Mascot Parity: Dialogs and widgets render contextual mascot expressions', (WidgetTester tester) async {
      // 1. Leave Chat Dialog with mascot_leave.png
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LeaveChatDialog(),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Apakah kamu yakin?'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);

      // 2. Report Chat Dialog with mascot_report.png
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ReportChatDialog(
              sessionId: 'sess-test-1',
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Laporkan Chat'), findsOneWidget);
      expect(find.byType(Image), findsWidgets);

      // 3. Counseling Rating Dialog with mascot_happy.png
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CounselingRatingDialog(
              sessionId: 'sess-counsel-1',
              counselorName: 'Kak Sarah',
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Sesi Konseling Selesai'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });
  });
}
