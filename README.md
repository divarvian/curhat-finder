# Curhat Finder 💬🌱

> **Platform Konseling Sebaya & Ruang Curhat Mahasiswa Berbasis Flutter & Supabase**

Curhat Finder adalah aplikasi mobile kesehatan mental mahasiswa yang dirancang untuk menyediakan ruang aman, inklusif, dan rahasia bagi mahasiswa dalam mencurahkan isi hati, berdiskusi secara anonim, maupun mendapatkan pendampingan dari Konselor Sebaya yang telah terverifikasi.

---

## ✨ Fitur Utama

### 1. 🤝 Konseling Sebaya (Peer Counseling)
- **Antrean On-Demand Realtime**: Mahasiswa dapat memilih konselor sebaya yang sedang aktif (*online*) dan mengantre secara otomatis.
- **Obrolan 1-on-1 Interaktif**:
  - Tanda status pesan (*Sent*, *Delivered*, *Read*).
  - Indikator mengetik (*Typing & Choosing Emoji Indicator*).
  - Pemilih emoji (*In-app Emoji Keyboard*).
  - Deteksi keaktifan (*Activity-based Presence Heartbeat*).
- **Kontrol Pesan**:
  - **Tarik Pesan (*Unsend*)**: Menarik pesan terkirim dalam batas toleransi waktu 30 menit.
  - **Hapus untuk Saya (*Delete for Me*)**: Menyembunyikan pesan tertentu hanya dari tampilan lokal pengguna.
- **Akhiri Sesi & Rating**: Mahasiswa dapat mengakhiri sesi dan memberikan ulasan bintang serta masukan untuk konselor.

### 2. 🎭 Obrolan Anonim (Anonymous Matchmaking)
- **Pencocokan Acak Berdasarkan Kebutuhan**: Pilihan mode *"Cuma mau didengar"*, *"Butuh saran"*, atau *"Obrolan santai"*.
- **3-Layer Deduplication Engine**: Mencegah duplikasi pesan saat jaringan tidak stabil atau saat terjadi *auto-retry*.
- **Auto-Reconnection & AI Bot Companion**: Rekoneksi otomatis saat koneksi pulih, serta pendampingan AI Bot saat antrean sedang sepi.
- **Pelaporan & Moderasi (*Report Engine*)**: Mekanisme pelaporan obrolan yang melanggar aturan komunitas demi menjaga ruang yang sehat.

### 3. 🔒 Jurnal & Mood Tracker Privat
- **Daily Mood Check-In**: Pencatatan emosi harian (*Senang, Biasa saja, Lelah, Sedih, Marah*) beserta catatan refleksi.
- **Ruang Sambat Privat**: Catatan curhat pribadi yang **100% terisolasi** menggunakan tabel khusus `user_private_sambats` dengan kebijakan keamanan PostgreSQL *Row Level Security (RLS)* — hanya dapat diakses oleh pemilik akun (`auth.uid() = user_id`).

### 4. 💡 Beranda & Tips Komunitas
- **Feed Tips Self-Care**: Kumpulan kiat praktis kesehatan mental, manajemen stres, dan produktivitas mahasiswa yang dapat difilter berdasarkan kategori.
- **Interaksi Komunitas**: Mahasiswa dapat membagikan tip positif dan menyukai tip bermanfaat.

### 5. 🛡️ Gerbang Verifikasi Konselor (*Approval Gate*)
- Pendaftaran konselor sebaya melalui proses verifikasi berkas/status (`pending`, `approved`, `rejected`).
- Konselor yang belum disetujui dialihkan ke layar antarmuka khusus pemantauan status dan dibatasi dari akses sesi konseling mahasiswa.

### 6. 🚨 Pulse & Hotline Darurat
- Direktori kontak darurat dan hotline bantuan krisis kesehatan mental universitas yang dapat dihubungi secara cepat saat situasi genting.

### 7. 🔔 Push Notification Realtime
- Didukung oleh integrasi **Firebase Cloud Messaging (FCM HTTP v1)** dan database triggers Supabase untuk memberikan pemberitahuan instan saat ada pesan masuk atau antrean baru.

---

## 🛠️ Tech Stack & Arsitektur

- **Framework**: [Flutter](https://flutter.dev/) (Channel Stable, Dart 3.x)
- **State Management**: [Flutter Riverpod](https://riverpod.dev/) (`NotifierProvider`, immutable state pattern)
- **Navigasi & Routing**: [GoRouter](https://pub.dev/packages/go_router) (Declarative routing, guarded redirects)
- **Backend & Database**: [Supabase](https://supabase.com/)
  - PostgreSQL 17 dengan RLS (*Row Level Security*) ketat di semua tabel
  - Supabase Realtime (Broadcast, Presence, Postgres Changes)
  - Supabase Edge Functions (Deno Runtime)
  - Stored Procedures & Atomic RPCs
- **Push Notification**: Firebase Core, Firebase Messaging (FCM v1), `flutter_local_notifications`
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
│   ├── services/
│   │   ├── notification_service.dart # Inisialisasi FCM & Notifikasi Lokal
│   │   ├── storage_service.dart     # Manajemen upload avatar Supabase Storage
│   │   └── supabase_service.dart    # Client Supabase & pembaca konfigurasi .env
│   ├── theme/
│   │   ├── app_colors.dart          # Palet warna aplikasi
│   │   ├── app_text_styles.dart     # Skala tipografi
│   │   └── app_theme.dart           # Tema Material Design 3
│   └── utils/
│       └── academic_helper.dart     # Resolver kode fakultas & prodi universitas
├── features/
│   ├── auth/                        # Registrasi wizard, login, approval gate konselor
│   ├── beranda/                     # Feed tips self-care & community service
│   ├── chat/                        # Obrolan konseling, anon chat, matchmaking, rating
│   ├── counselor/                   # Dashboard & navigasi khusus konselor sebaya
│   ├── jurnal/                      # Mood check-in & catatan sambat privat
│   ├── profile/                     # Profil pengguna, avatar, status
│   ├── pulse/                       # Hotline darurat & kontak krisis
│   └── splash/                      # Splash screen & routing otomatis berbasis role
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

Aplikasi ini dilengkapi dengan pengujian unit dan pengujian widget komprehensif:

```bash
# Jalankan analisis statis kode
flutter analyze

# Jalankan seluruh rangkaian test suite
flutter test test/widget_test.dart
```

Cakupan pengujian mencakup:
- Pemetaan akademik fakultas & program studi
- Antrean, deduplikasi pesan chat 3-layer, dan rekoneksi anon chat
- Kebijakan unsend pesan (toleransi 30 menit) dan delete for me
- Approval gate konselor sebaya & `CounselorPendingView`
- Keamanan pembacaan environment variables tanpa kebocoran kredensial

---

## 🔒 Kebijakan Keamanan & Privasi

1. **Prinsip Least Privilege**: Seluruh tabel Supabase dilindungi oleh *Row Level Security (RLS)*. Mahasiswa tidak dapat membaca data curhat atau sesi konseling milik pengguna lain.
2. **Kredensial Aman**: Tidak ada kredensial sensitif, service account private key, atau secret token yang di-hardcode di dalam source code.
3. **Isolasi Curhat**: Catatan sambat disimpan di tabel terpisah khusus pengguna terotentikasi, terpisah dari konten publik beranda.

---

## 📄 Lisensi

Hak Cipta © 2026 Tim Pengembang Curhat Finder. Seluruh hak cipta dilindungi undang-undang.
