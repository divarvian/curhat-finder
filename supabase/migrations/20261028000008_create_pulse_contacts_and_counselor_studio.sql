-- Migration 20261028000008: Create pulse_contacts, counselor_articles, and counselor_forums
-- Supports: P2-1 (FEAT-002: Dynamic Pulse Contacts) and P2-2 (FEAT-001: Counselor Creator Studio & Forum)

-- ============================================================================
-- 1. PULSE CONTACTS (Layanan Krisis & Kontak Konseling Kampus Dinamis)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.pulse_contacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    faculty TEXT NOT NULL,
    phone TEXT NOT NULL,
    whatsapp_number TEXT,
    description TEXT,
    is_emergency BOOLEAN NOT NULL DEFAULT false,
    avatar_url TEXT,
    display_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexing for fast search and display ordering
CREATE INDEX IF NOT EXISTS idx_pulse_contacts_faculty ON public.pulse_contacts(faculty);
CREATE INDEX IF NOT EXISTS idx_pulse_contacts_order ON public.pulse_contacts(display_order);

-- RLS for pulse_contacts
ALTER TABLE public.pulse_contacts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view pulse contacts" ON public.pulse_contacts;
CREATE POLICY "Anyone can view pulse contacts"
    ON public.pulse_contacts FOR SELECT TO authenticated
    USING (true);

-- Seed initial official contacts for Universitas Brawijaya & Emergency Hotlines
INSERT INTO public.pulse_contacts (name, faculty, phone, whatsapp_number, description, is_emergency, display_order)
VALUES
    ('Unit Bimbingan Konseling FILKOM', 'FILKOM', '0812-3000-8801', '6281230008801', 'Layanan bimbingan akademik dan konseling sebaya Fakultas Ilmu Komputer UB', false, 1),
    ('Layanan Konseling Mahasiswa FIB', 'FIB', '0812-3000-8802', '6281230008802', 'Unit konseling mahasiswa Fakultas Ilmu Budaya UB', false, 2),
    ('Pusat Konseling Fakultas Teknik', 'FT', '0812-3000-8803', '6281230008803', 'Layanan pendampingan psikologis Fakultas Teknik UB', false, 3),
    ('Layanan Konseling FISIP / FBiPK', 'FBiPK', '0812-3000-8804', '6281230008804', 'Layanan pendampingan konseling FISIP / FBiPK UB', false, 4),
    ('Unit Krisis & BK Fakultas Kedokteran', 'FK', '0341-569117', '6281230008805', 'Unit penanganan krisis dan konseling Fakultas Kedokteran UB', false, 5),
    ('Layanan Psikologi FEB UB', 'FEB', '0812-3000-8805', '6281230008806', 'Pusat layanan psikologi dan pengembangan karakter FEB UB', false, 6),
    ('IGD RS Universitas Brawijaya', 'Semua', '0341-403000', '628123403000', 'Instalasi Gawat Darurat Rumah Sakit UB 24 Jam', true, 7),
    ('Hotline Sejiwa Kemenkes (24 Jam)', 'Semua', '119 ext 8', '62811979119', 'Layanan krisis kesehatan jiwa dan pencegahan bunuh diri nasional Kemenkes RI', true, 8)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 2. COUNSELOR ARTICLES (Creator Studio Konselor)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.counselor_articles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    author_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'Self-care',
    content TEXT NOT NULL,
    thumbnail_url TEXT,
    likes_count INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_counselor_articles_author ON public.counselor_articles(author_id);
CREATE INDEX IF NOT EXISTS idx_counselor_articles_category ON public.counselor_articles(category);

ALTER TABLE public.counselor_articles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view counselor articles" ON public.counselor_articles;
CREATE POLICY "Anyone can view counselor articles"
    ON public.counselor_articles FOR SELECT TO authenticated
    USING (true);

DROP POLICY IF EXISTS "Counselors can insert articles" ON public.counselor_articles;
CREATE POLICY "Counselors can insert articles"
    ON public.counselor_articles FOR INSERT TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE id = auth.uid() AND role = 'konselor'
        )
    );

DROP POLICY IF EXISTS "Counselors can update own articles" ON public.counselor_articles;
CREATE POLICY "Counselors can update own articles"
    ON public.counselor_articles FOR UPDATE TO authenticated
    USING (author_id = auth.uid())
    WITH CHECK (author_id = auth.uid());

DROP POLICY IF EXISTS "Counselors can delete own articles" ON public.counselor_articles;
CREATE POLICY "Counselors can delete own articles"
    ON public.counselor_articles FOR DELETE TO authenticated
    USING (author_id = auth.uid());

-- ============================================================================
-- 3. COUNSELOR FORUMS (Forum Diskusi & Supervisi Antar-Konselor)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.counselor_forums (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    author_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    topic TEXT NOT NULL DEFAULT 'Studi Kasus',
    content TEXT NOT NULL,
    replies_count INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_counselor_forums_topic ON public.counselor_forums(topic);

ALTER TABLE public.counselor_forums ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Only counselors can view forum threads" ON public.counselor_forums;
CREATE POLICY "Only counselors can view forum threads"
    ON public.counselor_forums FOR SELECT TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE id = auth.uid() AND role = 'konselor'
        )
    );

DROP POLICY IF EXISTS "Only counselors can insert forum threads" ON public.counselor_forums;
CREATE POLICY "Only counselors can insert forum threads"
    ON public.counselor_forums FOR INSERT TO authenticated
    WITH CHECK (
        author_id = auth.uid() AND
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE id = auth.uid() AND role = 'konselor'
        )
    );
