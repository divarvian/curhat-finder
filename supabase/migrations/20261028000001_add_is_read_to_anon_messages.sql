-- Migration: 20261028000001_add_is_read_to_anon_messages.sql
-- Description: Menambahkan dukungan is_read (tanda terbaca / centang biru) untuk anon_messages

-- 1. Tambah kolom is_read ke anon_messages jika belum ada
ALTER TABLE public.anon_messages
ADD COLUMN IF NOT EXISTS is_read BOOLEAN NOT NULL DEFAULT false;

-- 2. Buat index untuk pencarian pesan belum terbaca berdasarkan session
CREATE INDEX IF NOT EXISTS idx_anon_messages_session_is_read
ON public.anon_messages (session_id, is_read);

-- 3. RLS: Izinkan peserta sesi mengupdate status is_read pada anon_messages
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'anon_messages' 
        AND policyname = 'Participants can update is_read on anon messages'
    ) THEN
        CREATE POLICY "Participants can update is_read on anon messages"
        ON public.anon_messages
        FOR UPDATE
        TO authenticated
        USING (
            EXISTS (
                SELECT 1 FROM public.anon_chat_sessions s
                WHERE s.id = anon_messages.session_id
                AND (s.user1_id = auth.uid() OR s.user2_id = auth.uid())
            )
        )
        WITH CHECK (
            EXISTS (
                SELECT 1 FROM public.anon_chat_sessions s
                WHERE s.id = anon_messages.session_id
                AND (s.user1_id = auth.uid() OR s.user2_id = auth.uid())
            )
        );
    END IF;
END $$;

-- 4. Buat fungsi RPC untuk menandai semua pesan partner dalam sesi sebagai terbaca
CREATE OR REPLACE FUNCTION public.mark_anon_messages_as_read(
    p_session_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE public.anon_messages
    SET is_read = true
    WHERE session_id = p_session_id
      AND (sender_id IS NULL OR sender_id != auth.uid())
      AND is_read = false;
END;
$$;
