-- Migrasi 0006: Penguatan Keamanan, Pengetatan RLS, Proteksi Role, dan Indeks Performa

-- 1. Cabut hak akses SELECT publik pada tabel profiles
DROP POLICY IF EXISTS "Allow read profiles for all" ON public.profiles;
DROP POLICY IF EXISTS "Allow all for profiles" ON public.profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Allow read counselor profiles" ON public.profiles;

-- Mahasiswa dan konselor hanya dapat melihat profil mereka sendiri
CREATE POLICY "Users can view own profile" 
ON public.profiles FOR SELECT TO authenticated 
USING (auth.uid() = id);

-- Pengguna terautentikasi dapat melihat profil konselor untuk keperluan bimbingan / SupportBuddy
CREATE POLICY "Allow read counselor profiles" 
ON public.profiles FOR SELECT TO authenticated 
USING (role = 'konselor');

-- 2. Buat PostgreSQL VIEW khusus untuk direktori konselor publik (tanpa mengekspos profil mahasiswa)
CREATE OR REPLACE VIEW public.counselor_directory WITH (security_invoker = off) AS
SELECT 
    id, 
    full_name,
    nickname, 
    gender, 
    faculty, 
    study_program, 
    topics, 
    hobbies, 
    is_online, 
    avatar_url, 
    avg_response_time, 
    total_helped_count, 
    active_sessions_count
FROM public.profiles 
WHERE role = 'konselor';

GRANT SELECT ON public.counselor_directory TO authenticated;
GRANT SELECT ON public.counselor_directory TO anon;

-- 3. Proteksi Kolom Role dari Eskalasi Hak Akses Klien
CREATE OR REPLACE FUNCTION public.prevent_profile_privilege_escalation()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.role IS DISTINCT FROM OLD.role THEN
        RAISE EXCEPTION 'Modifikasi role dilarang melalui API klien.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_prevent_profile_privilege_escalation ON public.profiles;
CREATE TRIGGER trg_prevent_profile_privilege_escalation
BEFORE UPDATE ON public.profiles
FOR EACH ROW EXECUTE FUNCTION public.prevent_profile_privilege_escalation();

-- 4. Perketat RLS Sesi Chat Anonim & Pesan Anonim
DROP POLICY IF EXISTS "Allow all for anon chat sessions" ON public.anon_chat_sessions;
DROP POLICY IF EXISTS "Allow all for anon messages" ON public.anon_messages;
DROP POLICY IF EXISTS "Participants can view own anon sessions" ON public.anon_chat_sessions;
DROP POLICY IF EXISTS "Authenticated users can create anon session" ON public.anon_chat_sessions;
DROP POLICY IF EXISTS "Participants can update own anon sessions" ON public.anon_chat_sessions;
DROP POLICY IF EXISTS "Participants can view anon messages" ON public.anon_messages;
DROP POLICY IF EXISTS "Participants can insert anon messages" ON public.anon_messages;

CREATE POLICY "Participants can view own anon sessions"
ON public.anon_chat_sessions FOR SELECT TO authenticated
USING (auth.uid() = user1_id OR auth.uid() = user2_id);

CREATE POLICY "Authenticated users can create anon session"
ON public.anon_chat_sessions FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user1_id);

CREATE POLICY "Participants can update own anon sessions"
ON public.anon_chat_sessions FOR UPDATE TO authenticated
USING (auth.uid() = user1_id OR auth.uid() = user2_id);

CREATE POLICY "Participants can view anon messages"
ON public.anon_messages FOR SELECT TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.anon_chat_sessions s
        WHERE s.id = anon_messages.session_id
        AND (s.user1_id = auth.uid() OR s.user2_id = auth.uid())
    )
);

CREATE POLICY "Participants can insert anon messages"
ON public.anon_messages FOR INSERT TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.anon_chat_sessions s
        WHERE s.id = anon_messages.session_id
        AND (s.user1_id = auth.uid() OR s.user2_id = auth.uid())
        AND s.status = 'active'
    )
);

-- 5. Perketat RLS Rooms, Room Comments, Likes, dan Bookmarks
DROP POLICY IF EXISTS "Allow all for rooms" ON public.rooms;
DROP POLICY IF EXISTS "Allow update rooms for all" ON public.rooms;
DROP POLICY IF EXISTS "Public read rooms" ON public.rooms;
DROP POLICY IF EXISTS "Authenticated users insert rooms" ON public.rooms;
DROP POLICY IF EXISTS "Authors update own rooms" ON public.rooms;
DROP POLICY IF EXISTS "Authors delete own rooms" ON public.rooms;

CREATE POLICY "Public read rooms" 
ON public.rooms FOR SELECT USING (true);

CREATE POLICY "Authenticated users insert rooms" 
ON public.rooms FOR INSERT TO authenticated 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Authors update own rooms" 
ON public.rooms FOR UPDATE TO authenticated 
USING (auth.uid() = user_id) 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Authors delete own rooms" 
ON public.rooms FOR DELETE TO authenticated 
USING (auth.uid() = user_id);

-- Room Comments
DROP POLICY IF EXISTS "Allow all for room_comments" ON public.room_comments;
DROP POLICY IF EXISTS "Public read room comments" ON public.room_comments;
DROP POLICY IF EXISTS "Authenticated users insert comments" ON public.room_comments;
DROP POLICY IF EXISTS "Authors delete own comments" ON public.room_comments;

CREATE POLICY "Public read room comments" 
ON public.room_comments FOR SELECT USING (true);

CREATE POLICY "Authenticated users insert comments" 
ON public.room_comments FOR INSERT TO authenticated 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Authors delete own comments" 
ON public.room_comments FOR DELETE TO authenticated 
USING (auth.uid() = user_id);

-- Room Likes
DROP POLICY IF EXISTS "Allow all for room_likes" ON public.room_likes;
DROP POLICY IF EXISTS "Users view own room likes" ON public.room_likes;
DROP POLICY IF EXISTS "Users insert own room likes" ON public.room_likes;
DROP POLICY IF EXISTS "Users delete own room likes" ON public.room_likes;

CREATE POLICY "Users view own room likes" 
ON public.room_likes FOR SELECT TO authenticated 
USING (auth.uid() = user_id);

CREATE POLICY "Users insert own room likes" 
ON public.room_likes FOR INSERT TO authenticated 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users delete own room likes" 
ON public.room_likes FOR DELETE TO authenticated 
USING (auth.uid() = user_id);

-- Room Bookmarks
DROP POLICY IF EXISTS "Allow all for room_bookmarks" ON public.room_bookmarks;
DROP POLICY IF EXISTS "Users view own room bookmarks" ON public.room_bookmarks;
DROP POLICY IF EXISTS "Users insert own room bookmarks" ON public.room_bookmarks;
DROP POLICY IF EXISTS "Users delete own room bookmarks" ON public.room_bookmarks;

CREATE POLICY "Users view own room bookmarks" 
ON public.room_bookmarks FOR SELECT TO authenticated 
USING (auth.uid() = user_id);

CREATE POLICY "Users insert own room bookmarks" 
ON public.room_bookmarks FOR INSERT TO authenticated 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users delete own room bookmarks" 
ON public.room_bookmarks FOR DELETE TO authenticated 
USING (auth.uid() = user_id);

-- 6. Tambahkan Indeks Performa Tinggi untuk Skalabilitas
CREATE INDEX IF NOT EXISTS idx_counseling_queues_status_counselor 
ON public.counseling_queues (status, assigned_counselor_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_chat_messages_session_time 
ON public.chat_messages (session_id, created_at ASC);

CREATE INDEX IF NOT EXISTS idx_anon_messages_session_time 
ON public.anon_messages (session_id, created_at ASC);

CREATE INDEX IF NOT EXISTS idx_room_comments_room_time 
ON public.room_comments (room_id, created_at ASC);

CREATE INDEX IF NOT EXISTS idx_rooms_category_time 
ON public.rooms (category, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_tips_category_time 
ON public.tips (category, created_at DESC);
