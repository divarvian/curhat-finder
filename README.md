# Template Starter Flutter Androzon Mobile Engineer 2026

Proyek ini adalah template dasar Flutter untuk project Androzon Mobile Engineer 2026.

---

## Struktur direktori

Proyek pada branch ini menggunakan arsitektur MVVM (Model-View-ViewModel) dengan pembagian folder berdasarkan fitur di bawah direktori `ui/`, serta pemisahan logika data ke dalam direktori `data/` (Data Layer).

Berikut adalah pemetaan folder pada branch `feature/bloc`:

```
lib/
├── main.dart                          # Entry point aplikasi (Inisialisasi Bloc & Repository)
├── app/
│   └── config/
│       └── router.dart                # Pengaturan rute menggunakan GoRouter
├── core/
│   └── theme/
│       ├── app_colors.dart            # Token warna aplikasi
│       ├── app_text_styles.dart       # Gaya tipografi aplikasi
│       └── app_theme.dart             # Tema utama Material 3
├── data/                              # Lapisan Data (Data Layer)
│   ├── models/
│   │   └── user.dart                  # Model data pengguna
│   ├── services/
│   │   └── auth_service.dart          # Layanan simulasi API autentikasi
│   └── repositories/
│       └── auth_repository.dart       # Repositori untuk konversi data ke model
└── ui/
    └── features/                      # Lapisan Tampilan (UI & State)
        ├── onboarding/
        │   └── views/
        │       └── onboarding_view.dart
        ├── auth/
        │   ├── bloc/
        │   │   ├── auth_cubit.dart    # Cubit untuk memproses logika bisnis auth
        │   │   └── auth_state.dart    # Status state dari auth (Loading, Success, Failure)
        │   └── views/
        │       ├── login_view.dart
        │       └── register_view.dart
        └── dashboard/
            └── views/
                └── dashboard_view.dart
```

### Rincian folder utama

- **`lib/main.dart`**: Titik masuk utama aplikasi. Bagian ini mendaftarkan `RepositoryProvider` untuk menyediakan `AuthRepository` dan `BlocProvider` untuk mengalirkan `AuthCubit` ke seluruh widget tree.
- **`lib/data/`**: Berisi model data (`User`), layanan API (`AuthService`), dan repositori (`AuthRepository`). Semua urusan pengambilan data dan pengubahan format data mentah dilakukan di sini.
- **`lib/ui/features/`**: Berisi halaman visual (views) dan pengelola status berupa Cubit. Logika tampilan dipisahkan dari detail cara data diambil dari server.

---

## Pembagian Branch Git

Untuk mempermudah pembandingan, repositori ini memisahkan fitur autentikasi (*auth*) ke dalam beberapa branch terpisah sesuai pustaka pengelola status yang digunakan:

1. **`main`**: Berisi demo penghitung (*Counter*) sederhana yang menggunakan ketiga pengelola status secara bersamaan di satu halaman dashboard utama. Branch ini juga berisi struktur dasar tema, splash screen, dan halaman onboarding.
2. **`feature/provider`**: Contoh implementasi fitur login dan pendaftaran pengguna menggunakan Provider.
3. **`feature/riverpod`**: Contoh implementasi fitur login dan pendaftaran pengguna menggunakan Riverpod.
4. **`feature/bloc`**: Contoh implementasi fitur login dan pendaftaran pengguna menggunakan BLoC (Cubit).

Kredensial percobaan (dummy) untuk halaman login:
- **Email**: `admin@example.com`
- **Password**: `password123`

---

## Perbandingan State Management

Berikut perbandingan objektif dari ketiga pustaka pengelola status yang diimplementasikan dalam proyek ini:

| Kriteria | Provider | Riverpod | BLoC / Cubit |
| :--- | :--- | :--- | :--- |
| **Tingkat Kesulitan** | Mudah dipelajari karena mirip dengan arsitektur bawaan Flutter. | Sedang, memerlukan pemahaman tentang konsep provider global di luar widget. | Tinggi, membutuhkan pemahaman tentang aliran data asinkron (*streams*) dan event. |
| **Kode Boilerplate** | Sangat sedikit. | Sedikit hingga sedang. | Cukup banyak karena harus mendefinisikan event, state, dan kelas BLoC. |
| **Ketergantungan Context** | Ya, membutuhkan `BuildContext` untuk membaca status. | Tidak, menggunakan objek `WidgetRef` untuk membaca status di luar *context*. | Ya, membutuhkan `BuildContext` untuk mencari provider BLoC yang sesuai. |
| **Skalabilitas** | Cocok untuk proyek kecil hingga menengah. | Sangat baik untuk proyek skala kecil hingga besar. | Sangat baik untuk proyek skala besar dengan tim yang banyak. |

---

## Panduan Penggunaan Google Fonts

Proyek ini menggunakan pustaka `google_fonts` untuk mengatur tipografi global secara dinamis.

### Penggunaan Standar (Memerlukan Koneksi Internet)
Font akan diunduh secara otomatis dari server Google saat aplikasi pertama kali dijalankan dan disimpan di dalam penyimpanan lokal perangkat:
```dart
import 'package:google_fonts/google_fonts.dart';

final TextStyle gayaTeks = GoogleFonts.inter(
  fontSize: 16,
  fontWeight: FontWeight.normal,
);
```

### Alternatif Penggunaan Font File Langsung (Secara Offline/Luring)

Jika Anda ingin menghindari penggunaan paket `google_fonts` dan menggunakan berkas font lokal secara langsung (cara bawaan Flutter), ikuti langkah-langkah berikut:

#### Langkah 1: Siapkan Berkas Font
1. Unduh berkas font pilihan Anda (format `.ttf` atau `.otf`) dari penyedia font (misalnya Google Fonts atau lainnya).
2. Buat direktori bernama `assets/fonts/` di dalam proyek Anda.
3. Simpan berkas font tersebut di dalam direktori tersebut (misalnya `Inter-Regular.ttf` dan `Inter-Bold.ttf`).

#### Langkah 2: Daftarkan Font di `pubspec.yaml`
Konfigurasikan keluarga font tersebut di bagian `flutter:` pada berkas `pubspec.yaml`:
```yaml
flutter:
  fonts:
    - family: Inter  # Nama keluarga font yang akan dipanggil di kode Dart
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700  # Menentukan ketebalan font untuk versi Bold
```

#### Langkah 3: Gunakan di Kode Dart
Anda dapat menerapkan font tersebut langsung menggunakan parameter `fontFamily` pada `TextStyle`:
```dart
const TextStyle gayaTeks = TextStyle(
  fontFamily: 'Inter',
  fontSize: 16,
  fontWeight: FontWeight.bold, // Ini akan menggunakan berkas Inter-Bold.ttf secara otomatis
);
```

---

## Panduan Pembuatan Ikon Peluncur dan Splash Screen

### Ikon Peluncur (App Icon)
Proyek ini menggunakan paket `icons_launcher` untuk memperbarui ikon aplikasi secara otomatis. 
- **Persyaratan Aset**: Gunakan gambar persegi berformat PNG dengan resolusi minimal 512x512 piksel. Pastikan tidak ada area transparan pada pinggiran gambar agar ikon tampil maksimal pada perangkat Android.
- **Cara Membuat**:
  1. Siapkan ikon Anda dan simpan di `assets/icons/icon_launcher.png`.
  2. Jalankan perintah berikut di terminal:
     ```bash
     dart run icons_launcher:create
     ```

### Splash Screen
Proyek ini menggunakan paket `flutter_native_splash` untuk memodifikasi splash screen bawaan perangkat.
- **Persyaratan Aset**: Siapkan logo berformat PNG dengan resolusi minimal 1024x1024 piksel untuk diletakkan di bagian tengah layar.
- **Cara Membuat**:
  1. Siapkan gambar splash screen Anda dan simpan di `assets/images/splash_screen.png`.
  2. Sesuaikan konfigurasi warna latar belakang dan letak gambar pada bagian `flutter_native_splash` di dalam berkas `pubspec.yaml`.
  3. Jalankan perintah berikut di terminal:
     ```bash
     flutter pub run flutter_native_splash:create
     ```

---

## Tautan Dokumentasi Resmi

Gunakan tautan di bawah ini untuk mempelajari dasar teori dari masing-masing pustaka pengelola status secara mendalam:
- [Dokumentasi Resmi Provider](https://pub.dev/packages/provider)
- [Dokumentasi Resmi Riverpod](https://riverpod.dev)
- [Dokumentasi Resmi BLoC](https://bloclibrary.dev)
