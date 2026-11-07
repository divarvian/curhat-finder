-- ============================================================================
-- Migration 20261107000001: Counselor Metrics Trigger, Unified Tips, and Table Cleanup
-- ============================================================================

-- ============================================================================
-- 1. REUSABLE COUNSELOR METRICS CALCULATION FUNCTION & TRIGGER
-- Automatically updates active_sessions_count, total_helped_count, and avg_response_time
-- ============================================================================

CREATE OR REPLACE FUNCTION public.recalculate_counselor_metrics(p_counselor_id UUID)
RETURNS VOID AS $$
DECLARE
    v_active_count INT;
    v_helped_count INT;
    v_avg_seconds NUMERIC;
    v_avg_resp_text TEXT;
BEGIN
    IF p_counselor_id IS NULL THEN
        RETURN;
    END IF;

    -- 1. Hitung sesi aktif konselor
    SELECT COUNT(*) INTO v_active_count
    FROM public.counseling_sessions
    WHERE counselor_id = p_counselor_id AND status = 'active';

    -- 2. Hitung total sesi yang berhasil diselesaikan (total dibantu)
    SELECT COUNT(*) INTO v_helped_count
    FROM public.counseling_sessions
    WHERE counselor_id = p_counselor_id AND status = 'completed';

    -- 3. Hitung rata-rata waktu respon (selisih dari antrean dibuat sampai sesi dimulai)
    SELECT AVG(EXTRACT(EPOCH FROM (cs.started_at - cq.created_at)))
    INTO v_avg_seconds
    FROM public.counseling_sessions cs
    LEFT JOIN public.counseling_queues cq ON cs.queue_id = cq.id
    WHERE cs.counselor_id = p_counselor_id AND cs.started_at IS NOT NULL;

    IF v_avg_seconds IS NULL OR v_avg_seconds <= 0 THEN
        v_avg_resp_text := '0m';
    ELSIF v_avg_seconds < 60 THEN
        v_avg_resp_text := '< 1m';
    ELSE
        v_avg_resp_text := (ROUND(v_avg_seconds / 60))::TEXT || 'm';
    END IF;

    -- 4. Sinkronkan secara atomik ke profiles
    UPDATE public.profiles
    SET active_sessions_count = v_active_count,
        total_helped_count = v_helped_count,
        avg_response_time = v_avg_resp_text,
        updated_at = now()
    WHERE id = p_counselor_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.sync_counselor_metrics()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM public.recalculate_counselor_metrics(COALESCE(NEW.counselor_id, OLD.counselor_id));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_sync_counselor_metrics ON public.counseling_sessions;
CREATE TRIGGER trg_sync_counselor_metrics
AFTER INSERT OR UPDATE OR DELETE ON public.counseling_sessions
FOR EACH ROW
EXECUTE FUNCTION public.sync_counselor_metrics();

-- Inisialisasi ulang metrik seluruh konselor yang ada saat ini
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN SELECT id FROM public.profiles WHERE role = 'konselor' LOOP
        PERFORM public.recalculate_counselor_metrics(r.id);
    END LOOP;
END $$;

-- ============================================================================
-- 2. ENHANCE public.tips TABLE FOR UNIFIED COUNSELOR TIPS & ARTICLES
-- ============================================================================

ALTER TABLE public.tips
ADD COLUMN IF NOT EXISTS summary TEXT,
ADD COLUMN IF NOT EXISTS reference_url TEXT,
ADD COLUMN IF NOT EXISTS is_counselor BOOLEAN DEFAULT false;

-- ============================================================================
-- 3. MIGRATE DATA FROM counselor_articles TO public.tips
-- ============================================================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
          AND table_name = 'counselor_articles'
    ) THEN
        INSERT INTO public.tips (
            user_id,
            category,
            title,
            content,
            is_counselor,
            likes_count,
            created_at
        )
        SELECT 
            ca.author_id,
            ca.category,
            ca.title,
            ca.content,
            true,
            ca.likes_count,
            ca.created_at
        FROM public.counselor_articles ca
        ON CONFLICT DO NOTHING;
    END IF;
END $$;

-- ============================================================================
-- 4. DROP OBSOLETE & REDUNDANT TABLES
-- ============================================================================

DROP TABLE IF EXISTS public.counselor_articles CASCADE;
DROP TABLE IF EXISTS public.counselor_forums CASCADE;
DROP TABLE IF EXISTS public.forum_posts CASCADE;
DROP TABLE IF EXISTS public.peer_anon_queue CASCADE;
