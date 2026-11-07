-- ============================================================================
-- Migration 20261106000002: 
-- 1. Normalize public.rooms: Drop author_tag, Add author_name, author_faculty, author_gender
-- 2. Normalize public.room_comments: Drop author_tag, Add author_name, author_faculty, author_role
-- 3. Seed Canonical Campus Rooms & Relational Comments with Real User IDs
-- 4. Seed Relational room_likes & room_bookmarks
-- 5. Add Counter Self-Healing Function (reconcile_all_counters)
-- ============================================================================

-- ============================================================================
-- 1. NORMALIZE public.rooms TABLE (Drop author_tag, Add Structured Columns)
-- ============================================================================

ALTER TABLE public.rooms
ADD COLUMN IF NOT EXISTS author_name TEXT NOT NULL DEFAULT 'Anonim',
ADD COLUMN IF NOT EXISTS author_faculty TEXT NOT NULL DEFAULT 'FILKOM',
ADD COLUMN IF NOT EXISTS author_gender TEXT NOT NULL DEFAULT 'Laki-laki';

-- Backfill data existing jika ada sebelum drop author_tag
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
          AND table_name = 'rooms' 
          AND column_name = 'author_tag'
    ) THEN
        UPDATE public.rooms
        SET author_faculty = CASE
                WHEN author_tag ILIKE '%FILKOM%' THEN 'FILKOM'
                WHEN author_tag ILIKE '%FEB%' THEN 'FEB'
                WHEN author_tag ILIKE '%FT%' THEN 'FT'
                WHEN author_tag ILIKE '%FIA%' THEN 'FIA'
                WHEN author_tag ILIKE '%FIB%' THEN 'FIB'
                WHEN author_tag ILIKE '%FK%' THEN 'FK'
                ELSE 'FILKOM'
            END,
            author_gender = CASE
                WHEN author_tag ILIKE '%Perempuan%' THEN 'Perempuan'
                ELSE 'Laki-laki'
            END,
            author_name = CASE
                WHEN user_id = 'b1111111-1111-1111-1111-111111111101'::uuid THEN 'Kak Sekar'
                WHEN user_id = 'b1111111-1111-1111-1111-111111111102'::uuid THEN 'Kak Harry'
                WHEN user_id = 'b1111111-1111-1111-1111-111111111103'::uuid THEN 'Kak Cris'
                WHEN user_id = 'b1111111-1111-1111-1111-111111111104'::uuid THEN 'Budi S.'
                WHEN user_id = 'b1111111-1111-1111-1111-111111111105'::uuid THEN 'Dinda'
                WHEN user_id = 'b1111111-1111-1111-1111-111111111106'::uuid THEN 'Reza'
                ELSE 'Anonim'
            END;

        -- Drop kolom author_tag yang sudah usang
        ALTER TABLE public.rooms DROP COLUMN author_tag;
    END IF;
END $$;

-- ============================================================================
-- 2. NORMALIZE public.room_comments TABLE (Drop author_tag, Add Structured Columns)
-- ============================================================================

ALTER TABLE public.room_comments
ADD COLUMN IF NOT EXISTS author_name TEXT NOT NULL DEFAULT 'Teman Kampus',
ADD COLUMN IF NOT EXISTS author_faculty TEXT NOT NULL DEFAULT 'FILKOM',
ADD COLUMN IF NOT EXISTS author_role TEXT NOT NULL DEFAULT 'mahasiswa';

-- Backfill data existing jika ada sebelum drop author_tag
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
          AND table_name = 'room_comments' 
          AND column_name = 'author_tag'
    ) THEN
        UPDATE public.room_comments
        SET author_role = CASE
                WHEN author_tag ILIKE '%Konselor%' OR user_id::text LIKE 'a1111111%' THEN 'konselor'
                ELSE 'mahasiswa'
            END,
            author_name = CASE
                WHEN user_id = 'a1111111-1111-1111-1111-111111111101'::uuid THEN 'Kak Dodo'
                WHEN user_id = 'a1111111-1111-1111-1111-111111111102'::uuid THEN 'Kak Leo'
                WHEN user_id = 'b1111111-1111-1111-1111-111111111101'::uuid THEN 'Kak Sekar'
                WHEN user_id = 'b1111111-1111-1111-1111-111111111102'::uuid THEN 'Kak Harry'
                WHEN user_id = 'b1111111-1111-1111-1111-111111111105'::uuid THEN 'Dinda'
                ELSE 'Teman Kampus'
            END,
            author_faculty = CASE
                WHEN user_id::text LIKE 'a1111111%' THEN 'Pusat Konseling'
                WHEN user_id = 'b1111111-1111-1111-1111-111111111101'::uuid THEN 'FIB'
                WHEN user_id = 'b1111111-1111-1111-1111-111111111102'::uuid THEN 'FEB'
                WHEN user_id = 'b1111111-1111-1111-1111-111111111105'::uuid THEN 'FILKOM'
                ELSE 'FILKOM'
            END;

        -- Drop kolom author_tag yang sudah usang
        ALTER TABLE public.room_comments DROP COLUMN author_tag;
    END IF;
END $$;

-- ============================================================================
-- 3. SEED CANONICAL CAMPUS ROOMS (DENGAN STRUKTUR BERSIH & USER IDs RIIL)
-- Hexadecimal UUID prefix 'd' for Rooms
-- ============================================================================

-- Room 1: Kesepian / Overthinking (Dinda - b111...105)
INSERT INTO public.rooms (
    id,
    user_id,
    category,
    title,
    content,
    author_name,
    author_faculty,
    author_gender,
    created_at
) VALUES (
    'd1111111-1111-1111-1111-111111111101',
    'b1111111-1111-1111-1111-111111111105',
    'Kesepian',
    'hidup udah agak mantap tapi ada aja postingan #mykisah yang bikin aku ngetik when yah kan aku juga mw',
    'hidup udah agak mantap, kerjaan mulai beres, tidur lumayan teratur, dompet walau tipis masih bisa napas. pokoknya udah mulai ngerasa, "oh... ternyata hidup bisa setenang ini ya."

eh terus buka sosmed.
muncul postingan #mykisah.
isinya orang-orang ketemu pasangan yang baik, dilamar, nikah, anniversary, saling support, dibeliin bunga, dibikinin bekel, diajak healing, dikasih kejutan kecil yang manis-manis.
aku cuma bisa scroll sambil senyum tipis.
terus tanpa sadar ngetik...
"when yah..."

kan aku juga mw.
ya Allah, aku gak minta yang wah-wah kok. pengen ngerasain jadi tokoh utama di postingan #mykisah sekali aja. 😔',
    'Dinda',
    'FILKOM',
    'Perempuan',
    now() - INTERVAL '1 day 2 hours'
)
ON CONFLICT (id) DO UPDATE SET
    user_id = EXCLUDED.user_id,
    category = EXCLUDED.category,
    title = EXCLUDED.title,
    content = EXCLUDED.content,
    author_name = EXCLUDED.author_name,
    author_faculty = EXCLUDED.author_faculty,
    author_gender = EXCLUDED.author_gender;

-- Room 2: Hubungan / Perpisahan (Kak Harry - b111...102)
INSERT INTO public.rooms (
    id,
    user_id,
    category,
    title,
    content,
    author_name,
    author_faculty,
    author_gender,
    created_at
) VALUES (
    'd1111111-1111-1111-1111-111111111102',
    'b1111111-1111-1111-1111-111111111102',
    'Hubungan',
    'ternyata yang paling sakit bukan kalah, tapi sadar kalau gak akan ada lagi "Di kesempatan berikutnya" buat dia',
    'Sering banget kita mikir kalau orang yang selalu ada bakal selamanya ada. Sampai akhirnya waktu memisahkan jalan hidup kita masing-masing. Buat kalian yang masih punya teman baik atau orang terkasih di samping kalian saat ini, tolong dijaga baik-baik ya. Jangan tunggu sampai mereka cuma tinggal memori di album foto lama.',
    'Kak Harry',
    'FEB',
    'Laki-laki',
    now() - INTERVAL '2 days 5 hours'
)
ON CONFLICT (id) DO UPDATE SET
    user_id = EXCLUDED.user_id,
    category = EXCLUDED.category,
    title = EXCLUDED.title,
    content = EXCLUDED.content,
    author_name = EXCLUDED.author_name,
    author_faculty = EXCLUDED.author_faculty,
    author_gender = EXCLUDED.author_gender;

-- Room 3: Akademik / Praktikum (Budi S. - b111...104)
INSERT INTO public.rooms (
    id,
    user_id,
    category,
    title,
    content,
    author_name,
    author_faculty,
    author_gender,
    created_at
) VALUES (
    'd1111111-1111-1111-1111-111111111103',
    'b1111111-1111-1111-1111-111111111104',
    'Akademik',
    'hidup udah agak mantap tapi ada aja tugas kalkulus dan praktikum yang bikin IP ketar-ketir',
    'Semester ini beneran ujian kesabaran dan mental banget. Tiap minggu ada 3 modul praktikum, asistensi revisi 4 kali, kuis mendadak, belum lagi persiapan UTS. Kadang cuma pengen rebahan seharian tanpa mikirin rumus dan error. Tapi ya dinikmati aja prosesnya, demi toga biru nanti!',
    'Budi S.',
    'FT',
    'Laki-laki',
    now() - INTERVAL '3 days 10 hours'
)
ON CONFLICT (id) DO UPDATE SET
    user_id = EXCLUDED.user_id,
    category = EXCLUDED.category,
    title = EXCLUDED.title,
    content = EXCLUDED.content,
    author_name = EXCLUDED.author_name,
    author_faculty = EXCLUDED.author_faculty,
    author_gender = EXCLUDED.author_gender;

-- Room 4: Keuangan / Bulan Tua Anak Kos (Reza - b111...106)
INSERT INTO public.rooms (
    id,
    user_id,
    category,
    title,
    content,
    author_name,
    author_faculty,
    author_gender,
    created_at
) VALUES (
    'd1111111-1111-1111-1111-111111111104',
    'b1111111-1111-1111-1111-111111111106',
    'Keuangan',
    'duh gusti, apa sih sekarang apa apa mahal. mo beli ini itu abis buat makan doang',
    'Bulan tua di Malang beneran butuh kalkulasi level dewa. Uang jajan bulanan yang dulu cukup buat sebulan, sekarang baru tanggal 18 udah menipis. Harga ayam geprek, nasi padang, sampai es teh semuanya naik. Ada tips bertahan hidup anak kos yang hemat tapi tetep bergizi gak teman-teman?',
    'Reza',
    'FIA',
    'Laki-laki',
    now() - INTERVAL '4 days 3 hours'
)
ON CONFLICT (id) DO UPDATE SET
    user_id = EXCLUDED.user_id,
    category = EXCLUDED.category,
    title = EXCLUDED.title,
    content = EXCLUDED.content,
    author_name = EXCLUDED.author_name,
    author_faculty = EXCLUDED.author_faculty,
    author_gender = EXCLUDED.author_gender;

-- ============================================================================
-- 4. SEED RELATIONAL ROOM COMMENTS (DENGAN TANGGAPAN KONSELOR & TEMAN KAMPUS)
-- Hexadecimal UUID prefix 'e' for Comments
-- ============================================================================

-- Komentar untuk Room 1 (Dinda - when yh)
INSERT INTO public.room_comments (
    id,
    room_id,
    user_id,
    author_name,
    author_faculty,
    author_role,
    content,
    likes_count,
    created_at
) VALUES
(
    'e1111111-1111-1111-1111-111111111101',
    'd1111111-1111-1111-1111-111111111101',
    'a1111111-1111-1111-1111-111111111101',
    'Kak Dodo',
    'Pusat Konseling',
    'konselor',
    'Halo Dinda! Sangat wajar kok punya rasa "when yh" saat melihat cuplikan terbaik hidup orang lain di sosmed. Tapi ingat, yang mereka tampilkan adalah highlight reel, bukan proses jatuh bangunnya. Ketenangan batin yang kamu punya sekarang adalah modal terbaik untuk hubungan sehat nanti ✨',
    14,
    now() - INTERVAL '1 day'
),
(
    'e1111111-1111-1111-1111-111111111102',
    'd1111111-1111-1111-1111-111111111101',
    'b1111111-1111-1111-1111-111111111101',
    'Kak Sekar',
    'FIB',
    'mahasiswa',
    'Relate banget Dindaa! Kadang jempol auto ngetik when yh pas scroll TikTok jam 12 malem wkwk. Tapi bener kata Kak Dodo, fokus rawat diri sendiri dulu ajaa, jodoh ga bakal ketuker kok.',
    8,
    now() - INTERVAL '20 hours'
),
(
    'e1111111-1111-1111-1111-111111111103',
    'd1111111-1111-1111-1111-111111111101',
    'b1111111-1111-1111-1111-111111111102',
    'Kak Harry',
    'FEB',
    'mahasiswa',
    'Semangat ya! Kuncinya kalau sosmed udah mulai bikin overthinking, langsung close app terus jalan sore muter kampus cari angin seger.',
    5,
    now() - INTERVAL '14 hours'
)
ON CONFLICT (id) DO UPDATE SET
    author_name = EXCLUDED.author_name,
    author_faculty = EXCLUDED.author_faculty,
    author_role = EXCLUDED.author_role,
    content = EXCLUDED.content;

-- Komentar untuk Room 3 (Budi S. - praktikum kalkulus)
INSERT INTO public.room_comments (
    id,
    room_id,
    user_id,
    author_name,
    author_faculty,
    author_role,
    content,
    likes_count,
    created_at
) VALUES
(
    'e1111111-1111-1111-1111-111111111104',
    'd1111111-1111-1111-1111-111111111103',
    'a1111111-1111-1111-1111-111111111102',
    'Kak Leo',
    'Pusat Konseling',
    'konselor',
    'Semangat Mas Budi! Jangan lupa atur napas dan istirahat tiap 45 menit ya. Otak yang lelah justru butuh waktu istirahat lebih banyak agar bisa menyerap rumus dengan efektif. Kamu pasti bisa lewati semester ini!',
    11,
    now() - INTERVAL '3 days'
),
(
    'e1111111-1111-1111-1111-111111111105',
    'd1111111-1111-1111-1111-111111111103',
    'b1111111-1111-1111-1111-111111111106',
    'Reza',
    'FIA',
    'mahasiswa',
    'Solidaritas anak teknik memang top, semangat bro! Nanti pas wisuda bakal kerasa manisnya perjuangan ini.',
    6,
    now() - INTERVAL '2 days 18 hours'
)
ON CONFLICT (id) DO UPDATE SET
    author_name = EXCLUDED.author_name,
    author_faculty = EXCLUDED.author_faculty,
    author_role = EXCLUDED.author_role,
    content = EXCLUDED.content;

-- ============================================================================
-- 5. SEED RELATIONAL room_likes & room_bookmarks
-- ============================================================================

INSERT INTO public.room_likes (user_id, room_id, created_at)
VALUES
-- Likes pada Room 1 (Dinda - when yh)
('b1111111-1111-1111-1111-111111111101', 'd1111111-1111-1111-1111-111111111101', now() - INTERVAL '1 day'),
('b1111111-1111-1111-1111-111111111102', 'd1111111-1111-1111-1111-111111111101', now() - INTERVAL '22 hours'),
('b1111111-1111-1111-1111-111111111103', 'd1111111-1111-1111-1111-111111111101', now() - INTERVAL '18 hours'),
('b1111111-1111-1111-1111-111111111104', 'd1111111-1111-1111-1111-111111111101', now() - INTERVAL '15 hours'),
('b1111111-1111-1111-1111-111111111106', 'd1111111-1111-1111-1111-111111111101', now() - INTERVAL '10 hours'),
('a1111111-1111-1111-1111-111111111101', 'd1111111-1111-1111-1111-111111111101', now() - INTERVAL '8 hours'),
('a1111111-1111-1111-1111-111111111102', 'd1111111-1111-1111-1111-111111111101', now() - INTERVAL '5 hours'),

-- Likes pada Room 2 (Kak Harry - hubungan)
('b1111111-1111-1111-1111-111111111101', 'd1111111-1111-1111-1111-111111111102', now() - INTERVAL '2 days'),
('b1111111-1111-1111-1111-111111111105', 'd1111111-1111-1111-1111-111111111102', now() - INTERVAL '1 day 16 hours'),
('a1111111-1111-1111-1111-111111111104', 'd1111111-1111-1111-1111-111111111102', now() - INTERVAL '1 day'),

-- Likes pada Room 3 (Budi S. - praktikum)
('b1111111-1111-1111-1111-111111111102', 'd1111111-1111-1111-1111-111111111103', now() - INTERVAL '3 days'),
('b1111111-1111-1111-1111-111111111106', 'd1111111-1111-1111-1111-111111111103', now() - INTERVAL '2 days 10 hours'),
('a1111111-1111-1111-1111-111111111102', 'd1111111-1111-1111-1111-111111111103', now() - INTERVAL '2 days')
ON CONFLICT (user_id, room_id) DO NOTHING;

INSERT INTO public.room_bookmarks (user_id, room_id, created_at)
VALUES
('b1111111-1111-1111-1111-111111111101', 'd1111111-1111-1111-1111-111111111101', now() - INTERVAL '1 day'),
('b1111111-1111-1111-1111-111111111102', 'd1111111-1111-1111-1111-111111111101', now() - INTERVAL '12 hours'),
('a1111111-1111-1111-1111-111111111101', 'd1111111-1111-1111-1111-111111111101', now() - INTERVAL '6 hours'),
('b1111111-1111-1111-1111-111111111104', 'd1111111-1111-1111-1111-111111111102', now() - INTERVAL '1 day 12 hours')
ON CONFLICT (user_id, room_id) DO NOTHING;

-- ============================================================================
-- 6. COUNTER RECONCILIATION FUNCTION (Self-Healing Exact Count)
-- ============================================================================

CREATE OR REPLACE FUNCTION public.reconcile_all_counters()
RETURNS void AS $$
BEGIN
    -- 1. Rekonsiliasi tips: likes_count & bookmarks_count
    UPDATE public.tips t SET
        likes_count = (SELECT COUNT(*) FROM public.tip_likes tl WHERE tl.tip_id = t.id),
        bookmarks_count = (SELECT COUNT(*) FROM public.tip_bookmarks tb WHERE tb.tip_id = t.id);

    -- 2. Rekonsiliasi rooms: likes_count, bookmarks_count, comments_count
    UPDATE public.rooms r SET
        likes_count = (SELECT COUNT(*) FROM public.room_likes rl WHERE rl.room_id = r.id),
        bookmarks_count = (SELECT COUNT(*) FROM public.room_bookmarks rb WHERE rb.room_id = r.id),
        comments_count = (SELECT COUNT(*) FROM public.room_comments rc WHERE rc.room_id = r.id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Jalankan sinkronisasi awal
-- Catatan: Jika ada baseline tambahan pada tips kanonikal, pertahankan nilai organik
UPDATE public.tips t SET
    likes_count = GREATEST(t.likes_count, (SELECT COUNT(*) FROM public.tip_likes tl WHERE tl.tip_id = t.id)),
    bookmarks_count = GREATEST(t.bookmarks_count, (SELECT COUNT(*) FROM public.tip_bookmarks tb WHERE tb.tip_id = t.id));

UPDATE public.rooms r SET
    likes_count = GREATEST(r.likes_count, (SELECT COUNT(*) FROM public.room_likes rl WHERE rl.room_id = r.id)),
    bookmarks_count = GREATEST(r.bookmarks_count, (SELECT COUNT(*) FROM public.room_bookmarks rb WHERE rb.room_id = r.id)),
    comments_count = (SELECT COUNT(*) FROM public.room_comments rc WHERE rc.room_id = r.id);
