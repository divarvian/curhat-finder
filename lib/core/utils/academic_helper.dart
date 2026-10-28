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

  static List<Map<String, dynamic>> get faculties => _faculties.isNotEmpty ? _faculties : _staticFaculties.map((e) => Map<String, dynamic>.from(e)).toList();
  static List<Map<String, dynamic>> get prodis => _prodis;

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
      debugPrint("AcademicHelper init warning: $e");
    }
  }

  /// Mengubah kode id (misal "14" atau "15") menjadi nama singkatan fakultas (misal "FILKOM", "FKG")
  static String resolveFaculty(String? codeOrName) {
    if (codeOrName == null || codeOrName.trim().isEmpty) return 'FILKOM';
    final trimmed = codeOrName.trim();

    final facList = _faculties.isNotEmpty ? _faculties : _staticFaculties.map((e) => Map<String, dynamic>.from(e)).toList();

    // 1. Cek kecocokan berdasarkan ID (misal "14", "01", "1")
    for (final f in facList) {
      final id = f['id']?.toString() ?? '';
      if (id == trimmed || id == trimmed.padLeft(2, '0')) {
        return f['singkatan']?.toString() ?? trimmed;
      }
    }

    // 2. Cek apakah sudah berupa singkatan (misal "FILKOM", "FKG", "FEB")
    for (final f in facList) {
      final singkatan = f['singkatan']?.toString() ?? '';
      if (singkatan.toLowerCase() == trimmed.toLowerCase()) {
        return singkatan;
      }
    }

    // 3. Cek apakah berupa nama lengkap fakultas
    for (final f in facList) {
      final nama = f['nama']?.toString() ?? '';
      if (nama.toLowerCase() == trimmed.toLowerCase()) {
        return f['singkatan']?.toString() ?? trimmed;
      }
    }

    return trimmed;
  }

  /// Mengubah kode id prodi (misal "14.01", "15.01") menjadi nama prodi (misal "S1 Teknik Informatika", "S1 Kedokteran Gigi")
  static String resolveProdi(String? codeOrName) {
    if (codeOrName == null || codeOrName.trim().isEmpty) return 'S1 Teknik Informatika';
    final trimmed = codeOrName.trim();

    if (_prodis.isNotEmpty) {
      // 1. Cek kecocokan berdasarkan ID (misal "14.01")
      for (final p in _prodis) {
        final id = p['id']?.toString() ?? '';
        if (id == trimmed) {
          return p['nama']?.toString() ?? trimmed;
        }
      }

      // 2. Cek apakah sudah berupa nama prodi
      for (final p in _prodis) {
        final nama = p['nama']?.toString() ?? '';
        if (nama.toLowerCase() == trimmed.toLowerCase()) {
          return nama;
        }
      }
    }

    // Fallback jika belum selesai inisialisasi dan pola menyerupai format ID (misal "14.01")
    if (trimmed == '14.01') return 'S1 Teknik Informatika';
    if (trimmed == '14.02') return 'S1 Sistem Informasi';
    if (trimmed == '14.03') return 'S1 Pendidikan Teknologi Informasi';
    if (trimmed == '14.04') return 'S1 Teknik Komputer';
    if (trimmed == '14.05') return 'S1 Teknologi Informasi';

    return trimmed;
  }
}
