-- Migration: 20261028000003_add_counselor_verification.sql
-- Description: Sistem verifikasi dan approval gate untuk peran Konselor Sebaya (Memperbaiki SEC-003)

-- 1. Tambahkan kolom is_verified dan counselor_status ke tabel profiles
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS is_verified BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN IF NOT EXISTS counselor_status TEXT NOT NULL DEFAULT 'unregistered';

-- 2. Beri status 'approved' & is_verified = true untuk akun konselor yang sudah ada di database saat ini
UPDATE public.profiles
SET is_verified = true,
    counselor_status = 'approved'
WHERE role = 'konselor';

-- Beri status 'approved' untuk mahasiswa biasa
UPDATE public.profiles
SET is_verified = true,
    counselor_status = 'approved'
WHERE role != 'konselor';

-- 3. Perbarui trigger handle_new_user agar konselor baru wajib berstatus pending
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  v_role text;
  v_is_verified boolean;
  v_counselor_status text;
BEGIN
  -- Ambil role dari raw_user_meta_data
  v_role := COALESCE(new.raw_user_meta_data->>'role', 'mahasiswa');
  
  -- Jika role adalah konselor, tahan di pending approval
  IF v_role = 'konselor' THEN
    v_is_verified := false;
    v_counselor_status := 'pending';
  ELSE
    v_is_verified := true;
    v_counselor_status := 'approved';
  END IF;

  INSERT INTO public.profiles (
    id, 
    full_name, 
    nickname, 
    faculty, 
    study_program, 
    batch_year, 
    gender, 
    role,
    is_verified,
    counselor_status,
    created_at, 
    updated_at
  )
  VALUES (
    new.id,
    COALESCE(new.raw_user_meta_data->>'full_name', 'Mahasiswa UB'),
    COALESCE(new.raw_user_meta_data->>'nickname', 'Sobat'),
    COALESCE(new.raw_user_meta_data->>'faculty', 'FILKOM'),
    COALESCE(new.raw_user_meta_data->>'study_program', 'S1 Teknik Informatika'),
    COALESCE(new.raw_user_meta_data->>'batch_year', '2025'),
    COALESCE(new.raw_user_meta_data->>'gender', 'Lainnya'),
    v_role,
    v_is_verified,
    v_counselor_status,
    now(),
    now()
  )
  ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    nickname = EXCLUDED.nickname,
    faculty = EXCLUDED.faculty,
    study_program = EXCLUDED.study_program,
    batch_year = EXCLUDED.batch_year,
    gender = EXCLUDED.gender,
    role = EXCLUDED.role,
    is_verified = EXCLUDED.is_verified,
    counselor_status = EXCLUDED.counselor_status,
    updated_at = now();

  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Perbarui view publik konselor agar hanya memuat konselor terverifikasi
DROP VIEW IF EXISTS public.counselor_profiles_view CASCADE;

CREATE OR REPLACE VIEW public.counselor_profiles_view AS
SELECT 
  id, 
  full_name, 
  nickname, 
  faculty, 
  study_program, 
  batch_year, 
  gender,
  role, 
  avatar_url, 
  hobbies, 
  counselor_status, 
  is_verified
FROM public.profiles
WHERE role = 'konselor' 
  AND is_verified = true 
  AND counselor_status = 'approved';

-- 5. Perketat RPC claim_counseling_queue agar menolak konselor unverified
CREATE OR REPLACE FUNCTION public.claim_counseling_queue(
  p_queue_id UUID,
  p_counselor_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_queue RECORD;
  v_session_id UUID;
  v_is_verified BOOLEAN;
BEGIN
  -- Validasi apakah konselor berstatus verified
  SELECT is_verified INTO v_is_verified
  FROM public.profiles
  WHERE id = p_counselor_id AND role = 'konselor';

  IF v_is_verified IS NOT TRUE THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'Akses ditolak: Akun konselor belum disetujui oleh admin'
    );
  END IF;

  -- Kunci antrean spesifik dengan FOR UPDATE
  SELECT * INTO v_queue
  FROM public.counseling_queues
  WHERE id = p_queue_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Antrean tidak ditemukan');
  END IF;

  IF v_queue.status != 'waiting' THEN
    RETURN jsonb_build_object('success', false, 'error', 'Antrean sudah diambil oleh konselor lain');
  END IF;

  -- Update status antrean menjadi claimed
  UPDATE public.counseling_queues
  SET status = 'claimed',
      assigned_counselor_id = p_counselor_id
  WHERE id = p_queue_id;

  -- Buat sesi aktif di counseling_sessions
  INSERT INTO public.counseling_sessions (
    student_id,
    counselor_id,
    student_alias,
    student_faculty,
    status,
    started_at
  )
  VALUES (
    v_queue.student_id,
    p_counselor_id,
    v_queue.student_alias,
    v_queue.student_faculty,
    'active',
    now()
  )
  RETURNING id INTO v_session_id;

  RETURN jsonb_build_object(
    'success', true,
    'session_id', v_session_id
  );
END;
$$;
