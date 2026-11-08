-- Migration 20261108000000: Add author_avatar_url, replica identity full, and verify RLS for room_comments

-- 1. Tambahkan kolom author_avatar_url ke public.room_comments jika belum ada
ALTER TABLE public.room_comments
ADD COLUMN IF NOT EXISTS author_avatar_url TEXT;

-- 2. Backfill avatar_url dari profiles untuk komentar yang sudah ada jika tersedia
UPDATE public.room_comments rc
SET author_avatar_url = p.avatar_url
FROM public.profiles p
WHERE rc.user_id = p.id
  AND (rc.author_avatar_url IS NULL OR rc.author_avatar_url = '')
  AND p.avatar_url IS NOT NULL;

-- 3. Aktifkan REPLICA IDENTITY FULL agar Supabase Realtime bisa menyiarkan event DELETE dengan room_id
ALTER TABLE public.room_comments REPLICA IDENTITY FULL;

-- 4. Pastikan RLS DELETE dan INSERT berjalan mulus untuk user terautentikasi
DROP POLICY IF EXISTS "Authors delete own comments" ON public.room_comments;
CREATE POLICY "Authors delete own comments" 
ON public.room_comments FOR DELETE TO authenticated 
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Authenticated users insert comments" ON public.room_comments;
CREATE POLICY "Authenticated users insert comments" 
ON public.room_comments FOR INSERT TO authenticated 
WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

-- 5. Berikan hak akses
GRANT ALL ON public.room_comments TO authenticated;
GRANT SELECT ON public.room_comments TO anon;
