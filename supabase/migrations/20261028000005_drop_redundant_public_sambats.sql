-- Migration: 20261028000005_drop_redundant_public_sambats.sql
-- Description: Menghapus tabel publik sambats lama untuk mencegah residu privasi curhat lama (P0 Sanitasi Privasi)

-- 1. Cabut fungsi cheer_sambat yang sebelumnya menempel pada tabel publik sambats
DROP FUNCTION IF EXISTS public.cheer_sambat(UUID);

-- 2. Hapus tabel publik sambats secara permanen beserta policy RLS-nya
-- Catatan: Seluruh data curhat pengguna telah 100% aman tersalin di tabel public.user_private_sambats
DROP TABLE IF EXISTS public.sambats CASCADE;
