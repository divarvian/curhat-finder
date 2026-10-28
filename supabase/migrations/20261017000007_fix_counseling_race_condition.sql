-- Migration: Fix Counseling Race Condition, Prevent Duplicate Sessions, and Atomic RPC
-- File: supabase/migrations/20261017000007_fix_counseling_race_condition.sql

-- 1. Tambah kolom session_id pada tabel counseling_queues
ALTER TABLE public.counseling_queues 
ADD COLUMN IF NOT EXISTS session_id UUID REFERENCES public.counseling_sessions(id) ON DELETE SET NULL;

-- 2. Bersihkan duplikat data aktif jika ada sebelum membuat index unik
WITH ranked_active_sessions AS (
    SELECT id, ROW_NUMBER() OVER (PARTITION BY student_id, counselor_id ORDER BY started_at DESC) as rn
    FROM public.counseling_sessions
    WHERE status = 'active'
)
UPDATE public.counseling_sessions
SET status = 'completed', ended_at = now()
WHERE id IN (SELECT id FROM ranked_active_sessions WHERE rn > 1);

WITH ranked_waiting_queues AS (
    SELECT id, ROW_NUMBER() OVER (PARTITION BY student_id, assigned_counselor_id ORDER BY created_at DESC) as rn
    FROM public.counseling_queues
    WHERE status = 'waiting'
)
UPDATE public.counseling_queues
SET status = 'cancelled', updated_at = now()
WHERE id IN (SELECT id FROM ranked_waiting_queues WHERE rn > 1);

-- 3. Tambahkan partial unique index untuk mencegah antrean dan sesi ganda
CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_waiting_queue_student_counselor 
ON public.counseling_queues (student_id, assigned_counselor_id) 
WHERE (status = 'waiting');

CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_active_session_student_counselor 
ON public.counseling_sessions (student_id, counselor_id) 
WHERE (status = 'active');

-- 4. RPC Function untuk penerimaan antrean secara atomik (Anti-Race Condition)
CREATE OR REPLACE FUNCTION public.accept_counseling_queue(
    p_queue_id UUID,
    p_counselor_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_queue RECORD;
    v_session RECORD;
BEGIN
    -- Kunci antrean secara eksplisit
    SELECT * INTO v_queue 
    FROM public.counseling_queues 
    WHERE id = p_queue_id 
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Antrean tidak ditemukan';
    END IF;

    -- Jika antrean sudah di-accept sebelumnya dan memiliki session_id
    IF v_queue.status = 'accepted' AND v_queue.session_id IS NOT NULL THEN
        SELECT * INTO v_session FROM public.counseling_sessions WHERE id = v_queue.session_id;
        IF FOUND THEN
            RETURN to_jsonb(v_session);
        END IF;
    END IF;

    -- Periksa apakah sudah ada sesi aktif sebelumnya antara mahasiswa dan konselor ini
    SELECT * INTO v_session
    FROM public.counseling_sessions
    WHERE student_id = v_queue.student_id 
      AND counselor_id = p_counselor_id 
      AND status = 'active'
    ORDER BY started_at DESC
    LIMIT 1;

    IF FOUND THEN
        -- Gunakan kembali sesi yang sudah aktif
        UPDATE public.counseling_queues
        SET status = 'accepted',
            session_id = v_session.id,
            assigned_counselor_id = p_counselor_id,
            updated_at = now()
        WHERE id = p_queue_id;

        RETURN to_jsonb(v_session);
    END IF;

    -- Buat sesi aktif baru secara atomik
    INSERT INTO public.counseling_sessions (
        queue_id,
        student_id,
        counselor_id,
        student_alias,
        student_faculty,
        status,
        started_at
    ) VALUES (
        p_queue_id,
        v_queue.student_id,
        p_counselor_id,
        v_queue.student_alias,
        v_queue.student_faculty,
        'active',
        now()
    )
    RETURNING * INTO v_session;

    -- Update status antrean bersama referensi session_id
    UPDATE public.counseling_queues
    SET status = 'accepted',
        session_id = v_session.id,
        assigned_counselor_id = p_counselor_id,
        updated_at = now()
    WHERE id = p_queue_id;

    -- Update metrik konselor
    UPDATE public.profiles
    SET active_sessions_count = COALESCE(active_sessions_count, 0) + 1
    WHERE id = p_counselor_id;

    RETURN to_jsonb(v_session);
END;
$$;
