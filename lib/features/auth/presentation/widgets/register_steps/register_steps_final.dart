import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      final options = ['Overhelmed', 'Hilang arah', 'Keuangan', 'Burnout', 'Hubungan', 'Keluarga', 'Anxiety'];
      return RegisterStepTemplate(
        title: 'Topik yang kamu kuasai',
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
                onTap: () => controller.toggleTopic(opt),
              );
            }).toList(),
          ),
        );
      } else {
        return RegisterStepTemplate(
          title: 'Apa hal yang bisa bikin kamu happy?',
          isNextEnabled: state.hobby.trim().isNotEmpty,
          buttonText: 'Masuk',
          onNext: onNext,
          content: RegisterTextField(
            hint: 'Ex. Main padel',
            value: state.hobby,
            onChanged: controller.updateHobby,
          ),
        );
      }
    }
}
