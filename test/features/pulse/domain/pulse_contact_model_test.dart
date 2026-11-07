import 'package:flutter_test/flutter_test.dart';
import 'package:curhat_finder/features/pulse/domain/pulse_contact_model.dart';

void main() {
  group('PulseContact Model Tests', () {
    test('PulseContact model correctly parses JSON and serializes to Map', () {
      final json = {
        'id': 'contact-1',
        'name': 'Unit Bimbingan Konseling FILKOM',
        'faculty': 'FILKOM',
        'phone': '0812-3000-8801',
        'whatsapp_number': '6281230008801',
        'description': 'Layanan bimbingan akademik dan konseling sebaya FILKOM UB',
        'is_emergency': false,
        'avatar_url': 'assets/images/profile.png',
        'display_order': 1,
      };

      final contact = PulseContact.fromJson(json);
      expect(contact.id, 'contact-1');
      expect(contact.name, 'Unit Bimbingan Konseling FILKOM');
      expect(contact.faculty, 'FILKOM');
      expect(contact.phone, '0812-3000-8801');
      expect(contact.whatsappNumber, '6281230008801');
      expect(contact.description, contains('FILKOM UB'));
      expect(contact.isEmergency, isFalse);
      expect(contact.displayOrder, 1);

      final outMap = contact.toJson();
      expect(outMap['whatsapp_number'], '6281230008801');
      expect(outMap['display_order'], 1);
    });
  });
}
