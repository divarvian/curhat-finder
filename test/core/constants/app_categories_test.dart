import 'package:flutter_test/flutter_test.dart';
import 'package:curhat_finder/core/constants/app_categories.dart';
import 'package:curhat_finder/core/utils/academic_helper.dart';

void main() {
  group('AppCategories SSOT Tests', () {
    test('tipCategories contains all 9 canonical tip categories', () {
      expect(AppCategories.tipCategories.length, 9);
      expect(AppCategories.tipCategories, containsAll([
        'Self-care',
        'Productivity',
        'Afirmasi',
        'Musik',
        'Curhat',
        'Akademik',
        'Manajemen Waktu',
        'Relasi',
        'Mental Health',
      ]));
    });

    test('tipFilterCategories starts with Semua followed by tipCategories', () {
      expect(AppCategories.tipFilterCategories.first, 'Semua');
      expect(AppCategories.tipFilterCategories.sublist(1), AppCategories.tipCategories);
    });

    test('roomCategories contains all 7 canonical room categories', () {
      expect(AppCategories.roomCategories.length, 7);
      expect(AppCategories.roomCategories, containsAll([
        'Akademik',
        'Kesepian',
        'Keuangan',
        'Relasi & Hubungan',
        'Mental Health',
        'Keluarga',
        'Lainnya',
      ]));
    });

    test('roomFilterCategories starts with Semua followed by roomCategories', () {
      expect(AppCategories.roomFilterCategories.first, 'Semua');
      expect(AppCategories.roomFilterCategories.sublist(1), AppCategories.roomCategories);
    });

    test('counselorSpecializationTopics contains 10 canonical topics', () {
      expect(AppCategories.counselorSpecializationTopics.length, 10);
      expect(AppCategories.counselorSpecializationTopics, contains('Relasi & Hubungan'));
      expect(AppCategories.counselorSpecializationTopics, contains('Overwhelmed'));
    });

    test('studentHobbies contains 10 canonical hobbies', () {
      expect(AppCategories.studentHobbies.length, 10);
      expect(AppCategories.studentHobbies, contains('Olahraga'));
      expect(AppCategories.studentHobbies, contains('Musik'));
    });

    test('supportBuddyFilterOptions covers all 18 UB faculties + Online + Semua', () {
      final options = AcademicHelper.supportBuddyFilterOptions;
      expect(options.first, 'Online');
      expect(options[1], 'Semua');
      expect(options.length, 20); // 2 + 18 faculties
      expect(options, contains('FILKOM'));
      expect(options, contains('FK'));
      expect(options, contains('FT'));
      expect(options, contains('FV'));
      expect(options, contains('SP'));
    });
  });
}
