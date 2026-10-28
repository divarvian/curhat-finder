-- Migration: 20261028000000_message_deletion_and_unsend.sql
-- Description: Menambahkan dukungan fitur Delete for Me dan Unsend (Delete for Everyone) untuk chat_messages dan anon_messages

-- 1. Tambah kolom pada chat_messages (Konseling)
ALTER TABLE chat_messages
  ADD COLUMN IF NOT EXISTS is_deleted_for_everyone BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS deleted_for_users UUID[] NOT NULL DEFAULT '{}';

-- 2. Tambah kolom pada anon_messages (Chat Anonim)
ALTER TABLE anon_messages
  ADD COLUMN IF NOT EXISTS is_deleted_for_everyone BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS deleted_for_users UUID[] NOT NULL DEFAULT '{}';

-- 3. Indeks GIN untuk mempercepat query deleted_for_users
CREATE INDEX IF NOT EXISTS idx_chat_messages_deleted_for_users ON chat_messages USING GIN (deleted_for_users);
CREATE INDEX IF NOT EXISTS idx_anon_messages_deleted_for_users ON anon_messages USING GIN (deleted_for_users);

-- 4. RPC Function untuk Hapus untuk Saya (Delete for Me)
CREATE OR REPLACE FUNCTION delete_messages_for_me(p_message_ids UUID[], p_is_anon BOOLEAN DEFAULT false)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_uid UUID := auth.uid();
BEGIN
  IF v_uid IS NULL THEN
    RETURN;
  END IF;

  IF p_is_anon THEN
    UPDATE anon_messages
    SET deleted_for_users = array_append(deleted_for_users, v_uid)
    WHERE id = ANY(p_message_ids)
      AND NOT (v_uid = ANY(deleted_for_users));
  ELSE
    UPDATE chat_messages
    SET deleted_for_users = array_append(deleted_for_users, v_uid)
    WHERE id = ANY(p_message_ids)
      AND NOT (v_uid = ANY(deleted_for_users));
  END IF;
END;
$$;

-- 5. RPC Function untuk Tarik Pesan (Delete for Everyone / Unsend)
CREATE OR REPLACE FUNCTION unsend_messages_for_everyone(p_message_ids UUID[], p_is_anon BOOLEAN DEFAULT false)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_uid UUID := auth.uid();
BEGIN
  IF v_uid IS NULL THEN
    RETURN;
  END IF;

  IF p_is_anon THEN
    UPDATE anon_messages
    SET is_deleted_for_everyone = true,
        deleted_at = now()
    WHERE id = ANY(p_message_ids)
      AND (sender_id = v_uid OR sender_id IS NULL);
  ELSE
    -- Chat konseling: sender_id harus sama dan ditarik dalam rentang waktu toleransi (misal 30 menit)
    UPDATE chat_messages
    SET is_deleted_for_everyone = true,
        deleted_at = now()
    WHERE id = ANY(p_message_ids)
      AND sender_id = v_uid
      AND created_at >= (now() - INTERVAL '30 minutes');
  END IF;
END;
$$;
