import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:curhat_finder/core/utils/app_error_translator.dart';

void main() {
  group('AppErrorTranslator Tests', () {
    test('translates AuthException invalid credentials', () {
      const authEx = AuthException('Invalid login credentials');
      final result = AppErrorTranslator.translateAuthError(authEx);
      expect(result, contains('Email atau kata sandi yang kamu masukkan salah'));
    });

    test('translates AuthException rate limit', () {
      const authEx = AuthException('Email rate limit exceeded');
      final result = AppErrorTranslator.translateAuthError(authEx);
      expect(result, contains('Terlalu banyak percobaan'));
    });

    test('translates AuthException user already registered', () {
      const authEx = AuthException('User already registered');
      final result = AppErrorTranslator.translateAuthError(authEx);
      expect(result, contains('Email ini sudah terdaftar'));
    });

    test('translates AuthException short password', () {
      const authEx = AuthException('Password should be at least 6 characters');
      final result = AppErrorTranslator.translateAuthError(authEx);
      expect(result, contains('Kata sandi minimal harus'));
    });

    test('translates PostgrestException 23505 unique violation', () {
      const dbEx = PostgrestException(message: 'duplicate key value violates unique constraint', code: '23505');
      final result = AppErrorTranslator.translateDatabaseError(dbEx);
      expect(result, contains('Data ini sudah pernah dikirim'));
    });

    test('translates PostgrestException 42501 RLS denial', () {
      const dbEx = PostgrestException(message: 'new row violates row-level security policy', code: '42501');
      final result = AppErrorTranslator.translateDatabaseError(dbEx);
      expect(result, contains('Akses ditolak'));
    });

    test('translates custom trigger exception for offline counselor', () {
      const dbEx = PostgrestException(message: 'Konselor sedang offline', code: 'P0001');
      final result = AppErrorTranslator.translateDatabaseError(dbEx);
      expect(result, contains('Konselor sedang offline'));
    });

    test('translates custom trigger exception for active session existing', () {
      const dbEx = PostgrestException(message: 'Mahasiswa masih memiliki sesi aktif', code: 'P0001');
      final result = AppErrorTranslator.translateDatabaseError(dbEx);
      expect(result, contains('masih memiliki sesi konseling aktif'));
    });
  });
}
