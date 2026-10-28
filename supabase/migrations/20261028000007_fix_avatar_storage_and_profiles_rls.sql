-- Migration: 20261028000007_fix_avatar_storage_and_profiles_rls.sql
-- Description: Kebijakan RLS UPDATE/DELETE Storage Avatar (STO-001) & Pengetatan INSERT Profiles (SEC-005)

-- ==============================================================================
-- 1. STO-001: Kebijakan RLS UPDATE dan DELETE pada Storage Bucket Avatars
-- ==============================================================================

-- Izinkan user mengupdate (overwrite / upsert) file avatar miliknya sendiri
DROP POLICY IF EXISTS "Users can update own avatar" ON storage.objects;
CREATE POLICY "Users can update own avatar"
ON storage.objects FOR UPDATE TO authenticated
USING (
    bucket_id = 'avatars' 
    AND (storage.foldername(name))[1] = auth.uid()::text
)
WITH CHECK (
    bucket_id = 'avatars' 
    AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Izinkan user menghapus file avatar miliknya sendiri
DROP POLICY IF EXISTS "Users can delete own avatar" ON storage.objects;
CREATE POLICY "Users can delete own avatar"
ON storage.objects FOR DELETE TO authenticated
USING (
    bucket_id = 'avatars' 
    AND (storage.foldername(name))[1] = auth.uid()::text
);

-- ==============================================================================
-- 2. SEC-005: Pengetatan Kebijakan RLS INSERT pada Tabel public.profiles
-- ==============================================================================

-- Cabut kebijakan INSERT terbuka bebas (WITH CHECK (true))
DROP POLICY IF EXISTS "Enable insert on profiles" ON public.profiles;
DROP POLICY IF EXISTS "Users can only insert their own profile" ON public.profiles;

-- Pengguna terautentikasi hanya diizinkan meng-insert profil dengan ID yang cocok dengan auth.uid()
CREATE POLICY "Users can only insert their own profile"
ON public.profiles FOR INSERT TO authenticated
WITH CHECK (auth.uid() = id);
