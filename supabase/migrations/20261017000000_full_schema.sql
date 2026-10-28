-- ====================================================================
-- CURHAT FINDER: FULL DATABASE SCHEMA & REALTIME SETUP FOR SUPABASE
-- ====================================================================

-- 1. ENUMS
DO $$ BEGIN
    CREATE TYPE user_role AS ENUM ('mahasiswa', 'konselor', 'admin');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE queue_status AS ENUM ('waiting', 'accepted', 'completed', 'cancelled');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE session_status AS ENUM ('active', 'completed', 'cancelled');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE sender_role_type AS ENUM ('student', 'counselor', 'system');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 2. PROFILES TABLE
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    role user_role NOT NULL DEFAULT 'mahasiswa',
    full_name TEXT NOT NULL,
    nickname TEXT,
    gender TEXT,
    batch_year TEXT,
    faculty TEXT,
    study_program TEXT,
    avatar_url TEXT,
    hobbies TEXT[] DEFAULT '{}',
    topics TEXT[] DEFAULT '{}',
    is_online BOOLEAN DEFAULT false,
    active_sessions_count INT DEFAULT 0,
    total_helped_count INT DEFAULT 0,
    avg_response_time TEXT DEFAULT '0m',
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 3. COUNSELING QUEUES (Antrean Mahasiswa)
CREATE TABLE IF NOT EXISTS public.counseling_queues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    student_alias TEXT NOT NULL DEFAULT 'Anonym',
    student_gender TEXT NOT NULL DEFAULT 'Perempuan',
    student_faculty TEXT NOT NULL DEFAULT 'FILKOM',
    preferred_topic TEXT,
    status queue_status NOT NULL DEFAULT 'waiting',
    assigned_counselor_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 4. COUNSELING SESSIONS (Sesi Bimbingan Aktif)
CREATE TABLE IF NOT EXISTS public.counseling_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    queue_id UUID REFERENCES public.counseling_queues(id) ON DELETE SET NULL,
    student_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    counselor_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    student_alias TEXT NOT NULL,
    student_faculty TEXT NOT NULL,
    status session_status NOT NULL DEFAULT 'active',
    started_at TIMESTAMPTZ DEFAULT now(),
    ended_at TIMESTAMPTZ
);

-- 5. CHAT MESSAGES
CREATE TABLE IF NOT EXISTS public.chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES public.counseling_sessions(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    sender_role sender_role_type NOT NULL,
    message_text TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 6. JOURNALS (Kalender Mood & Refleksi Harian)
CREATE TABLE IF NOT EXISTS public.journals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    mood_index INT NOT NULL CHECK (mood_index BETWEEN 0 AND 4),
    mood_note TEXT,
    entry_date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 7. SAMBATS (Ruang Curhat / Venting Publik)
CREATE TABLE IF NOT EXISTS public.sambats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    category TEXT DEFAULT 'Lainnya',
    is_anonymous BOOLEAN DEFAULT true,
    cheer_count INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 8. FORUM & CREATOR POSTS
CREATE TABLE IF NOT EXISTS public.forum_posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    author_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    author_name TEXT NOT NULL,
    author_role TEXT NOT NULL,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    category TEXT DEFAULT 'Edukasi',
    likes_count INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 9. PEER ANON QUEUE (Matching Acak Teman Cerita)
CREATE TABLE IF NOT EXISTS public.peer_anon_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES public.profiles(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'searching' CHECK (status IN ('searching', 'matched', 'cancelled')),
    matched_session_id UUID,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- ====================================================================
-- AUTOMATIC TRIGGER FOR USER REGISTRATION (auth.users -> profiles)
-- ====================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (
        id,
        role,
        full_name,
        nickname,
        gender,
        batch_year,
        faculty,
        study_program,
        hobbies,
        topics,
        is_online
    ) VALUES (
        NEW.id,
        COALESCE((NEW.raw_user_meta_data->>'role')::user_role, 'mahasiswa'::user_role),
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'Pengguna Baru'),
        NEW.raw_user_meta_data->>'nickname',
        NEW.raw_user_meta_data->>'gender',
        NEW.raw_user_meta_data->>'batch_year',
        NEW.raw_user_meta_data->>'faculty',
        NEW.raw_user_meta_data->>'study_program',
        ARRAY(SELECT jsonb_array_elements_text(COALESCE(NEW.raw_user_meta_data->'hobbies', '[]'::jsonb))),
        ARRAY(SELECT jsonb_array_elements_text(COALESCE(NEW.raw_user_meta_data->'topics', '[]'::jsonb))),
        CASE WHEN (NEW.raw_user_meta_data->>'role') = 'konselor' THEN true ELSE false END
    )
    ON CONFLICT (id) DO UPDATE SET
        full_name = EXCLUDED.full_name,
        role = EXCLUDED.role,
        updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ====================================================================
-- REALTIME REPLICATION CONFIGURATION
-- ====================================================================
DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.profiles;
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.counseling_queues;
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.counseling_sessions;
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.chat_messages;
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.sambats;
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.peer_anon_queue;
EXCEPTION WHEN duplicate_object THEN null; END $$;

-- ====================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ====================================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public profiles are viewable by authenticated users" ON public.profiles;
CREATE POLICY "Public profiles are viewable by authenticated users" ON public.profiles FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE TO authenticated USING (auth.uid() = id);

ALTER TABLE public.counseling_queues ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Students can view and create their own queues" ON public.counseling_queues;
CREATE POLICY "Students can view and create their own queues" ON public.counseling_queues FOR ALL TO authenticated USING (auth.uid() = student_id);

DROP POLICY IF EXISTS "Counselors can view and accept queues" ON public.counseling_queues;
CREATE POLICY "Counselors can view and accept queues" ON public.counseling_queues FOR ALL TO authenticated USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'konselor')
);

ALTER TABLE public.counseling_sessions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Participants can view and update their sessions" ON public.counseling_sessions;
CREATE POLICY "Participants can view and update their sessions" ON public.counseling_sessions FOR ALL TO authenticated USING (
    auth.uid() = student_id OR auth.uid() = counselor_id
);

ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Participants can view and send messages" ON public.chat_messages;
CREATE POLICY "Participants can view and send messages" ON public.chat_messages FOR ALL TO authenticated USING (
    EXISTS (
        SELECT 1 FROM public.counseling_sessions s 
        WHERE s.id = session_id AND (s.student_id = auth.uid() OR s.counselor_id = auth.uid())
    )
);

ALTER TABLE public.journals ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can manage own journals" ON public.journals;
CREATE POLICY "Users can manage own journals" ON public.journals FOR ALL TO authenticated USING (auth.uid() = user_id);

ALTER TABLE public.sambats ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view sambats" ON public.sambats;
CREATE POLICY "Anyone can view sambats" ON public.sambats FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "Users can create sambats" ON public.sambats;
CREATE POLICY "Users can create sambats" ON public.sambats FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can cheer sambats" ON public.sambats;
CREATE POLICY "Users can cheer sambats" ON public.sambats FOR UPDATE TO authenticated USING (true);

-- Storage bucket setup for avatars
INSERT INTO storage.buckets (id, name, public) 
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "Avatar images are publicly accessible" ON storage.objects;
CREATE POLICY "Avatar images are publicly accessible" ON storage.objects FOR SELECT USING (bucket_id = 'avatars');

DROP POLICY IF EXISTS "Authenticated users can upload avatar" ON storage.objects;
CREATE POLICY "Authenticated users can upload avatar" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'avatars');
