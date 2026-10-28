-- Migration 0006: Fix handle_new_user trigger function to safely handle role ENUM and exceptions
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER 
LANGUAGE plpgsql 
SECURITY DEFINER 
SET search_path = public, auth, pg_temp
AS $$
DECLARE
    v_role public.user_role;
    v_is_verified boolean;
    v_counselor_status text;
    v_hobbies text[] := '{}';
    v_topics text[] := '{}';
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

    -- 5. Insert or update the profile safely
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
        COALESCE(NEW.raw_user_meta_data->>'faculty', 'FILKOM'),
        COALESCE(NEW.raw_user_meta_data->>'study_program', 'S1 Teknik Informatika'),
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
        is_verified = EXCLUDED.is_verified,
        counselor_status = EXCLUDED.counselor_status,
        updated_at = now();

    RETURN NEW;
EXCEPTION WHEN OTHERS THEN
    -- Mencegah transaksi registrasi auth gagal jika terjadi error pada sinkronisasi profil
    RAISE WARNING 'handle_new_user error: %', SQLERRM;
    RETURN NEW;
END;
$$;

-- Pastikan trigger terhubung dengan benar
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
