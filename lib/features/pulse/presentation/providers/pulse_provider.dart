import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';
import '../../domain/pulse_contact_model.dart';

class PulseState {
  final String searchQuery;
  final int selectedFilterIndex;
  final List<PulseContact> allContacts;
  final bool isLoading;

  const PulseState({
    this.searchQuery = '',
    this.selectedFilterIndex = 0, // 0 = Semua
    this.allContacts = const [],
    this.isLoading = false,
  });

  PulseState copyWith({
    String? searchQuery,
    int? selectedFilterIndex,
    List<PulseContact>? allContacts,
    bool? isLoading,
  }) {
    return PulseState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilterIndex: selectedFilterIndex ?? this.selectedFilterIndex,
      allContacts: allContacts ?? this.allContacts,
      isLoading: isLoading ?? this.isLoading,
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

  static const List<PulseContact> defaultContacts = [
    PulseContact(
      name: 'Unit Bimbingan Konseling FILKOM',
      faculty: 'FILKOM',
      phone: '0812-3000-8801',
      whatsappNumber: '6281230008801',
      description: 'Layanan bimbingan akademik dan konseling sebaya FILKOM UB',
      avatarPath: 'assets/images/profile.png',
      displayOrder: 1,
    ),
    PulseContact(
      name: 'Layanan Konseling Mahasiswa FIB',
      faculty: 'FIB',
      phone: '0812-3000-8802',
      whatsappNumber: '6281230008802',
      description: 'Unit konseling mahasiswa Fakultas Ilmu Budaya UB',
      avatarPath: 'assets/images/profile.png',
      displayOrder: 2,
    ),
    PulseContact(
      name: 'Pusat Konseling Fakultas Teknik',
      faculty: 'FT',
      phone: '0812-3000-8803',
      whatsappNumber: '6281230008803',
      description: 'Layanan pendampingan psikologis Fakultas Teknik UB',
      avatarPath: 'assets/images/profile.png',
      displayOrder: 3,
    ),
    PulseContact(
      name: 'Layanan Konseling FISIP / FBiPK',
      faculty: 'FBiPK',
      phone: '0812-3000-8804',
      whatsappNumber: '6281230008804',
      description: 'Layanan pendampingan konseling FISIP / FBiPK UB',
      avatarPath: 'assets/images/profile.png',
      displayOrder: 4,
    ),
    PulseContact(
      name: 'Unit Krisis & BK Fakultas Kedokteran',
      faculty: 'FK',
      phone: '0341-569117',
      whatsappNumber: '6281230008805',
      description: 'Unit penanganan krisis dan konseling Fakultas Kedokteran UB',
      avatarPath: 'assets/images/profile.png',
      displayOrder: 5,
    ),
    PulseContact(
      name: 'Layanan Psikologi FEB UB',
      faculty: 'FEB',
      phone: '0812-3000-8805',
      whatsappNumber: '6281230008806',
      description: 'Pusat layanan psikologi dan pengembangan karakter FEB UB',
      avatarPath: 'assets/images/profile.png',
      displayOrder: 6,
    ),
    PulseContact(
      name: 'IGD RS Universitas Brawijaya',
      faculty: 'Semua',
      phone: '0341-403000',
      whatsappNumber: '628123403000',
      description: 'Instalasi Gawat Darurat Rumah Sakit UB 24 Jam',
      isEmergency: true,
      avatarPath: 'assets/images/profile.png',
      displayOrder: 7,
    ),
    PulseContact(
      name: 'Hotline Sejiwa Kemenkes (24 Jam)',
      faculty: 'Semua',
      phone: '119 ext 8',
      whatsappNumber: '62811979119',
      description: 'Layanan krisis kesehatan jiwa nasional Kemenkes RI',
      isEmergency: true,
      avatarPath: 'assets/images/profile.png',
      displayOrder: 8,
    ),
  ];

  @override
  PulseState build() {
    // Initial state with default contacts
    final state = const PulseState(allContacts: defaultContacts);
    // Load dynamic contacts from Supabase asynchronously
    loadContactsFromSupabase();
    return state;
  }

  Future<void> loadContactsFromSupabase() async {
    try {
      final client = SupabaseService.client;
      final response = await client
          .from('pulse_contacts')
          .select()
          .order('display_order', ascending: true);

      final List<dynamic> data = response as List<dynamic>;
      if (data.isNotEmpty) {
        final fetchedContacts = data
            .map((item) => PulseContact.fromJson(item as Map<String, dynamic>))
            .toList();
        state = state.copyWith(allContacts: fetchedContacts, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (_) {
      // Keep existing/default fallback contacts on error or offline
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refreshContacts() async {
    state = state.copyWith(isLoading: true);
    await loadContactsFromSupabase();
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
          contact.faculty.toLowerCase().contains(query) ||
          (contact.description != null && contact.description!.toLowerCase().contains(query));

      return matchesCategory && matchesQuery;
    }).toList();
  }
}

final pulseProvider = NotifierProvider<PulseNotifier, PulseState>(() {
  return PulseNotifier();
});
