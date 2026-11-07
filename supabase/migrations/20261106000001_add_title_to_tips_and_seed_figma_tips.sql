-- ============================================================================
-- Migration 20261106000001: 
-- 1. Add title column to public.tips
-- 2. Fix handle_new_user trigger function (counselor_status & is_verified for mahasiswa)
-- 3. Seed Realistic UB Student Personas in auth.users & public.profiles
-- 4. Seed Canonical Figma Tips & UB Community Tips with Relational User IDs
-- 5. Seed Relational Interactions (tip_likes, tip_bookmarks, room_comments)
-- 6. Organic Metric Distribution (Replacing synthetic 99999 placeholders)
-- ============================================================================

-- ============================================================================
-- 1. ADD COLUMN title TO public.tips
-- ============================================================================

ALTER TABLE public.tips 
ADD COLUMN IF NOT EXISTS title TEXT;

-- ============================================================================
-- 2. FIX TRIGGER FUNCTION handle_new_user (Set counselor_status = 'approved' for mahasiswa)
-- ============================================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    v_role user_role := 'mahasiswa';
    v_is_verified boolean := true;
    v_counselor_status text := 'approved';
    v_hobbies text[] := '{}';
    v_topics text[] := '{}';
    v_raw_faculty text;
    v_raw_prodi text;
    v_faculty text := 'FILKOM';
    v_study_program text := 'S1 Teknik Informatika';
BEGIN
    -- Ekstrak role dari metadata
    IF NEW.raw_user_meta_data->>'role' = 'konselor' THEN
        v_role := 'konselor';
        v_is_verified := false;
        v_counselor_status := 'pending';
    ELSE
        v_role := 'mahasiswa';
        v_is_verified := true;
        v_counselor_status := 'approved';
    END IF;

    -- Ekstrak hobbies jika ada
    IF NEW.raw_user_meta_data->'hobbies' IS NOT NULL THEN
        SELECT ARRAY_AGG(x.val::text)
        INTO v_hobbies
        FROM jsonb_array_elements_text(NEW.raw_user_meta_data->'hobbies') AS x(val);
    END IF;

    -- Ekstrak topics jika ada
    IF NEW.raw_user_meta_data->'topics' IS NOT NULL THEN
        SELECT ARRAY_AGG(x.val::text)
        INTO v_topics
        FROM jsonb_array_elements_text(NEW.raw_user_meta_data->'topics') AS x(val);
    END IF;

    -- Ekstrak dan normalisasi fakultas
    v_raw_faculty := COALESCE(NEW.raw_user_meta_data->>'faculty', 'FILKOM');
    v_faculty := CASE
        WHEN v_raw_faculty IN ('14', 'FILKOM') OR v_raw_faculty ILIKE '%Ilmu Komputer%' THEN 'FILKOM'
        WHEN v_raw_faculty IN ('01', '1', 'FH') OR v_raw_faculty ILIKE '%Hukum%' THEN 'FH'
        WHEN v_raw_faculty IN ('02', '2', 'FEB') OR v_raw_faculty ILIKE '%Ekonomi%' THEN 'FEB'
        WHEN v_raw_faculty IN ('03', '3', 'FIA') OR v_raw_faculty ILIKE '%Administrasi%' THEN 'FIA'
        WHEN v_raw_faculty IN ('04', '4', 'FBiPK') OR v_raw_faculty ILIKE '%Bio-Industri%' THEN 'FBiPK'
        WHEN v_raw_faculty IN ('05', '5', 'FAST') OR v_raw_faculty ILIKE '%Peternakan%' THEN 'FAST'
        WHEN v_raw_faculty IN ('06', '6', 'FT') OR (v_raw_faculty ILIKE '%Teknik%' AND v_raw_faculty NOT ILIKE '%Agroindustri%' AND v_raw_faculty NOT ILIKE '%Komputer%') THEN 'FT'
        WHEN v_raw_faculty IN ('07', '7', 'FK') OR (v_raw_faculty ILIKE '%Kedokteran%' AND v_raw_faculty NOT ILIKE '%Gigi%' AND v_raw_faculty NOT ILIKE '%Hewan%') THEN 'FK'
        WHEN v_raw_faculty IN ('08', '8', 'FPIK') OR v_raw_faculty ILIKE '%Perikanan%' THEN 'FPIK'
        WHEN v_raw_faculty IN ('09', '9', 'FSTeM') OR v_raw_faculty ILIKE '%Matematika%' THEN 'FSTeM'
        WHEN v_raw_faculty IN ('10', 'FTAB') OR v_raw_faculty ILIKE '%Agroindustri%' THEN 'FTAB'
        WHEN v_raw_faculty IN ('11', 'FIB') OR v_raw_faculty ILIKE '%Ilmu Budaya%' THEN 'FIB'
        WHEN v_raw_faculty IN ('12', 'FISIP') OR v_raw_faculty ILIKE '%Ilmu Sosial%' THEN 'FISIP'
        WHEN v_raw_faculty IN ('13', 'FKH') OR v_raw_faculty ILIKE '%Kedokteran Hewan%' THEN 'FKH'
        WHEN v_raw_faculty IN ('15', 'FKG') OR v_raw_faculty ILIKE '%Kedokteran Gigi%' THEN 'FKG'
        WHEN v_raw_faculty IN ('16', 'FV') OR v_raw_faculty ILIKE '%Vokasi%' THEN 'FV'
        WHEN v_raw_faculty IN ('17', 'FIKES') OR v_raw_faculty ILIKE '%Ilmu Kesehatan%' THEN 'FIKES'
        WHEN v_raw_faculty IN ('18', 'SP') OR v_raw_faculty ILIKE '%Pascasarjana%' THEN 'SP'
        ELSE v_raw_faculty
    END;

    -- Ekstrak dan normalisasi prodi
    v_raw_prodi := COALESCE(NEW.raw_user_meta_data->>'study_program', 'S1 Teknik Informatika');
    v_study_program := CASE
        WHEN v_raw_prodi IN ('14.01', 'Teknik Informatika') THEN 'S1 Teknik Informatika'
        WHEN v_raw_prodi IN ('14.02', 'Sistem Informasi') THEN 'S1 Sistem Informasi'
        WHEN v_raw_prodi IN ('14.03', 'Pendidikan Teknologi Informasi') THEN 'S1 Pendidikan Teknologi Informasi'
        WHEN v_raw_prodi IN ('14.04', 'Teknik Komputer') THEN 'S1 Teknik Komputer'
        WHEN v_raw_prodi IN ('14.05', 'Teknologi Informasi') THEN 'S1 Teknologi Informasi'
        WHEN v_raw_prodi = '01.01' THEN 'S1 Ilmu Hukum'
        WHEN v_raw_prodi = '07.01' OR v_raw_prodi = 'Kedokteran' THEN 'S1 Kedokteran'
        ELSE v_raw_prodi
    END;

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
        is_online,
        is_verified,
        counselor_status,
        created_at,
        updated_at
    ) VALUES (
        NEW.id,
        v_role,
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'Pengguna Baru'),
        COALESCE(NEW.raw_user_meta_data->>'nickname', 'Sobat'),
        COALESCE(NEW.raw_user_meta_data->>'gender', 'Lainnya'),
        COALESCE(NEW.raw_user_meta_data->>'batch_year', '2025'),
        v_faculty,
        v_study_program,
        v_hobbies,
        v_topics,
        CASE WHEN v_role::text = 'konselor' THEN true ELSE false END,
        v_is_verified,
        v_counselor_status,
        now(),
        now()
    )
    ON CONFLICT (id) DO UPDATE SET
        full_name = EXCLUDED.full_name,
        role = EXCLUDED.role,
        nickname = EXCLUDED.nickname,
        faculty = EXCLUDED.faculty,
        study_program = EXCLUDED.study_program,
        batch_year = EXCLUDED.batch_year,
        gender = EXCLUDED.gender,
        hobbies = CASE WHEN array_length(EXCLUDED.hobbies, 1) > 0 THEN EXCLUDED.hobbies ELSE profiles.hobbies END,
        topics = CASE WHEN array_length(EXCLUDED.topics, 1) > 0 THEN EXCLUDED.topics ELSE profiles.topics END,
        is_verified = CASE WHEN EXCLUDED.role = 'konselor' THEN profiles.is_verified ELSE EXCLUDED.is_verified END,
        counselor_status = CASE WHEN EXCLUDED.role = 'konselor' THEN profiles.counselor_status ELSE EXCLUDED.counselor_status END,
        updated_at = now();

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 3. SEED REALISTIC STUDENT PERSONAS IN auth.users & public.profiles
-- Password for all seed users is 'password123'
-- Valid hexadecimal UUID prefix 'b' for UB Students
-- ============================================================================

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
-- 1. Sekar Ayu Wandira (Kak Sekar - FIB Sastra Inggris)
(
    'b1111111-1111-1111-1111-111111111101',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'student.sekar@ub.ac.id',
    extensions.crypt('password123', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"Sekar Ayu Wandira","nickname":"Kak Sekar","role":"mahasiswa","gender":"Perempuan","faculty":"Fakultas Ilmu Budaya (FIB)","study_program":"S1 Sastra Inggris","batch_year":"2022","hobbies":["Membaca","Menulis","Musik Akustik"],"topics":["Afirmasi","Kesehatan Mental","Self-love"]}',
    now() - INTERVAL '30 days',
    now()
),
-- 2. Harry Wicaksono (Kak Harry - FEB Manajemen)
(
    'b1111111-1111-1111-1111-111111111102',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'student.harry@ub.ac.id',
    extensions.crypt('password123', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"Harry Wicaksono","nickname":"Kak Harry","role":"mahasiswa","gender":"Laki-laki","faculty":"Fakultas Ekonomi dan Bisnis (FEB)","study_program":"S1 Manajemen","batch_year":"2021","hobbies":["Olahraga","Membaca Buku","Podcasting"],"topics":["Produktivitas","Manajemen Waktu","Karier"]}',
    now() - INTERVAL '35 days',
    now()
),
-- 3. Cris Pratama (Kak Cris - FK Kedokteran)
(
    'b1111111-1111-1111-1111-111111111103',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'student.cris@ub.ac.id',
    extensions.crypt('password123', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"Cris Pratama","nickname":"Kak Cris","role":"mahasiswa","gender":"Perempuan","faculty":"Fakultas Kedokteran (FK)","study_program":"S1 Kedokteran","batch_year":"2023","hobbies":["Jogging","Meditation","Memasak Sehat"],"topics":["Self-care","Kesehatan Fisik","Tidur Berkualitas"]}',
    now() - INTERVAL '25 days',
    now()
),
-- 4. Budi Santoso (FT Teknik Sipil)
(
    'b1111111-1111-1111-1111-111111111104',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'student.budi@ub.ac.id',
    extensions.crypt('password123', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"Budi Santoso","nickname":"Budi S.","role":"mahasiswa","gender":"Laki-laki","faculty":"Fakultas Teknik (FT)","study_program":"S1 Teknik Sipil","batch_year":"2022","hobbies":["Badminton","Gaming","Musik Rock"],"topics":["Akademik","Stress Management","Tugas Kuliah"]}',
    now() - INTERVAL '40 days',
    now()
),
-- 5. Dinda Permata (FILKOM Teknik Informatika)
(
    'b1111111-1111-1111-1111-111111111105',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'student.dinda@ub.ac.id',
    extensions.crypt('password123', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"Dinda Permata","nickname":"Dinda","role":"mahasiswa","gender":"Perempuan","faculty":"Fakultas Ilmu Komputer (FILKOM)","study_program":"S1 Teknik Informatika","batch_year":"2024","hobbies":["Coding","Desain Grafis","Ngopi"],"topics":["Curhat","Adaptasi Kampus","Pertemanan"]}',
    now() - INTERVAL '20 days',
    now()
),
-- 6. Reza Rahardian (FIA Administrasi Bisnis)
(
    'b1111111-1111-1111-1111-111111111106',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'student.reza@ub.ac.id',
    extensions.crypt('password123', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"Reza Rahardian","nickname":"Reza","role":"mahasiswa","gender":"Laki-laki","faculty":"Fakultas Ilmu Administrasi (FIA)","study_program":"S1 Administrasi Bisnis","batch_year":"2023","hobbies":["Fotografi","Travelling","Musik Lo-Fi"],"topics":["Musik","Finansial Mahasiswa","Organisasi"]}',
    now() - INTERVAL '28 days',
    now()
)
ON CONFLICT (id) DO UPDATE SET
    raw_user_meta_data = EXCLUDED.raw_user_meta_data,
    updated_at = now();

-- Pastikan sinkronisasi eksplisit pada public.profiles
INSERT INTO public.profiles (
    id, role, full_name, nickname, gender, batch_year, faculty, study_program,
    hobbies, topics, is_online, is_verified, counselor_status, created_at, updated_at
) VALUES
('b1111111-1111-1111-1111-111111111101', 'mahasiswa', 'Sekar Ayu Wandira', 'Kak Sekar', 'Perempuan', '2022', 'Fakultas Ilmu Budaya (FIB)', 'S1 Sastra Inggris', ARRAY['Membaca','Menulis','Musik Akustik'], ARRAY['Afirmasi','Kesehatan Mental','Self-love'], false, true, 'approved', now() - INTERVAL '30 days', now()),
('b1111111-1111-1111-1111-111111111102', 'mahasiswa', 'Harry Wicaksono', 'Kak Harry', 'Laki-laki', '2021', 'Fakultas Ekonomi dan Bisnis (FEB)', 'S1 Manajemen', ARRAY['Olahraga','Membaca Buku','Podcasting'], ARRAY['Produktivitas','Manajemen Waktu','Karier'], false, true, 'approved', now() - INTERVAL '35 days', now()),
('b1111111-1111-1111-1111-111111111103', 'mahasiswa', 'Cris Pratama', 'Kak Cris', 'Perempuan', '2023', 'Fakultas Kedokteran (FK)', 'S1 Kedokteran', ARRAY['Jogging','Meditation','Memasak Sehat'], ARRAY['Self-care','Kesehatan Fisik','Tidur Berkualitas'], false, true, 'approved', now() - INTERVAL '25 days', now()),
('b1111111-1111-1111-1111-111111111104', 'mahasiswa', 'Budi Santoso', 'Budi S.', 'Laki-laki', '2022', 'Fakultas Teknik (FT)', 'S1 Teknik Sipil', ARRAY['Badminton','Gaming','Musik Rock'], ARRAY['Akademik','Stress Management','Tugas Kuliah'], false, true, 'approved', now() - INTERVAL '40 days', now()),
('b1111111-1111-1111-1111-111111111105', 'mahasiswa', 'Dinda Permata', 'Dinda', 'Perempuan', '2024', 'Fakultas Ilmu Komputer (FILKOM)', 'S1 Teknik Informatika', ARRAY['Coding','Desain Grafis','Ngopi'], ARRAY['Curhat','Adaptasi Kampus','Pertemanan'], false, true, 'approved', now() - INTERVAL '20 days', now()),
('b1111111-1111-1111-1111-111111111106', 'mahasiswa', 'Reza Rahardian', 'Reza', 'Laki-laki', '2023', 'Fakultas Ilmu Administrasi (FIA)', 'S1 Administrasi Bisnis', ARRAY['Fotografi','Travelling','Musik Lo-Fi'], ARRAY['Musik','Finansial Mahasiswa','Organisasi'], false, true, 'approved', now() - INTERVAL '28 days', now())
ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    nickname = EXCLUDED.nickname,
    gender = EXCLUDED.gender,
    batch_year = EXCLUDED.batch_year,
    faculty = EXCLUDED.faculty,
    study_program = EXCLUDED.study_program,
    hobbies = EXCLUDED.hobbies,
    topics = EXCLUDED.topics,
    is_verified = true,
    counselor_status = 'approved',
    updated_at = now();

-- ============================================================================
-- 4. SEED CANONICAL TIPS FIGMA & COMMUNITY TIPS (WITH REAL USER IDs & ORGANIC METRICS)
-- Valid hexadecimal UUID prefix 'c' for Tips
-- ============================================================================

-- Tip 1: Afirmasi (Kak Sekar - b111...101) - Sesuai docs/ui/Isi Tips.png dan Tips.png
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
) VALUES (
    'c1111111-1111-1111-1111-111111111101',
    'b1111111-1111-1111-1111-111111111101',
    'Tips mengatasi perasaan when yh berlebih',
    'Kak Sekar',
    'FIB',
    'Perempuan',
    'Afirmasi',
    'Pernah ga sih kamu merasa when yh, ya when yh gitu, when yh secara berlebihan? Di era media sosial sekarang, frasa "kapan ya" alias "when yh" sering banget muncul secara otomatis di kepala kita saat melihat pencapaian, gaya hidup, atau kesuksesan orang lain. Meskipun terlihat sepele sebagai candaan, memelihara perasaan ini terlalu sering bisa menjebak kita dalam siklus rasa insecure dan tidak percaya pada kemampuan diri sendiri.' || E'\n\n' ||
    'Langkah Nyata Mengurangi Frekuensi "When Yh":' || E'\n' ||
    '1. Ubah Pertanyaan Menjadi Aksi: Setiap kali pikiran "when yh" muncul, langsung potong kalimat itu dan ganti dengan kalimat afirmasi positif, seperti: "Waktuku akan tiba, dan sekarang aku sedang berproses."' || E'\n' ||
    '2. Praktikkan Jurnal Rasa Syukur: Luangkan waktu 5 menit setiap malam untuk menulis 3 hal baik yang sudah kamu capai atau miliki hari ini, sekecil apa pun itu.' || E'\n' ||
    '3. Fokus pada Jalur Sendiri: Ingat bahwa garis start dan finish setiap orang berbeda. Membandingkan prosesmu dengan hasil akhir orang lain hanya akan membuang energimu secara sia-sia.',
    184,
    62,
    now() - INTERVAL '1 day 4 hours'
)
ON CONFLICT (id) DO UPDATE SET
    user_id = EXCLUDED.user_id,
    title = EXCLUDED.title,
    author_name = EXCLUDED.author_name,
    author_faculty = EXCLUDED.author_faculty,
    author_gender = EXCLUDED.author_gender,
    category = EXCLUDED.category,
    content = EXCLUDED.content,
    likes_count = EXCLUDED.likes_count,
    bookmarks_count = EXCLUDED.bookmarks_count;

-- Tip 2: Productivity (Kak Harry - b111...102) - Sesuai docs/ui/Tips.png
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
) VALUES (
    'c1111111-1111-1111-1111-111111111102',
    'b1111111-1111-1111-1111-111111111102',
    'Tips mencapai produktifitas tinggi dalam diam',
    'Kak Harry',
    'FEB',
    'Laki-laki',
    'Productivity',
    '“Work Hard in silence. Let success be your noise.” Dikelilingi dengan lingkungan yang berisik? haus validasi? atau bahkan suka mengkritik dirimu? Ikuti caraku untuk tetap fokus pada diri sendiri di saat dunia melawan dirimu!' || E'\n\n' ||
    'Langkah Praktis:' || E'\n' ||
    '1. Matikan Notifikasi Distraksi: Gunakan Do Not Disturb saat sesi deep work fokus belajar atau nugas.' || E'\n' ||
    '2. Ukur Progres Bukan Omongan: Buktikan hasil lewat aksi dan karya nyata, bukan kata-kata di media sosial.' || E'\n' ||
    '3. Jaga Konsistensi Kecil: 1 jam fokus berkualitas setiap hari mengalahkan 10 jam maraton satu kali sebulan.',
    142,
    48,
    now() - INTERVAL '2 days 6 hours'
)
ON CONFLICT (id) DO UPDATE SET
    user_id = EXCLUDED.user_id,
    title = EXCLUDED.title,
    author_name = EXCLUDED.author_name,
    author_faculty = EXCLUDED.author_faculty,
    author_gender = EXCLUDED.author_gender,
    category = EXCLUDED.category,
    content = EXCLUDED.content,
    likes_count = EXCLUDED.likes_count,
    bookmarks_count = EXCLUDED.bookmarks_count;

-- Tip 3: Self-care (Kak Cris - b111...103) - Sesuai docs/ui/Tips.png
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
) VALUES (
    'c1111111-1111-1111-1111-111111111103',
    'b1111111-1111-1111-1111-111111111103',
    'Tips jaga hidrasi diri lewat air putih',
    'Kak Cris',
    'FK',
    'Perempuan',
    'Self-care',
    'Pernah ga sih ngerasa susah banget nolak boba atau soda pas kumpul bareng teman? Ingat, tubuhmu adalah aset investasi terbaikmu! Caraku mengatasinya: selalu pesan air putih dingin, lalu tatap mata temanmu dengan penuh determinasi dan bilang "Agua saja, Siuuu!"' || E'\n\n' ||
    'Langkah Praktis:' || E'\n' ||
    '1. Bawa Tumbler Favorit: Jadikan botol minum sebagai teman setia ke mana pun kamu pergi di kampus.' || E'\n' ||
    '2. Pasang Pengingat Minum: Minum 1 gelas setiap sebelum dan sesudah aktivitas belajar.' || E'\n' ||
    '3. Nikmati Kesegarannya: Air putih dingin tanpa gula membantu menjaga fokus dan mencegah rasa pusing/lemas.',
    119,
    37,
    now() - INTERVAL '3 days 2 hours'
)
ON CONFLICT (id) DO UPDATE SET
    user_id = EXCLUDED.user_id,
    title = EXCLUDED.title,
    author_name = EXCLUDED.author_name,
    author_faculty = EXCLUDED.author_faculty,
    author_gender = EXCLUDED.author_gender,
    category = EXCLUDED.category,
    content = EXCLUDED.content,
    likes_count = EXCLUDED.likes_count,
    bookmarks_count = EXCLUDED.bookmarks_count;

-- Tip 4: Musik (Dinda - b111...105)
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
) VALUES (
    'c1111111-1111-1111-1111-111111111104',
    'b1111111-1111-1111-1111-111111111105',
    'Playlist Lo-Fi & Ghibli penyelamat deadline koding',
    'Dinda',
    'FILKOM',
    'Perempuan',
    'Musik',
    'Kalau lagi burnout nugas coding atau laporan di lab sampai larut malam, coba dengerin playlist lo-fi atau soundtrack Studio Ghibli. Mindset langsung rileks dan fokus naik tanpa bikin pusing!' || E'\n\n' ||
    'Langkah Rekomendasi:' || E'\n' ||
    '1. Gunakan earphone dengan volume sedang agar tidak cepat lelah pendengaran.' || E'\n' ||
    '2. Hindari lagu berlirik saat butuh konsentrasi logika tinggi.' || E'\n' ||
    '3. Selingi dengan peregangan otot leher setiap 45 menit.',
    86,
    29,
    now() - INTERVAL '18 hours'
)
ON CONFLICT (id) DO UPDATE SET
    user_id = EXCLUDED.user_id,
    title = EXCLUDED.title,
    author_name = EXCLUDED.author_name,
    author_faculty = EXCLUDED.author_faculty,
    author_gender = EXCLUDED.author_gender,
    category = EXCLUDED.category,
    content = EXCLUDED.content,
    likes_count = EXCLUDED.likes_count,
    bookmarks_count = EXCLUDED.bookmarks_count;

-- Tip 5: Curhat (Budi S. - b111...104)
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
) VALUES (
    'c1111111-1111-1111-1111-111111111105',
    'b1111111-1111-1111-1111-111111111104',
    'Menyikapi timeline hidup yang beda dengan teman sebaya',
    'Budi S.',
    'FT',
    'Laki-laki',
    'Curhat',
    'Wajar banget ngerasa tertinggal pas liat postingan pencapaian temen di LinkedIn atau IG. Tapi ingat kawan, timeline setiap orang beda-beda. Fokus rawat bunga di kebunmu sendiri.' || E'\n\n' ||
    'Pengingat Hati:' || E'\n' ||
    '1. Berhenti membandingkan bab 1 hidupmu dengan bab 10 orang lain.' || E'\n' ||
    '2. Rayakan progres kecilmu hari ini, sekecil apa pun itu.' || E'\n' ||
    '3. Percayalah bahwa setiap usaha jujur akan menemukan buah manisnya.',
    95,
    33,
    now() - INTERVAL '4 days 10 hours'
)
ON CONFLICT (id) DO UPDATE SET
    user_id = EXCLUDED.user_id,
    title = EXCLUDED.title,
    author_name = EXCLUDED.author_name,
    author_faculty = EXCLUDED.author_faculty,
    author_gender = EXCLUDED.author_gender,
    category = EXCLUDED.category,
    content = EXCLUDED.content,
    likes_count = EXCLUDED.likes_count,
    bookmarks_count = EXCLUDED.bookmarks_count;

-- Tip 6: Productivity (Reza - b111...106)
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
) VALUES (
    'c1111111-1111-1111-1111-111111111106',
    'b1111111-1111-1111-1111-111111111106',
    'Manajemen to-do list 3 prioritas anti-stres',
    'Reza',
    'FIA',
    'Laki-laki',
    'Productivity',
    'Bikin "To-Do List 3 Prioritas Utama" tiap pagi. Kalau 3 hal ini beres, hari itu udah sukses. Jangan paksain nulis 15 daftar yang ujung-ujungnya bikin stres sendiri karena gak kelar.' || E'\n\n' ||
    'Langkah Praktis:' || E'\n' ||
    '1. Pilih 1 tugas terberat di pagi hari saat energi otak masih optimal.' || E'\n' ||
    '2. Selesaikan 2 tugas pendukung di siang atau sore hari.' || E'\n' ||
    '3. Tutup hari dengan istirahat tanpa rasa bersalah.',
    74,
    21,
    now() - INTERVAL '5 days 8 hours'
)
ON CONFLICT (id) DO UPDATE SET
    user_id = EXCLUDED.user_id,
    title = EXCLUDED.title,
    author_name = EXCLUDED.author_name,
    author_faculty = EXCLUDED.author_faculty,
    author_gender = EXCLUDED.author_gender,
    category = EXCLUDED.category,
    content = EXCLUDED.content,
    likes_count = EXCLUDED.likes_count,
    bookmarks_count = EXCLUDED.bookmarks_count;

-- ============================================================================
-- 5. BACKFILL & NORMALIZE EXISTING TIPS (Hapus nilai dummy 99999 & isi user_id)
-- ============================================================================

-- Backfill user_id pada tips lama yang user_id-nya masih NULL
UPDATE public.tips
SET user_id = CASE
    WHEN author_faculty ILIKE '%FIB%' THEN 'b1111111-1111-1111-1111-111111111101'::uuid
    WHEN author_faculty ILIKE '%FEB%' THEN 'b1111111-1111-1111-1111-111111111102'::uuid
    WHEN author_faculty ILIKE '%FK%'  THEN 'b1111111-1111-1111-1111-111111111103'::uuid
    WHEN author_faculty ILIKE '%FT%'  THEN 'b1111111-1111-1111-1111-111111111104'::uuid
    WHEN author_faculty ILIKE '%FILKOM%' THEN 'b1111111-1111-1111-1111-111111111105'::uuid
    ELSE 'b1111111-1111-1111-1111-111111111106'::uuid
END
WHERE user_id IS NULL;

-- Backfill title jika masih ada yang NULL
UPDATE public.tips
SET title = CASE
    WHEN content ILIKE 'Tips %' AND position(E'\n' in content) > 0
        THEN split_part(content, E'\n', 1)
    WHEN content ILIKE 'Tips %'
        THEN content
    ELSE CONCAT('Tips ', category)
END
WHERE title IS NULL OR trim(title) = '';

-- Normalisasi angka likes_count dan bookmarks_count yang tidak realistis (> 500)
UPDATE public.tips
SET likes_count = CASE
    WHEN likes_count >= 99999 THEN 184
    WHEN likes_count > 500 THEN FLOOR(random() * 60 + 50)::int
    ELSE likes_count
END,
bookmarks_count = CASE
    WHEN bookmarks_count > 200 THEN FLOOR(random() * 20 + 20)::int
    ELSE bookmarks_count
END
WHERE likes_count > 500 OR bookmarks_count > 200;

-- ============================================================================
-- 6. SEED RELATIONAL tip_likes & tip_bookmarks (Antar Persona Mahasiswa & Konselor)
-- ============================================================================

INSERT INTO public.tip_likes (user_id, tip_id, created_at)
VALUES
-- Interaksi pada Tip Kak Sekar (Afirmasi)
('b1111111-1111-1111-1111-111111111102', 'c1111111-1111-1111-1111-111111111101', now() - INTERVAL '1 day'),
('b1111111-1111-1111-1111-111111111103', 'c1111111-1111-1111-1111-111111111101', now() - INTERVAL '22 hours'),
('b1111111-1111-1111-1111-111111111104', 'c1111111-1111-1111-1111-111111111101', now() - INTERVAL '20 hours'),
('b1111111-1111-1111-1111-111111111105', 'c1111111-1111-1111-1111-111111111101', now() - INTERVAL '15 hours'),
('b1111111-1111-1111-1111-111111111106', 'c1111111-1111-1111-1111-111111111101', now() - INTERVAL '10 hours'),
('a1111111-1111-1111-1111-111111111101', 'c1111111-1111-1111-1111-111111111101', now() - INTERVAL '8 hours'),
('a1111111-1111-1111-1111-111111111102', 'c1111111-1111-1111-1111-111111111101', now() - INTERVAL '5 hours'),

-- Interaksi pada Tip Kak Harry (Productivity)
('b1111111-1111-1111-1111-111111111101', 'c1111111-1111-1111-1111-111111111102', now() - INTERVAL '2 days'),
('b1111111-1111-1111-1111-111111111103', 'c1111111-1111-1111-1111-111111111102', now() - INTERVAL '1 day 18 hours'),
('b1111111-1111-1111-1111-111111111105', 'c1111111-1111-1111-1111-111111111102', now() - INTERVAL '1 day 12 hours'),
('a1111111-1111-1111-1111-111111111104', 'c1111111-1111-1111-1111-111111111102', now() - INTERVAL '1 day'),

-- Interaksi pada Tip Kak Cris (Self-care)
('b1111111-1111-1111-1111-111111111101', 'c1111111-1111-1111-1111-111111111103', now() - INTERVAL '2 days 10 hours'),
('b1111111-1111-1111-1111-111111111102', 'c1111111-1111-1111-1111-111111111103', now() - INTERVAL '2 days'),
('b1111111-1111-1111-1111-111111111104', 'c1111111-1111-1111-1111-111111111103', now() - INTERVAL '1 day 14 hours'),
('a1111111-1111-1111-1111-111111111105', 'c1111111-1111-1111-1111-111111111103', now() - INTERVAL '1 day')
ON CONFLICT (user_id, tip_id) DO NOTHING;

INSERT INTO public.tip_bookmarks (user_id, tip_id, created_at)
VALUES
('b1111111-1111-1111-1111-111111111102', 'c1111111-1111-1111-1111-111111111101', now() - INTERVAL '1 day'),
('b1111111-1111-1111-1111-111111111105', 'c1111111-1111-1111-1111-111111111101', now() - INTERVAL '12 hours'),
('a1111111-1111-1111-1111-111111111101', 'c1111111-1111-1111-1111-111111111101', now() - INTERVAL '6 hours'),
('b1111111-1111-1111-1111-111111111101', 'c1111111-1111-1111-1111-111111111102', now() - INTERVAL '2 days'),
('b1111111-1111-1111-1111-111111111104', 'c1111111-1111-1111-1111-111111111103', now() - INTERVAL '1 day 8 hours')
ON CONFLICT (user_id, tip_id) DO NOTHING;

-- ============================================================================
-- 7. SEED & NORMALIZE ROOMS (RUANG CURHAT KOMUNITAS) WITH USER IDs
-- ============================================================================

-- Backfill user_id pada rooms jika masih NULL
UPDATE public.rooms
SET user_id = CASE
    WHEN author_tag ILIKE '%FILKOM%' THEN 'b1111111-1111-1111-1111-111111111105'::uuid
    WHEN author_tag ILIKE '%FEB%'    THEN 'b1111111-1111-1111-1111-111111111102'::uuid
    WHEN author_tag ILIKE '%FT%'     THEN 'b1111111-1111-1111-1111-111111111104'::uuid
    WHEN author_tag ILIKE '%FIA%'    THEN 'b1111111-1111-1111-1111-111111111106'::uuid
    WHEN author_tag ILIKE '%FIB%'    THEN 'b1111111-1111-1111-1111-111111111101'::uuid
    ELSE 'b1111111-1111-1111-1111-111111111103'::uuid
END
WHERE user_id IS NULL;

-- Normalisasi likes_count pada rooms agar organik (tidak 1240 / 890 melainkan 45 s.d. 135)
UPDATE public.rooms
SET likes_count = CASE
    WHEN likes_count > 300 THEN FLOOR(random() * 50 + 65)::int
    ELSE likes_count
END,
bookmarks_count = CASE
    WHEN bookmarks_count > 100 THEN FLOOR(random() * 20 + 15)::int
    ELSE bookmarks_count
END
WHERE likes_count > 300 OR bookmarks_count > 100;

-- Backfill user_id pada room_comments jika masih NULL
UPDATE public.room_comments
SET user_id = CASE
    WHEN author_tag ILIKE '%Konselor%' OR author_tag ILIKE '%Dodo%' THEN 'a1111111-1111-1111-1111-111111111101'::uuid
    WHEN author_tag ILIKE '%Leo%' THEN 'a1111111-1111-1111-1111-111111111102'::uuid
    WHEN author_tag ILIKE '%Sekar%' THEN 'b1111111-1111-1111-1111-111111111101'::uuid
    WHEN author_tag ILIKE '%Harry%' THEN 'b1111111-1111-1111-1111-111111111102'::uuid
    ELSE 'b1111111-1111-1111-1111-111111111105'::uuid
END
WHERE user_id IS NULL;
