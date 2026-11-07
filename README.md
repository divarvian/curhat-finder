# Curhat Finder 💬🌱

> **Platform Konseling Sebaya & Ruang Curhat Mahasiswa Berbasis Flutter & Supabase**

Curhat Finder adalah aplikasi mobile kesehatan mental mahasiswa yang dirancang untuk menyediakan ruang aman, inklusif, dan rahasia bagi mahasiswa dalam mencurahkan isi hati, berdiskusi secara anonim, maupun mendapatkan pendampingan dari Konselor Sebaya yang telah terverifikasi.

---

## ✨ Fitur Utama

### 1. 🤝 Konseling Sebaya (Peer Counseling)
- **Antrean On-Demand Realtime**: Mahasiswa dapat memilih konselor sebaya yang sedang aktif (*online*) dan mengantre secara otomatis (`counseling_queues`).
- **Obrolan 1-on-1 Interaktif**:
  - Tanda status pesan (*Sent*, *Delivered*, *Read*).
  - Indikator mengetik (*Typing & Choosing Emoji Indicator*).
  - Pemilih emoji terintegrasi (*In-app Emoji Keyboard*).
  - Deteksi keaktifan (*Activity-based Presence Heartbeat*).
- **Kontrol Pesan**:
  - **Tarik Pesan (*Unsend*)**: Menarik pesan terkirim dalam batas toleransi waktu 30 menit.
  - **Hapus untuk Saya (*Delete for Me*)**: Menyembunyikan pesan tertentu dari tampilan lokal pengguna.
- **Akhiri Sesi & Rating**: Mahasiswa dapat mengakhiri sesi dan memberikan ulasan bintang serta masukan untuk konselor.
- **Otomasi Metrik Konselor**: Penghitungan atomik sesi aktif, total mahasiswa terbantu, dan rata-rata waktu respon konselor melalui trigger database PostgreSQL Supabase.

### 2. 🎭 Obrolan Anonim (Anonymous Matchmaking)
- **Pencocokan Acak Berdasarkan Kebutuhan**: Pilihan mode *"Cuma mau didengar"*, *"Butuh saran"*, atau *"Obrolan santai"*.
- **3-Layer Deduplication Engine**: Mencegah duplikasi pesan saat jaringan tidak stabil atau saat terjadi *auto-retry*.
- **Auto-Reconnection & AI Bot Companion**: Rekoneksi otomatis saat koneksi pulih, serta pendampingan AI Bot saat antrean sedang sepi.
- **Pelaporan & Moderasi (*Report Engine*)**: Mekanisme pelaporan obrolan yang melanggar aturan komunitas demi menjaga ruang yang sehat.

### 3. 🏢 Ruang Curhat (Campus Rooms Feed)
- **Feed Curhat Per Kategori & Fakultas**: Ruang diskusi terbuka/anonim mahasiswa untuk saling menyemangati berdasarkan topik (*Akademik*, *Burnout*, *Keuangan*, *Keluarga*, dll).
- **Interaksi Optimistik Zero-Delay**: Sistem suka (*like*) dan simpan (*bookmark*) instan 0ms dengan algoritma **Echo Cancellation** untuk mencegah anomali lonjakan double-counting (+2/0) saat sinkronisasi realtime.
- **Komentar Bimbingan Terverifikasi**: Komentar dari konselor sebaya otomatis mendapatkan lencana resmi verified *Konselor Sebaya*.
- **Manajemen Konten Pemilik (Menu Titik 3)**: Penulis postingan/tips dapat menghapus konten buatannya secara aman dengan dialog konfirmasi kanonikal Milo, terhapus secara *cascade* di database.

### 4. 🔒 Jurnal & Mood Tracker Privat
- **Daily Mood Check-In**: Pencatatan emosi harian (*Senang, Biasa saja, Lelah, Sedih, Marah*) beserta catatan refleksi.
- **Ruang Sambat Privat**: Catatan curhat pribadi yang **100% terisolasi** menggunakan tabel khusus `user_private_sambats` dengan kebijakan keamanan PostgreSQL *Row Level Security (RLS)* — hanya dapat diakses oleh pemilik akun (`auth.uid() = user_id`).

### 5. 💡 Beranda & Tips Komunitas
- **Feed Tips Self-Care**: Kumpulan kiat praktis kesehatan mental dan produktivitas mahasiswa yang dapat difilter berdasarkan kategori.
- **Halaman Detail "Isi Tips" (`TipDetailView`)**: Tampilan tips terstruktur (Judul headline tebal, kategori, dan deskripsi) dengan maskot Milo mengintip (*sticky peeking*) di bibir bawah kartu (`mascot_seek.png`).
- **Modal Terpadu Pembuatan Tips (`CreateTipSheet`)**: Bottom sheet interaktif untuk membuat dan membagikan tips self-care positif ke komunitas.

### 6. 🧘 Latihan Pernapasan & Relaksasi Zen
- **Panduan Pernapasan Ritmis 4-7-8**: Latihan relaksasi visual interaktif (*Inhale*, *Hold*, *Exhale*) untuk meredakan kecemasan dan stres akademik.
- **Pengingat Hidrasi Milo**: Tampilan penutup latihan pernapasan dengan pesan ramah *"Jangan lupa minum air putih, ya"* bersama maskot Milo (`mascot_drink.png`).

### 7. 🎓 Dashboard & Forum Konselor Sebaya
- **Pemantauan Antrean & Sesi Aktif**: Dashboard beranda konselor dengan status kehadiran (*Ready to Listen toggle*), ringkasan statistik performa, dan antrean masuk mahasiswa.
- **Leaderboard Top Isu Per Fakultas 🔥**: Tiga baris kartu vertikal bertingkat (Peringkat 1, 2, 3) yang mengagregasikan tren isu kesehatan mental mahasiswa per fakultas secara real-time dari data postingan rooms.
- **Creator Studio**: Formulir in-place terpadu bagi konselor untuk mempublikasikan artikel panduan kesehatan mental langsung ke feed tips (`public.tips`).
- **Kurasi Topik Keahlian Terstandarisasi (`ManageTopicsSheet`)**: Pemilihan topik bimbingan konselor berbasis filter chip resmi pendaftaran, menjaga konsistensi profil konselor.

### 8. 🚨 Pulse & Layanan Krisis Kampus (ULTKSP & LKM)
- **Layanan Utama Berdampingan**:
  - **ULTKSP (Unit Layanan Kekerasan Seksual & Perundungan)**: Satgas PPKSP Universitas Brawijaya untuk penanganan krisis kekerasan seksual, pelecehan fisik/verbal, intimidasi, dan perundungan (*bullying*) siaga 24/7 dengan perlindungan aman, kerahasiaan identitas, dan pendampingan hukum kampus.
  - **LKM (Layanan Konseling Mahasiswa)**: Pusat layanan konseling psikologis, kesehatan mental, penanganan stres akademik/burnout, dan bimbingan sebaya mahasiswa UB.
- **Tombol Informasi `(i)` di Lingkaran**: Modal bottom sheet interaktif yang mengedukasi mahasiswa mengenai perbedaan ruang lingkup, wewenang, dan panduan kapan harus menghubungi ULTKSP vs LKM.
- **Aksi Cepat Telepon & WhatsApp**: Akses instan ke nomor telepon darurat dan WhatsApp resmi masing-masing unit layanan dengan satu ketukan.
- **Direktori Kontak per Fakultas & Nasional**: Direktori kontak bimbingan konseling seluruh fakultas di lingkungan UB, IGD RS UB 24 Jam, dan Hotline Sejiwa Kemenkes 119.

### 9. 🎨 Desain Figma Fidelity & Aksesibilitas
- **Tipografi Ramah Disleksia**: Standarisasi letter-spacing positif (+0.15px s.d. +0.25px) dan line-height proporsional (1.45–1.5) guna mencegah *visual crowding* dan *line-jumping*.
- **Ekspresi Kontekstual Maskot Milo**: 5 variasi maskot Milo beresolusi tinggi (Peeking, Leave, Report, Radar Detective, Emergency Siren, Happy Rating).
- **Paritas Tata Letak Profil**: Desain kartu Informasi Akun membulat 32px, soft dividers, dan tombol logout soft coral konsisten antara mahasiswa dan konselor.
- **Sistem Skeleton Shimmer Mandiri**: Shimmer sweep gradient halus tanpa dependensi eksternal (`AppSkeleton` & `AppShimmer`) yang mencakup seluruh kartu, riwayat jurnal, chat, profil, dan beranda konselor.

---

## 🛠️ Tech Stack & Arsitektur

- **Framework**: [Flutter](https://flutter.dev/) (Channel Stable, Dart 3.x)
- **State Management**: [Flutter Riverpod](https://riverpod.dev/) (`NotifierProvider`, immutable state pattern)
- **Navigasi & Routing**: [GoRouter](https://pub.dev/packages/go_router) (Declarative routing, guarded redirects, type-safe routes)
- **Backend & Database**: [Supabase](https://supabase.com/)
  - PostgreSQL 17 dengan RLS (*Row Level Security*) ketat di semua tabel
  - Supabase Realtime (Broadcast, Presence, Postgres Changes)
  - Supabase Edge Functions (Deno Runtime)
  - Database Triggers & Stored Procedures (Sinkronisasi metrik performa konselor, counter likes/comments)
  - Supabase CLI Migration System (27 migrasi database terkelola)
- **Push Notification**: Firebase Core, Firebase Messaging (FCM v1 HTTP), `flutter_local_notifications`
- **Konfigurasi Environment**: `flutter_dotenv` (Isolasi kredensial via `.env` dan `.env.example`)
- **Code Generation**: Freezed, JSON Serializable, GoRouter Builder, Build Runner

---

## 📂 Struktur Direktori

```
lib/
├── app/
│   └── config/
│       ├── router.dart              # Konfigurasi GoRouter dan Route Guards
│       └── router.g.dart            # Generated routes
├── core/
│   ├── constants/
│   │   └── app_categories.dart      # Single Source of Truth kategori tips, room, topik, dan hobi
│   ├── services/
│   │   ├── notification_service.dart # Inisialisasi FCM & Notifikasi Lokal
│   │   ├── storage_service.dart     # Manajemen upload avatar Supabase Storage
│   │   └── supabase_service.dart    # Client Supabase & pembaca konfigurasi .env
│   ├── theme/
│   │   ├── app_colors.dart          # Palet warna aplikasi
│   │   ├── app_radii.dart           # Standarisasi border radius
│   │   ├── app_text_styles.dart     # Skala tipografi ramah disleksia
│   │   └── app_theme.dart           # Tema Material Design 3
│   ├── utils/
│   │   ├── academic_helper.dart     # Resolver kode fakultas (18 UB) & prodi universitas
│   │   └── app_error_translator.dart# Terjemahan error auth & jaringan ke bahasa Indonesia
│   └── widgets/
│       ├── app_pill.dart            # Komponen pill/chip dengan presisi optical vertical centering
│       ├── app_skeleton.dart        # Engine shimmer & skeleton loader mandiri
│       └── dialogs/                 # Dialog konfirmasi (hapus postingan, logout)
├── features/
│   ├── auth/                        # Registrasi wizard, login, approval gate konselor
│   ├── beranda/                     # Feed tips self-care, detail "Isi Tips", CreateTipSheet
│   ├── chat/                        # Obrolan konseling, anon matchmaking, rooms feed, rating
│   ├── counselor/                   # Dashboard beranda, forum leaderboard, creator studio, profil
│   ├── jurnal/                      # Mood check-in & catatan sambat privat
│   ├── main_nav/                    # Bottom navigation bar mahasiswa
│   ├── onboarding/                  # Layar selamat datang & orientasi pengguna
│   ├── profile/                     # Profil pengguna, avatar, pengaturan akun
│   ├── pulse/                       # Hotline darurat & kontak krisis
│   ├── splash/                      # Splash screen & routing otomatis berbasis role
│   └── zen/                         # Latihan pernapasan & relaksasi ritmis
└── main.dart                        # Entry point aplikasi
```

---

## 🚀 Panduan Memulai (Quick Start)

### 1. Prasyarat
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi 3.12 atau lebih baru)
- Android Studio / VS Code dengan ekstensi Flutter & Dart
- Perangkat Android fisik atau Emulator

### 2. Kloning Repositori
```bash
git clone https://github.com/divarvian/curhat-finder.git
cd curhat-finder
```

### 3. Konfigurasi Environment (`.env`)
Salin file template `.env.example` menjadi `.env`:
```bash
cp .env.example .env
```
Buka file `.env` dan sesuaikan URL dan Publishable Anon Key proyek Supabase Anda:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-publishable-key
```

> **Catatan Keamanan**: File `.env` lokal telah dimasukkan ke dalam `.gitignore` dan tidak akan pernah terdorong ke repositori Git publik.

### 4. Konfigurasi Firebase Android (Client Config)
Salin file template `google-services.json.example` menjadi `google-services.json` di folder `android/app/`:
```bash
cp android/app/google-services.json.example android/app/google-services.json
```
Isi konfigurasi client dari Firebase Console proyek Anda.

### 5. Unduh Dependensi
```bash
flutter pub get
```

### 6. Jalankan Aplikasi
```bash
flutter run
```

---

## 🧪 Pengujian & Kualitas Kode

Aplikasi ini mengadopsi arsitektur pengujian modular (*Feature-First Modular Testing*) dengan **139 unit & widget tests** (100% kelulusan):

```bash
# Jalankan analisis statis kode (Harus 0 issues)
flutter analyze

# Jalankan seluruh rangkaian test suite otomatis
flutter test
```

Cakupan pengujian mencakup:
- **Core & Theme**: Skala warna, radius, tipografi disleksia, error translator, dan komponen skeleton shimmer.
- **Autentikasi**: Registrasi multi-step, verifikasi role, approval gate konselor, dan sesi login/logout.
- **Beranda & Tips**: Model tips, provider interaksi optimistik, kartu tips, dan halaman detail "Isi Tips".
- **Ruang Curhat (Rooms) & Komentar**: Postingan curhat, komentar konselor terverifikasi, provider likes/bookmarks optimistik, dialog hapus konten milik sendiri.
- **Konseling & Chat**: Deduplikasi pesan 3-layer, unsend pesan (toleransi 30 menit), rating konseling, dan sesi chat konselor.
- **Dashboard Konselor**: Leaderboard vertikal Top Isu Per Fakultas, kurasi topik keahlian, skeleton kartu presensi, dan paritas profil.
- **Database Integrity**: Integritas file migrasi SQL, trigger database konselor, dan kebijakan keamanan PostgreSQL RLS.

---

## 🔒 Kebijakan Keamanan & Privasi

1. **Prinsip Least Privilege**: Seluruh tabel Supabase dilindungi oleh *Row Level Security (RLS)*. Mahasiswa tidak dapat membaca data curhat atau sesi konseling milik pengguna lain.
2. **Kredensial Aman**: Tidak ada kredensial sensitif, service account private key, atau secret token yang di-hardcode di dalam source code.
3. **Isolasi Curhat Privat**: Catatan sambat disimpan di tabel `user_private_sambats` terpisah khusus pengguna terotentikasi, terpisah total dari feed publik komunitas.
4. **Kepemilikan Konten Granular**: Operasi penghapusan tips dan ruang curhat divalidasi langsung di database melalui policy `auth.uid() = user_id`.

---

## 📄 Lisensi

Hak Cipta © 2026 Tim Pengembang Curhat Finder. Seluruh hak cipta dilindungi undang-undang.

