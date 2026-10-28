import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/pulse_contact_model.dart';

class PulseState {
  final String searchQuery;
  final int selectedFilterIndex;
  final List<PulseContact> allContacts;

  PulseState({
    this.searchQuery = '',
    this.selectedFilterIndex = 0, // 0 = Semua
    this.allContacts = const [],
  });

  PulseState copyWith({
    String? searchQuery,
    int? selectedFilterIndex,
    List<PulseContact>? allContacts,
  }) {
    return PulseState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilterIndex: selectedFilterIndex ?? this.selectedFilterIndex,
      allContacts: allContacts ?? this.allContacts,
    );
  }
}

class PulseNotifier extends Notifier<PulseState> {
  static const List<String> categories = [
    'Semua',
    'FILKOM',
    'FIB',
    'FT',
    'FBiPK',
    'FK',
    'FEB'
  ];

  @override
  PulseState build() {
    // Kontak resmi layanan konseling kampus UB dan nomor darurat krisis
    final initialContacts = [
      PulseContact(
        name: 'Unit Bimbingan Konseling FILKOM',
        faculty: 'FILKOM',
        phone: '0812-3000-8801',
        avatarPath: 'assets/images/profile.png',
      ),
      PulseContact(
        name: 'Layanan Konseling Mahasiswa FIB',
        faculty: 'FIB',
        phone: '0812-3000-8802',
        avatarPath: 'assets/images/profile.png',
      ),
      PulseContact(
        name: 'Pusat Konseling Fakultas Teknik',
        faculty: 'FT',
        phone: '0812-3000-8803',
        avatarPath: 'assets/images/profile.png',
      ),
      PulseContact(
        name: 'Layanan Konseling FISIP / FBiPK',
        faculty: 'FBiPK',
        phone: '0812-3000-8804',
        avatarPath: 'assets/images/profile.png',
      ),
      PulseContact(
        name: 'Unit Krisis & BK Fakultas Kedokteran',
        faculty: 'FK',
        phone: '0341-569117',
        avatarPath: 'assets/images/profile.png',
      ),
      PulseContact(
        name: 'Layanan Psikologi FEB UB',
        faculty: 'FEB',
        phone: '0812-3000-8805',
        avatarPath: 'assets/images/profile.png',
      ),
      PulseContact(
        name: 'IGD RS Universitas Brawijaya',
        faculty: 'Semua',
        phone: '0341-403000',
        avatarPath: 'assets/images/profile.png',
      ),
      PulseContact(
        name: 'Hotline Sejiwa Kemenkes (24 Jam)',
        faculty: 'Semua',
        phone: '119 ext 8',
        avatarPath: 'assets/images/profile.png',
      ),
    ];

    return PulseState(allContacts: initialContacts);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setFilterIndex(int index) {
    state = state.copyWith(selectedFilterIndex: index);
  }

  List<PulseContact> get filteredContacts {
    final selectedCategory = categories[state.selectedFilterIndex];
    final query = state.searchQuery.toLowerCase();

    return state.allContacts.where((contact) {
      // Filter by category
      final matchesCategory = selectedCategory == 'Semua' || contact.faculty == selectedCategory;
      
      // Filter by search query
      final matchesQuery = query.isEmpty ||
          contact.name.toLowerCase().contains(query) ||
          contact.faculty.toLowerCase().contains(query);

      return matchesCategory && matchesQuery;
    }).toList();
  }
}

final pulseProvider = NotifierProvider<PulseNotifier, PulseState>(() {
  return PulseNotifier();
});
