-- ====================================================================
-- FIX: handle_new_user search_path, array safety, and exception handling
-- Problem: GoTrue /auth/v1/signup failed with "500 Database error saving new user"
-- Root cause: Migration 20261106000001 overwrote handle_new_user() without 
--             SET search_path = public, auth, pg_temp, causing type casting to 
--             user_role and profiles access to fail in GoTrue's execution context.
--             Additionally, jsonb_array_elements_text on empty arrays [] without 
--             safety checks evaluated to NULL.
-- ====================================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER 
LANGUAGE plpgsql 
SECURITY DEFINER 
SET search_path = public, auth, pg_temp
AS $$
DECLARE
    v_role public.user_role;
    v_is_verified boolean := true;
    v_counselor_status text := 'approved';
    v_hobbies text[] := '{}';
    v_topics text[] := '{}';
    v_raw_faculty text;
    v_raw_prodi text;
    v_faculty text := 'FILKOM';
    v_study_program text := 'S1 Teknik Informatika';
BEGIN
    -- 1. Safely determine role casting to public.user_role enum
    BEGIN
        v_role := COALESCE((NEW.raw_user_meta_data->>'role')::public.user_role, 'mahasiswa'::public.user_role);
    EXCEPTION WHEN OTHERS THEN
        v_role := 'mahasiswa'::public.user_role;
    END;

    -- 2. Determine verification status based on role
    IF v_role::text = 'konselor' THEN
        v_is_verified := false;
        v_counselor_status := 'pending';
    ELSE
        v_is_verified := true;
        v_counselor_status := 'approved';
    END IF;

    -- 3. Extract hobbies if provided as array
    BEGIN
        IF jsonb_typeof(NEW.raw_user_meta_data->'hobbies') = 'array' THEN
            SELECT ARRAY(SELECT jsonb_array_elements_text(NEW.raw_user_meta_data->'hobbies')) INTO v_hobbies;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        v_hobbies := '{}';
    END;

    -- 4. Extract topics if provided as array
    BEGIN
        IF jsonb_typeof(NEW.raw_user_meta_data->'topics') = 'array' THEN
            SELECT ARRAY(SELECT jsonb_array_elements_text(NEW.raw_user_meta_data->'topics')) INTO v_topics;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        v_topics := '{}';
    END;

    -- 5. Extract and normalize faculty
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

    -- 6. Extract and normalize prodi
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

    -- 7. Insert or update the profile safely
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
        hobbies = EXCLUDED.hobbies,
        topics = EXCLUDED.topics,
        is_verified = CASE WHEN EXCLUDED.role = 'konselor' THEN profiles.is_verified ELSE EXCLUDED.is_verified END,
        counselor_status = CASE WHEN EXCLUDED.role = 'konselor' THEN profiles.counselor_status ELSE EXCLUDED.counselor_status END,
        updated_at = now();

    RETURN NEW;
EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'handle_new_user error: %', SQLERRM;
    RETURN NEW;
END;
$$;

-- Ensure trigger is correctly attached to auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
