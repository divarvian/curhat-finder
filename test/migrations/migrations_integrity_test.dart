import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Database Migrations Integrity Tests', () {
    test('Storage and profile RLS migration 0007 contains valid SQL policies', () {
      final migrationFile = File('supabase/migrations/20261028000007_fix_avatar_storage_and_profiles_rls.sql');
      expect(migrationFile.existsSync(), isTrue);
      final sqlContent = migrationFile.readAsStringSync();

      // STO-001: Storage Avatar UPDATE and DELETE policies
      expect(sqlContent, contains('CREATE POLICY "Users can update own avatar"'));
      expect(sqlContent, contains('FOR UPDATE TO authenticated'));
      expect(sqlContent, contains("bucket_id = 'avatars'"));
      expect(sqlContent, contains('CREATE POLICY "Users can delete own avatar"'));
      expect(sqlContent, contains('FOR DELETE TO authenticated'));

      // SEC-005: Profiles INSERT tightened policy
      expect(sqlContent, contains('DROP POLICY IF EXISTS "Enable insert on profiles"'));
      expect(sqlContent, contains('CREATE POLICY "Users can only insert their own profile"'));
      expect(sqlContent, contains('FOR INSERT TO authenticated'));
      expect(sqlContent, contains('WITH CHECK (auth.uid() = id)'));
    });

    test('Migration 0008 contains valid pulse_contacts, articles, and forums definitions', () {
      final migrationFile = File('supabase/migrations/20261028000008_create_pulse_contacts_and_counselor_studio.sql');
      expect(migrationFile.existsSync(), isTrue);
      final sqlContent = migrationFile.readAsStringSync();

      expect(sqlContent, contains('CREATE TABLE IF NOT EXISTS public.pulse_contacts'));
      expect(sqlContent, contains('CREATE TABLE IF NOT EXISTS public.counselor_articles'));
      expect(sqlContent, contains('CREATE TABLE IF NOT EXISTS public.counselor_forums'));
      expect(sqlContent, contains('Unit Bimbingan Konseling FILKOM'));
      expect(sqlContent, contains('Hotline Sejiwa Kemenkes (24 Jam)'));
      expect(sqlContent, contains('ENABLE ROW LEVEL SECURITY'));
    });

    test('Migration 20261107000001 contains counselor metrics trigger, unified tips, and dropped tables', () {
      final migrationFile = File('supabase/migrations/20261107000001_counselor_metrics_and_unified_tips.sql');
      expect(migrationFile.existsSync(), isTrue);
      final sqlContent = migrationFile.readAsStringSync();

      // Recalculate metrics function & trigger
      expect(sqlContent, contains('CREATE OR REPLACE FUNCTION public.recalculate_counselor_metrics'));
      expect(sqlContent, contains('CREATE OR REPLACE FUNCTION public.sync_counselor_metrics()'));
      expect(sqlContent, contains('CREATE TRIGGER trg_sync_counselor_metrics'));
      expect(sqlContent, contains('active_sessions_count = v_active_count'));
      expect(sqlContent, contains('total_helped_count = v_helped_count'));
      expect(sqlContent, contains('avg_response_time = v_avg_resp_text'));

      // Enhanced tips
      expect(sqlContent, contains('ALTER TABLE public.tips'));
      expect(sqlContent, contains('ADD COLUMN IF NOT EXISTS summary TEXT'));
      expect(sqlContent, contains('ADD COLUMN IF NOT EXISTS reference_url TEXT'));
      expect(sqlContent, contains('ADD COLUMN IF NOT EXISTS is_counselor BOOLEAN DEFAULT false'));

      // Dropped obsolete tables
      expect(sqlContent, contains('DROP TABLE IF EXISTS public.counselor_articles CASCADE;'));
      expect(sqlContent, contains('DROP TABLE IF EXISTS public.counselor_forums CASCADE;'));
      expect(sqlContent, contains('DROP TABLE IF EXISTS public.forum_posts CASCADE;'));
      expect(sqlContent, contains('DROP TABLE IF EXISTS public.peer_anon_queue CASCADE;'));
    });
  });
}
