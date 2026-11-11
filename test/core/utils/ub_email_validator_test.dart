import 'package:flutter_test/flutter_test.dart';
import 'package:curhat_finder/core/utils/ub_email_validator.dart';

void main() {
  group('UbEmailValidator Tests', () {
    group('isUbEmail', () {
      test('accepts valid official UB domains', () {
        expect(UbEmailValidator.isUbEmail('student@student.ub.ac.id'), isTrue);
        expect(UbEmailValidator.isUbEmail('215150201111001@student.ub.ac.id'), isTrue);
        expect(UbEmailValidator.isUbEmail('counselor@demo.ub.ac.id'), isTrue);
        expect(UbEmailValidator.isUbEmail('sarah@demo.ub.ac.id'), isTrue);
        expect(UbEmailValidator.isUbEmail('rektor@ub.ac.id'), isTrue);
        expect(UbEmailValidator.isUbEmail('dosen@filkom.ub.ac.id'), isTrue);
        expect(UbEmailValidator.isUbEmail('admin@fk.ub.ac.id'), isTrue);
        expect(UbEmailValidator.isUbEmail('  USER@STUDENT.UB.AC.ID  '), isTrue);
      });

      test('rejects non-UB domains like gmail, yahoo, outlook', () {
        expect(UbEmailValidator.isUbEmail('user@gmail.com'), isFalse);
        expect(UbEmailValidator.isUbEmail('user@yahoo.co.id'), isFalse);
        expect(UbEmailValidator.isUbEmail('user@yahoo.com'), isFalse);
        expect(UbEmailValidator.isUbEmail('user@outlook.com'), isFalse);
        expect(UbEmailValidator.isUbEmail('user@hotmail.com'), isFalse);
        expect(UbEmailValidator.isUbEmail('user@icloud.com'), isFalse);
      });

      test('rejects spoofed or deceptive domains resembling UB', () {
        expect(UbEmailValidator.isUbEmail('user@evil-ub.ac.id'), isFalse);
        expect(UbEmailValidator.isUbEmail('user@ub.ac.id.evil.com'), isFalse);
        expect(UbEmailValidator.isUbEmail('user@notub.ac.id'), isFalse);
        expect(UbEmailValidator.isUbEmail('user@fakeub.ac.id'), isFalse);
        expect(UbEmailValidator.isUbEmail('user@.ub.ac.id'), isFalse);
        expect(UbEmailValidator.isUbEmail('user@..ub.ac.id'), isFalse);
      });

      test('rejects empty, null, and malformed inputs', () {
        expect(UbEmailValidator.isUbEmail(null), isFalse);
        expect(UbEmailValidator.isUbEmail(''), isFalse);
        expect(UbEmailValidator.isUbEmail('   '), isFalse);
        expect(UbEmailValidator.isUbEmail('plainusername'), isFalse);
        expect(UbEmailValidator.isUbEmail('@student.ub.ac.id'), isFalse);
        expect(UbEmailValidator.isUbEmail('user@'), isFalse);
        expect(UbEmailValidator.isUbEmail('user@student@ub.ac.id'), isFalse);
        expect(UbEmailValidator.isUbEmail('user name@student.ub.ac.id'), isFalse);
      });
    });

    group('formatLoginEmail', () {
      test('appends @student.ub.ac.id when input has no @', () {
        expect(
          UbEmailValidator.formatLoginEmail('215150201111001'),
          '215150201111001@student.ub.ac.id',
        );
        expect(
          UbEmailValidator.formatLoginEmail('budi.santoso'),
          'budi.santoso@student.ub.ac.id',
        );
        expect(
          UbEmailValidator.formatLoginEmail('  ANTON  '),
          'anton@student.ub.ac.id',
        );
      });

      test('preserves existing domain when input contains @', () {
        expect(
          UbEmailValidator.formatLoginEmail('sarah@demo.ub.ac.id'),
          'sarah@demo.ub.ac.id',
        );
        expect(
          UbEmailValidator.formatLoginEmail('dosen@ub.ac.id'),
          'dosen@ub.ac.id',
        );
      });
    });

    group('validateLoginInput', () {
      test('returns error when input is null or empty', () {
        expect(UbEmailValidator.validateLoginInput(null), 'Email/Username wajib diisi');
        expect(UbEmailValidator.validateLoginInput(''), 'Email/Username wajib diisi');
        expect(UbEmailValidator.validateLoginInput('   '), 'Email/Username wajib diisi');
      });

      test('rejects non-UB emails with appropriate error message', () {
        expect(
          UbEmailValidator.validateLoginInput('user@gmail.com'),
          UbEmailValidator.invalidDomainMessage,
        );
        expect(
          UbEmailValidator.validateLoginInput('user@yahoo.com'),
          UbEmailValidator.invalidDomainMessage,
        );
      });

      test('accepts valid UB emails', () {
        expect(UbEmailValidator.validateLoginInput('budi@student.ub.ac.id'), isNull);
        expect(UbEmailValidator.validateLoginInput('sarah@demo.ub.ac.id'), isNull);
        expect(UbEmailValidator.validateLoginInput('staff@ub.ac.id'), isNull);
      });

      test('accepts valid username/NIM without @', () {
        expect(UbEmailValidator.validateLoginInput('215150201111001'), isNull);
        expect(UbEmailValidator.validateLoginInput('budi.santoso'), isNull);
      });

      test('rejects username with spaces', () {
        expect(
          UbEmailValidator.validateLoginInput('budi santoso'),
          'Username tidak boleh mengandung spasi',
        );
      });
    });

    group('validateRegisterEmail', () {
      test('returns error when empty', () {
        expect(UbEmailValidator.validateRegisterEmail(null), 'Email wajib diisi');
        expect(UbEmailValidator.validateRegisterEmail(''), 'Email wajib diisi');
      });

      test('rejects non-UB email for registration', () {
        expect(
          UbEmailValidator.validateRegisterEmail('user@gmail.com'),
          UbEmailValidator.invalidDomainMessage,
        );
      });

      test('accepts valid UB email for registration', () {
        expect(UbEmailValidator.validateRegisterEmail('user@student.ub.ac.id'), isNull);
        expect(UbEmailValidator.validateRegisterEmail('user@demo.ub.ac.id'), isNull);
      });
    });
  });
}
