-- ====================================================================
-- COMPREHENSIVE FEATURES & SEEDS MIGRATION
-- 1. Tips table & interactions (likes, bookmarks)
-- 2. Rooms table & interactions (likes, comments, bookmarks)
-- 3. Anonymous Chat sessions & messages
-- 4. Automatic counters & triggers
-- 5. RLS policies & Realtime publication
-- 6. High-quality realistic seed data
-- ====================================================================

-- 1. TIPS TABLE
CREATE TABLE IF NOT EXISTS public.tips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    author_name TEXT NOT NULL DEFAULT 'Anon',
    author_faculty TEXT NOT NULL DEFAULT 'FILKOM',
    author_gender TEXT NOT NULL DEFAULT 'Laki-laki',
    category TEXT NOT NULL CHECK (category IN ('Self-care', 'Productivity', 'Afirmasi', 'Musik', 'Curhat', 'Lainnya')),
    content TEXT NOT NULL,
    likes_count INT NOT NULL DEFAULT 0,
    bookmarks_count INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- TIP LIKES & BOOKMARKS
CREATE TABLE IF NOT EXISTS public.tip_likes (
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    tip_id UUID NOT NULL REFERENCES public.tips(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, tip_id)
);

CREATE TABLE IF NOT EXISTS public.tip_bookmarks (
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    tip_id UUID NOT NULL REFERENCES public.tips(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, tip_id)
);

-- Trigger to maintain tip likes_count & bookmarks_count
CREATE OR REPLACE FUNCTION public.handle_tip_like_counter()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        UPDATE public.tips SET likes_count = likes_count + 1 WHERE id = NEW.tip_id;
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE public.tips SET likes_count = GREATEST(likes_count - 1, 0) WHERE id = OLD.tip_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_tip_like_changed ON public.tip_likes;
CREATE TRIGGER on_tip_like_changed
    AFTER INSERT OR DELETE ON public.tip_likes
    FOR EACH ROW EXECUTE FUNCTION public.handle_tip_like_counter();

CREATE OR REPLACE FUNCTION public.handle_tip_bookmark_counter()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        UPDATE public.tips SET bookmarks_count = bookmarks_count + 1 WHERE id = NEW.tip_id;
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE public.tips SET bookmarks_count = GREATEST(bookmarks_count - 1, 0) WHERE id = OLD.tip_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_tip_bookmark_changed ON public.tip_bookmarks;
CREATE TRIGGER on_tip_bookmark_changed
    AFTER INSERT OR DELETE ON public.tip_bookmarks
    FOR EACH ROW EXECUTE FUNCTION public.handle_tip_bookmark_counter();

-- 2. ROOMS TABLE (Curhat Komunitas)
CREATE TABLE IF NOT EXISTS public.rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    author_tag TEXT NOT NULL DEFAULT 'Anonim • FILKOM',
    category TEXT NOT NULL CHECK (category IN ('Akademik', 'Kesepian', 'Keuangan', 'Hubungan', 'Lainnya')),
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    likes_count INT NOT NULL DEFAULT 0,
    comments_count INT NOT NULL DEFAULT 0,
    bookmarks_count INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ROOM COMMENTS
CREATE TABLE IF NOT EXISTS public.room_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id UUID NOT NULL REFERENCES public.rooms(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    author_tag TEXT NOT NULL DEFAULT 'Teman Kampus',
    content TEXT NOT NULL,
    likes_count INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ROOM LIKES & BOOKMARKS
CREATE TABLE IF NOT EXISTS public.room_likes (
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    room_id UUID NOT NULL REFERENCES public.rooms(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, room_id)
);

CREATE TABLE IF NOT EXISTS public.room_bookmarks (
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    room_id UUID NOT NULL REFERENCES public.rooms(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, room_id)
);

-- Triggers for room counts
CREATE OR REPLACE FUNCTION public.handle_room_like_counter()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        UPDATE public.rooms SET likes_count = likes_count + 1 WHERE id = NEW.room_id;
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE public.rooms SET likes_count = GREATEST(likes_count - 1, 0) WHERE id = OLD.room_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_room_like_changed ON public.room_likes;
CREATE TRIGGER on_room_like_changed
    AFTER INSERT OR DELETE ON public.room_likes
    FOR EACH ROW EXECUTE FUNCTION public.handle_room_like_counter();

CREATE OR REPLACE FUNCTION public.handle_room_bookmark_counter()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        UPDATE public.rooms SET bookmarks_count = bookmarks_count + 1 WHERE id = NEW.room_id;
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE public.rooms SET bookmarks_count = GREATEST(bookmarks_count - 1, 0) WHERE id = OLD.room_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_room_bookmark_changed ON public.room_bookmarks;
CREATE TRIGGER on_room_bookmark_changed
    AFTER INSERT OR DELETE ON public.room_bookmarks
    FOR EACH ROW EXECUTE FUNCTION public.handle_room_bookmark_counter();

CREATE OR REPLACE FUNCTION public.handle_room_comment_counter()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        UPDATE public.rooms SET comments_count = comments_count + 1 WHERE id = NEW.room_id;
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE public.rooms SET comments_count = GREATEST(comments_count - 1, 0) WHERE id = OLD.room_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_room_comment_changed ON public.room_comments;
CREATE TRIGGER on_room_comment_changed
    AFTER INSERT OR DELETE ON public.room_comments
    FOR EACH ROW EXECUTE FUNCTION public.handle_room_comment_counter();

-- 3. ANONYMOUS CHAT SESSIONS & MESSAGES
CREATE TABLE IF NOT EXISTS public.anon_chat_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user1_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    user2_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    mode TEXT NOT NULL DEFAULT 'Cuma mau didengar',
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'ended')),
    is_bot_session BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    ended_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.anon_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES public.anon_chat_sessions(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    sender_alias TEXT NOT NULL DEFAULT 'Anonim',
    message_text TEXT NOT NULL,
    is_system BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ====================================================================
-- RLS POLICIES FOR NEW TABLES
-- ====================================================================
ALTER TABLE public.tips ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tip_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tip_bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.room_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.room_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.room_bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.anon_chat_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.anon_messages ENABLE ROW LEVEL SECURITY;

-- Permissive Read for public/authenticated
CREATE POLICY "Allow read tips for all" ON public.tips FOR SELECT USING (true);
CREATE POLICY "Allow insert tips for auth users" ON public.tips FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow update tips for auth users" ON public.tips FOR UPDATE USING (true);

CREATE POLICY "Allow all on tip_likes for auth users" ON public.tip_likes FOR ALL USING (true);
CREATE POLICY "Allow all on tip_bookmarks for auth users" ON public.tip_bookmarks FOR ALL USING (true);

CREATE POLICY "Allow read rooms for all" ON public.rooms FOR SELECT USING (true);
CREATE POLICY "Allow insert rooms for auth users" ON public.rooms FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow update rooms for auth users" ON public.rooms FOR UPDATE USING (true);

CREATE POLICY "Allow read room_comments for all" ON public.room_comments FOR SELECT USING (true);
CREATE POLICY "Allow insert room_comments for auth users" ON public.room_comments FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow all on room_likes for auth users" ON public.room_likes FOR ALL USING (true);
CREATE POLICY "Allow all on room_bookmarks for auth users" ON public.room_bookmarks FOR ALL USING (true);

CREATE POLICY "Allow all on anon_chat_sessions for auth users" ON public.anon_chat_sessions FOR ALL USING (true);
CREATE POLICY "Allow all on anon_messages for auth users" ON public.anon_messages FOR ALL USING (true);

-- ====================================================================
-- REALTIME REPLICATION CONFIGURATION
-- ====================================================================
DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.tips;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.tip_likes;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.tip_bookmarks;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.rooms;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.room_comments;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.room_likes;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.room_bookmarks;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.anon_chat_sessions;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.anon_messages;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

-- ====================================================================
-- SEED DATA (REALISTIC CAMPUS CONTENT)
-- ====================================================================

-- 1. SEED TIPS
INSERT INTO public.tips (author_name, author_faculty, author_gender, category, content, likes_count, bookmarks_count)
VALUES
-- Musik
('Anon', 'FILKOM', 'Laki-laki', 'Musik', 'Kalau lagi burnout nugas coding atau laporan di lab sampai larut, coba dengerin playlist lo-fi atau soundtrack Studio Ghibli. Mindset langsung rileks dan fokus naik 2x lipat tanpa bikin pusing!', 142, 45),
('Anon', 'FEB', 'Perempuan', 'Musik', 'Rekomendasi lagu buat nenangin overthinking sebelum tidur: "Nanti Kita Seperti Ini" sama aransemen piano Yiruma (River Flows in You). Beneran bikin nafas berasa lebih enteng.', 98, 31),
('Anon', 'FIB', 'Perempuan', 'Musik', 'Pas lagi bad mood berat atau ngerasa capek mental, dengerin lagu-lagu indie folk akustik kayak Kings of Convenience atau Banda Neira. Rasanya kayak dipeluk secara virtual.', 76, 28),

-- Self-care
('Anon', 'FK', 'Perempuan', 'Self-care', 'Pengingat kecil: Jangan lupa minum air putih minimal 2 liter sehari pas marathon nugas di perpus pusat. Dehidrasi ringan sering kali nyamar jadi rasa pusing, lemes, dan gampang emosian.', 215, 89),
('Anon', 'FIA', 'Laki-laki', 'Self-care', 'Setiap duduk natap layar laptop 1 jam, sempetin 2 menit buat jalan muter kamar/kosan dan regangkan bahu. Postur tubuh yang tegang ngefek banget ke tingkat stres harian.', 134, 52),
('Anon', 'FSTeM', 'Perempuan', 'Self-care', 'Tidur 7 jam itu bukan kemalasan, tapi investasi performa otak. Begadang maraton 2 hari berturut-turut cuma bakal bikin kamu blank pas kuis besok paginya.', 189, 73),

-- Productivity
('Anon', 'FT', 'Laki-laki', 'Productivity', 'Teknik Pomodoro 25 menit fokus penuh tanpa sentuh HP + 5 menit istirahat beneran penyelamat deadline semester ini. Jangan paksain maraton 4 jam tanpa jeda, otak kita ada limitnya.', 312, 120),
('Anon', 'FILKOM', 'Laki-laki', 'Productivity', 'Pecah tugas besar jadi sub-tugas kecil yang konyol saking gampangnya (misal: "buka dokumen Word", "tulis judul bab"). Mulai langkah pertama itu selalu yang paling berat, trik ini bantu ngalahin prokrastinasi.', 267, 95),
('Anon', 'FEB', 'Perempuan', 'Productivity', 'Bikin "To-Do List 3 Prioritas Utama" tiap pagi. Kalau 3 hal ini beres, hari itu udah sukses. Jangan paksain nulis 15 daftar yang ujung-ujungnya bikin stres sendiri karena gak kelar.', 154, 61),

-- Afirmasi
('Anon', 'FKG', 'Perempuan', 'Afirmasi', 'Gak apa-apa hari ini belum selesai semua target yang kamu rencanain. Kamu udah berjuang sejauh ini hari ini, banggalah sama langkah kecilmu dan istirahatlah dengan tenang.', 420, 156),
('Anon', 'FISIP', 'Laki-laki', 'Afirmasi', 'Kamu berharga bukan cuma karena IPK atau prestasi yang kamu capai. Kehadiranmu, kebaikan hatimu, dan caramu memperlakukan orang lain juga bernilai tinggi.', 380, 142),
('Anon', 'FH', 'Perempuan', 'Afirmasi', 'Tarik nafas dalam-dalam... hembuskan perlahan. Hal yang kamu khawatirkan hari ini kemungkinan besar gak akan seburuk bayanganmu. Kamu pasti bisa lewatin ini.', 290, 110),

-- Curhat
('Anon', 'FBiPK', 'Laki-laki', 'Curhat', 'Wajar banget ngerasa tertinggal pas liat postingan pencapaian temen di LinkedIn atau IG. Tapi ingat kawan, timeline setiap orang beda-beda. Fokus rawat bunga di kebunmu sendiri.', 512, 230),
('Anon', 'FAST', 'Perempuan', 'Curhat', 'Buat anak rantau yang lagi kangen rumah (homesick): telpon orang rumah walau cuma 5 menit. Suara ibu atau bapak seringkali jadi obat penawar lelah paling ampuh.', 345, 128),
('Anon', 'FTAB', 'Laki-laki', 'Curhat', 'Kalau lagi ngerasa sendirian di tengah ramainya kampus, ingat kalau ribuan mahasiswa lain di sini juga sering ngerasain hal yang sama. Jangan ragu buat sapa duluan ya.', 198, 64)
ON CONFLICT DO NOTHING;

-- 2. SEED ROOMS
INSERT INTO public.rooms (author_tag, category, title, content, likes_count, comments_count, bookmarks_count)
VALUES
(
    'Laki-laki • FILKOM',
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
    1240,
    3,
    180
),
(
    'Perempuan • FEB',
    'Kesepian',
    'ternyata yang paling sakit bukan kalah, tapi sadar kalau gak akan ada lagi "Di kesempatan berikutnya" buat dia.',
    'Sering banget kita mikir kalau orang yang selalu ada bakal selamanya ada. Sampai akhirnya waktu memisahkan jalan hidup kita masing-masing. Buat kalian yang masih punya teman baik atau orang terkasih di samping kalian saat ini, tolong dijaga baik-baik ya. Jangan tunggu sampai mereka cuma tinggal memori di album foto lama.',
    890,
    2,
    95
),
(
    'Laki-laki • FT',
    'Akademik',
    'hidup udah agak mantap tapi ada aja tugas kalkulus dan praktikum yang bikin IP ketar-ketir',
    'Semester ini beneran ujian kesabaran dan mental banget. Tiap minggu ada 3 modul praktikum, asistensi revisi 4 kali, kuis mendadak, belum lagi persiapan UTS. Kadang cuma pengen rebahan seharian tanpa mikirin rumus dan error. Tapi ya dinikmati aja prosesnya, demi toga biru nanti!',
    675,
    2,
    72
),
(
    'Perempuan • FILKOM',
    'Keuangan',
    'duh gusti, apa sih sekarang apa apa mahal. mo beli ini itu abis buat makan doang',
    'Bulan tua di Malang beneran butuh kalkulasi level dewa. Uang jajan bulanan yang dulu cukup buat sebulan, sekarang baru tanggal 18 udah menipis. Harga ayam geprek, nasi padang, sampai es teh semuanya naik. Ada tips bertahan hidup anak kos yang hemat tapi tetep bergizi gak teman-teman?',
    540,
    3,
    115
),
(
    'Laki-laki • FIA',
    'Akademik',
    'Dilema skripsi bab 4: data udah dapet tapi bingung ngerangkai analisisnya',
    'Ada yang pernah ngerasain stuck berhari-hari natap kursor kedip-kedip di laptop? Pengen banget segera lulus tahun ini biar orang tua bangga, tapi kepala rasanya buntu banget. Buat yang lagi di fase akhir juga, semangat ya kita pasti bisa ngelewatin ini!',
    412,
    1,
    64
)
ON CONFLICT DO NOTHING;

-- 3. SEED ROOM COMMENTS
DO $$
DECLARE
    r_id UUID;
BEGIN
    SELECT id INTO r_id FROM public.rooms WHERE title LIKE '%#mykisah%' LIMIT 1;
    IF r_id IS NOT NULL THEN
        INSERT INTO public.room_comments (room_id, author_tag, content, likes_count) VALUES
        (r_id, 'Anonim • FEB', 'sini bang kutemenin, when yh... kita emang sama-sama nunggu giliran aja kok wkwk', 42),
        (r_id, 'Anonim • FIA', 'Fokus benahi diri dulu kak, jodoh yang tepat bakal dateng di waktu yang paling pas!', 28),
        (r_id, 'Anonim • FK', 'Valid banget perasaannya. Tapi bersyukur juga kamu udah di fase mandiri dan tenang, itu pencapaian besar loh!', 35)
        ON CONFLICT DO NOTHING;
    END IF;

    SELECT id INTO r_id FROM public.rooms WHERE category = 'Keuangan' LIMIT 1;
    IF r_id IS NOT NULL THEN
        INSERT INTO public.room_comments (room_id, author_tag, content, likes_count) VALUES
        (r_id, 'Anonim • FT', 'Masak nasi sendiri di kos kak! Beli lauknya aja di warteg, lumayan bisa hemat 40% sebulan.', 67),
        (r_id, 'Anonim • FPIK', 'Cari promo tanggal kembar atau manfaatin voucher diskon ojol makan hemat kawan.', 19),
        (r_id, 'Anonim • FH', 'Semangat anak kos! Kalo beneran kepepet, telur ceplok + kecap selalu jadi kawan setia.', 51)
        ON CONFLICT DO NOTHING;
    END IF;
END $$;

-- 4. SEED INITIAL SAMBATS
ALTER TABLE public.sambats ALTER COLUMN user_id DROP NOT NULL;

INSERT INTO public.sambats (content, category, is_anonymous, cheer_count)
VALUES
('Pengen makan mie instan tengah malem tapi takut jerawatan dan gendut, padahal baunya udah kecium dari kamar sebelah kosan 😭', 'Curhat', true, 89),
('Hujan deras di Malang sore ini bikin males ke mana-mana, enaknya tidur berselimut sambil dengerin suara air hujan.', 'Self-care', true, 120),
('Dosen penguji acc revisian bab 3 tanpa coretan banyak! Akhirnya bisa tidur nyenyak malam ini guys ✨', 'Afirmasi', true, 245)
ON CONFLICT DO NOTHING;
