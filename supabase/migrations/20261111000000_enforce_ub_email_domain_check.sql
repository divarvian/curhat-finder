-- ====================================================================
-- ENFORCE UB EMAIL DOMAIN AT DATABASE LEVEL
-- 1. Trigger BEFORE INSERT on auth.users to block non-UB email signups
-- 2. Update public.check_user_exists to prevent role-redirects on non-UB emails
-- ====================================================================

-- 1. Function & Trigger on auth.users (BEFORE INSERT)
CREATE OR REPLACE FUNCTION public.validate_ub_email_before_signup()
RETURNS TRIGGER 
LANGUAGE plpgsql 
SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
BEGIN
    -- Pastikan email tidak null dan berdomain *.ub.ac.id atau ub.ac.id
    IF NEW.email IS NULL OR lower(trim(NEW.email)) !~* '^[a-z0-9._%+-]+@([a-z0-9-]+\.)*ub\.ac\.id$' THEN
        RAISE EXCEPTION 'Hanya email resmi Universitas Brawijaya (*.ub.ac.id) yang diperbolehkan untuk mendaftar.'
            USING ERRCODE = '23514'; -- check_violation
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tr_validate_ub_email_signup ON auth.users;
CREATE TRIGGER tr_validate_ub_email_signup
    BEFORE INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.validate_ub_email_before_signup();

-- 2. Smart check_user_exists RPC
CREATE OR REPLACE FUNCTION public.check_user_exists(lookup_email text)
RETURNS boolean AS $$
DECLARE
    clean_email text := lower(trim(lookup_email));
BEGIN
    -- Jika input bukan domain UB resmi, kembalikan TRUE agar klien lama
    -- menganggap ini akun yang sudah terdaftar dan TIDAK mengarahkan ke halaman role/pendaftaran!
    IF clean_email !~* '^[a-z0-9._%+-]+@([a-z0-9-]+\.)*ub\.ac\.id$' THEN
        RETURN true;
    END IF;

    RETURN EXISTS (
        SELECT 1 FROM auth.users WHERE lower(email) = clean_email
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION public.check_user_exists(text) TO anon, authenticated;
