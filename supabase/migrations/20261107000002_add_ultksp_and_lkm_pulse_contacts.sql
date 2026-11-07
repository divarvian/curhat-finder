-- Migration 20261107000002: Add ULTKSP and LKM official contacts to pulse_contacts
-- ULTKSP: Unit Layanan Kekerasan Seksual & Perundungan (Satgas PPKSP Universitas Brawijaya)
-- LKM: Layanan Konseling Mahasiswa (Pusat Konseling & Kesehatan Mental Mahasiswa UB)

INSERT INTO public.pulse_contacts (name, faculty, phone, whatsapp_number, description, is_emergency, avatar_url, display_order)
SELECT 
    'ULTKSP (Unit Layanan Kekerasan Seksual & Perundungan)', 
    'Semua', 
    '0811-3770-008', 
    '628113770008', 
    'Satgas PPKSP Universitas Brawijaya. Penanganan krisis kekerasan seksual, pelecehan verbal/fisik, dan perundungan 24/7.', 
    true, 
    'assets/images/mascot_emergency.png', 
    0
WHERE NOT EXISTS (
    SELECT 1 FROM public.pulse_contacts WHERE name LIKE '%ULTKSP%'
);

INSERT INTO public.pulse_contacts (name, faculty, phone, whatsapp_number, description, is_emergency, avatar_url, display_order)
SELECT 
    'LKM (Layanan Konseling Mahasiswa)', 
    'Semua', 
    '0812-3000-8800', 
    '6281230008800', 
    'Pusat layanan konseling psikologis, kesehatan mental, stres akademik, dan bimbingan sebaya mahasiswa UB.', 
    false, 
    'assets/images/mascot.png', 
    1
WHERE NOT EXISTS (
    SELECT 1 FROM public.pulse_contacts WHERE name LIKE '%LKM (Layanan Konseling Mahasiswa)%'
);
