/// Single Source of Truth (SSOT) untuk seluruh kategori, topik, dan opsi pill di Curhat Finder
/// Digunakan secara terpadu oleh fitur Mahasiswa dan Konselor.
class AppCategories {
  AppCategories._();

  // ===========================================================================
  // 1. KATEGORI TIPS (Self-Care, Productivity, Afirmasi, dll.)
  // ===========================================================================
  
  /// Kategori tips resmi yang dapat dibuat oleh Mahasiswa maupun Konselor
  static const List<String> tipCategories = [
    'Self-care',
    'Productivity',
    'Afirmasi',
    'Musik',
    'Curhat',
    'Akademik',
    'Manajemen Waktu',
    'Relasi',
    'Mental Health',
  ];

  /// Kategori filter tips (termasuk 'Semua' sebagai opsi pertama)
  static List<String> get tipFilterCategories => const [
    'Semua',
    'Self-care',
    'Productivity',
    'Afirmasi',
    'Musik',
    'Curhat',
    'Akademik',
    'Manajemen Waktu',
    'Relasi',
    'Mental Health',
  ];

  // ===========================================================================
  // 2. KATEGORI ROOMS / FORUM CURHAT
  // ===========================================================================

  /// Kategori postingan curhat resmi pada Rooms kampus
  static const List<String> roomCategories = [
    'Akademik',
    'Kesepian',
    'Keuangan',
    'Relasi & Hubungan',
    'Mental Health',
    'Keluarga',
    'Lainnya',
  ];

  /// Kategori filter rooms / forum curhat (termasuk 'Semua' sebagai opsi pertama)
  static List<String> get roomFilterCategories => const [
    'Semua',
    'Akademik',
    'Kesepian',
    'Keuangan',
    'Relasi & Hubungan',
    'Mental Health',
    'Keluarga',
    'Lainnya',
  ];

  // ===========================================================================
  // 3. TOPIK SPESIALISASI KONSELOR SEBAYA
  // ===========================================================================

  /// 10 topik resmi keahlian konselor yang disinkronkan antara pendaftaran dan profil
  static const List<String> counselorSpecializationTopics = [
    'Overwhelmed',
    'Hilang arah',
    'Keuangan',
    'Burnout',
    'Relasi & Hubungan',
    'Keluarga',
    'Anxiety',
    'Akademik',
    'Manajemen Waktu',
    'Karier',
  ];

  // ===========================================================================
  // 4. HOBI & MINAT MAHASISWA
  // ===========================================================================

  /// 10 hobi & minat resmi mahasiswa untuk matching dan profil
  static const List<String> studentHobbies = [
    'Olahraga',
    'Musik',
    'Membaca',
    'Gaming',
    'Traveling',
    'Seni',
    'Fotografi',
    'Menulis',
    'Film',
    'Kuliner',
  ];
}
