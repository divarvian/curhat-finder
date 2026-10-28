-- Fix handle_new_user trigger with explicit search_path and safe jsonb array parsing
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER 
LANGUAGE plpgsql 
SECURITY DEFINER 
SET search_path = public, auth, pg_temp
AS $$
DECLARE
    v_role public.user_role;
    v_hobbies text[] := '{}';
    v_topics text[] := '{}';
BEGIN
    -- Determine role safely
    BEGIN
        v_role := COALESCE((NEW.raw_user_meta_data->>'role')::public.user_role, 'mahasiswa'::public.user_role);
    EXCEPTION WHEN OTHERS THEN
        v_role := 'mahasiswa'::public.user_role;
    END;

    -- Extract hobbies if array
    BEGIN
        IF jsonb_typeof(NEW.raw_user_meta_data->'hobbies') = 'array' THEN
            SELECT ARRAY(SELECT jsonb_array_elements_text(NEW.raw_user_meta_data->'hobbies')) INTO v_hobbies;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        v_hobbies := '{}';
    END;

    -- Extract topics if array
    BEGIN
        IF jsonb_typeof(NEW.raw_user_meta_data->'topics') = 'array' THEN
            SELECT ARRAY(SELECT jsonb_array_elements_text(NEW.raw_user_meta_data->'topics')) INTO v_topics;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        v_topics := '{}';
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
        is_online
    ) VALUES (
        NEW.id,
        v_role,
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'Pengguna Baru'),
        NEW.raw_user_meta_data->>'nickname',
        NEW.raw_user_meta_data->>'gender',
        NEW.raw_user_meta_data->>'batch_year',
        NEW.raw_user_meta_data->>'faculty',
        NEW.raw_user_meta_data->>'study_program',
        v_hobbies,
        v_topics,
        CASE WHEN v_role = 'konselor' THEN true ELSE false END
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
        updated_at = now();

    RETURN NEW;
EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'handle_new_user error: %', SQLERRM;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Also ensure INSERT policy exists on public.profiles
DROP POLICY IF EXISTS "Enable insert on profiles" ON public.profiles;
CREATE POLICY "Enable insert on profiles" ON public.profiles FOR INSERT WITH CHECK (true);
