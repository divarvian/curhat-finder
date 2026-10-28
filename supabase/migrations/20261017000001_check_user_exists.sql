-- Function to check if a user with a given email already exists in auth.users
CREATE OR REPLACE FUNCTION public.check_user_exists(lookup_email text)
RETURNS boolean AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM auth.users WHERE lower(email) = lower(trim(lookup_email))
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION public.check_user_exists(text) TO anon, authenticated;
