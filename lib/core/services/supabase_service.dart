import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  /// Mengambil URL Supabase dari file .env dengan fallback ke compile-time --dart-define
  static String get supabaseUrl {
    if (dotenv.isInitialized) {
      final val = dotenv.maybeGet('SUPABASE_URL');
      if (val != null && val.isNotEmpty) return val;
    }
    return const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  }

  /// Mengambil Anon Key Supabase dari file .env dengan fallback ke compile-time --dart-define
  static String get supabaseAnonKey {
    if (dotenv.isInitialized) {
      final val = dotenv.maybeGet('SUPABASE_ANON_KEY');
      if (val != null && val.isNotEmpty) return val;
    }
    return const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  }

  static Future<void> initialize() async {
    final url = supabaseUrl;
    final key = supabaseAnonKey;

    if (url.isEmpty || key.isEmpty) {
      throw StateError(
        'Supabase configuration missing! Please ensure SUPABASE_URL and SUPABASE_ANON_KEY '
        'are defined in .env or via --dart-define.',
      );
    }

    await Supabase.initialize(
      url: url,
      publishableKey: key,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
    );
  }

  static SupabaseClient? get maybeClient {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  static SupabaseClient get client => Supabase.instance.client;
  static User? get currentUser {
    try {
      return maybeClient?.auth.currentUser;
    } catch (_) {
      return null;
    }
  }
  static String? get currentUserId => currentUser?.id;
  static bool get isAuthenticated => currentUser != null;
}

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return SupabaseService.client;
});
