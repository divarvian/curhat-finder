-- ====================================================================
-- Migration: Setup Anon Chat Engine (Atomic Matchmaking, Lifecycle & Reports)
-- ====================================================================

-- 1. Perbarui Constraint Status pada anon_chat_sessions
ALTER TABLE public.anon_chat_sessions DROP CONSTRAINT IF EXISTS anon_chat_sessions_status_check;
ALTER TABLE public.anon_chat_sessions ADD CONSTRAINT anon_chat_sessions_status_check 
    CHECK (status IN ('waiting', 'active', 'ended', 'cancelled'));

-- 2. Buat Tabel Pelaporan Obrolan Anonim (anon_reports)
CREATE TABLE IF NOT EXISTS public.anon_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES public.anon_chat_sessions(id) ON DELETE CASCADE,
    reporter_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    reported_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    reason TEXT NOT NULL,
    details TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'resolved'))
);

-- RLS untuk anon_reports
ALTER TABLE public.anon_reports ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can insert own reports" ON public.anon_reports;
CREATE POLICY "Users can insert own reports"
ON public.anon_reports FOR INSERT TO authenticated
WITH CHECK (auth.uid() = reporter_id);

DROP POLICY IF EXISTS "Users can view own reports" ON public.anon_reports;
CREATE POLICY "Users can view own reports"
ON public.anon_reports FOR SELECT TO authenticated
USING (auth.uid() = reporter_id);

-- 3. Atomic Matchmaking RPC Function (match_anon_peer)
CREATE OR REPLACE FUNCTION public.match_anon_peer(p_mode TEXT)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_matched_session RECORD;
    v_new_session RECORD;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    -- Bersihkan antrean waiting lama milik user ini (> 2 menit)
    UPDATE public.anon_chat_sessions
    SET status = 'cancelled', ended_at = now()
    WHERE user1_id = v_user_id 
      AND status = 'waiting' 
      AND created_at < now() - INTERVAL '2 minutes';

    -- Cari sesi 'waiting' aktif dengan mode sama yang dibuat oleh user lain
    -- Gunakan FOR UPDATE SKIP LOCKED untuk mencegah race conditions
    SELECT * INTO v_matched_session
    FROM public.anon_chat_sessions
    WHERE status = 'waiting'
      AND mode = p_mode
      AND user1_id <> v_user_id
      AND user2_id IS NULL
      AND is_bot_session = false
      AND created_at >= now() - INTERVAL '60 seconds'
    ORDER BY created_at ASC
    LIMIT 1
    FOR UPDATE SKIP LOCKED;

    -- Jika partner ditemukan, pasangkan user sebagai user2
    IF FOUND THEN
        UPDATE public.anon_chat_sessions
        SET user2_id = v_user_id,
            status = 'active'
        WHERE id = v_matched_session.id;

        -- Kirim pesan sistem bahwa partner terhubung
        INSERT INTO public.anon_messages (session_id, sender_id, sender_alias, message_text, is_system)
        VALUES (
            v_matched_session.id,
            NULL,
            'Sistem',
            'Partner obrolan telah terhubung! Katakan halo dan ceritakan apa yang kamu rasakan ✨',
            true
        );

        RETURN json_build_object(
            'session_id', v_matched_session.id,
            'status', 'active',
            'matched', true,
            'role', 'joiner'
        );
    END IF;

    -- Cek jika user sudah memiliki sesi 'waiting' yang baru saja dibuat (< 25 detik)
    SELECT * INTO v_matched_session
    FROM public.anon_chat_sessions
    WHERE user1_id = v_user_id
      AND status = 'waiting'
      AND mode = p_mode
      AND is_bot_session = false
      AND created_at >= now() - INTERVAL '25 seconds'
    LIMIT 1;

    IF FOUND THEN
        RETURN json_build_object(
            'session_id', v_matched_session.id,
            'status', 'waiting',
            'matched', false,
            'role', 'creator'
        );
    END IF;

    -- Jika tidak ada, buat sesi baru sebagai creator (status 'waiting')
    INSERT INTO public.anon_chat_sessions (user1_id, mode, status, is_bot_session)
    VALUES (v_user_id, p_mode, 'waiting', false)
    RETURNING * INTO v_new_session;

    -- Pesan sambutan awal
    INSERT INTO public.anon_messages (session_id, sender_id, sender_alias, message_text, is_system)
    VALUES (
        v_new_session.id,
        NULL,
        'Sistem',
        'Kamu sudah berada di ruang obrolan anonim (' || p_mode || '). Privasimu aman 100%.',
        true
    );

    RETURN json_build_object(
        'session_id', v_new_session.id,
        'status', 'waiting',
        'matched', false,
        'role', 'creator'
    );
END;
$$;

-- 4. Cancel Matchmaking RPC Function (cancel_anon_match)
CREATE OR REPLACE FUNCTION public.cancel_anon_match(p_session_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    UPDATE public.anon_chat_sessions
    SET status = 'cancelled',
        ended_at = now()
    WHERE id = p_session_id
      AND user1_id = auth.uid()
      AND status = 'waiting';
END;
$$;

-- 5. Fallback Companion RPC Function (enable_anon_companion_fallback)
CREATE OR REPLACE FUNCTION public.enable_anon_companion_fallback(p_session_id UUID, p_mode TEXT)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_prompt TEXT;
BEGIN
    UPDATE public.anon_chat_sessions
    SET is_bot_session = true,
        status = 'active'
    WHERE id = p_session_id
      AND user1_id = auth.uid();

    IF p_mode LIKE '%didengar%' THEN
        v_prompt := 'Teman pendengar hadir untukmu. Aku di sini untuk mendengarkan semua ceritamu tanpa menghakimi 🤍';
    ELSE
        v_prompt := 'Teman curhatmu siap bertukar pikiran. Ceritakan apa yang ada di benakmu, kita cari solusi bareng-bareng ya 🌿';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM public.anon_messages
        WHERE session_id = p_session_id AND sender_alias = 'Teman Anonim'
    ) THEN
        INSERT INTO public.anon_messages (session_id, sender_id, sender_alias, message_text, is_system)
        VALUES (
            p_session_id,
            NULL,
            'Teman Anonim',
            v_prompt,
            false
        );
    END IF;
END;
$$;

-- 6. Submit Anon Report RPC Function (submit_anon_report)
CREATE OR REPLACE FUNCTION public.submit_anon_report(
    p_session_id UUID,
    p_reason TEXT,
    p_details TEXT DEFAULT NULL
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_session RECORD;
    v_reported_id UUID;
    v_report_id UUID;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    SELECT * INTO v_session
    FROM public.anon_chat_sessions
    WHERE id = p_session_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Session not found';
    END IF;

    IF v_session.user1_id = v_user_id THEN
        v_reported_id := v_session.user2_id;
    ELSIF v_session.user2_id = v_user_id THEN
        v_reported_id := v_session.user1_id;
    ELSE
        RAISE EXCEPTION 'User not a participant of this session';
    END IF;

    INSERT INTO public.anon_reports (session_id, reporter_id, reported_user_id, reason, details)
    VALUES (p_session_id, v_user_id, v_reported_id, p_reason, p_details)
    RETURNING id INTO v_report_id;

    -- Akhiri sesi obrolan secara otomatis demi kenyamanan & keamanan pelapor
    UPDATE public.anon_chat_sessions
    SET status = 'ended', ended_at = now()
    WHERE id = p_session_id;

    RETURN json_build_object(
        'success', true,
        'report_id', v_report_id
    );
END;
$$;

-- 7. Pastikan Publikasi Realtime untuk anon_chat_sessions dan anon_messages
DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.anon_chat_sessions;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.anon_messages;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
