import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:curhat_finder/core/services/supabase_service.dart';

void main() {
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
