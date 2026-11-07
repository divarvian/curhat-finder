import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curhat_finder/core/theme/app_colors.dart';
import 'package:curhat_finder/features/auth/presentation/views/register_view.dart';
import 'package:curhat_finder/features/auth/presentation/widgets/register_steps/register_steps_final.dart';

void main() {
  group('RegisterView & Steps Tests', () {
    testWidgets('RegisterView renders differentiated background for counselor vs student', (tester) async {
      // 1. Counselor registration: blue background
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterView(isKonselor: true),
          ),
        ),
      );
      await tester.pump();

      final scaffolds = tester.widgetList<Scaffold>(find.byType(Scaffold));
      final counselorBgScaffold = scaffolds.firstWhere(
        (s) => s.backgroundColor == AppColors.counselorRegisterBg,
      );
      expect(counselorBgScaffold, isNotNull);

      // 2. Student registration: standard background
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterView(isKonselor: false),
          ),
        ),
      );
      await tester.pump();

      final studentScaffolds = tester.widgetList<Scaffold>(find.byType(Scaffold));
      final studentBgScaffold = studentScaffolds.firstWhere(
        (s) => s.backgroundColor == AppColors.background,
      );
      expect(studentBgScaffold, isNotNull);
    });

    testWidgets('StepFinal renders counselor topics vs student hobbies with role-adapted button', (tester) async {
      // 1. Counselor StepFinal: Topik yang kamu kuasai
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StepFinal(isKonselor: true, onNext: () {}),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Topik yang kamu kuasai'), findsOneWidget);
      expect(find.text('Pilih satu atau lebih topik yang sesuai dengan keahlian konselingmu'), findsOneWidget);
      expect(find.text('Overwhelmed'), findsOneWidget);
      expect(find.text('Burnout'), findsOneWidget);
      expect(find.text('Anxiety'), findsOneWidget);

      // Verify button color is Coral Pink AppColors.counselorRegisterBtn
      final counselorBtn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(counselorBtn.style?.backgroundColor?.resolve({}), AppColors.counselorRegisterBtn);

      // 2. Student StepFinal: Apa hal yang bisa bikin kamu happy?
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StepFinal(isKonselor: false, onNext: () {}),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Apa hal yang bisa bikin kamu happy?'), findsOneWidget);
      expect(find.text('Olahraga'), findsOneWidget);
      expect(find.text('Gaming'), findsOneWidget);

      // Verify button color is Navy AppColors.twilightDarker
      final studentBtn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(studentBtn.style?.backgroundColor?.resolve({}), AppColors.twilightDarker);
    });
  });
}
