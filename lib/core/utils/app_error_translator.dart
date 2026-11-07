import 'package:supabase_flutter/supabase_flutter.dart';

/// Utilitas terpusat untuk menerjemahkan error Supabase (GoTrue, Postgrest, RLS, Network)
/// menjadi pesan yang ramah, santun, dan mudah dipahami dalam bahasa Indonesia.
class AppErrorTranslator {
  AppErrorTranslator._();

  /// Menerjemahkan error autentikasi (GoTrue Auth)
  static String translateAuthError(dynamic error) {
    if (error is AuthException) {
      final msg = error.message.toLowerCase();
      if (msg.contains('invalid login credentials') || msg.contains('invalid credentials')) {
        return 'Email atau kata sandi yang kamu masukkan salah. Silakan coba lagi.';
      }
      if (msg.contains('rate limit') || msg.contains('over_email_send_rate_limit')) {
        return 'Terlalu banyak percobaan dalam waktu singkat. Mohon tunggu beberapa saat.';
      }
      if (msg.contains('user already registered') || msg.contains('already exists')) {
        return 'Email ini sudah terdaftar. Silakan login atau gunakan fitur lupa password.';
      }
      if (msg.contains('password should be at least')) {
        return 'Kata sandi minimal harus terdiri dari 6 karakter.';
      }
      if (msg.contains('signup requires a valid password')) {
        return 'Kata sandi tidak boleh kosong.';
      }
      if (msg.contains('network') || msg.contains('failed to connect') || msg.contains('socket')) {
        return 'Gagal terhubung ke internet. Mohon periksa kembali jaringanmu.';
      }
      return error.message;
    }

    final errStr = error.toString().toLowerCase();
    if (errStr.contains('invalid login credentials') || errStr.contains('invalid credentials')) {
      return 'Email atau kata sandi yang kamu masukkan salah. Silakan coba lagi.';
    }
    if (errStr.contains('network') || errStr.contains('socketexception') || errStr.contains('failed host lookup')) {
      return 'Gagal terhubung ke internet. Mohon periksa kembali jaringanmu.';
    }
    if (errStr.contains('rate limit')) {
      return 'Terlalu banyak percobaan dalam waktu singkat. Mohon tunggu beberapa saat.';
    }

    return 'Terjadi kendala pada proses masuk. Silakan coba beberapa saat lagi.';
  }

  /// Menerjemahkan error database (PostgREST & PL/pgSQL Trigger)
  static String translateDatabaseError(dynamic error) {
    if (error is PostgrestException) {
      switch (error.code) {
        case '23505': // unique_violation
          return 'Data ini sudah pernah dikirim atau sudah tersimpan.';
        case '42501': // insufficient_privilege / RLS policy violation
          return 'Akses ditolak atau kamu tidak memiliki izin untuk aksi ini.';
        case 'P0001': // raise_exception dari custom trigger PL/pgSQL
          final msg = error.message.toLowerCase();
          if (msg.contains('offline')) {
            return 'Konselor sedang offline dan tidak menerima antrean baru.';
          }
          if (msg.contains('masih memiliki sesi')) {
            return 'Kamu masih memiliki sesi konseling aktif yang sedang berjalan.';
          }
          return error.message;
        default:
          final msg = error.message.toLowerCase();
          if (msg.contains('offline')) {
            return 'Konselor sedang offline dan tidak menerima antrean baru.';
          }
          if (msg.contains('masih memiliki sesi')) {
            return 'Kamu masih memiliki sesi konseling aktif yang sedang berjalan.';
          }
          return 'Gagal memproses permintaan database. Silakan coba beberapa saat lagi.';
      }
    }

    final errStr = error.toString().toLowerCase();
    if (errStr.contains('offline')) {
      return 'Konselor sedang offline dan tidak menerima antrean baru.';
    }
    if (errStr.contains('masih memiliki sesi')) {
      return 'Kamu masih memiliki sesi konseling aktif yang sedang berjalan.';
    }
    if (errStr.contains('23505') || errStr.contains('duplicate key')) {
      return 'Data ini sudah pernah dikirim atau sudah tersimpan.';
    }
    if (errStr.contains('socketexception') || errStr.contains('network') || errStr.contains('failed host lookup')) {
      return 'Gagal terhubung ke internet. Mohon periksa kembali jaringanmu.';
    }

    return 'Terjadi kendala pada sistem. Silakan coba kembali nanti.';
  }
}
