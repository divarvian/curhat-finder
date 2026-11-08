-- ====================================================================
-- SEED AUTH IDENTITIES FOR ALL DEMO USERS
-- Enables Supabase GoTrue Auth to authenticate email/password demo users
-- ====================================================================

INSERT INTO auth.identities (
    id,
    user_id,
    identity_data,
    provider,
    provider_id,
    last_sign_in_at,
    created_at,
    updated_at
)
SELECT
    id,
    id,
    jsonb_build_object('sub', id::text, 'email', email),
    'email',
    id::text,
    now(),
    created_at,
    updated_at
FROM auth.users
ON CONFLICT (provider_id, provider) DO NOTHING;
