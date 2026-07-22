import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatListState {
  final int selectedMainCategory;
  final int selectedSubCategory;
  final int? selectedAnonType; // 0 = Cuma mau didengar, 1 = Mau dengar pendapat juga

  ChatListState({
    this.selectedMainCategory = 0,
    this.selectedSubCategory = 0,
    this.selectedAnonType,
  });

  ChatListState copyWith({
    int? selectedMainCategory,
    int? selectedSubCategory,
    int? selectedAnonType,
    bool clearAnonType = false,
  }) {
    return ChatListState(
      selectedMainCategory: selectedMainCategory ?? this.selectedMainCategory,
      selectedSubCategory: selectedSubCategory ?? this.selectedSubCategory,
      selectedAnonType: clearAnonType ? null : (selectedAnonType ?? this.selectedAnonType),
    );
  }
}

class ChatListNotifier extends Notifier<ChatListState> {
  @override
  ChatListState build() {
    return ChatListState();
  }

  void setMainCategory(int index) {
    state = state.copyWith(
      selectedMainCategory: index,
      selectedSubCategory: 0, // Reset sub category saat ganti main category
      clearAnonType: true, // Reset anon type
    );
  }

  void setSubCategory(int index) {
    state = state.copyWith(selectedSubCategory: index);
  }

  void setAnonType(int type) {
    state = state.copyWith(selectedAnonType: type);
  }
}

final chatListProvider = NotifierProvider<ChatListNotifier, ChatListState>(() {
  return ChatListNotifier();
});
