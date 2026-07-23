import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'register_state.dart';

class RegisterController extends Notifier<RegisterState> {
  @override
  RegisterState build() {
    return const RegisterState();
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
  void toggleHobby(String hobby) {
    final newHobbies = Set<String>.from(state.hobbies);
    if (newHobbies.contains(hobby)) {
      newHobbies.remove(hobby);
    } else {
      newHobbies.add(hobby);
    }
    state = state.copyWith(hobbies: newHobbies);
  }
  
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
