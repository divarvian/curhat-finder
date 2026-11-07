import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../constants/app_assets.dart';

class AcademicHelper {
  static List<Map<String, dynamic>> _faculties = [];
  static List<Map<String, dynamic>> _prodis = [];
  static bool _isInitialized = false;

  static const List<Map<String, String>> _staticFaculties = [
    {"id": "01", "singkatan": "FH", "nama": "Hukum"},
    {"id": "02", "singkatan": "FEB", "nama": "Ekonomi dan Bisnis"},
    {"id": "03", "singkatan": "FIA", "nama": "Ilmu Administrasi"},
    {"id": "04", "singkatan": "FBiPK", "nama": "Bio-Industri Pertanian dan Kehutanan"},
    {"id": "05", "singkatan": "FAST", "nama": "Sains dan Teknologi Peternakan"},
    {"id": "06", "singkatan": "FT", "nama": "Teknik"},
    {"id": "07", "singkatan": "FK", "nama": "Kedokteran"},
    {"id": "08", "singkatan": "FPIK", "nama": "Perikanan dan Ilmu Kelautan"},
    {"id": "09", "singkatan": "FSTeM", "nama": "Sains, Teknologi, dan Matematika"},
    {"id": "10", "singkatan": "FTAB", "nama": "Teknologi Agroindustri dan Biosistem"},
    {"id": "11", "singkatan": "FIB", "nama": "Ilmu Budaya"},
    {"id": "12", "singkatan": "FISIP", "nama": "Ilmu Sosial dan Ilmu Politik"},
    {"id": "13", "singkatan": "FKH", "nama": "Kedokteran Hewan"},
    {"id": "14", "singkatan": "FILKOM", "nama": "Ilmu Komputer"},
    {"id": "15", "singkatan": "FKG", "nama": "Kedokteran Gigi"},
    {"id": "16", "singkatan": "FV", "nama": "Vokasi"},
    {"id": "17", "singkatan": "FIKES", "nama": "Ilmu Kesehatan"},
    {"id": "18", "singkatan": "SP", "nama": "Sekolah Pascasarjana"},
  ];

  static const List<Map<String, String>> _staticProdis = [
    {"id": "01.01", "fakultas_id": "01", "nama": "S1 Ilmu Hukum"},
    {"id": "01.02", "fakultas_id": "01", "nama": "S2 Ilmu Hukum"},
    {"id": "01.03", "fakultas_id": "01", "nama": "S2 Kenotariatan"},
    {"id": "01.04", "fakultas_id": "01", "nama": "S3 Ilmu Hukum"},
    {"id": "02.01", "fakultas_id": "02", "nama": "S1 Ekonomi Pembangunan"},
    {"id": "02.02", "fakultas_id": "02", "nama": "S1 Ekonomi, Keuangan, dan Perbankan"},
    {"id": "02.03", "fakultas_id": "02", "nama": "S1 Ekonomi Islam"},
    {"id": "02.04", "fakultas_id": "02", "nama": "S1 Manajemen"},
    {"id": "02.05", "fakultas_id": "02", "nama": "S1 Kewirausahaan"},
    {"id": "02.06", "fakultas_id": "02", "nama": "S1 Akuntansi"},
    {"id": "02.07", "fakultas_id": "02", "nama": "S2 Ilmu Ekonomi"},
    {"id": "02.08", "fakultas_id": "02", "nama": "S2 Ekonomi Bisnis dan Islam"},
    {"id": "02.09", "fakultas_id": "02", "nama": "S2 Manajemen"},
    {"id": "02.10", "fakultas_id": "02", "nama": "S2 Akuntansi"},
    {"id": "02.11", "fakultas_id": "02", "nama": "S3 Ilmu Ekonomi"},
    {"id": "02.12", "fakultas_id": "02", "nama": "S3 Ilmu Manajemen"},
    {"id": "02.13", "fakultas_id": "02", "nama": "S3 Ilmu Akuntansi"},
    {"id": "02.14", "fakultas_id": "02", "nama": "Pendidikan Profesi Akuntansi"},
    {"id": "03.01", "fakultas_id": "03", "nama": "S1 Ilmu Administrasi Bisnis"},
    {"id": "03.02", "fakultas_id": "03", "nama": "S1 Perpajakan"},
    {"id": "03.03", "fakultas_id": "03", "nama": "S1 Pariwisata"},
    {"id": "03.04", "fakultas_id": "03", "nama": "S1 Ilmu Administrasi Publik"},
    {"id": "03.05", "fakultas_id": "03", "nama": "S1 Ilmu Perpustakaan"},
    {"id": "03.06", "fakultas_id": "03", "nama": "S1 Administrasi Pendidikan"},
    {"id": "03.07", "fakultas_id": "03", "nama": "S2 Administrasi Bisnis"},
    {"id": "03.08", "fakultas_id": "03", "nama": "S2 Ilmu Administrasi Publik"},
    {"id": "03.09", "fakultas_id": "03", "nama": "S2 Manajemen Pendidikan Tinggi"},
    {"id": "03.10", "fakultas_id": "03", "nama": "S3 Ilmu Administrasi"},
    {"id": "04.01", "fakultas_id": "04", "nama": "S1 Agroekoteknologi"},
    {"id": "04.02", "fakultas_id": "04", "nama": "S1 Agribisnis"},
    {"id": "04.03", "fakultas_id": "04", "nama": "S1 Kehutanan"},
    {"id": "04.04", "fakultas_id": "04", "nama": "S2 Agronomi"},
    {"id": "04.05", "fakultas_id": "04", "nama": "S2 Pengelolaan Tanah dan Air"},
    {"id": "04.06", "fakultas_id": "04", "nama": "S2 Ekonomi Pertanian"},
    {"id": "04.07", "fakultas_id": "04", "nama": "S2 Sosiologi"},
    {"id": "04.08", "fakultas_id": "04", "nama": "S2 Agribisnis"},
    {"id": "04.09", "fakultas_id": "04", "nama": "S2 Patologi Tumbuhan"},
    {"id": "04.10", "fakultas_id": "04", "nama": "S2 Entomologi Pertanian"},
    {"id": "04.11", "fakultas_id": "04", "nama": "S3 Ilmu Pertanian"},
    {"id": "05.01", "fakultas_id": "05", "nama": "S1 Peternakan"},
    {"id": "05.02", "fakultas_id": "05", "nama": "S1 Industri Peternakan Cerdas"},
    {"id": "05.03", "fakultas_id": "05", "nama": "S2 Ilmu Peternakan"},
    {"id": "05.04", "fakultas_id": "05", "nama": "S3 Ilmu Peternakan"},
    {"id": "06.01", "fakultas_id": "06", "nama": "S1 Teknik Sipil"},
    {"id": "06.02", "fakultas_id": "06", "nama": "S1 Teknik Mesin"},
    {"id": "06.03", "fakultas_id": "06", "nama": "S1 Teknik Pengairan"},
    {"id": "06.04", "fakultas_id": "06", "nama": "S1 Teknik Elektro"},
    {"id": "06.05", "fakultas_id": "06", "nama": "S1 Teknik Industri"},
    {"id": "06.06", "fakultas_id": "06", "nama": "S1 Teknik Kimia"},
    {"id": "06.07", "fakultas_id": "06", "nama": "S1 Perencanaan Wilayah dan Kota"},
    {"id": "06.08", "fakultas_id": "06", "nama": "S1 Arsitektur"},
    {"id": "06.09", "fakultas_id": "06", "nama": "S2 Teknik Sipil"},
    {"id": "06.10", "fakultas_id": "06", "nama": "S2 Teknik Mesin"},
    {"id": "06.11", "fakultas_id": "06", "nama": "S2 Teknik Elektro"},
    {"id": "06.12", "fakultas_id": "06", "nama": "S2 Arsitektur Lingkungan Binaan"},
    {"id": "06.13", "fakultas_id": "06", "nama": "S2 Perencanaan Wilayah dan Kota"},
    {"id": "06.14", "fakultas_id": "06", "nama": "S2 Teknik Industri"},
    {"id": "06.15", "fakultas_id": "06", "nama": "S2 Teknik Pengairan"},
    {"id": "06.16", "fakultas_id": "06", "nama": "S3 Ilmu Teknik Sipil"},
    {"id": "06.17", "fakultas_id": "06", "nama": "S3 Ilmu Teknik Mesin"},
    {"id": "06.18", "fakultas_id": "06", "nama": "S3 Teknik Elektro"},
    {"id": "06.19", "fakultas_id": "06", "nama": "S3 Teknik Sumber Daya Air"},
    {"id": "06.20", "fakultas_id": "06", "nama": "S3 Perencanaan Wilayah dan Kota"},
    {"id": "06.21", "fakultas_id": "06", "nama": "Profesi Insinyur"},
    {"id": "06.22", "fakultas_id": "06", "nama": "Profesi Arsitek"},
    {"id": "07.01", "fakultas_id": "07", "nama": "S1 Kedokteran"},
    {"id": "07.02", "fakultas_id": "07", "nama": "S1 Farmasi"},
    {"id": "07.03", "fakultas_id": "07", "nama": "S1 Kebidanan"},
    {"id": "07.04", "fakultas_id": "07", "nama": "S2 Kebidanan"},
    {"id": "07.05", "fakultas_id": "07", "nama": "S2 Manajemen Rumah Sakit"},
    {"id": "07.06", "fakultas_id": "07", "nama": "S2 Biomedik"},
    {"id": "07.07", "fakultas_id": "07", "nama": "S3 Ilmu Kedokteran"},
    {"id": "08.01", "fakultas_id": "08", "nama": "S1 Agrobisnis Perikanan"},
    {"id": "08.02", "fakultas_id": "08", "nama": "S1 Budidaya Perairan"},
    {"id": "08.03", "fakultas_id": "08", "nama": "S1 Ilmu Kelautan"},
    {"id": "08.04", "fakultas_id": "08", "nama": "S1 Manajemen Sumberdaya Perairan"},
    {"id": "08.05", "fakultas_id": "08", "nama": "S1 Pemanfaatan Sumberdaya Perikanan"},
    {"id": "08.06", "fakultas_id": "08", "nama": "S1 Teknologi Hasil Perikanan"},
    {"id": "08.07", "fakultas_id": "08", "nama": "S2 Budidaya Perairan"},
    {"id": "08.08", "fakultas_id": "08", "nama": "S3 Ilmu Perikanan dan Kelautan"},
    {"id": "09.01", "fakultas_id": "09", "nama": "S1 Biologi"},
    {"id": "09.02", "fakultas_id": "09", "nama": "S1 Fisika"},
    {"id": "09.03", "fakultas_id": "09", "nama": "S1 Kimia"},
    {"id": "09.04", "fakultas_id": "09", "nama": "S1 Matematika"},
    {"id": "09.05", "fakultas_id": "09", "nama": "S1 Statistika"},
    {"id": "09.06", "fakultas_id": "09", "nama": "S1 Teknik Geofisika"},
    {"id": "09.07", "fakultas_id": "09", "nama": "S1 Instrumentasi"},
    {"id": "09.08", "fakultas_id": "09", "nama": "S1 Ilmu Aktuaria"},
    {"id": "09.09", "fakultas_id": "09", "nama": "S2 Biologi"},
    {"id": "09.10", "fakultas_id": "09", "nama": "S2 Kimia"},
    {"id": "09.11", "fakultas_id": "09", "nama": "S2 Fisika"},
    {"id": "09.12", "fakultas_id": "09", "nama": "S2 Matematika"},
    {"id": "09.13", "fakultas_id": "09", "nama": "S2 Statistika"},
    {"id": "09.14", "fakultas_id": "09", "nama": "S3 Biologi"},
    {"id": "09.15", "fakultas_id": "09", "nama": "S3 Kimia"},
    {"id": "09.16", "fakultas_id": "09", "nama": "S3 Fisika"},
    {"id": "09.17", "fakultas_id": "09", "nama": "S3 Matematika"},
    {"id": "10.01", "fakultas_id": "10", "nama": "S1 Ilmu dan Teknologi Pangan"},
    {"id": "10.02", "fakultas_id": "10", "nama": "S1 Teknologi Industri Pertanian"},
    {"id": "10.03", "fakultas_id": "10", "nama": "S1 Teknik Lingkungan"},
    {"id": "10.04", "fakultas_id": "10", "nama": "S1 Bioteknologi"},
    {"id": "10.05", "fakultas_id": "10", "nama": "S1 Teknologi Bioproses"},
    {"id": "10.06", "fakultas_id": "10", "nama": "S1 Teknik Pertanian"},
    {"id": "10.07", "fakultas_id": "10", "nama": "S2 Teknologi Hasil Pertanian"},
    {"id": "10.08", "fakultas_id": "10", "nama": "S2 Teknologi Industri Pertanian"},
    {"id": "10.09", "fakultas_id": "10", "nama": "S2 Teknik Pertanian dan Biosistem"},
    {"id": "10.10", "fakultas_id": "10", "nama": "S3 Teknologi Industri Pertanian"},
    {"id": "10.11", "fakultas_id": "10", "nama": "S3 Teknik Biosistem"},
    {"id": "10.12", "fakultas_id": "10", "nama": "S3 Ilmu Pangan"},
    {"id": "11.01", "fakultas_id": "11", "nama": "S1 Sastra Inggris"},
    {"id": "11.02", "fakultas_id": "11", "nama": "S1 Sastra Jepang"},
    {"id": "11.03", "fakultas_id": "11", "nama": "S1 Sastra Cina"},
    {"id": "11.04", "fakultas_id": "11", "nama": "S1 Bahasa dan Sastra Perancis"},
    {"id": "11.05", "fakultas_id": "11", "nama": "S1 Pendidikan Bahasa dan Sastra Indonesia"},
    {"id": "11.06", "fakultas_id": "11", "nama": "S1 Pendidikan Bahasa Inggris"},
    {"id": "11.07", "fakultas_id": "11", "nama": "S1 Pendidikan Bahasa Jepang"},
    {"id": "11.08", "fakultas_id": "11", "nama": "S1 Antropologi (Sosial)"},
    {"id": "11.09", "fakultas_id": "11", "nama": "S1 Seni Rupa Murni"},
    {"id": "11.10", "fakultas_id": "11", "nama": "S2 Ilmu Linguistik"},
    {"id": "12.01", "fakultas_id": "12", "nama": "S1 Hubungan Internasional"},
    {"id": "12.02", "fakultas_id": "12", "nama": "S1 Ilmu Komunikasi"},
    {"id": "12.03", "fakultas_id": "12", "nama": "S1 Ilmu Politik"},
    {"id": "12.04", "fakultas_id": "12", "nama": "S1 Psikologi"},
    {"id": "12.05", "fakultas_id": "12", "nama": "S1 Sosiologi"},
    {"id": "12.06", "fakultas_id": "12", "nama": "S1 Ilmu Pemerintahan"},
    {"id": "12.07", "fakultas_id": "12", "nama": "S2 Ilmu Sosial"},
    {"id": "12.08", "fakultas_id": "12", "nama": "S2 Ilmu Komunikasi"},
    {"id": "12.09", "fakultas_id": "12", "nama": "S2 Sains Psikologi"},
    {"id": "12.10", "fakultas_id": "12", "nama": "S3 Ilmu Sosiologi"},
    {"id": "13.01", "fakultas_id": "13", "nama": "S1 Pendidikan Dokter Hewan"},
    {"id": "14.01", "fakultas_id": "14", "nama": "S1 Teknik Informatika"},
    {"id": "14.02", "fakultas_id": "14", "nama": "S1 Teknik Komputer"},
    {"id": "14.03", "fakultas_id": "14", "nama": "S1 Sistem Informasi"},
    {"id": "14.04", "fakultas_id": "14", "nama": "S1 Teknologi Informasi"},
    {"id": "14.05", "fakultas_id": "14", "nama": "S1 Pendidikan Teknologi Informasi"},
    {"id": "14.06", "fakultas_id": "14", "nama": "S2 Ilmu Komputer"},
    {"id": "14.07", "fakultas_id": "14", "nama": "S2 Sistem Informasi"},
    {"id": "14.08", "fakultas_id": "14", "nama": "S3 Ilmu Komputer"},
    {"id": "15.01", "fakultas_id": "15", "nama": "S1 Kedokteran Gigi"},
    {"id": "16.01", "fakultas_id": "16", "nama": "D4 Manajemen Perhotelan"},
    {"id": "16.02", "fakultas_id": "16", "nama": "D3 Keuangan dan Perbankan"},
    {"id": "16.03", "fakultas_id": "16", "nama": "D3 Administrasi Bisnis"},
    {"id": "16.04", "fakultas_id": "16", "nama": "D4 Desain Grafis"},
    {"id": "16.05", "fakultas_id": "16", "nama": "D3 Teknologi Informasi"},
    {"id": "17.01", "fakultas_id": "17", "nama": "S1 Keperawatan"},
    {"id": "17.02", "fakultas_id": "17", "nama": "S1 Ilmu Gizi"},
    {"id": "17.03", "fakultas_id": "17", "nama": "S2 Keperawatan"},
    {"id": "17.04", "fakultas_id": "17", "nama": "S2 Gizi"},
    {"id": "18.01", "fakultas_id": "18", "nama": "S2 Kajian Wanita"},
    {"id": "18.02", "fakultas_id": "18", "nama": "S2 Pengelolaan Sumberdaya Lingkungan dan Pembangunan"},
    {"id": "18.03", "fakultas_id": "18", "nama": "S2 Wawasan Pertahanan Nasional"},
    {"id": "18.04", "fakultas_id": "18", "nama": "S2 Kepemimpinan dan Inovasi Kebijakan"},
    {"id": "18.05", "fakultas_id": "18", "nama": "S3 Ilmu Lingkungan"},
    {"id": "18.06", "fakultas_id": "18", "nama": "S3 Ilmu Ketahanan Nasional"},
    {"id": "18.07", "fakultas_id": "18", "nama": "S3 Kepemimpinan dan Inovasi Kebijakan"},
  ];

  /// Daftar seluruh fakultas resmi UB (dari asset atau fallback statis)
  static List<Map<String, dynamic>> get faculties =>
      _faculties.isNotEmpty ? _faculties : _staticFaculties.map((e) => Map<String, dynamic>.from(e)).toList();

  /// Daftar seluruh program studi resmi UB (dari asset atau fallback statis)
  static List<Map<String, dynamic>> get prodis =>
      _prodis.isNotEmpty ? _prodis : _staticProdis.map((e) => Map<String, dynamic>.from(e)).toList();

  /// Daftar seluruh singkatan fakultas resmi UB
  static List<String> get facultyShortNames =>
      _staticFaculties.map((f) => f['singkatan']!).toList();

  /// Opsi filter subkategori pada Support Buddy (Konselor Sebaya)
  static List<String> get supportBuddyFilterOptions =>
      ['Online', 'Semua', ...facultyShortNames];

  /// Mengambil daftar prodi untuk fakultas tertentu (berdasarkan ID '01'-'18' atau singkatan 'FILKOM')
  static List<Map<String, dynamic>> getProdisByFaculty(String facultyIdOrSingkatan) {
    final facId = resolveFacultyId(facultyIdOrSingkatan);
    final prodiList = prodis;
    return prodiList.where((p) => p['fakultas_id']?.toString() == facId).toList();
  }

  /// Mengubah singkatan fakultas (misal 'FILKOM') menjadi kode ID numerik (misal '14')
  static String resolveFacultyId(String? codeOrName) {
    if (codeOrName == null || codeOrName.trim().isEmpty) return '14';
    final trimmed = codeOrName.trim();

    final facList = faculties;
    for (final f in facList) {
      final id = f['id']?.toString() ?? '';
      final singkatan = f['singkatan']?.toString() ?? '';
      if (id == trimmed || id == trimmed.padLeft(2, '0') || singkatan.toLowerCase() == trimmed.toLowerCase()) {
        return id;
      }
    }
    return trimmed;
  }

  /// Pencocokan string nama fakultas yang akurat, menghindari false-positive (misal FT vs FTAB, FK vs FKG)
  static bool matchesFacultyFilter(String facultyStr, String filterShortName) {
    if (filterShortName.isEmpty || filterShortName.toLowerCase() == 'semua') {
      return true;
    }

    final upper = facultyStr.toUpperCase();
    final filterUpper = filterShortName.toUpperCase();
    final tokens = upper.split(RegExp(r'[\s\(\)\,\.\-\/]+'));

    if (filterUpper == 'FT') {
      return (tokens.contains('FT') && !tokens.contains('FTAB')) ||
          (upper.contains('FAKULTAS TEKNIK') && !upper.contains('AGROINDUSTRI') && !upper.contains('BIOSISTEM'));
    }

    if (filterUpper == 'FK') {
      return (tokens.contains('FK') && !tokens.contains('FKG') && !tokens.contains('FKH')) ||
          (upper.contains('KEDOKTERAN') && !upper.contains('GIGI') && !upper.contains('HEWAN'));
    }

    if (filterUpper == 'FILKOM') {
      return upper.contains('FILKOM') || upper.contains('ILMU KOMPUTER');
    }

    if (filterUpper == 'FIB') {
      return upper.contains('FIB') || upper.contains('ILMU BUDAYA');
    }

    if (filterUpper == 'FEB') {
      return upper.contains('FEB') || upper.contains('EKONOMI');
    }

    if (filterUpper == 'FISIP') {
      return upper.contains('FISIP') || upper.contains('ILMU SOSIAL');
    }

    if (filterUpper == 'FBIPK' || filterUpper == 'BIPK') {
      return upper.contains('FBIPK') || upper.contains('BIPK') || upper.contains('BIO-INDUSTRI');
    }

    if (tokens.contains(filterUpper)) return true;
    final resolved = resolveFaculty(facultyStr).toUpperCase();
    return resolved == filterUpper || upper.contains(filterUpper);
  }

  /// Inisialisasi data fakultas dan prodi dari asset JSON
  static Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      final facStr = await rootBundle.loadString(AppAssets.fakultasJson);
      final prodiStr = await rootBundle.loadString(AppAssets.prodiJson);

      final List<dynamic> facDecoded = json.decode(facStr);
      final List<dynamic> prodiDecoded = json.decode(prodiStr);

      _faculties = facDecoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      _prodis = prodiDecoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      _isInitialized = true;
    } catch (e) {
      debugPrint('AcademicHelper init warning: ');
    }
  }

  /// Mengubah kode id numerik (misal '14' atau '01'), format panjang ('Fakultas Ilmu Komputer (FILKOM)'),
  /// atau nama umum menjadi singkatan resmi fakultas UB (misal 'FILKOM', 'FK', 'FEB')
  static String resolveFaculty(String? codeOrName) {
    if (codeOrName == null || codeOrName.trim().isEmpty) return 'FILKOM';
    final trimmed = codeOrName.trim();
    final upper = trimmed.toUpperCase();

    final facList = faculties;

    // 1. Cek kecocokan berdasarkan ID (misal '14', '01', '1')
    for (final f in facList) {
      final id = f['id']?.toString() ?? '';
      if (id == trimmed || id == trimmed.padLeft(2, '0')) {
        return f['singkatan']?.toString() ?? trimmed;
      }
    }

    // 2. Cek apakah sudah berupa singkatan persis (misal 'FILKOM', 'FKG', 'FEB')
    for (final f in facList) {
      final singkatan = f['singkatan']?.toString() ?? '';
      if (singkatan.toLowerCase() == trimmed.toLowerCase()) {
        return singkatan;
      }
    }

    // 3. Cek apakah berupa nama lengkap fakultas persis
    for (final f in facList) {
      final nama = f['nama']?.toString() ?? '';
      if (nama.toLowerCase() == trimmed.toLowerCase()) {
        return f['singkatan']?.toString() ?? trimmed;
      }
    }

    // 4. Deteksi cerdas untuk variasi string historis / verbose (misal 'Fakultas Ilmu Komputer (FILKOM)')
    if (upper.contains('(FILKOM)') || upper.contains('FILKOM') || upper.contains('ILMU KOMPUTER')) return 'FILKOM';
    if (upper.contains('(FKG)') || upper.contains('KEDOKTERAN GIGI')) return 'FKG';
    if (upper.contains('(FKH)') || upper.contains('KEDOKTERAN HEWAN')) return 'FKH';
    if (upper.contains('(FK)') || (upper.contains('KEDOKTERAN') && !upper.contains('GIGI') && !upper.contains('HEWAN'))) return 'FK';
    if (upper.contains('(FTAB)') || upper.contains('AGROINDUSTRI') || upper.contains('BIOSISTEM')) return 'FTAB';
    if (upper.contains('(FT)') || (upper.contains('TEKNIK') && !upper.contains('AGROINDUSTRI') && !upper.contains('ILMU KOMPUTER') && !upper.contains('PETERNAKAN'))) return 'FT';
    if (upper.contains('(FH)') || upper.contains('HUKUM')) return 'FH';
    if (upper.contains('(FEB)') || upper.contains('EKONOMI')) return 'FEB';
    if (upper.contains('(FIA)') || upper.contains('ADMINISTRASI')) return 'FIA';
    if (upper.contains('(FBIPK)') || upper.contains('BIO-INDUSTRI') || upper.contains('KEHUTANAN')) return 'FBiPK';
    if (upper.contains('(FAST)') || upper.contains('PETERNAKAN')) return 'FAST';
    if (upper.contains('(FPIK)') || upper.contains('PERIKANAN') || upper.contains('KELAUTAN')) return 'FPIK';
    if (upper.contains('(FSTEM)') || upper.contains('MATEMATIKA')) return 'FSTeM';
    if (upper.contains('(FIB)') || upper.contains('ILMU BUDAYA') || upper.contains('SASTRA')) return 'FIB';
    if (upper.contains('(FISIP)') || upper.contains('ILMU SOSIAL') || upper.contains('POLITIK')) return 'FISIP';
    if (upper.contains('(FV)') || upper.contains('VOKASI')) return 'FV';
    if (upper.contains('(FIKES)') || upper.contains('KESEHATAN')) return 'FIKES';
    if (upper.contains('(SP)') || upper.contains('PASCASARJANA')) return 'SP';

    return trimmed;
  }

  /// Mengubah kode id prodi ('14.01'), nama tanpa jenjang ('Teknik Informatika'),
  /// atau format lainnya menjadi nama kanonikal prodi resmi UB ('S1 Teknik Informatika')
  static String resolveProdi(String? codeOrName) {
    if (codeOrName == null || codeOrName.trim().isEmpty) return 'S1 Teknik Informatika';
    final trimmed = codeOrName.trim();
    final lower = trimmed.toLowerCase();

    final prodiList = prodis;

    // 1. Cek kecocokan berdasarkan ID (misal '14.01', '07.01')
    for (final p in prodiList) {
      final id = p['id']?.toString() ?? '';
      if (id == trimmed) {
        return p['nama']?.toString() ?? trimmed;
      }
    }

    // 2. Cek apakah sudah berupa nama lengkap prodi persis (case-insensitive)
    for (final p in prodiList) {
      final nama = p['nama']?.toString() ?? '';
      if (nama.toLowerCase() == lower) {
        return nama;
      }
    }

    // 3. Degree-agnostic matching: Memetakan nama tanpa gelar (misal 'Teknik Informatika' -> 'S1 Teknik Informatika')
    for (final p in prodiList) {
      final nama = p['nama']?.toString() ?? '';
      final pureName = nama.replaceFirst(RegExp(r'^(S1|S2|S3|D3|D4|Profesi)\s+', caseSensitive: false), '').trim();
      if (pureName.toLowerCase() == lower) {
        return nama;
      }
    }

    // 4. Substring / partial matching jika input mengandung nama prodi
    for (final p in prodiList) {
      final nama = p['nama']?.toString() ?? '';
      if (lower.contains(nama.toLowerCase())) {
        return nama;
      }
    }

    return trimmed;
  }
}
