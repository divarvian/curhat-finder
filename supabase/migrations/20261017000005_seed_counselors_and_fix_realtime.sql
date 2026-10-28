-- ====================================================================
-- CURHAT FINDER: SEED COUNSELORS, REALTIME PROFILES, AND INTERACTION FIXES
-- ====================================================================

-- 1. Pastikan RLS profiles mengizinkan pembacaan publik untuk konselor
DROP POLICY IF EXISTS "Public profiles are viewable by authenticated users" ON public.profiles;
DROP POLICY IF EXISTS "Allow read profiles for all" ON public.profiles;
CREATE POLICY "Allow read profiles for all" ON public.profiles FOR SELECT USING (true);

-- 2. Pastikan RLS room_likes dan room_bookmarks memiliki WITH CHECK (true)
DROP POLICY IF EXISTS "Allow all on room_likes for auth users" ON public.room_likes;
DROP POLICY IF EXISTS "Allow all on room_likes" ON public.room_likes;
CREATE POLICY "Allow all on room_likes" ON public.room_likes FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow all on room_bookmarks for auth users" ON public.room_bookmarks;
DROP POLICY IF EXISTS "Allow all on room_bookmarks" ON public.room_bookmarks;
CREATE POLICY "Allow all on room_bookmarks" ON public.room_bookmarks FOR ALL USING (true) WITH CHECK (true);

-- 3. Aktifkan Replica Identity FULL pada profiles agar update realtime (termasuk is_online) disiarkan lengkap
ALTER TABLE public.profiles REPLICA IDENTITY FULL;

DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.profiles;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

-- 4. Seed user accounts untuk konselor di auth.users (Foreign Key Requirement)
INSERT INTO auth.users (
    id,
    instance_id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at
) VALUES
(
    'a1111111-1111-1111-1111-111111111101',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'counselor.dodo@ub.ac.id',
    extensions.crypt('password123', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"Kak Dodo","nickname":"Kak Dodo","role":"konselor","gender":"Laki-laki","faculty":"Fakultas Ilmu Komputer (FILKOM)"}',
    now(),
    now()
),
(
    'a1111111-1111-1111-1111-111111111102',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'counselor.leo@ub.ac.id',
    extensions.crypt('password123', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"Kak Leo","nickname":"Kak Leo","role":"konselor","gender":"Laki-laki","faculty":"Fakultas Ilmu Komputer (FILKOM)"}',
    now(),
    now()
),
(
    'a1111111-1111-1111-1111-111111111103',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'counselor.tifa@ub.ac.id',
    extensions.crypt('password123', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"Kak Tifa","nickname":"Kak Tifa","role":"konselor","gender":"Perempuan","faculty":"Fakultas Ilmu Budaya (FIB)"}',
    now(),
    now()
),
(
    'a1111111-1111-1111-1111-111111111104',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'counselor.dimas@ub.ac.id',
    extensions.crypt('password123', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"Kak Dimas","nickname":"Kak Dimas","role":"konselor","gender":"Laki-laki","faculty":"Fakultas Teknik (FT)"}',
    now(),
    now()
),
(
    'a1111111-1111-1111-1111-111111111105',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'counselor.nadia@ub.ac.id',
    extensions.crypt('password123', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"Kak Nadia","nickname":"Kak Nadia","role":"konselor","gender":"Perempuan","faculty":"Fakultas Biologi & Pertanian (FBiPK)"}',
    now(),
    now()
),
(
    'a1111111-1111-1111-1111-111111111106',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'counselor.ryan@ub.ac.id',
    extensions.crypt('password123', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"Kak dr. Ryan","nickname":"Kak Ryan","role":"konselor","gender":"Laki-laki","faculty":"Fakultas Kedokteran (FK)"}',
    now(),
    now()
)
ON CONFLICT (id) DO NOTHING;

-- 5. Seed data konselor di public.profiles
INSERT INTO public.profiles (
    id,
    role,
    full_name,
    nickname,
    gender,
    faculty,
    study_program,
    batch_year,
    hobbies,
    topics,
    is_online,
    active_sessions_count,
    total_helped_count,
    avg_response_time,
    created_at,
    updated_at
) VALUES
(
    'a1111111-1111-1111-1111-111111111101',
    'konselor',
    'Kak Dodo',
    'Kak Dodo',
    'Laki-laki',
    'Fakultas Ilmu Komputer (FILKOM)',
    'Teknik Informatika',
    '2022',
    ARRAY['Sepak Bola', 'Memasak', 'Olahraga'],
    ARRAY['Burnout', 'Overwhelmed', 'Anxiety'],
    true,
    1,
    24,
    '3m',
    now() - INTERVAL '10 days',
    now()
),
(
    'a1111111-1111-1111-1111-111111111102',
    'konselor',
    'Kak Leo',
    'Kak Leo',
    'Laki-laki',
    'Fakultas Ilmu Komputer (FILKOM)',
    'Sistem Informasi',
    '2021',
    ARRAY['Membaca', 'Gaming', 'Kopi'],
    ARRAY['Keuangan', 'Hubungan', 'Manajemen Waktu'],
    false,
    0,
    38,
    '5m',
    now() - INTERVAL '9 days',
    now()
),
(
    'a1111111-1111-1111-1111-111111111103',
    'konselor',
    'Kak Tifa',
    'Kak Tifa',
    'Perempuan',
    'Fakultas Ilmu Budaya (FIB)',
    'Sastra Inggris',
    '2022',
    ARRAY['Melukis', 'Musik', 'Menulis'],
    ARRAY['Hilang Arah', 'Hubungan', 'Keluarga'],
    true,
    0,
    42,
    '2m',
    now() - INTERVAL '8 days',
    now()
),
(
    'a1111111-1111-1111-1111-111111111104',
    'konselor',
    'Kak Dimas',
    'Kak Dimas',
    'Laki-laki',
    'Fakultas Teknik (FT)',
    'Teknik Mesin',
    '2020',
    ARRAY['Gitar', 'Fotografi', 'Otomotif'],
    ARRAY['Akademik', 'Burnout', 'Praktikum'],
    false,
    0,
    19,
    '7m',
    now() - INTERVAL '7 days',
    now()
),
(
    'a1111111-1111-1111-1111-111111111105',
    'konselor',
    'Kak Nadia',
    'Kak Nadia',
    'Perempuan',
    'Fakultas Biologi & Pertanian (FBiPK)',
    'Bioteknologi',
    '2021',
    ARRAY['Gardening', 'Podcast', 'Yoga'],
    ARRAY['Adaptasi Kampus', 'Quarter-Life Crisis', 'Homesick'],
    true,
    0,
    31,
    '4m',
    now() - INTERVAL '6 days',
    now()
),
(
    'a1111111-1111-1111-1111-111111111106',
    'konselor',
    'Kak dr. Ryan',
    'Kak Ryan',
    'Laki-laki',
    'Fakultas Kedokteran (FK)',
    'Kedokteran Umum',
    '2019',
    ARRAY['Jogging', 'Mendengarkan', 'Catur'],
    ARRAY['Stres Klinis', 'Insomnia', 'Anxiety'],
    false,
    0,
    55,
    '1m',
    now() - INTERVAL '5 days',
    now()
)
ON CONFLICT (id) DO UPDATE SET
    role = EXCLUDED.role,
    full_name = EXCLUDED.full_name,
    nickname = EXCLUDED.nickname,
    gender = EXCLUDED.gender,
    faculty = EXCLUDED.faculty,
    study_program = EXCLUDED.study_program,
    hobbies = EXCLUDED.hobbies,
    topics = EXCLUDED.topics,
    is_online = EXCLUDED.is_online,
    active_sessions_count = EXCLUDED.active_sessions_count,
    total_helped_count = EXCLUDED.total_helped_count,
    avg_response_time = EXCLUDED.avg_response_time,
    updated_at = now();
