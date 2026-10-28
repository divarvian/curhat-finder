-- Migration 0009: Add fcm_token to profiles for push notifications
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS fcm_token TEXT;

CREATE INDEX IF NOT EXISTS idx_profiles_fcm_token ON public.profiles (id) WHERE fcm_token IS NOT NULL;
