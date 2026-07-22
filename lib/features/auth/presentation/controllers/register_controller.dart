import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterState {
  final int currentStep;
  final String fullName;
  final String nickname;
  final String gender;
  final String batch;
  final String facultyId;
  final String prodiId;
  final String hobby;
  final Set<String> topics;

  RegisterState({
    this.currentStep = 0,
    this.fullName = '',
    this.nickname = '',
    this.gender = '',
    this.batch = '',
    this.facultyId = '',
    this.prodiId = '',
    this.hobby = '',
    this.topics = const {},
  });

  RegisterState copyWith({
    int? currentStep,
    String? fullName,
    String? nickname,
    String? gender,
    String? batch,
    String? facultyId,
    String? prodiId,
    String? hobby,
    Set<String>? topics,
  }) {
    return RegisterState(
      currentStep: currentStep ?? this.currentStep,
      fullName: fullName ?? this.fullName,
      nickname: nickname ?? this.nickname,
      gender: gender ?? this.gender,
      batch: batch ?? this.batch,
      facultyId: facultyId ?? this.facultyId,
      prodiId: prodiId ?? this.prodiId,
      hobby: hobby ?? this.hobby,
      topics: topics ?? this.topics,
    );
  }
}

class RegisterController extends Notifier<RegisterState> {
  @override
  RegisterState build() {
    return RegisterState();
  }

  void nextStep(int totalSteps) {
    if (state.currentStep < totalSteps - 1) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }
  
  void setStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  void updateFullName(String name) => state = state.copyWith(fullName: name);
  void updateNickname(String name) => state = state.copyWith(nickname: name);
  void updateGender(String gender) => state = state.copyWith(gender: gender);
  void updateBatch(String batch) => state = state.copyWith(batch: batch);
  void updateHobby(String hobby) => state = state.copyWith(hobby: hobby);
  
  void selectFaculty(String facultyId) {
    state = state.copyWith(
      facultyId: facultyId,
      prodiId: '', // Reset prodi if faculty changes
    );
  }
  
  void selectProdi(String prodiId) {
    state = state.copyWith(prodiId: prodiId);
  }

  void toggleTopic(String topic) {
    final newTopics = Set<String>.from(state.topics);
    if (newTopics.contains(topic)) {
      newTopics.remove(topic);
    } else {
      newTopics.add(topic);
    }
    state = state.copyWith(topics: newTopics);
  }
  
  // Business logic to filter and group prodi
  Map<String, List<dynamic>> getGroupedProdi(List<dynamic> allProdi) {
    if (state.facultyId.isEmpty) return {};
    
    final filtered = allProdi.where((p) => p['fakultas_id'] == state.facultyId).toList();
    final Map<String, List<dynamic>> grouped = {};
    
    for (var p in filtered) {
      final nama = p['nama'] as String;
      String prefix = '';
      String display = nama;

      if (nama.startsWith('S1 ') || nama.startsWith('S2 ') || nama.startsWith('S3 ')) {
        prefix = nama.substring(0, 2);
        display = nama.substring(3);
      } else if (nama.startsWith('D3 ') || nama.startsWith('D4 ')) {
        prefix = nama.substring(0, 2);
        display = nama.substring(3);
      } else if (nama.startsWith('Profesi ')) {
        prefix = 'Profesi';
        display = nama.substring(8);
      } else {
        prefix = 'Lainnya';
      }

      if (!grouped.containsKey(prefix)) grouped[prefix] = [];
      grouped[prefix]!.add({'id': p['id'], 'display': display});
    }
    return grouped;
  }
}

final registerControllerProvider = NotifierProvider<RegisterController, RegisterState>(() {
  return RegisterController();
});
