import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curhat_finder/features/auth/presentation/views/login_view.dart';
import 'package:curhat_finder/core/utils/ub_email_validator.dart';

void main() {
  group('LoginView Email Domain Validation Tests', () {
    testWidgets('rejects non-UB email (e.g. gmail.com) on submit with error text', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginView(),
          ),
        ),
      );
      await tester.pump();

      // Find the email input field and password input field
      final emailField = find.widgetWithText(TextFormField, 'Email/Username');
      final passField = find.widgetWithText(TextFormField, 'Password');
      final loginButton = find.text('Masuk');

      expect(emailField, findsOneWidget);
      expect(passField, findsOneWidget);
      expect(loginButton, findsOneWidget);

      // Enter gmail.com address
      await tester.enterText(emailField, 'mahasiswa@gmail.com');
      await tester.enterText(passField, 'password123');
      await tester.pump();

      // Tap Masuk
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Form validation error should appear
      expect(find.text(UbEmailValidator.invalidDomainMessage), findsOneWidget);
    });

    testWidgets('rejects yahoo.com email on submit with error text', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginView(),
          ),
        ),
      );
      await tester.pump();

      final emailField = find.widgetWithText(TextFormField, 'Email/Username');
      final passField = find.widgetWithText(TextFormField, 'Password');
      final loginButton = find.text('Masuk');

      await tester.enterText(emailField, 'test@yahoo.com');
      await tester.enterText(passField, 'password123');
      await tester.pump();

      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(find.text(UbEmailValidator.invalidDomainMessage), findsOneWidget);
    });

    testWidgets('accepts valid UB email without showing domain error', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginView(),
          ),
        ),
      );
      await tester.pump();

      final emailField = find.widgetWithText(TextFormField, 'Email/Username');
      await tester.enterText(emailField, 'budi@student.ub.ac.id');
      await tester.pump();

      // Domain error must not be present
      expect(find.text(UbEmailValidator.invalidDomainMessage), findsNothing);
    });

    testWidgets('accepts valid demo UB email without showing domain error', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginView(),
          ),
        ),
      );
      await tester.pump();

      final emailField = find.widgetWithText(TextFormField, 'Email/Username');
      await tester.enterText(emailField, 'counselor@demo.ub.ac.id');
      await tester.pump();

      expect(find.text(UbEmailValidator.invalidDomainMessage), findsNothing);
    });

    testWidgets('accepts username/NIM without showing domain error', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginView(),
          ),
        ),
      );
      await tester.pump();

      final emailField = find.widgetWithText(TextFormField, 'Email/Username');
      await tester.enterText(emailField, '215150201111001');
      await tester.pump();

      expect(find.text(UbEmailValidator.invalidDomainMessage), findsNothing);
    });
  });
}
