-- Migration: 20261028000002_create_user_private_sambats.sql
-- Description: Tabel terisolasi privat untuk fitur Sambat di modul Jurnal (Memperbaiki PRIV-001)

CREATE TABLE IF NOT EXISTS public.user_private_sambats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  mood_tag TEXT NOT NULL DEFAULT 'Sambat',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Index untuk mempercepat query berdasarkan user_id dan created_at
CREATE INDEX IF NOT EXISTS idx_user_private_sambats_user_created 
ON public.user_private_sambats (user_id, created_at DESC);

-- Aktifkan Row Level Security (RLS)
ALTER TABLE public.user_private_sambats ENABLE ROW LEVEL SECURITY;

-- Kebijakan RLS: 100% Terisolasi per User
CREATE POLICY "Users can only view their own private sambats"
ON public.user_private_sambats FOR SELECT TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can only insert their own private sambats"
ON public.user_private_sambats FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can only update their own private sambats"
ON public.user_private_sambats FOR UPDATE TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can only delete their own private sambats"
ON public.user_private_sambats FOR DELETE TO authenticated
USING (auth.uid() = user_id);

-- Migrasikan data sambat milik user yang sebelumnya tersimpan di tabel publik ke tabel privat ini
INSERT INTO public.user_private_sambats (user_id, content, created_at)
SELECT user_id, content, created_at
FROM public.sambats
WHERE user_id IS NOT NULL;
