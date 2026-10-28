-- ====================================================================
-- Migration: Anon Reconnection, Server-Side Companion Bot, and Active Session Query
-- ====================================================================

-- 1. Fungsi Server-Side Companion Bot Auto-Reply
CREATE OR REPLACE FUNCTION public.handle_anon_bot_reply()
RETURNS TRIGGER AS $$
DECLARE
    v_session RECORD;
    v_reply TEXT;
    v_replies TEXT[];
BEGIN
    -- Hanya proses jika pengirim adalah manusia (sender_id IS NOT NULL) dan bukan pesan sistem
    IF NEW.sender_id IS NULL OR NEW.is_system = true THEN
        RETURN NEW;
    END IF;

    -- Cek apakah sesi ini adalah sesi bot
    SELECT * INTO v_session
    FROM public.anon_chat_sessions
    WHERE id = NEW.session_id;

    IF NOT FOUND OR v_session.is_bot_session = false OR v_session.status <> 'active' THEN
        RETURN NEW;
    END IF;

    -- Pilih kumpulan balasan berdasarkan mode sesi
    IF v_session.mode LIKE '%didengar%' THEN
        v_replies := ARRAY[
            'Aku paham banget apa yang kamu rasain. Pasti berat ya menghadapi situasi seperti itu...',
            'Terima kasih sudah berani terbuka dan cerita ke aku. Kamu gak sendirian kok, aku setia mendengarkan.',
            'Nafas dalam-dalam dulu ya... Luapkan aja semuanya di sini tanpa rasa cemas.',
            'Wajar banget kamu merasa begitu. Setiap emosi dan perasaanmu itu valid.',
            'Aku di sini menyimak ceritamu. Lanjutin aja kalau itu bikin hatimu lebih lega 🤍',
            'Terkadang dunia terasa terlalu bising ya... Di ruang ini kamu boleh rehat sejenak dan jadi dirimu sendiri.',
            'Peluk hangat dari jauh untukmu. Ceritakan apa pun yang masih mengganjal di hatimu ya.'
        ];
    ELSE
        v_replies := ARRAY[
            'Dari sudut pandangku, kamu sudah berjuang luar biasa sejauh ini. Mungkin kamu bisa coba istirahat sejenak dulu?',
            'Kondisi ini memang menantang, tapi jangan ragu buat ambil langkah kecil satu per satu ya.',
            'Menurutku, penting buat kamu prioritaskan ketenangan pikiranmu dulu sebelum mikirin ekspektasi orang lain.',
            'Kalau aku di posisimu, mungkin aku bakal coba komunikasikan ini pelan-pelan ke orang terdekat. Kamu pasti bisa melaluinya!',
            'Keren banget kamu punya kesadaran reflektif seperti ini. Satu solusi yang bisa dicoba adalah beri jeda untuk dirimu hari ini.',
            'Jangan terlalu keras pada dirimu sendiri ya. Apa kira-kira hal paling sederhana yang bisa bikin kamu merasa lebih baik sekarang?',
            'Cobalah fokus ke hal-hal yang berada di kendalimu dulu. Satu masalah pada satu waktu, kamu punya kekuatan buat melewatinya!'
        ];
    END IF;

    -- Pilih satu balasan secara acak
    v_reply := v_replies[1 + floor(random() * array_length(v_replies, 1))::int];

    -- Masukkan balasan bot ke dalam anon_messages
    INSERT INTO public.anon_messages (
        session_id,
        sender_id,
        sender_alias,
        message_text,
        is_system
    ) VALUES (
        NEW.session_id,
        NULL,
        'Teman Anonim',
        v_reply,
        false
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS trg_anon_bot_auto_reply ON public.anon_messages;
CREATE TRIGGER trg_anon_bot_auto_reply
AFTER INSERT ON public.anon_messages
FOR EACH ROW
EXECUTE FUNCTION public.handle_anon_bot_reply();

-- 2. Fungsi Mengambil Sesi Anonim Aktif Milik Pengguna (Reconnection Query)
CREATE OR REPLACE FUNCTION public.get_active_anon_session()
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_session RECORD;
    v_partner_alias TEXT := 'Anonim';
BEGIN
    IF v_user_id IS NULL THEN
        RETURN NULL;
    END IF;

    -- Bersihkan sesi yang sudah terlalu lama tidak aktif (> 30 menit)
    UPDATE public.anon_chat_sessions
    SET status = 'ended', ended_at = now()
    WHERE (user1_id = v_user_id OR user2_id = v_user_id)
      AND status = 'active'
      AND created_at < now() - INTERVAL '30 minutes';

    SELECT * INTO v_session
    FROM public.anon_chat_sessions
    WHERE (user1_id = v_user_id OR user2_id = v_user_id)
      AND status = 'active'
    ORDER BY created_at DESC
    LIMIT 1;

    IF NOT FOUND THEN
        RETURN NULL;
    END IF;

    IF v_session.is_bot_session THEN
        v_partner_alias := 'Teman Virtual';
    ELSE
        v_partner_alias := 'Mahasiswa UB';
    END IF;

    RETURN json_build_object(
        'id', v_session.id,
        'user1_id', v_session.user1_id,
        'user2_id', v_session.user2_id,
        'mode', v_session.mode,
        'status', v_session.status,
        'is_bot_session', v_session.is_bot_session,
        'partner_alias', v_partner_alias,
        'created_at', v_session.created_at
    );
END;
$$;

-- 3. Fungsi Pembersihan Sesi Stale Otomatis
CREATE OR REPLACE FUNCTION public.cleanup_stale_anon_sessions()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    UPDATE public.anon_chat_sessions
    SET status = 'ended', ended_at = now()
    WHERE status = 'active'
      AND created_at < now() - INTERVAL '30 minutes';

    UPDATE public.anon_chat_sessions
    SET status = 'cancelled', ended_at = now()
    WHERE status = 'waiting'
      AND created_at < now() - INTERVAL '3 minutes';
END;
$$;
