-- Migration 20261106000000: Normalize Faculty and Study Program Master Data
-- Normalizes faculty abbreviations and study program full names across public.profiles and auth.users

-- ============================================================================
-- 1. NORMALISASI FAKULTAS (public.profiles.faculty)
-- ============================================================================

UPDATE public.profiles
SET faculty = CASE
    WHEN faculty = '01' OR faculty = '1' THEN 'FH'
    WHEN faculty = '02' OR faculty = '2' THEN 'FEB'
    WHEN faculty = '03' OR faculty = '3' THEN 'FIA'
    WHEN faculty = '04' OR faculty = '4' THEN 'FBiPK'
    WHEN faculty = '05' OR faculty = '5' THEN 'FAST'
    WHEN faculty = '06' OR faculty = '6' THEN 'FT'
    WHEN faculty = '07' OR faculty = '7' THEN 'FK'
    WHEN faculty = '08' OR faculty = '8' THEN 'FPIK'
    WHEN faculty = '09' OR faculty = '9' THEN 'FSTeM'
    WHEN faculty = '10' OR faculty = '10' THEN 'FTAB'
    WHEN faculty = '11' OR faculty = '11' THEN 'FIB'
    WHEN faculty = '12' OR faculty = '12' THEN 'FISIP'
    WHEN faculty = '13' OR faculty = '13' THEN 'FKH'
    WHEN faculty = '14' OR faculty = '14' THEN 'FILKOM'
    WHEN faculty = '15' OR faculty = '15' THEN 'FKG'
    WHEN faculty = '16' OR faculty = '16' THEN 'FV'
    WHEN faculty = '17' OR faculty = '17' THEN 'FIKES'
    WHEN faculty = '18' OR faculty = '18' THEN 'SP'
    WHEN faculty ILIKE '%FILKOM%' OR faculty ILIKE '%Ilmu Komputer%' THEN 'FILKOM'
    WHEN faculty ILIKE '%FKG%' OR faculty ILIKE '%Kedokteran Gigi%' THEN 'FKG'
    WHEN faculty ILIKE '%FKH%' OR faculty ILIKE '%Kedokteran Hewan%' THEN 'FKH'
    WHEN faculty ILIKE '%FK%' OR (faculty ILIKE '%Kedokteran%' AND faculty NOT ILIKE '%Gigi%' AND faculty NOT ILIKE '%Hewan%') THEN 'FK'
    WHEN faculty ILIKE '%FTAB%' OR faculty ILIKE '%Agroindustri%' THEN 'FTAB'
    WHEN faculty ILIKE '%FT%' OR (faculty ILIKE '%Teknik%' AND faculty NOT ILIKE '%Agroindustri%' AND faculty NOT ILIKE '%Komputer%') THEN 'FT'
    WHEN faculty ILIKE '%FH%' OR faculty ILIKE '%Hukum%' THEN 'FH'
    WHEN faculty ILIKE '%FEB%' OR faculty ILIKE '%Ekonomi%' THEN 'FEB'
    WHEN faculty ILIKE '%FIA%' OR faculty ILIKE '%Administrasi%' THEN 'FIA'
    WHEN faculty ILIKE '%FBiPK%' OR faculty ILIKE '%Bio-Industri%' THEN 'FBiPK'
    WHEN faculty ILIKE '%FAST%' OR faculty ILIKE '%Peternakan%' THEN 'FAST'
    WHEN faculty ILIKE '%FPIK%' OR faculty ILIKE '%Perikanan%' THEN 'FPIK'
    WHEN faculty ILIKE '%FSTeM%' OR faculty ILIKE '%Matematika%' THEN 'FSTeM'
    WHEN faculty ILIKE '%FIB%' OR faculty ILIKE '%Ilmu Budaya%' OR faculty ILIKE '%Sastra%' THEN 'FIB'
    WHEN faculty ILIKE '%FISIP%' OR faculty ILIKE '%Ilmu Sosial%' THEN 'FISIP'
    WHEN faculty ILIKE '%FV%' OR faculty ILIKE '%Vokasi%' THEN 'FV'
    WHEN faculty ILIKE '%FIKES%' OR faculty ILIKE '%Ilmu Kesehatan%' THEN 'FIKES'
    WHEN faculty ILIKE '%SP%' OR faculty ILIKE '%Pascasarjana%' THEN 'SP'
    ELSE faculty
END
WHERE faculty IS NOT NULL;

-- ============================================================================
-- 2. NORMALISASI PROGRAM STUDI (public.profiles.study_program)
-- ============================================================================

UPDATE public.profiles
SET study_program = CASE
    WHEN study_program = '01.01' THEN 'S1 Ilmu Hukum'
    WHEN study_program = '01.02' THEN 'S2 Ilmu Hukum'
    WHEN study_program = '01.03' THEN 'S2 Kenotariatan'
    WHEN study_program = '01.04' THEN 'S3 Ilmu Hukum'
    WHEN study_program = '02.01' THEN 'S1 Ekonomi Pembangunan'
    WHEN study_program = '02.02' THEN 'S1 Ekonomi, Keuangan, dan Perbankan'
    WHEN study_program = '02.03' THEN 'S1 Ekonomi Islam'
    WHEN study_program = '02.04' THEN 'S1 Manajemen'
    WHEN study_program = '02.05' THEN 'S1 Kewirausahaan'
    WHEN study_program = '02.06' THEN 'S1 Akuntansi'
    WHEN study_program = '02.07' THEN 'S2 Ilmu Ekonomi'
    WHEN study_program = '02.08' THEN 'S2 Ekonomi Bisnis dan Islam'
    WHEN study_program = '02.09' THEN 'S2 Manajemen'
    WHEN study_program = '02.10' THEN 'S2 Akuntansi'
    WHEN study_program = '02.11' THEN 'S3 Ilmu Ekonomi'
    WHEN study_program = '02.12' THEN 'S3 Ilmu Manajemen'
    WHEN study_program = '02.13' THEN 'S3 Ilmu Akuntansi'
    WHEN study_program = '02.14' THEN 'Pendidikan Profesi Akuntansi'
    WHEN study_program = '03.01' THEN 'S1 Ilmu Administrasi Bisnis'
    WHEN study_program = '03.02' THEN 'S1 Perpajakan'
    WHEN study_program = '03.03' THEN 'S1 Pariwisata'
    WHEN study_program = '03.04' THEN 'S1 Ilmu Administrasi Publik'
    WHEN study_program = '03.05' THEN 'S1 Ilmu Perpustakaan'
    WHEN study_program = '03.06' THEN 'S1 Administrasi Pendidikan'
    WHEN study_program = '03.07' THEN 'S2 Administrasi Bisnis'
    WHEN study_program = '03.08' THEN 'S2 Ilmu Administrasi Publik'
    WHEN study_program = '03.09' THEN 'S2 Manajemen Pendidikan Tinggi'
    WHEN study_program = '03.10' THEN 'S3 Ilmu Administrasi'
    WHEN study_program = '04.01' THEN 'S1 Agroekoteknologi'
    WHEN study_program = '04.02' THEN 'S1 Agribisnis'
    WHEN study_program = '04.03' THEN 'S1 Kehutanan'
    WHEN study_program = '04.04' THEN 'S2 Agronomi'
    WHEN study_program = '04.05' THEN 'S2 Pengelolaan Tanah dan Air'
    WHEN study_program = '04.06' THEN 'S2 Ekonomi Pertanian'
    WHEN study_program = '04.07' THEN 'S2 Sosiologi'
    WHEN study_program = '04.08' THEN 'S2 Agribisnis'
    WHEN study_program = '04.09' THEN 'S2 Patologi Tumbuhan'
    WHEN study_program = '04.10' THEN 'S2 Entomologi Pertanian'
    WHEN study_program = '04.11' THEN 'S3 Ilmu Pertanian'
    WHEN study_program = '05.01' THEN 'S1 Peternakan'
    WHEN study_program = '05.02' THEN 'S1 Industri Peternakan Cerdas'
    WHEN study_program = '05.03' THEN 'S2 Ilmu Peternakan'
    WHEN study_program = '05.04' THEN 'S3 Ilmu Peternakan'
    WHEN study_program = '06.01' THEN 'S1 Teknik Sipil'
    WHEN study_program = '06.02' THEN 'S1 Teknik Mesin'
    WHEN study_program = '06.03' THEN 'S1 Teknik Pengairan'
    WHEN study_program = '06.04' THEN 'S1 Teknik Elektro'
    WHEN study_program = '06.05' THEN 'S1 Teknik Industri'
    WHEN study_program = '06.06' THEN 'S1 Teknik Kimia'
    WHEN study_program = '06.07' THEN 'S1 Perencanaan Wilayah dan Kota'
    WHEN study_program = '06.08' THEN 'S1 Arsitektur'
    WHEN study_program = '06.09' THEN 'S2 Teknik Sipil'
    WHEN study_program = '06.10' THEN 'S2 Teknik Mesin'
    WHEN study_program = '06.11' THEN 'S2 Teknik Elektro'
    WHEN study_program = '06.12' THEN 'S2 Arsitektur Lingkungan Binaan'
    WHEN study_program = '06.13' THEN 'S2 Perencanaan Wilayah dan Kota'
    WHEN study_program = '06.14' THEN 'S2 Teknik Industri'
    WHEN study_program = '06.15' THEN 'S2 Teknik Pengairan'
    WHEN study_program = '06.16' THEN 'S3 Ilmu Teknik Sipil'
    WHEN study_program = '06.17' THEN 'S3 Ilmu Teknik Mesin'
    WHEN study_program = '06.18' THEN 'S3 Teknik Elektro'
    WHEN study_program = '06.19' THEN 'S3 Teknik Sumber Daya Air'
    WHEN study_program = '06.20' THEN 'S3 Perencanaan Wilayah dan Kota'
    WHEN study_program = '06.21' THEN 'Profesi Insinyur'
    WHEN study_program = '06.22' THEN 'Profesi Arsitek'
    WHEN study_program = '07.01' THEN 'S1 Kedokteran'
    WHEN study_program = '07.02' THEN 'S1 Farmasi'
    WHEN study_program = '07.03' THEN 'S1 Kebidanan'
    WHEN study_program = '07.04' THEN 'S2 Kebidanan'
    WHEN study_program = '07.05' THEN 'S2 Manajemen Rumah Sakit'
    WHEN study_program = '07.06' THEN 'S2 Biomedik'
    WHEN study_program = '07.07' THEN 'S3 Ilmu Kedokteran'
    WHEN study_program = '08.01' THEN 'S1 Agrobisnis Perikanan'
    WHEN study_program = '08.02' THEN 'S1 Budidaya Perairan'
    WHEN study_program = '08.03' THEN 'S1 Ilmu Kelautan'
    WHEN study_program = '08.04' THEN 'S1 Manajemen Sumberdaya Perairan'
    WHEN study_program = '08.05' THEN 'S1 Pemanfaatan Sumberdaya Perikanan'
    WHEN study_program = '08.06' THEN 'S1 Teknologi Hasil Perikanan'
    WHEN study_program = '08.07' THEN 'S2 Budidaya Perairan'
    WHEN study_program = '08.08' THEN 'S3 Ilmu Perikanan dan Kelautan'
    WHEN study_program = '09.01' THEN 'S1 Biologi'
    WHEN study_program = '09.02' THEN 'S1 Fisika'
    WHEN study_program = '09.03' THEN 'S1 Kimia'
    WHEN study_program = '09.04' THEN 'S1 Matematika'
    WHEN study_program = '09.05' THEN 'S1 Statistika'
    WHEN study_program = '09.06' THEN 'S1 Teknik Geofisika'
    WHEN study_program = '09.07' THEN 'S1 Instrumentasi'
    WHEN study_program = '09.08' THEN 'S1 Ilmu Aktuaria'
    WHEN study_program = '09.09' THEN 'S2 Biologi'
    WHEN study_program = '09.10' THEN 'S2 Kimia'
    WHEN study_program = '09.11' THEN 'S2 Fisika'
    WHEN study_program = '09.12' THEN 'S2 Matematika'
    WHEN study_program = '09.13' THEN 'S2 Statistika'
    WHEN study_program = '09.14' THEN 'S3 Biologi'
    WHEN study_program = '09.15' THEN 'S3 Kimia'
    WHEN study_program = '09.16' THEN 'S3 Fisika'
    WHEN study_program = '09.17' THEN 'S3 Matematika'
    WHEN study_program = '10.01' THEN 'S1 Ilmu dan Teknologi Pangan'
    WHEN study_program = '10.02' THEN 'S1 Teknologi Industri Pertanian'
    WHEN study_program = '10.03' THEN 'S1 Teknik Lingkungan'
    WHEN study_program = '10.04' THEN 'S1 Bioteknologi'
    WHEN study_program = '10.05' THEN 'S1 Teknologi Bioproses'
    WHEN study_program = '10.06' THEN 'S1 Teknik Pertanian'
    WHEN study_program = '10.07' THEN 'S2 Teknologi Hasil Pertanian'
    WHEN study_program = '10.08' THEN 'S2 Teknologi Industri Pertanian'
    WHEN study_program = '10.09' THEN 'S2 Teknik Pertanian dan Biosistem'
    WHEN study_program = '10.10' THEN 'S3 Teknologi Industri Pertanian'
    WHEN study_program = '10.11' THEN 'S3 Teknik Biosistem'
    WHEN study_program = '10.12' THEN 'S3 Ilmu Pangan'
    WHEN study_program = '11.01' THEN 'S1 Sastra Inggris'
    WHEN study_program = '11.02' THEN 'S1 Sastra Jepang'
    WHEN study_program = '11.03' THEN 'S1 Sastra Cina'
    WHEN study_program = '11.04' THEN 'S1 Bahasa dan Sastra Perancis'
    WHEN study_program = '11.05' THEN 'S1 Pendidikan Bahasa dan Sastra Indonesia'
    WHEN study_program = '11.06' THEN 'S1 Pendidikan Bahasa Inggris'
    WHEN study_program = '11.07' THEN 'S1 Pendidikan Bahasa Jepang'
    WHEN study_program = '11.08' THEN 'S1 Antropologi (Sosial)'
    WHEN study_program = '11.09' THEN 'S1 Seni Rupa Murni'
    WHEN study_program = '11.10' THEN 'S2 Ilmu Linguistik'
    WHEN study_program = '12.01' THEN 'S1 Hubungan Internasional'
    WHEN study_program = '12.02' THEN 'S1 Ilmu Komunikasi'
    WHEN study_program = '12.03' THEN 'S1 Ilmu Politik'
    WHEN study_program = '12.04' THEN 'S1 Psikologi'
    WHEN study_program = '12.05' THEN 'S1 Sosiologi'
    WHEN study_program = '12.06' THEN 'S1 Ilmu Pemerintahan'
    WHEN study_program = '12.07' THEN 'S2 Ilmu Sosial'
    WHEN study_program = '12.08' THEN 'S2 Ilmu Komunikasi'
    WHEN study_program = '12.09' THEN 'S2 Sains Psikologi'
    WHEN study_program = '12.10' THEN 'S3 Ilmu Sosiologi'
    WHEN study_program = '13.01' THEN 'S1 Pendidikan Dokter Hewan'
    WHEN study_program = '14.01' THEN 'S1 Teknik Informatika'
    WHEN study_program = '14.02' THEN 'S1 Teknik Komputer'
    WHEN study_program = '14.03' THEN 'S1 Sistem Informasi'
    WHEN study_program = '14.04' THEN 'S1 Teknologi Informasi'
    WHEN study_program = '14.05' THEN 'S1 Pendidikan Teknologi Informasi'
    WHEN study_program = '14.06' THEN 'S2 Ilmu Komputer'
    WHEN study_program = '14.07' THEN 'S2 Sistem Informasi'
    WHEN study_program = '14.08' THEN 'S3 Ilmu Komputer'
    WHEN study_program = '15.01' THEN 'S1 Kedokteran Gigi'
    WHEN study_program = '16.01' THEN 'D4 Manajemen Perhotelan'
    WHEN study_program = '16.02' THEN 'D3 Keuangan dan Perbankan'
    WHEN study_program = '16.03' THEN 'D3 Administrasi Bisnis'
    WHEN study_program = '16.04' THEN 'D4 Desain Grafis'
    WHEN study_program = '16.05' THEN 'D3 Teknologi Informasi'
    WHEN study_program = '17.01' THEN 'S1 Keperawatan'
    WHEN study_program = '17.02' THEN 'S1 Ilmu Gizi'
    WHEN study_program = '17.03' THEN 'S2 Keperawatan'
    WHEN study_program = '17.04' THEN 'S2 Gizi'
    WHEN study_program = '18.01' THEN 'S2 Kajian Wanita'
    WHEN study_program = '18.02' THEN 'S2 Pengelolaan Sumberdaya Lingkungan dan Pembangunan'
    WHEN study_program = '18.03' THEN 'S2 Wawasan Pertahanan Nasional'
    WHEN study_program = '18.04' THEN 'S2 Kepemimpinan dan Inovasi Kebijakan'
    WHEN study_program = '18.05' THEN 'S3 Ilmu Lingkungan'
    WHEN study_program = '18.06' THEN 'S3 Ilmu Ketahanan Nasional'
    WHEN study_program = '18.07' THEN 'S3 Kepemimpinan dan Inovasi Kebijakan'
    WHEN study_program = 'Teknik Informatika' THEN 'S1 Teknik Informatika'
    WHEN study_program = 'Sistem Informasi' THEN 'S1 Sistem Informasi'
    WHEN study_program = 'Pendidikan Teknologi Informasi' THEN 'S1 Pendidikan Teknologi Informasi'
    WHEN study_program = 'Teknik Komputer' THEN 'S1 Teknik Komputer'
    WHEN study_program = 'Teknologi Informasi' THEN 'S1 Teknologi Informasi'
    WHEN study_program = 'Sastra Inggris' THEN 'S1 Sastra Inggris'
    WHEN study_program = 'Sastra Jepang' THEN 'S1 Sastra Jepang'
    WHEN study_program = 'Bahasa dan Sastra Perancis' THEN 'S1 Bahasa dan Sastra Perancis'
    WHEN study_program = 'Pendidikan Dokter' OR study_program = 'Kedokteran' THEN 'S1 Kedokteran'
    WHEN study_program = 'Ilmu Keperawatan' THEN 'S1 Keperawatan'
    WHEN study_program = 'Ilmu Gizi' THEN 'S1 Gizi'
    WHEN study_program = 'Farmasi' THEN 'S1 Farmasi'
    WHEN study_program = 'Ilmu Hukum' THEN 'S1 Ilmu Hukum'
    WHEN study_program = 'Manajemen' THEN 'S1 Manajemen'
    WHEN study_program = 'Akuntansi' THEN 'S1 Akuntansi'
    WHEN study_program = 'Ekonomi Pembangunan' THEN 'S1 Ekonomi Pembangunan'
    WHEN study_program = 'Psikologi' THEN 'S1 Psikologi'
    WHEN study_program = 'Ilmu Komunikasi' THEN 'S1 Ilmu Komunikasi'
    WHEN study_program = 'Hubungan Internasional' THEN 'S1 Hubungan Internasional'
    WHEN study_program = 'Sosiologi' THEN 'S1 Sosiologi'
    ELSE study_program
END
WHERE study_program IS NOT NULL;

-- ============================================================================
-- 3. SINKRONISASI METADATA (auth.users.raw_user_meta_data)
-- ============================================================================

UPDATE auth.users u
SET raw_user_meta_data = 
    COALESCE(u.raw_user_meta_data, '{}'::jsonb) || 
    jsonb_build_object(
        'faculty', p.faculty,
        'study_program', p.study_program
    )
FROM public.profiles p
WHERE u.id = p.id
  AND (
      u.raw_user_meta_data->>'faculty' IS DISTINCT FROM p.faculty OR
      u.raw_user_meta_data->>'study_program' IS DISTINCT FROM p.study_program
  );

-- ============================================================================
-- 4. PEMBARUAN TRIGGER FUNCTION handle_new_user AGAR MENORMALISASI SECARA OTOMATIS
-- ============================================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    v_role user_role := 'mahasiswa';
    v_is_verified boolean := false;
    v_counselor_status text := null;
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

    -- Ekstrak dan normalisasi prodi (beberapa ID umum dan nama tanpa gelar)
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
