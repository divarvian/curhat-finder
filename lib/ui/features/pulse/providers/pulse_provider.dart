import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pulse_contact_model.dart';

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
    // Initial dummy data
    final dummyContacts = [
      PulseContact(
        name: 'Konselor Fakultas',
        faculty: 'FILKOM',
        phone: '0812-3456-789',
        avatarPath: 'assets/images/profile.png',
      ),
      PulseContact(
        name: 'Konselor Fakultas',
        faculty: 'FK',
        phone: '0812-3456-789',
        avatarPath: 'assets/images/profile.png',
      ),
      PulseContact(
        name: 'Konselor Fakultas',
        faculty: 'FEB',
        phone: '0812-3456-789',
        avatarPath: 'assets/images/profile.png',
      ),
      PulseContact(
        name: 'Konselor Pusat',
        faculty: 'FT',
        phone: '0812-1111-2222',
        avatarPath: 'assets/images/profile.png',
      ),
    ];

    return PulseState(allContacts: dummyContacts);
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
