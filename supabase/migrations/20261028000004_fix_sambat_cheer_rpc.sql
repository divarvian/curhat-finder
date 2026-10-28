-- Migration: 20261028000004_fix_sambat_cheer_rpc.sql
-- Description: Cabut policy UPDATE bebas pada sambats dan ganti dengan atomic RPC cheer_sambat (Memperbaiki SEC-004)

-- 1. Cabut policy update bebas yang mengizinkan manipulasi konten sepihak
DROP POLICY IF EXISTS "Users can cheer sambats" ON public.sambats;
DROP POLICY IF EXISTS "Users can only update their own sambats" ON public.sambats;

-- 2. Kebijakan UPDATE hanya boleh dilakukan oleh pemilik sambat untuk konten miliknya sendiri
CREATE POLICY "Users can only update their own sambats"
ON public.sambats FOR UPDATE TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 3. Stored Procedure Atomic Cheer dengan hak akses SECURITY DEFINER
CREATE OR REPLACE FUNCTION public.cheer_sambat(p_sambat_id UUID)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_new_cheer INT;
BEGIN
  UPDATE public.sambats
  SET cheer_count = COALESCE(cheer_count, 0) + 1
  WHERE id = p_sambat_id
  RETURNING cheer_count INTO v_new_cheer;
  
  RETURN v_new_cheer;
END;
$$;

-- Berikan izin eksekusi kepada seluruh user terautentikasi
GRANT EXECUTE ON FUNCTION public.cheer_sambat(UUID) TO authenticated;
