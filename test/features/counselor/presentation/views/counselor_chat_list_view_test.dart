import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curhat_finder/core/widgets/app_skeleton.dart';
import 'package:curhat_finder/features/counselor/presentation/providers/counselor_provider.dart';
import 'package:curhat_finder/features/counselor/presentation/views/counselor_chat_list_view.dart';
import '../../../../helpers/fake_notifiers.dart';

void main() {
  group('CounselorChatListView Tests', () {
    testWidgets('CounselorChatListView renders CounselorChatSessionSkeleton when loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            counselorProvider.overrideWith(
              () => FakeCounselorNotifier(
                const CounselorState(isLoading: true),
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CounselorChatListView(),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(CounselorChatSessionSkeleton), findsNWidgets(4));
      expect(find.text('Belum ada sesi chat aktif'), findsNothing);
    });
  });
}
