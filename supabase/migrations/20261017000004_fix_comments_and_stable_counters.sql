-- ====================================================================
-- FIX ROOM COMMENTS & SYNCHRONIZE ACCURATE COUNTERS
-- 1. Insert rich, realistic comments for all rooms
-- 2. Recalculate exact comments_count from room_comments
-- 3. Stagger created_at timestamps for deterministic sorting
-- ====================================================================

-- 1. Add comments for rooms that have 0 comments
DO $$
DECLARE
    r_kalkulus UUID;
    r_skripsi UUID;
    r_kesempatan UUID;
BEGIN
    SELECT id INTO r_kalkulus FROM public.rooms WHERE title LIKE '%kalkulus%' LIMIT 1;
    IF r_kalkulus IS NOT NULL THEN
        INSERT INTO public.room_comments (room_id, author_tag, content, likes_count, created_at) VALUES
        (r_kalkulus, 'Anonim • FILKOM', 'Tenang bro, kalkulus emang momok di semester awal. Coba tonton tutorial YouTube dari 3Blue1Brown atau nanya ke aslab waktu asistensi.', 14, now() - INTERVAL '4 hours'),
        (r_kalkulus, 'Anonim • FT', 'Kuncinya banyakin latihan soal tahun-tahun sebelumnya kak! Biasanya tipe soal ujian gak jauh beda.', 8, now() - INTERVAL '2 hours')
        ON CONFLICT DO NOTHING;
    END IF;

    SELECT id INTO r_skripsi FROM public.rooms WHERE title LIKE '%skripsi bab 4%' LIMIT 1;
    IF r_skripsi IS NOT NULL THEN
        INSERT INTO public.room_comments (room_id, author_tag, content, likes_count, created_at) VALUES
        (r_skripsi, 'Anonim • FIA', 'Trik dari aku: bikin outline poin per poin dulu dari rumusan masalah, baru jabarin analisisnya satu-satu.', 19, now() - INTERVAL '5 hours'),
        (r_skripsi, 'Anonim • FISIP', 'Jangan paksain nulis sempurna di draf pertama kak. Tulis aja yang ada di kepala dulu, revisi belakangan bareng dospem!', 25, now() - INTERVAL '3 hours'),
        (r_skripsi, 'Anonim • FEB', 'Semangat pejuang toga! Jangan lupa istirahat juga ya, jalan kaki sore bentar keliling gazebo UB bisa balikin fokus.', 12, now() - INTERVAL '1 hour')
        ON CONFLICT DO NOTHING;
    END IF;

    SELECT id INTO r_kesempatan FROM public.rooms WHERE title LIKE '%kesempatan berikutnya%' LIMIT 1;
    IF r_kesempatan IS NOT NULL THEN
        INSERT INTO public.room_comments (room_id, author_tag, content, likes_count, created_at) VALUES
        (r_kesempatan, 'Anonim • FIB', 'Sakit banget emang kalau harus mengikhlaskan hal yang belum tuntas. Peluk hangat dari jauh kak, waktu bakal bantu sembuhin pelan-pelan.', 31, now() - INTERVAL '6 hours'),
        (r_kesempatan, 'Anonim • FP', 'Kamu sudah berusaha yang terbaik di saat itu. Sekarang giliran fokus menyayangi dirimu sendiri ya.', 18, now() - INTERVAL '4 hours')
        ON CONFLICT DO NOTHING;
    END IF;
END $$;

-- 2. Recalculate accurate comments_count for all rooms based on actual rows in room_comments
UPDATE public.rooms r
SET comments_count = (
    SELECT COUNT(*) FROM public.room_comments rc WHERE rc.room_id = r.id
);

-- 3. Stagger created_at timestamps on tips so ordering is 100% deterministic
DO $$
DECLARE
    t RECORD;
    i INT := 1;
BEGIN
    FOR t IN SELECT id FROM public.tips ORDER BY category, id LOOP
        UPDATE public.tips
        SET created_at = (now() - (i * INTERVAL '10 minutes'))
        WHERE id = t.id;
        i := i + 1;
    END LOOP;
END $$;

-- 4. Stagger created_at timestamps on rooms so ordering is 100% deterministic
DO $$
DECLARE
    rm RECORD;
    j INT := 1;
BEGIN
    FOR rm IN SELECT id FROM public.rooms ORDER BY category, id LOOP
        UPDATE public.rooms
        SET created_at = (now() - (j * INTERVAL '15 minutes'))
        WHERE id = rm.id;
        j := j + 1;
    END LOOP;
END $$;
