import 'package:flutter_test/flutter_test.dart';
import 'package:curhat_finder/core/utils/academic_helper.dart';

void main() {
  group('AcademicHelper Unit Tests', () {
    test('resolveFaculty correctly maps codes, abbreviations, and verbose names', () {
      // 18 faculties code mapping
      expect(AcademicHelper.resolveFaculty('01'), 'FH');
      expect(AcademicHelper.resolveFaculty('1'), 'FH');
      expect(AcademicHelper.resolveFaculty('02'), 'FEB');
      expect(AcademicHelper.resolveFaculty('06'), 'FT');
      expect(AcademicHelper.resolveFaculty('07'), 'FK');
      expect(AcademicHelper.resolveFaculty('14'), 'FILKOM');
      expect(AcademicHelper.resolveFaculty('15'), 'FKG');
      expect(AcademicHelper.resolveFaculty('18'), 'SP');

      // Direct abbreviations
      expect(AcademicHelper.resolveFaculty('FILKOM'), 'FILKOM');
      expect(AcademicHelper.resolveFaculty('filkom'), 'FILKOM');
      expect(AcademicHelper.resolveFaculty('FK'), 'FK');

      // Verbose & historical strings
      expect(AcademicHelper.resolveFaculty('Fakultas Ilmu Komputer (FILKOM)'), 'FILKOM');
      expect(AcademicHelper.resolveFaculty('Fakultas Kedokteran'), 'FK');
      expect(AcademicHelper.resolveFaculty('Fakultas Hukum (FH)'), 'FH');
      expect(AcademicHelper.resolveFaculty('Ilmu Budaya'), 'FIB');

      // Null and empty fallbacks
      expect(AcademicHelper.resolveFaculty(null), 'FILKOM');
      expect(AcademicHelper.resolveFaculty(''), 'FILKOM');
    });

    test('resolveProdi correctly maps IDs across multiple faculties', () {
      expect(AcademicHelper.resolveProdi('01.01'), 'S1 Ilmu Hukum');
      expect(AcademicHelper.resolveProdi('02.01'), 'S1 Ekonomi Pembangunan');
      expect(AcademicHelper.resolveProdi('07.01'), 'S1 Kedokteran');
      expect(AcademicHelper.resolveProdi('14.01'), 'S1 Teknik Informatika');
      expect(AcademicHelper.resolveProdi('14.02'), 'S1 Teknik Komputer');
      expect(AcademicHelper.resolveProdi('14.03'), 'S1 Sistem Informasi');
      expect(AcademicHelper.resolveProdi('18.01'), 'S2 Kajian Wanita');
      expect(AcademicHelper.resolveProdi(null), 'S1 Teknik Informatika');
      expect(AcademicHelper.resolveProdi(''), 'S1 Teknik Informatika');
    });

    test('resolveProdi performs intelligent degree-agnostic matching', () {
      // Omitted degree prefix from legacy seeds
      expect(AcademicHelper.resolveProdi('Teknik Informatika'), 'S1 Teknik Informatika');
      expect(AcademicHelper.resolveProdi('teknik informatika'), 'S1 Teknik Informatika');
      expect(AcademicHelper.resolveProdi('Sistem Informasi'), 'S1 Sistem Informasi');
      expect(AcademicHelper.resolveProdi('Sastra Inggris'), 'S1 Sastra Inggris');
      expect(AcademicHelper.resolveProdi('Ilmu Hukum'), 'S1 Ilmu Hukum');
    });

    test('getProdisByFaculty and resolveFacultyId filter correctly', () {
      expect(AcademicHelper.resolveFacultyId('FILKOM'), '14');
      expect(AcademicHelper.resolveFacultyId('FK'), '07');
      expect(AcademicHelper.resolveFacultyId('FH'), '01');

      final filkomProdis = AcademicHelper.getProdisByFaculty('14');
      expect(filkomProdis, isNotEmpty);
      expect(filkomProdis.any((p) => p['nama'] == 'S1 Teknik Informatika'), isTrue);

      final byShortName = AcademicHelper.getProdisByFaculty('FILKOM');
      expect(byShortName.length, filkomProdis.length);

      final fhProdis = AcademicHelper.getProdisByFaculty('01');
      expect(fhProdis.any((p) => p['nama'] == 'S1 Ilmu Hukum'), isTrue);
    });

    test('facultyShortNames returns non-empty list of UB faculties', () {
      final faculties = AcademicHelper.facultyShortNames;
      expect(faculties.length, 18);
      expect(faculties, contains('FILKOM'));
      expect(faculties, contains('FT'));
      expect(faculties, contains('FK'));
      expect(faculties, contains('FEB'));
      expect(faculties, contains('SP'));
    });

    test('AcademicHelper.prodis returns all 155 prodis via static fallback', () {
      final allProdis = AcademicHelper.prodis;
      expect(allProdis.length, 155);
    });

    test('matchesFacultyFilter handles exact matches and avoids false positives', () {
      expect(AcademicHelper.matchesFacultyFilter('Fakultas Teknik', 'FT'), isTrue);
      expect(AcademicHelper.matchesFacultyFilter('FT', 'FT'), isTrue);
      expect(AcademicHelper.matchesFacultyFilter('FTAB', 'FT'), isFalse);
      expect(AcademicHelper.matchesFacultyFilter('Fakultas Kedokteran', 'FK'), isTrue);
      expect(AcademicHelper.matchesFacultyFilter('FKG', 'FK'), isFalse);
      expect(AcademicHelper.matchesFacultyFilter('FKH', 'FK'), isFalse);
      expect(AcademicHelper.matchesFacultyFilter('FILKOM', 'Semua'), isTrue);
    });
  });
}
