-- ====================================================================
-- CURHAT FINDER: COMPLETE FRESH ORGANIC SEEDER MIGRATION
-- 1. Pembersihan total data lama (fresh drop)
-- 2. Standarisasi kredensial: password '12345678', email @demo.ub.ac.id
-- 3. Nama natural tanpa 'Kak' untuk konselor dan mahasiswa
-- 4. Pulse lengkap untuk seluruh 18 fakultas + kontak darurat resmi UB
-- 5. Rooms, Tips, Sesi Chat, Likes & Komentar 100% organik terhubung
-- ====================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- --------------------------------------------------------------------
-- 1. BERSIHKAN SELURUH DATA LAMA SECARA BERURUTAN
-- --------------------------------------------------------------------
DO $$ 
BEGIN
    DELETE FROM public.chat_messages;
    DELETE FROM public.counseling_sessions;
    DELETE FROM public.counseling_queues;
    
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'anon_messages') THEN
        DELETE FROM public.anon_messages;
    END IF;
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'anon_reports') THEN
        DELETE FROM public.anon_reports;
    END IF;
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'anon_chat_sessions') THEN
        DELETE FROM public.anon_chat_sessions;
    END IF;
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'user_private_sambats') THEN
        DELETE FROM public.user_private_sambats;
    END IF;
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'sambats') THEN
        DELETE FROM public.sambats;
    END IF;
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'peer_anon_queue') THEN
        DELETE FROM public.peer_anon_queue;
    END IF;
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'counselor_articles') THEN
        DELETE FROM public.counselor_articles;
    END IF;
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'counselor_forums') THEN
        DELETE FROM public.counselor_forums;
    END IF;
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'forum_posts') THEN
        DELETE FROM public.forum_posts;
    END IF;

    DELETE FROM public.room_comments;
    DELETE FROM public.room_likes;
    DELETE FROM public.room_bookmarks;
    DELETE FROM public.rooms;
    DELETE FROM public.tip_likes;
    DELETE FROM public.tip_bookmarks;
    DELETE FROM public.tips;
    DELETE FROM public.journals;
    DELETE FROM public.pulse_contacts;
    DELETE FROM public.profiles;
    DELETE FROM auth.users;
END $$;

-- --------------------------------------------------------------------
-- 2. SEED AUTH USERS (6 Konselor Resmi + 12 Mahasiswa Organik)
-- Seluruh password: '12345678', email: *@demo.ub.ac.id
-- --------------------------------------------------------------------

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
-- === KONSELOR (6 Akun) ===
(
    'c0000001-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'sarah.amalia@demo.ub.ac.id',
    extensions.crypt('12345678', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"Sarah Amalia","nickname":"Sarah","role":"konselor","gender":"Perempuan","faculty":"Fakultas Ilmu Sosial dan Ilmu Politik (FISIP)","study_program":"S1 Psikologi","batch_year":"2022","is_verified":true,"counselor_status":"approved"}',
    now(),
    now()
),
(
    'c0000001-0000-0000-0000-000000000002',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'dodo.pratama@demo.ub.ac.id',
    extensions.crypt('12345678', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"Dodo Pratama","nickname":"Dodo","role":"konselor","gender":"Laki-laki","faculty":"Fakultas Ilmu Komputer (FILKOM)","study_program":"S1 Teknik Informatika","batch_year":"2021","is_verified":true,"counselor_status":"approved"}',
    now(),
    now()
),
(
    'c0000001-0000-0000-0000-000000000003',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'dimas.setiawan@demo.ub.ac.id',
    extensions.crypt('12345678', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"Dimas Setiawan","nickname":"Dimas","role":"konselor","gender":"Laki-laki","faculty":"Fakultas Teknik (FT)","study_program":"S1 Teknik Industri","batch_year":"2021","is_verified":true,"counselor_status":"approved"}',
    now(),
    now()
),
(
    'c0000001-0000-0000-0000-000000000004',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'nadia.salsabila@demo.ub.ac.id',
    extensions.crypt('12345678', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"Nadia Salsabila","nickname":"Nadia","role":"konselor","gender":"Perempuan","faculty":"Fakultas Kedokteran (FK)","study_program":"S1 Kedokteran","batch_year":"2022","is_verified":true,"counselor_status":"approved"}',
    now(),
    now()
),
(
    'c0000001-0000-0000-0000-000000000005',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'tifa.faradiba@demo.ub.ac.id',
    extensions.crypt('12345678', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"Tifa Faradiba","nickname":"Tifa","role":"konselor","gender":"Perempuan","faculty":"Fakultas Ilmu Budaya (FIB)","study_program":"S1 Sastra Inggris","batch_year":"2022","is_verified":true,"counselor_status":"approved"}',
    now(),
    now()
),
(
    'c0000001-0000-0000-0000-000000000006',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'rizky.maulana@demo.ub.ac.id',
    extensions.crypt('12345678', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"Rizky Maulana","nickname":"Rizky","role":"konselor","gender":"Laki-laki","faculty":"Fakultas Ekonomi dan Bisnis (FEB)","study_program":"S1 Manajemen","batch_year":"2021","is_verified":true,"counselor_status":"approved"}',
    now(),
    now()
),

-- === MAHASISWA ORGANIK (12 Akun Lintas Fakultas) ===
(
    'e0000001-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'budi.santoso@demo.ub.ac.id',
    extensions.crypt('12345678', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"Budi Santoso","nickname":"Budi","role":"mahasiswa","gender":"Laki-laki","faculty":"FILKOM","study_program":"S1 Sistem Informasi","batch_year":"2023"}',
    now(),
    now()
),
(
    'e0000001-0000-0000-0000-000000000002',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'citra.lestari@demo.ub.ac.id',
    extensions.crypt('12345678', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"Citra Lestari","nickname":"Citra","role":"mahasiswa","gender":"Perempuan","faculty":"FIA","study_program":"S1 Ilmu Administrasi Bisnis","batch_year":"2024"}',
    now(),
    now()
),
(
    'e0000001-0000-0000-0000-000000000003',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'fajar.ramadhan@demo.ub.ac.id',
    extensions.crypt('12345678', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"Fajar Ramadhan","nickname":"Fajar","role":"mahasiswa","gender":"Laki-laki","faculty":"FT","study_program":"S1 Teknik Mesin","batch_year":"2022"}',
    now(),
    now()
),
(
    'e0000001-0000-0000-0000-000000000004',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'anisa.rahma@demo.ub.ac.id',
    extensions.crypt('12345678', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"Anisa Rahma","nickname":"Anisa","role":"mahasiswa","gender":"Perempuan","faculty":"FEB","study_program":"S1 Akuntansi","batch_year":"2023"}',
    now(),
    now()
),
(
    'e0000001-0000-0000-0000-000000000005',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'kevin.wijaya@demo.ub.ac.id',
    extensions.crypt('12345678', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"Kevin Wijaya","nickname":"Kevin","role":"mahasiswa","gender":"Laki-laki","faculty":"FH","study_program":"S1 Ilmu Hukum","batch_year":"2023"}',
    now(),
    now()
),
(
    'e0000001-0000-0000-0000-000000000006',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'putri.handayani@demo.ub.ac.id',
    extensions.crypt('12345678', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"Putri Handayani","nickname":"Putri","role":"mahasiswa","gender":"Perempuan","faculty":"FBiPK","study_program":"S1 Agribisnis","batch_year":"2024"}',
    now(),
    now()
),
(
    'e0000001-0000-0000-0000-000000000007',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'dewa.pratama@demo.ub.ac.id',
    extensions.crypt('12345678', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"Dewa Pratama","nickname":"Dewa","role":"mahasiswa","gender":"Laki-laki","faculty":"FK","study_program":"S1 Kedokteran","batch_year":"2022"}',
    now(),
    now()
),
(
    'e0000001-0000-0000-0000-000000000008',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'maya.anggraini@demo.ub.ac.id',
    extensions.crypt('12345678', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"Maya Anggraini","nickname":"Maya","role":"mahasiswa","gender":"Perempuan","faculty":"FIB","study_program":"S1 Sastra Jepang","batch_year":"2023"}',
    now(),
    now()
),
(
    'e0000001-0000-0000-0000-000000000009',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'ilham.saputra@demo.ub.ac.id',
    extensions.crypt('12345678', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"Ilham Saputra","nickname":"Ilham","role":"mahasiswa","gender":"Laki-laki","faculty":"FAST","study_program":"S1 Peternakan","batch_year":"2024"}',
    now(),
    now()
),
(
    'e0000001-0000-0000-0000-000000000010',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'nabila.zahra@demo.ub.ac.id',
    extensions.crypt('12345678', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"Nabila Zahra","nickname":"Nabila","role":"mahasiswa","gender":"Perempuan","faculty":"FIKES","study_program":"S1 Ilmu Keperawatan","batch_year":"2023"}',
    now(),
    now()
),
(
    'e0000001-0000-0000-0000-000000000011',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'rian.hidayat@demo.ub.ac.id',
    extensions.crypt('12345678', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"Rian Hidayat","nickname":"Rian","role":"mahasiswa","gender":"Laki-laki","faculty":"FV","study_program":"D4 Manajemen Perhotelan","batch_year":"2022"}',
    now(),
    now()
),
(
    'e0000001-0000-0000-0000-000000000012',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'tiara.kusuma@demo.ub.ac.id',
    extensions.crypt('12345678', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"Tiara Kusuma","nickname":"Tiara","role":"mahasiswa","gender":"Perempuan","faculty":"FPIK","study_program":"S1 Ilmu Kelautan","batch_year":"2024"}',
    now(),
    now()
)
ON CONFLICT (id) DO NOTHING;

-- Seed auth.identities agar GoTrue Auth Engine dapat mengautentikasi seluruh user demo via email/password
INSERT INTO auth.identities (
    id,
    user_id,
    identity_data,
    provider,
    provider_id,
    last_sign_in_at,
    created_at,
    updated_at
)
SELECT
    id,
    id,
    jsonb_build_object('sub', id::text, 'email', email),
    'email',
    id::text,
    now(),
    created_at,
    updated_at
FROM auth.users
ON CONFLICT (provider_id, provider) DO NOTHING;

-- --------------------------------------------------------------------
-- 3. PERBARUI & LENGKAPI PROFILES SECARA DETAIL
-- --------------------------------------------------------------------

-- Profil Konselor (Approved, Verified, Online, Rating, Avatar Realistis)
UPDATE public.profiles SET
    avatar_url = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80',
    topics = ARRAY['Relasi & Hubungan', 'Anxiety', 'Keluarga'],
    is_online = true,
    is_verified = true,
    counselor_status = 'approved',
    active_sessions_count = 1,
    total_helped_count = 42,
    avg_response_time = '3m'
WHERE id = 'c0000001-0000-0000-0000-000000000001';

UPDATE public.profiles SET
    avatar_url = 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop&q=80',
    topics = ARRAY['Overwhelmed', 'Burnout', 'Akademik'],
    is_online = true,
    is_verified = true,
    counselor_status = 'approved',
    active_sessions_count = 0,
    total_helped_count = 58,
    avg_response_time = '5m'
WHERE id = 'c0000001-0000-0000-0000-000000000002';

UPDATE public.profiles SET
    avatar_url = 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&auto=format&fit=crop&q=80',
    topics = ARRAY['Karier', 'Manajemen Waktu', 'Overwhelmed'],
    is_online = true,
    is_verified = true,
    counselor_status = 'approved',
    active_sessions_count = 0,
    total_helped_count = 35,
    avg_response_time = '4m'
WHERE id = 'c0000001-0000-0000-0000-000000000003';

UPDATE public.profiles SET
    avatar_url = 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400&auto=format&fit=crop&q=80',
    topics = ARRAY['Mental Health', 'Burnout', 'Overwhelmed'],
    is_online = true,
    is_verified = true,
    counselor_status = 'approved',
    active_sessions_count = 0,
    total_helped_count = 61,
    avg_response_time = '2m'
WHERE id = 'c0000001-0000-0000-0000-000000000004';

UPDATE public.profiles SET
    avatar_url = 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&auto=format&fit=crop&q=80',
    topics = ARRAY['Hilang arah', 'Relasi & Hubungan', 'Anxiety'],
    is_online = false,
    is_verified = true,
    counselor_status = 'approved',
    active_sessions_count = 0,
    total_helped_count = 29,
    avg_response_time = '5m'
WHERE id = 'c0000001-0000-0000-0000-000000000005';

UPDATE public.profiles SET
    avatar_url = 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&auto=format&fit=crop&q=80',
    topics = ARRAY['Keuangan', 'Karier', 'Hilang arah'],
    is_online = true,
    is_verified = true,
    counselor_status = 'approved',
    active_sessions_count = 0,
    total_helped_count = 37,
    avg_response_time = '4m'
WHERE id = 'c0000001-0000-0000-0000-000000000006';

-- Profil Mahasiswa (Avatar, Hobi, Online Status)
UPDATE public.profiles SET
    avatar_url = 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400&auto=format&fit=crop&q=80',
    hobbies = ARRAY['Gaming', 'Musik', 'Seni'],
    is_online = true,
    is_verified = true
WHERE id = 'e0000001-0000-0000-0000-000000000001';

UPDATE public.profiles SET
    avatar_url = 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400&auto=format&fit=crop&q=80',
    hobbies = ARRAY['Membaca', 'Traveling', 'Fotografi'],
    is_online = true,
    is_verified = true
WHERE id = 'e0000001-0000-0000-0000-000000000002';

UPDATE public.profiles SET
    avatar_url = 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=400&auto=format&fit=crop&q=80',
    hobbies = ARRAY['Olahraga', 'Gaming', 'Film'],
    is_online = false,
    is_verified = true
WHERE id = 'e0000001-0000-0000-0000-000000000003';

UPDATE public.profiles SET
    avatar_url = 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&auto=format&fit=crop&q=80',
    hobbies = ARRAY['Kuliner', 'Menulis', 'Musik'],
    is_online = true,
    is_verified = true
WHERE id = 'e0000001-0000-0000-0000-000000000004';

UPDATE public.profiles SET
    avatar_url = 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=400&auto=format&fit=crop&q=80',
    hobbies = ARRAY['Olahraga', 'Membaca', 'Film'],
    is_online = false,
    is_verified = true
WHERE id = 'e0000001-0000-0000-0000-000000000005';

UPDATE public.profiles SET
    avatar_url = 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400&auto=format&fit=crop&q=80',
    hobbies = ARRAY['Seni', 'Traveling', 'Fotografi'],
    is_online = true,
    is_verified = true
WHERE id = 'e0000001-0000-0000-0000-000000000006';

UPDATE public.profiles SET
    avatar_url = 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=400&auto=format&fit=crop&q=80',
    hobbies = ARRAY['Musik', 'Olahraga', 'Membaca'],
    is_online = false,
    is_verified = true
WHERE id = 'e0000001-0000-0000-0000-000000000007';

UPDATE public.profiles SET
    avatar_url = 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=400&auto=format&fit=crop&q=80',
    hobbies = ARRAY['Seni', 'Menulis', 'Film'],
    is_online = true,
    is_verified = true
WHERE id = 'e0000001-0000-0000-0000-000000000008';

UPDATE public.profiles SET
    avatar_url = 'https://images.unsplash.com/photo-1480429370139-e0132c086e2a?w=400&auto=format&fit=crop&q=80',
    hobbies = ARRAY['Olahraga', 'Traveling', 'Gaming'],
    is_online = false,
    is_verified = true
WHERE id = 'e0000001-0000-0000-0000-000000000009';

UPDATE public.profiles SET
    avatar_url = 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=400&auto=format&fit=crop&q=80',
    hobbies = ARRAY['Membaca', 'Kuliner', 'Seni'],
    is_online = true,
    is_verified = true
WHERE id = 'e0000001-0000-0000-0000-000000000010';

UPDATE public.profiles SET
    avatar_url = 'https://images.unsplash.com/photo-1501196354995-cbb51c65aaea?w=400&auto=format&fit=crop&q=80',
    hobbies = ARRAY['Kuliner', 'Fotografi', 'Musik'],
    is_online = false,
    is_verified = true
WHERE id = 'e0000001-0000-0000-0000-000000000011';

UPDATE public.profiles SET
    avatar_url = 'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?w=400&auto=format&fit=crop&q=80',
    hobbies = ARRAY['Traveling', 'Seni', 'Fotografi'],
    is_online = true,
    is_verified = true
WHERE id = 'e0000001-0000-0000-0000-000000000012';

-- --------------------------------------------------------------------
-- 4. SEED PULSE CONTACTS (Kontak Darurat + Seluruh 18 Fakultas UB Asli)
-- --------------------------------------------------------------------

INSERT INTO public.pulse_contacts (
    name,
    faculty,
    phone,
    whatsapp_number,
    description,
    is_emergency,
    display_order
) VALUES
-- Layanan Darurat & Nasional (Kategori 'Semua')
(
    'HopeHelps UB (Unit Cepat Tanggap Krisis Psikologis & Kekerasan Seksual 24/7)',
    'Semua',
    '0851-5833-7959',
    '6285158337959',
    'Layanan respons cepat pendampingan krisis psikologis darurat, pencegahan perundungan, dan kekerasan seksual 24/7. Ketik pesan dengan format "Emergency".',
    true,
    1
),
(
    'Lembaga Konseling Mahasiswa (LKM) UB',
    'Semua',
    '0811-3716-113',
    '628113716113',
    'Subdirektorat Konseling & Kesejahteraan Kemahasiswaan UB. Pendaftaran konseling psikolog kampus online via konseling.ub.ac.id.',
    false,
    2
),
(
    'IGD RS Universitas Brawijaya (24 Jam)',
    'Semua',
    '(0341) 4372409',
    '628113699962',
    'Instalasi Gawat Darurat (IGD) Rumah Sakit Universitas Brawijaya melayani medis & kegawatdaruratan 24 Jam. Jl. Soekarno Hatta, Malang.',
    true,
    3
),
(
    'Hotline Sejiwa Kemenkes RI (24 Jam Bebas Pulsa)',
    'Semua',
    '119 ext 8',
    '62811979119',
    'Layanan krisis kesehatan jiwa dan pencegahan bunuh diri nasional Kemenkes RI. Bebas pulsa 24 jam.',
    true,
    4
),

-- 18 Fakultas Resmi Universitas Brawijaya
(
    'Unit Bimbingan Konseling & Kemahasiswaan FILKOM UB',
    'FILKOM',
    '(0341) 577911',
    '6281132299552',
    'Layanan konseling sebaya, konsultasi studi akademik, dan ULTKSP FILKOM UB (pendaftaran via s.ub.ac.id/konselingfilkom).',
    false,
    5
),
(
    'ULKPKS & Unit Layanan Terpadu Fakultas Teknik UB',
    'FT',
    '(0341) 587710',
    '628557612300',
    'Unit Layanan Konseling, Perundungan, dan Kekerasan Seksual (ULKPKS) Gedung Dekanat FT Lantai 1 (teknik.ub.ac.id).',
    false,
    6
),
(
    'Unit Bimbingan Konseling & Kemahasiswaan FH UB',
    'FH',
    '(0341) 553898',
    '6285158337959',
    'Layanan pendampingan akademik, advokasi kemahasiswaan, dan konseling mahasiswa Fakultas Hukum UB.',
    false,
    7
),
(
    'ULKPKS & Layanan Konseling Mahasiswa FEB UB',
    'FEB',
    '(0341) 555000',
    '6285284927433',
    'Layanan konseling psikologis rahasia ULKPKS FEB UB (ulkpks-feb.ub.ac.id) & Layanan Kemahasiswaan Gedung Utama Lt. 2.',
    false,
    8
),
(
    'Badan Konseling Mahasiswa (BKM) FIA UB',
    'FIA',
    '(0341) 553737',
    '6285158337959',
    'Pusat Layanan Terpadu Gedung B Lantai 1 FIA UB, pendampingan akademik, stres skripsi, dan konseling pribadi.',
    false,
    9
),
(
    'Unit Layanan Terpadu & Pendampingan FP / FBiPK UB',
    'FBiPK',
    '(0341) 551611',
    '6285167052268',
    'Layanan pendampingan bimbingan akademik, konseling mahasiswa, dan ULT FP / FBiPK Universitas Brawijaya.',
    false,
    10
),
(
    'Badan Layanan Mahasiswa Terpadu (BLMT) FAST / Fapet UB',
    'FAST',
    '(0341) 553513',
    '6282223332115',
    'Layanan bimbingan konseling sebaya, konsultasi studi, dan penanganan kemahasiswaan FAST / Fapet UB.',
    false,
    11
),
(
    'ULTKSP & Unit Penanganan Krisis Fakultas Kedokteran UB',
    'FK',
    '(0341) 569117',
    '6282240043900',
    'Unit krisis psikologis, bimbingan konseling mahasiswa kesehatan, dan hotline ULTKSP Fakultas Kedokteran UB.',
    false,
    12
),
(
    'Unit Layanan Terpadu & Konseling Mahasiswa FPIK UB',
    'FPIK',
    '(0341) 553512',
    '6285158337959',
    'Layanan pendampingan studi, bimbingan konseling, dan ULTKSP Fakultas Perikanan dan Ilmu Kelautan UB.',
    false,
    13
),
(
    'ULKPKS & Layanan Konseling FSTeM / FMIPA UB',
    'FSTeM',
    '(0341) 554403',
    '628113716113',
    'Gedung Graha Sainta Lt. 3, penanganan konseling (s.ub.ac.id/layanankpks) dan perundungan mahasiswa FSTeM UB.',
    false,
    14
),
(
    'Badan Konseling & Pertimbangan Akademik (BKPA) FTAB / FTP UB',
    'FTAB',
    '(0341) 580106',
    '6282313136258',
    'Unit Layanan Konseling & Pengembangan Karakter (ulkpk-ftab.ub.ac.id) Fakultas Teknologi Pertanian UB.',
    false,
    15
),
(
    'ULTKSP & Layanan Konseling Fakultas Ilmu Budaya UB',
    'FIB',
    '(0341) 551611',
    '6285648786182',
    'Hotline pendampingan konseling psikologis, pencegahan perundungan, dan ULTKSP Fakultas Ilmu Budaya UB.',
    false,
    16
),
(
    'ULTKSP & Layanan Konseling Psikososial FISIP UB',
    'FISIP',
    '(0341) 551611',
    '628561366166',
    'Layanan pendampingan psikososial rahasia, konseling, dan respons kekerasan seksual FISIP Universitas Brawijaya.',
    false,
    17
),
(
    'ULTKSP & Unit Konseling Fakultas Kedokteran Hewan UB',
    'FKH',
    '(0341) 551611',
    '6282141755757',
    'Layanan hotline bimbingan konseling dan ULTKSP Fakultas Kedokteran Hewan Universitas Brawijaya.',
    false,
    18
),
(
    'ULTKSP & Layanan Konseling Fakultas Kedokteran Gigi UB',
    'FKG',
    '(0341) 551611',
    '6281365084888',
    'Hotline pengaduan dan pendampingan konseling mahasiswa Fakultas Kedokteran Gigi Universitas Brawijaya.',
    false,
    19
),
(
    'Unit Layanan Terpadu & Konseling Fakultas Vokasi UB',
    'FV',
    '(0341) 553240',
    '6289652944096',
    'Layanan terpadu akademik, bimbingan konseling karir dan pribadi mahasiswa Fakultas Vokasi Universitas Brawijaya.',
    false,
    20
),
(
    'Unit Bimbingan Konseling Fakultas Ilmu Kesehatan UB',
    'FIKES',
    '(0341) 5080686',
    '6285158337959',
    'Gedung A Lantai 2 FIKES UB Kampus Puncak Dieng, layanan pendampingan psikologis mahasiswa ilmu kesehatan.',
    false,
    21
),
(
    'Layanan Bimbingan Konseling Sekolah Pascasarjana UB',
    'SP',
    '(0341) 571260',
    '628113716113',
    'Gedung Pascasarjana Jl. MT Haryono 169 Malang, pendampingan studi dan konseling mahasiswa magister & doktor UB.',
    false,
    22
);

-- --------------------------------------------------------------------
-- 4.5 SINKRONISASI CONSTRAINT KATEGORI DENGAN APPCATEGORIES
-- --------------------------------------------------------------------
ALTER TABLE public.rooms DROP CONSTRAINT IF EXISTS rooms_category_check;
ALTER TABLE public.rooms ADD CONSTRAINT rooms_category_check 
    CHECK (category IN ('Akademik', 'Kesepian', 'Keuangan', 'Relasi & Hubungan', 'Mental Health', 'Keluarga', 'Lainnya', 'Hubungan'));

ALTER TABLE public.tips DROP CONSTRAINT IF EXISTS tips_category_check;
ALTER TABLE public.tips ADD CONSTRAINT tips_category_check 
    CHECK (category IN ('Self-care', 'Productivity', 'Afirmasi', 'Musik', 'Curhat', 'Akademik', 'Manajemen Waktu', 'Relasi', 'Mental Health', 'Lainnya'));

-- --------------------------------------------------------------------
-- 5. SEED ROOMS (Curhat Komunitas) Lengkap 7 Kategori Resmi
-- --------------------------------------------------------------------

INSERT INTO public.rooms (
    id,
    user_id,
    author_name,
    author_faculty,
    category,
    title,
    content,
    likes_count,
    comments_count,
    created_at
) VALUES
(
    'a0000001-0000-0000-0000-000000000001',
    'e0000001-0000-0000-0000-000000000001', -- Budi Santoso
    'Budi Santoso',
    'FILKOM',
    'Akademik',
    'Kewalahan tugas akhir semester dan proyek barengan',
    'Lagi di fase serba mepet. Tugas pemrograman web, riset basis data, sama persiapan magang datang di minggu yang sama. Rasanya jam tidur berkurang drastis dan kepala rasanya penuh terus. Ada teman-teman yang punya strategi biar ngga gampang burnout saat deadline bertubi-tubi?',
    4,
    3,
    now() - interval '4 hours'
),
(
    'a0000001-0000-0000-0000-000000000002',
    'e0000001-0000-0000-0000-000000000002', -- Citra Lestari
    'Citra Lestari',
    'FIA',
    'Kesepian',
    'Anak rantau semester awal, kadang ngerasa sepi banget di kosan',
    'Udah 4 bulan merantau di Malang, tapi tiap balik ke kamar kos setelah kelas sore suka ngerasa hampa. Teman-teman sekelas ramah, tapi belum nemu yang bener-bener sefrekuensi buat cerita dari hati ke hati. Normal ngga sih fase adaptasi ini?',
    5,
    3,
    now() - interval '10 hours'
),
(
    'a0000001-0000-0000-0000-000000000003',
    'e0000001-0000-0000-0000-000000000004', -- Anisa Rahma
    'Anisa Rahma',
    'FEB',
    'Keuangan',
    'Ngelola uang bulanan pas-pasan di akhir bulan',
    'Bulan ini banyak pengeluaran tak terduga buat praktikum dan iuran kelompok. Masih ada 10 hari lagi tapi tabungan udah menipis. Mau minta ke orang tua ngerasa ngga enak karena tahu kondisi di rumah lagi pas-pasan juga. Ada rekomendasi side income yang fleksibel buat mahasiswa?',
    3,
    2,
    now() - interval '1 day'
),
(
    'a0000001-0000-0000-0000-000000000004',
    'e0000001-0000-0000-0000-000000000003', -- Fajar Ramadhan
    'Fajar Ramadhan',
    'FT',
    'Mental Health',
    'Sering cemas berlebih tiap mau presentasi atau ujian lisan',
    'Tiap ada jadwal presentasi proyek desain mesin, jantungku suka berdegup kencang banget sampai tangan gemetaran dan suara tercekat. Padahal materinya udah kupelajari semalaman. Gimana ya cara calming down yang efektif pas detik-detik sebelum maju ke depan?',
    4,
    3,
    now() - interval '1 day 6 hours'
),
(
    'a0000001-0000-0000-0000-000000000005',
    'e0000001-0000-0000-0000-000000000005', -- Kevin Wijaya
    'Kevin Wijaya',
    'FH',
    'Relasi & Hubungan',
    'Bingung cara ngomong ke teman kelompok yang pasif',
    'Dalam satu tugas kelompok studi kasus hukum pidana, ada satu rekan yang bener-bener hilang kabar tapi namanya tetap pengen dimasukin ke laporan. Di satu sisi pengen tegas demi keadilan anggota lain, tapi di sisi lain ngga pengen merusak pertemanan. Langkah terbaiknya gimana ya?',
    3,
    2,
    now() - interval '2 days'
),
(
    'a0000001-0000-0000-0000-000000000006',
    'e0000001-0000-0000-0000-000000000006', -- Putri Handayani
    'Putri Handayani',
    'FBiPK',
    'Keluarga',
    'Ekspektasi orang tua yang tinggi soal IPK dan masa depan',
    'Orang tuaku selalu membandingkan prestasiku dengan saudara sepupu yang udah lulus cumlaude. Rasanya setiap telepon bukan nanya kabarku atau kesehatanku, tapi selalu nanya nilai. Beban ini bikin aku sering ngerasa kurang dan takut ngecewain mereka.',
    4,
    2,
    now() - interval '3 days'
),
(
    'a0000001-0000-0000-0000-000000000007',
    'e0000001-0000-0000-0000-000000000008', -- Maya Anggraini
    'Maya Anggraini',
    'FIB',
    'Lainnya',
    'Tempat tenang di sekitar kampus UB buat refreshing sejenak',
    'Lagi butuh tempat yang adem dan ngga terlalu ramai buat sekadar duduk baca buku atau dengerin lagu tanpa diganggu bisingnya jalanan. Teman-teman ada rekomendasi spot favorit di dalam atau dekat kampus UB yang nyaman?',
    3,
    2,
    now() - interval '4 days'
);

-- --------------------------------------------------------------------
-- 6. SEED ROOM LIKES (Organik dari User Seeder)
-- --------------------------------------------------------------------

INSERT INTO public.room_likes (user_id, room_id, created_at) VALUES
-- Room 1 (Budi) dilike oleh Sarah (konselor), Citra, Fajar, Dimas
('c0000001-0000-0000-0000-000000000001', 'a0000001-0000-0000-0000-000000000001', now() - interval '3 hours'),
('e0000001-0000-0000-0000-000000000002', 'a0000001-0000-0000-0000-000000000001', now() - interval '2 hours'),
('e0000001-0000-0000-0000-000000000003', 'a0000001-0000-0000-0000-000000000001', now() - interval '90 minutes'),
('c0000001-0000-0000-0000-000000000003', 'a0000001-0000-0000-0000-000000000001', now() - interval '45 minutes'),

-- Room 2 (Citra) dilike oleh Budi, Sarah, Maya, Anisa, Tifa
('e0000001-0000-0000-0000-000000000001', 'a0000001-0000-0000-0000-000000000002', now() - interval '9 hours'),
('c0000001-0000-0000-0000-000000000001', 'a0000001-0000-0000-0000-000000000002', now() - interval '8 hours'),
('e0000001-0000-0000-0000-000000000008', 'a0000001-0000-0000-0000-000000000002', now() - interval '7 hours'),
('e0000001-0000-0000-0000-000000000004', 'a0000001-0000-0000-0000-000000000002', now() - interval '5 hours'),
('c0000001-0000-0000-0000-000000000005', 'a0000001-0000-0000-0000-000000000002', now() - interval '3 hours'),

-- Room 3 (Anisa) dilike oleh Rizky (konselor), Kevin, Budi
('c0000001-0000-0000-0000-000000000006', 'a0000001-0000-0000-0000-000000000003', now() - interval '20 hours'),
('e0000001-0000-0000-0000-000000000005', 'a0000001-0000-0000-0000-000000000003', now() - interval '18 hours'),
('e0000001-0000-0000-0000-000000000001', 'a0000001-0000-0000-0000-000000000003', now() - interval '15 hours'),

-- Room 4 (Fajar) dilike oleh Nadia (konselor), Sarah, Dewa, Kevin
('c0000001-0000-0000-0000-000000000004', 'a0000001-0000-0000-0000-000000000004', now() - interval '1 day'),
('c0000001-0000-0000-0000-000000000001', 'a0000001-0000-0000-0000-000000000004', now() - interval '22 hours'),
('e0000001-0000-0000-0000-000000000007', 'a0000001-0000-0000-0000-000000000004', now() - interval '20 hours'),
('e0000001-0000-0000-0000-000000000005', 'a0000001-0000-0000-0000-000000000004', now() - interval '16 hours'),

-- Room 5 (Kevin) dilike oleh Dimas, Fajar, Anisa
('c0000001-0000-0000-0000-000000000003', 'a0000001-0000-0000-0000-000000000005', now() - interval '1 day 18 hours'),
('e0000001-0000-0000-0000-000000000003', 'a0000001-0000-0000-0000-000000000005', now() - interval '1 day 12 hours'),
('e0000001-0000-0000-0000-000000000004', 'a0000001-0000-0000-0000-000000000005', now() - interval '1 day'),

-- Room 6 (Putri) dilike oleh Sarah, Citra, Maya, Nabila
('c0000001-0000-0000-0000-000000000001', 'a0000001-0000-0000-0000-000000000006', now() - interval '2 days 18 hours'),
('e0000001-0000-0000-0000-000000000002', 'a0000001-0000-0000-0000-000000000006', now() - interval '2 days 12 hours'),
('e0000001-0000-0000-0000-000000000008', 'a0000001-0000-0000-0000-000000000006', now() - interval '2 days'),
('e0000001-0000-0000-0000-000000000010', 'a0000001-0000-0000-0000-000000000006', now() - interval '1 day 12 hours'),

-- Room 7 (Maya) dilike oleh Budi, Tifa, Tiara
('e0000001-0000-0000-0000-000000000001', 'a0000001-0000-0000-0000-000000000007', now() - interval '3 days 18 hours'),
('c0000001-0000-0000-0000-000000000005', 'a0000001-0000-0000-0000-000000000007', now() - interval '3 days 10 hours'),
('e0000001-0000-0000-0000-000000000012', 'a0000001-0000-0000-0000-000000000007', now() - interval '2 days 20 hours');

-- --------------------------------------------------------------------
-- 7. SEED ROOM COMMENTS (Organik Mahasiswa & Bimbingan Konselor)
-- --------------------------------------------------------------------

INSERT INTO public.room_comments (
    id,
    room_id,
    user_id,
    author_name,
    author_faculty,
    author_role,
    author_avatar_url,
    content,
    likes_count,
    created_at
) VALUES
-- Komentar di Room 1 (Budi - Akademik)
(
    'f0000001-0000-0000-0000-000000000001',
    'a0000001-0000-0000-0000-000000000001',
    'e0000001-0000-0000-0000-000000000003', -- Fajar Ramadhan (Mahasiswa FT)
    'Fajar Ramadhan',
    'FT',
    'mahasiswa',
    'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=400&auto=format&fit=crop&q=80',
    'Semangat Bud! Anak teknik juga lagi fase babak belur sama laporan praktikum. Trikku biasanya breakdown tugas jadi potongan kecil per hari, terus kerjain yang paling bikin stres di pagi hari pas otak masih segar.',
    2,
    now() - interval '3 hours'
),
(
    'f0000001-0000-0000-0000-000000000002',
    'a0000001-0000-0000-0000-000000000001',
    'c0000001-0000-0000-0000-000000000002', -- Dodo Pratama (Konselor FILKOM)
    'Dodo Pratama',
    'FILKOM',
    'konselor',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop&q=80',
    'Halo Budi, wajar sekali merasa overwhelmed ketika beberapa tanggung jawab besar datang berbarengan. Coba terapkan teknik Pomodoro (25 menit fokus, 5 menit jeda tanpa layar) dan jangan ragu delegasikan bagian proyek kelompok yang relevan. Kalau butuh ruang refleksi lebih dalam, pintu konseling FILKOM selalu terbuka.',
    4,
    now() - interval '2 hours'
),
(
    'f0000001-0000-0000-0000-000000000003',
    'a0000001-0000-0000-0000-000000000001',
    'e0000001-0000-0000-0000-000000000002', -- Citra Lestari (Mahasiswa FIA)
    'Citra Lestari',
    'FIA',
    'mahasiswa',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400&auto=format&fit=crop&q=80',
    'Jangan lupa tetap makan teratur ya kak. Kadang saking sibuknya ngetik kodingan suka lupa minum air putih.',
    1,
    now() - interval '1 hour'
),

-- Komentar di Room 2 (Citra - Kesepian)
(
    'f0000001-0000-0000-0000-000000000004',
    'a0000001-0000-0000-0000-000000000002',
    'e0000001-0000-0000-0000-000000000004', -- Anisa Rahma (Mahasiswa FEB)
    'Anisa Rahma',
    'FEB',
    'mahasiswa',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&auto=format&fit=crop&q=80',
    'Sangat normal kok Citra! Dulu waktu semester 1 aku juga sering nangis pas denger adzan maghrib di kos. Nanti pelan-pelan setelah ikut UKM atau kepanitiaan bakal ketemu circle yang cocok. Yuk kalau mau sesekali ngopi di sekitar Suhat!',
    3,
    now() - interval '8 hours'
),
(
    'f0000001-0000-0000-0000-000000000005',
    'a0000001-0000-0000-0000-000000000002',
    'c0000001-0000-0000-0000-000000000001', -- Sarah Amalia (Konselor FISIP)
    'Sarah Amalia',
    'FISIP',
    'konselor',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80',
    'Proses transisi budaya dan adaptasi tempat tinggal baru memang membutuhkan energi emosional yang besar. Beri dirimu ruang dan apresiasi bahwa kamu sudah berani melangkah sejauh ini di Malang. Perasaan hampa itu sinyal wajar dari tubuh yang merindukan rasa aman di rumah, bukan tanda kelemahan.',
    5,
    now() - interval '6 hours'
),
(
    'f0000001-0000-0000-0000-000000000006',
    'a0000001-0000-0000-0000-000000000002',
    'e0000001-0000-0000-0000-000000000008', -- Maya Anggraini (Mahasiswa FIB)
    'Maya Anggraini',
    'FIB',
    'mahasiswa',
    'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=400&auto=format&fit=crop&q=80',
    'Kalau sore senggang coba jalan-jalan santai di Gazebo UB atau sekitar rektorat, hawanya sejuk dan bikin pikiran lebih rileks.',
    1,
    now() - interval '4 hours'
),

-- Komentar di Room 3 (Anisa - Keuangan)
(
    'f0000001-0000-0000-0000-000000000007',
    'a0000001-0000-0000-0000-000000000003',
    'c0000001-0000-0000-0000-000000000006', -- Rizky Maulana (Konselor FEB)
    'Rizky Maulana',
    'FEB',
    'konselor',
    'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&auto=format&fit=crop&q=80',
    'Hai Anisa, bijak sekali sudah berinisiatif mencari alternatif. Di lingkungan kampus UB ada program magang riset laboratorium, asisten dosen paruh waktu, atau program wirausaha mahasiswa binaan inkubator bisnis UB. Di samping itu, jika butuh bantuan keringanan biaya studi darurat, fakultas memiliki pos beasiswa ikatan alumni yang bisa diajukan.',
    3,
    now() - interval '18 hours'
),
(
    'f0000001-0000-0000-0000-000000000008',
    'a0000001-0000-0000-0000-000000000003',
    'e0000001-0000-0000-0000-000000000005', -- Kevin Wijaya (Mahasiswa FH)
    'Kevin Wijaya',
    'FH',
    'mahasiswa',
    'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=400&auto=format&fit=crop&q=80',
    'Bisa coba freelance online seperti transkripsi data atau admin olshop, lumayan buat nambah uang makan tanpa ganggu jadwal kuliah.',
    2,
    now() - interval '12 hours'
),

-- Komentar di Room 4 (Fajar - Mental Health & Cemas)
(
    'f0000001-0000-0000-0000-000000000009',
    'a0000001-0000-0000-0000-000000000004',
    'c0000001-0000-0000-0000-000000000004', -- Nadia Salsabila (Konselor FK)
    'Nadia Salsabila',
    'FK',
    'konselor',
    'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400&auto=format&fit=crop&q=80',
    'Respon fisik seperti jantung berdebar dan tangan gemetar adalah mekanisme fight-or-flight alami saat tubuh menganggap situasi tersebut menegangkan. Coba terapkan teknik "Box Breathing" (tarik napas 4 detik, tahan 4 detik, hembuskan 4 detik, tahan kosong 4 detik). Minum air putih hangat sebelum giliran maju juga membantu menenangkan saraf vagus.',
    4,
    now() - interval '22 hours'
),
(
    'f0000001-0000-0000-0000-000000000010',
    'a0000001-0000-0000-0000-000000000004',
    'e0000001-0000-0000-0000-000000000001', -- Budi Santoso (Mahasiswa FILKOM)
    'Budi Santoso',
    'FILKOM',
    'mahasiswa',
    'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400&auto=format&fit=crop&q=80',
    'Aku juga dulu gitu bro. Trikku sekarang: fokusin pandangan ke dahi audiens atau titik dinding di belakang mereka, jangan langsung tatap mata kalau masih grogi.',
    2,
    now() - interval '18 hours'
),
(
    'f0000001-0000-0000-0000-000000000011',
    'a0000001-0000-0000-0000-000000000004',
    'e0000001-0000-0000-0000-000000000007', -- Dewa Pratama (Mahasiswa FK)
    'Dewa Pratama',
    'FK',
    'mahasiswa',
    'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=400&auto=format&fit=crop&q=80',
    'Setuju sama Kak Nadia. Relaksasi otot progresif juga ampuh banget buat ngurangin ketegangan fisik.',
    1,
    now() - interval '14 hours'
);

-- --------------------------------------------------------------------
-- 8. SEED TIPS KAMPUS (Lengkap 9 Kategori Resmi)
-- --------------------------------------------------------------------

INSERT INTO public.tips (
    id,
    user_id,
    title,
    author_name,
    author_faculty,
    author_gender,
    category,
    content,
    likes_count,
    bookmarks_count,
    created_at
) VALUES
(
    'd0000001-0000-0000-0000-000000000001',
    'c0000001-0000-0000-0000-000000000001', -- Sarah Amalia (Konselor)
    'Menjaga Keseimbangan Emosi di Tengah Ujian',
    'Sarah Amalia',
    'FISIP',
    'Perempuan',
    'Self-care',
    'Luangkan minimal 15 menit sehari tanpa gawai. Nikmati secangkir teh hangat atau jalan kaki tanpa memikirkan nilai.',
    5,
    3,
    now() - interval '1 day'
),
(
    'd0000001-0000-0000-0000-000000000002',
    'c0000001-0000-0000-0000-000000000002', -- Dodo Pratama (Konselor)
    'Strategi Time-Blocking untuk Mahasiswa IT',
    'Dodo Pratama',
    'FILKOM',
    'Laki-laki',
    'Productivity',
    'Kelompokkan waktu belajar koding dan waktu istirahat secara tegas agar terhindar dari siklus begadang berkepanjangan.',
    6,
    4,
    now() - interval '2 days'
),
(
    'd0000001-0000-0000-0000-000000000003',
    'c0000001-0000-0000-0000-000000000005', -- Tifa Faradiba (Konselor)
    'Afirmasi Pagi Menghargai Progres Diri',
    'Tifa Faradiba',
    'FIB',
    'Perempuan',
    'Afirmasi',
    'Progres kecil setiap hari tetaplah sebuah langkah maju. Aku tidak sedang berlomba dengan siapa pun selain diriku yang kemarin.',
    7,
    5,
    now() - interval '3 days'
),
(
    'd0000001-0000-0000-0000-000000000004',
    'e0000001-0000-0000-0000-000000000001', -- Budi Santoso (Mahasiswa)
    'Playlist Lofi & Ambient Sound Malang Saat Hujan',
    'Budi Santoso',
    'FILKOM',
    'Laki-laki',
    'Musik',
    'Dengarkan alunan musik tanpa lirik untuk meningkatkan fokus kerja di perpus kampus.',
    4,
    2,
    now() - interval '4 days'
),
(
    'd0000001-0000-0000-0000-000000000005',
    'c0000001-0000-0000-0000-000000000004', -- Nadia Salsabila (Konselor)
    'Mengenali Tanda Burnout pada Mahasiswa',
    'Nadia Salsabila',
    'FK',
    'Perempuan',
    'Mental Health',
    'Rasa lelah yang tidak hilang meski sudah tidur, hilangnya motivasi pada hal yang disukai, dan mudah tersinggung adalah sinyal tubuh butuh rehat.',
    8,
    6,
    now() - interval '5 days'
),
(
    'd0000001-0000-0000-0000-000000000006',
    'c0000001-0000-0000-0000-000000000003', -- Dimas Setiawan (Konselor)
    'Matriks Eisenhower untuk Skripsi & Organisasi',
    'Dimas Setiawan',
    'FT',
    'Laki-laki',
    'Manajemen Waktu',
    'Bedakan antara hal mendesak dan hal penting. Jangan biarkan tugas penting tertunda karena terjebak hal mendesak yang sepele.',
    5,
    3,
    now() - interval '6 days'
),
(
    'd0000001-0000-0000-0000-000000000007',
    'e0000001-0000-0000-0000-000000000002', -- Citra Lestari (Mahasiswa)
    'Berdamai dengan Perasaan Tertinggal',
    'Citra Lestari',
    'FIA',
    'Perempuan',
    'Curhat',
    'Media sosial hanya menampilkan panggung depan orang lain. Setiap orang memiliki musim mekarnya masing-masing.',
    6,
    4,
    now() - interval '7 days'
),
(
    'd0000001-0000-0000-0000-000000000008',
    'c0000001-0000-0000-0000-000000000001', -- Sarah Amalia (Konselor)
    'Komunikasi Asertif dengan Teman Kelompok',
    'Sarah Amalia',
    'FISIP',
    'Perempuan',
    'Relasi',
    'Sampaikan kebutuhan dan batas kemampuanmu dengan jelas tanpa menyalahkan atau merasa bersalah.',
    5,
    3,
    now() - interval '8 days'
),
(
    'd0000001-0000-0000-0000-000000000009',
    'c0000001-0000-0000-0000-000000000006', -- Rizky Maulana (Konselor)
    'Persiapan Menghadapi Ujian Lisan & Sidang',
    'Rizky Maulana',
    'FEB',
    'Laki-laki',
    'Akademik',
    'Latihan berbicara di depan cermin dan rekam suaramu. Kepercayaan diri tumbuh dari repetisi yang disengaja.',
    4,
    2,
    now() - interval '9 days'
);

-- Seed Tip Likes & Bookmarks (Organik)
INSERT INTO public.tip_likes (user_id, tip_id, created_at) VALUES
('e0000001-0000-0000-0000-000000000001', 'd0000001-0000-0000-0000-000000000001', now() - interval '20 hours'),
('e0000001-0000-0000-0000-000000000002', 'd0000001-0000-0000-0000-000000000001', now() - interval '18 hours'),
('e0000001-0000-0000-0000-000000000003', 'd0000001-0000-0000-0000-000000000001', now() - interval '16 hours'),
('e0000001-0000-0000-0000-000000000004', 'd0000001-0000-0000-0000-000000000001', now() - interval '14 hours'),
('c0000001-0000-0000-0000-000000000002', 'd0000001-0000-0000-0000-000000000001', now() - interval '12 hours');

INSERT INTO public.tip_bookmarks (user_id, tip_id, created_at) VALUES
('e0000001-0000-0000-0000-000000000001', 'd0000001-0000-0000-0000-000000000001', now() - interval '20 hours'),
('e0000001-0000-0000-0000-000000000002', 'd0000001-0000-0000-0000-000000000001', now() - interval '18 hours'),
('e0000001-0000-0000-0000-000000000004', 'd0000001-0000-0000-0000-000000000001', now() - interval '14 hours');

-- --------------------------------------------------------------------
-- 9. SEED SESI KONSELING AKTIF & RIWAYAT CHAT REALISTIS
-- Budi Santoso (Mahasiswa) & Sarah Amalia (Konselor)
-- --------------------------------------------------------------------

INSERT INTO public.counseling_sessions (
    id,
    student_id,
    counselor_id,
    student_alias,
    student_faculty,
    status,
    started_at
) VALUES (
    '10000001-0000-0000-0000-000000000001',
    'e0000001-0000-0000-0000-000000000001', -- Budi Santoso
    'c0000001-0000-0000-0000-000000000001', -- Sarah Amalia
    'Sobat Belajar',
    'FILKOM',
    'active',
    now() - interval '1 hour'
);

INSERT INTO public.chat_messages (
    id,
    session_id,
    sender_id,
    sender_role,
    message_text,
    is_read,
    created_at
) VALUES
(
    'b0000001-0000-0000-0000-000000000001',
    '10000001-0000-0000-0000-000000000001',
    'e0000001-0000-0000-0000-000000000001', -- Budi
    'student',
    'Halo Kak Sarah, selamat sore. Saya Budi dari FILKOM...',
    true,
    now() - interval '50 minutes'
),
(
    'b0000001-0000-0000-0000-000000000002',
    '10000001-0000-0000-0000-000000000001',
    'c0000001-0000-0000-0000-000000000001', -- Sarah
    'counselor',
    'Halo Budi, selamat sore! Senang bisa terhubung denganmu. Bagaimana kabarmu hari ini? Silakan ceritakan apa yang sedang kamu rasakan dengan nyaman, sesi ini sepenuhnya rahasia.',
    true,
    now() - interval '47 minutes'
),
(
    'b0000001-0000-0000-0000-000000000003',
    '10000001-0000-0000-0000-000000000001',
    'e0000001-0000-0000-0000-000000000001', -- Budi
    'student',
    'Akhir-akhir ini saya ngerasa cemas terus pas malam Kak, mikirin skripsi sama prospek kerja nanti. Kadang susah tidur sampai subuh.',
    true,
    now() - interval '42 minutes'
),
(
    'b0000001-0000-0000-0000-000000000004',
    '10000001-0000-0000-0000-000000000001',
    'c0000001-0000-0000-0000-000000000001', -- Sarah
    'counselor',
    'Terima kasih sudah berani membagikan ini, Budi. Sangat manusiawi merasa cemas saat menghadapi persimpangan besar menjelang kelulusan. Mari kita urai perlahan ya, hal apa yang saat ini paling membebani pikiranmu di antara keduanya?',
    false,
    now() - interval '35 minutes'
);

-- --------------------------------------------------------------------
-- 10. SEED ANTREAN KONSELING MAHASISWA MENUNGGU (Ready to Accept)
-- Citra Lestari (FIA)
-- --------------------------------------------------------------------

INSERT INTO public.counseling_queues (
    id,
    student_id,
    student_alias,
    student_gender,
    student_faculty,
    preferred_topic,
    status,
    created_at
) VALUES (
    '20000001-0000-0000-0000-000000000001',
    'e0000001-0000-0000-0000-000000000002', -- Citra Lestari
    'Bunga Kamboja',
    'Perempuan',
    'FIA',
    'Relasi & Hubungan',
    'waiting',
    now() - interval '15 minutes'
);
