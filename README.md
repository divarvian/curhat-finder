# Template Starter Flutter Androzon Mobile Engineer 2026

Proyek ini adalah template dasar Flutter untuk project Androzon Mobile Engineer 2026.

---

## Struktur direktori

Direktori proyek disusun menggunakan pendekatan berbasis fitur (feature-first) agar mudah dikembangkan dan dirapikan seiring bertambahnya modul.

```
lib/
├── main.dart                          # Entry point aplikasi (terkonfigurasi dengan Provider)
├── app/
│   └── config/
│       └── router.dart                # Konfigurasi routing menggunakan GoRouter
├── core/
│   └── theme/
│       ├── app_colors.dart            # Token warna global aplikasi
│       ├── app_text_styles.dart       # Tipografi global aplikasi
│       └── app_theme.dart             # Konfigurasi ThemeData Material 3
├── data/                              # Direktori Data Layer (Model, Service, Repository)
│   ├── models/
│   │   └── user.dart                  # Model User terautentikasi
│   ├── services/
│   │   └── auth_service.dart          # Simulasi layanan API Auth
│   └── repositories/
│       └── auth_repository.dart       # Repositori Auth sebagai single source of truth
└── ui/
    └── features/
        ├── onboarding/
        │   └── views/
        │       └── onboarding_view.dart
        ├── auth/
        │   ├── view_models/
        │   │   └── auth_notifier.dart # Pengelola state autentikasi menggunakan ChangeNotifier
        │   └── views/
        │       ├── login_view.dart    # Tampilan masuk akun
        │       └── register_view.dart # Tampilan daftar akun
        └── dashboard/
            └── views/
                └── dashboard_view.dart # Tampilan dasbor setelah login

assets/
├── images/          # Gambar dan splash screen
└── icons/           # Ikon launcher aplikasi
```

### Penjelasan folder utama

- **`lib/main.dart`**: Entry point aplikasi. Mendaftarkan `AuthService`, `AuthRepository`, dan `AuthNotifier` secara bertingkat di root widget tree menggunakan Provider.
- **`lib/app/config/`**: Konfigurasi global seperti routing menggunakan GoRouter.
- **`lib/core/theme/`**: Design system aplikasi, berisi warna (`AppColors`), tipografi (`AppTextStyles`), dan tema Material 3 (`AppTheme`) yang digunakan secara konsisten.
- **`lib/data/`**: Direktori Data Layer yang mengelola model data `User`, simulasi API `AuthService`, dan `AuthRepository` untuk memisahkan logika bisnis dari UI.
- **`lib/ui/features/`**: Folder fitur tampilan (UI) yang dibagi per domain. Setiap fitur memiliki sub-folder `views/` untuk UI dan folder `view_models/` untuk ChangeNotifier pengelola status.
- **`assets/`**: Penyimpanan berkas statis gambar dan ikon aplikasi.

---

## Pembagian branch Git

Untuk mempermudah pembandingan, repositori ini memisahkan fitur autentikasi (auth) ke dalam beberapa branch terpisah sesuai pustaka pengelola status yang digunakan:

1. **`main`**: Berisi demo penghitung (Counter) sederhana yang menggunakan ketiga pengelola status secara bersamaan di satu halaman dashboard utama. Branch ini juga berisi struktur dasar tema, splash screen, dan halaman onboarding.
2. **`feature/provider`**: Contoh implementasi fitur login dan pendaftaran pengguna menggunakan Provider.
3. **`feature/riverpod`**: Contoh implementasi fitur login dan pendaftaran pengguna menggunakan Riverpod.
4. **`feature/bloc`**: Contoh implementasi fitur login dan pendaftaran pengguna menggunakan BLoC (Cubit).

Kredensial percobaan (dummy) untuk halaman login:
- **Email**: `admin@example.com`
- **Password**: `password123`

---

## Perbandingan state management

Berikut perbandingan objektif dari ketiga pustaka pengelola status yang diimplementasikan dalam proyek ini:

| Kriteria | Provider | Riverpod | BLoC / Cubit |
| :--- | :--- | :--- | :--- |
| **Tingkat Kesulitan** | Mudah dipelajari karena mirip dengan arsitektur bawaan Flutter. | Sedang, memerlukan pemahaman tentang konsep provider global di luar widget. | Tinggi, membutuhkan pemahaman tentang aliran data asinkron (streams) dan event. |
| **Kode Boilerplate** | Sangat sedikit. | Sedikit hingga sedang. | Cukup banyak karena harus mendefinisikan event, state, dan kelas BLoC. |
| **Ketergantungan Context** | Ya, membutuhkan `BuildContext` untuk membaca status. | Tidak, menggunakan objek `WidgetRef` untuk membaca status di luar context. | Ya, membutuhkan `BuildContext` untuk mencari provider BLoC yang sesuai. |
| **Skalabilitas** | Cocok untuk proyek kecil hingga menengah. | Sangat baik untuk proyek skala kecil hingga besar. | Sangat baik untuk proyek skala besar dengan tim yang banyak. |

---

## Panduan penggunaan Google Fonts

Proyek ini menggunakan pustaka `google_fonts` untuk mengatur tipografi global secara dinamis.

### Penggunaan standar (memerlukan koneksi internet)

Font akan diunduh secara otomatis dari server Google saat aplikasi pertama kali dijalankan dan disimpan di dalam penyimpanan lokal perangkat:
```dart
import 'package:google_fonts/google_fonts.dart';

final TextStyle gayaTeks = GoogleFonts.inter(
  fontSize: 16,
  fontWeight: FontWeight.normal,
);
```

### Alternatif penggunaan font file langsung (secara offline/luring)

Jika Anda ingin menghindari penggunaan paket `google_fonts` dan menggunakan berkas font lokal secara langsung (cara bawaan Flutter), ikuti langkah-langkah berikut:

#### Langkah 1: Siapkan berkas font

1. Unduh berkas font pilihan Anda (format `.ttf` or `.otf`) dari penyedia font (misalnya Google Fonts atau lainnya).
2. Buat direktori bernama `assets/fonts/` di dalam proyek Anda.
3. Simpan berkas font tersebut di dalam direktori tersebut (misalnya `Inter-Regular.ttf` dan `Inter-Bold.ttf`).

#### Langkah 2: Daftarkan font di `pubspec.yaml`

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

#### Langkah 3: Gunakan di kode Dart

Anda dapat menerapkan font tersebut langsung menggunakan parameter `fontFamily` pada `TextStyle`:
```dart
const TextStyle gayaTeks = TextStyle(
  fontFamily: 'Inter',
  fontSize: 16,
  fontWeight: FontWeight.bold, // Ini akan menggunakan berkas Inter-Bold.ttf secara otomatis
);
```

---

## Panduan pembuatan ikon peluncur dan splash screen

### Ikon peluncur (App Icon)

Proyek ini menggunakan paket `icons_launcher` untuk memperbarui ikon aplikasi secara otomatis. 
- **Persyaratan aset**: Gunakan gambar persegi berformat PNG dengan resolusi minimal 512x512 piksel. Pastikan tidak ada area transparan pada pinggiran gambar agar ikon tampil maksimal pada perangkat Android.
- **Cara membuat**:
  1. Siapkan ikon Anda dan simpan di `assets/icons/icon_launcher.png`.
  2. Jalankan perintah berikut di terminal:
     ```bash
     dart run icons_launcher:create
     ```

### Splash screen

Proyek ini menggunakan paket `flutter_native_splash` untuk memodifikasi splash screen bawaan perangkat.
- **Persyaratan aset**: Siapkan logo berformat PNG dengan resolusi minimal 1024x1024 piksel untuk diletakkan di bagian tengah layar.
- **Cara membuat**:
  1. Siapkan gambar splash screen Anda dan simpan di `assets/images/splash_screen.png`.
  2. Sesuaikan konfigurasi warna latar belakang dan letak gambar pada bagian `flutter_native_splash` di dalam berkas `pubspec.yaml`.
  3. Jalankan perintah berikut di terminal:
     ```bash
     flutter pub run flutter_native_splash:create
     ```

---

## Tautan dokumentasi resmi

Gunakan tautan di bawah ini untuk mempelajari dasar teori dari masing-masing pustaka pengelola status secara mendalam:
- [Dokumentasi Resmi Provider](https://pub.dev/packages/provider)
- [Dokumentasi Resmi Riverpod](https://riverpod.dev)
- [Dokumentasi Resmi BLoC](https://bloclibrary.dev)
