import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curhat_finder/core/constants/app_categories.dart';
import '../../controllers/register_controller.dart';
import 'register_step_template.dart';

// --- STEP 7: HOBBY OR TOPIC ---
class StepFinal extends ConsumerWidget {
  final bool isKonselor;
  final VoidCallback onNext;
  
  const StepFinal({
    super.key, 
    required this.isKonselor,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registerControllerProvider);
    final controller = ref.read(registerControllerProvider.notifier);

    if (isKonselor) {
      final options = AppCategories.counselorSpecializationTopics;
      return RegisterStepTemplate(
        isKonselor: true,
        title: 'Topik yang kamu kuasai',
        subtitle: 'Pilih satu atau lebih topik yang sesuai dengan keahlian konselingmu',
        isNextEnabled: state.topics.isNotEmpty,
        buttonText: 'Masuk',
        onNext: onNext,
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: options.map((opt) {
            final isSelected = state.topics.contains(opt);
            return RegisterPillOption(
              label: opt,
              isSelected: isSelected,
              isKonselor: true,
              onTap: () => controller.toggleTopic(opt),
            );
          }).toList(),
        ),
      );
    } else {
      final options = AppCategories.studentHobbies;
      return RegisterStepTemplate(
        isKonselor: false,
        title: 'Apa hal yang bisa bikin kamu happy?',
        isNextEnabled: state.hobbies.isNotEmpty,
        buttonText: 'Masuk',
        onNext: onNext,
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: options.map((opt) {
            final isSelected = state.hobbies.contains(opt);
            return RegisterPillOption(
              label: opt,
              isSelected: isSelected,
              isKonselor: false,
              onTap: () => controller.toggleHobby(opt),
            );
          }).toList(),
        ),
      );
    }
    }
}
