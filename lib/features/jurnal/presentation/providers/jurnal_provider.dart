import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../beranda/data/community_service.dart';

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
  late final CommunityService _communityService;

  @override
  JurnalState build() {
    _communityService = ref.watch(communityServiceProvider);
    Future.microtask(() => _loadInitialJournals());
    return JurnalState();
  }

  void _loadInitialJournals() async {
    try {
      final rows = await _communityService.fetchUserJournals();
      if (rows.isNotEmpty) {
        final items = rows.map((r) {
          final mood = r['mood_index'] as int? ?? 0;
          final dateStr = (r['entry_date'] ?? r['created_at'] ?? '').toString();
          final formattedDate = dateStr.length >= 10 ? dateStr.substring(0, 10) : 'Hari ini';

          return JurnalHistoryItem(
            title: _getMoodTitle(mood),
            text: r['mood_note'] ?? 'Tidak ada cerita.',
            date: formattedDate,
            imagePath: _getMoodImagePath(mood),
          );
        }).toList();

        state = state.copyWith(checkInHistory: items);
      }
    } catch (_) {}

    try {
      final privateSambats = await _communityService.fetchUserPrivateSambats();
      if (privateSambats.isNotEmpty) {
        final items = privateSambats.map((s) {
          final dateStr = (s['created_at'] ?? '').toString();
          final formattedDate = dateStr.length >= 10 ? dateStr.substring(0, 10) : 'Hari ini';
          return JurnalHistoryItem(
            title: (s['mood_tag'] as String?) ?? 'Sambat',
            text: (s['content'] as String?) ?? '',
            date: formattedDate,
            imagePath: 'assets/images/angry.png',
          );
        }).toList();

        state = state.copyWith(sambatHistory: items);
      }
    } catch (_) {}
  }

  void setTab(int index) {
    state = state.copyWith(selectedTab: index);
  }

  void setMood(int mood) {
    state = state.copyWith(selectedMood: mood);
  }

  void saveCheckIn(String note) async {
    if (state.selectedMood == null) return;

    final mood = state.selectedMood!;
    final now = DateTime.now();
    final dateStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    final newItem = JurnalHistoryItem(
      title: _getMoodTitle(mood),
      text: note.isNotEmpty ? note : 'Tidak ada cerita.',
      date: dateStr,
      imagePath: _getMoodImagePath(mood),
    );

    state = state.copyWith(
      checkInHistory: [newItem, ...state.checkInHistory],
      clearMood: true,
    );

    try {
      await _communityService.createJournal(
        moodIndex: mood,
        moodNote: note.isNotEmpty ? note : null,
      );
    } catch (_) {}
  }

  void saveSambat(String note) async {
    if (note.trim().isEmpty) return;

    final now = DateTime.now();
    final dateStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    final newItem = JurnalHistoryItem(
      title: 'Sambat',
      text: note.trim(),
      date: dateStr,
      imagePath: 'assets/images/angry.png',
    );

    state = state.copyWith(
      sambatHistory: [newItem, ...state.sambatHistory],
    );

    try {
      await _communityService.createPrivateSambat(
        content: note.trim(),
        moodTag: 'Sambat',
      );
    } catch (_) {}
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
