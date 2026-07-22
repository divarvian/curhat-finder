import 'package:flutter_riverpod/flutter_riverpod.dart';

class JurnalHistoryItem {
  final String title;
  final String text;
  final String date;
  final String imagePath;

  JurnalHistoryItem({
    required this.title,
    required this.text,
    required this.date,
    required this.imagePath,
  });
}

class JurnalState {
  final int selectedTab; // 0 for Check-In, 1 for Sambat
  final int? selectedMood; // 0: Senang, 1: Biasa saja, 2: Lelah, 3: Sedih, 4: Marah
  final List<JurnalHistoryItem> checkInHistory;
  final List<JurnalHistoryItem> sambatHistory;

  JurnalState({
    this.selectedTab = 0,
    this.selectedMood,
    this.checkInHistory = const [],
    this.sambatHistory = const [],
  });

  JurnalState copyWith({
    int? selectedTab,
    int? selectedMood,
    List<JurnalHistoryItem>? checkInHistory,
    List<JurnalHistoryItem>? sambatHistory,
    bool clearMood = false,
  }) {
    return JurnalState(
      selectedTab: selectedTab ?? this.selectedTab,
      selectedMood: clearMood ? null : (selectedMood ?? this.selectedMood),
      checkInHistory: checkInHistory ?? this.checkInHistory,
      sambatHistory: sambatHistory ?? this.sambatHistory,
    );
  }
}

class JurnalNotifier extends Notifier<JurnalState> {
  @override
  JurnalState build() {
    return JurnalState();
  }

  void setTab(int index) {
    state = state.copyWith(selectedTab: index);
  }

  void setMood(int mood) {
    state = state.copyWith(selectedMood: mood);
  }

  void saveCheckIn(String note) {
    if (state.selectedMood == null) return;

    final newItem = JurnalHistoryItem(
      title: _getMoodTitle(state.selectedMood!),
      text: note.isNotEmpty ? note : 'Tidak ada cerita.',
      date: '07/09/2026',
      imagePath: _getMoodImagePath(state.selectedMood!),
    );

    state = state.copyWith(
      checkInHistory: [newItem, ...state.checkInHistory],
      clearMood: true,
    );
  }

  void saveSambat(String note) {
    if (note.trim().isEmpty) return;

    final newItem = JurnalHistoryItem(
      title: 'Sambat',
      text: note,
      date: '07/09/2026',
      imagePath: 'assets/images/angry.png',
    );

    state = state.copyWith(
      sambatHistory: [newItem, ...state.sambatHistory],
    );
  }

  String _getMoodTitle(int moodIndex) {
    switch (moodIndex) {
      case 0: return 'Senang';
      case 1: return 'Biasa saja';
      case 2: return 'Lelah';
      case 3: return 'Sedih';
      case 4: return 'Marah';
      default: return 'Mood';
    }
  }

  String _getMoodImagePath(int moodIndex) {
    switch (moodIndex) {
      case 0: return 'assets/images/happy.png';
      case 1: return 'assets/images/flat.png';
      case 2: return 'assets/images/tired.png';
      case 3: return 'assets/images/sad.png';
      case 4: return 'assets/images/angry.png';
      default: return 'assets/images/happy.png';
    }
  }
}

final jurnalProvider = NotifierProvider<JurnalNotifier, JurnalState>(() {
  return JurnalNotifier();
});
