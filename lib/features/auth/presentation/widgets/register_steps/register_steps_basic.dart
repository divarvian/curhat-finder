import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/register_controller.dart';
import 'register_step_template.dart';

// --- STEP 1: FULL NAME ---
class StepFullName extends ConsumerWidget {
  final VoidCallback onNext;
  const StepFullName({super.key, required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registerControllerProvider);
    final controller = ref.read(registerControllerProvider.notifier);

    return RegisterStepTemplate(
      title: 'Tulis nama\nlengkap kamu ya',
      isNextEnabled: state.fullName.trim().isNotEmpty,
      onNext: onNext,
      content: RegisterTextField(
        hint: 'Ex. Bambang',
        value: state.fullName,
        onChanged: controller.updateFullName,
      ),
    );
  }
}

// --- STEP 2: NICKNAME ---
class StepNickname extends ConsumerWidget {
  final VoidCallback onNext;
  const StepNickname({super.key, required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registerControllerProvider);
    final controller = ref.read(registerControllerProvider.notifier);

    return RegisterStepTemplate(
      title: 'Kalo nama\npanggilan kamu?',
      isNextEnabled: state.nickname.trim().isNotEmpty,
      onNext: onNext,
      content: RegisterTextField(
        hint: 'Ex. Bam',
        value: state.nickname,
        onChanged: controller.updateNickname,
      ),
    );
  }
}

// --- STEP 3: GENDER ---
class StepGender extends ConsumerWidget {
  final VoidCallback onNext;
  const StepGender({super.key, required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registerControllerProvider);
    final controller = ref.read(registerControllerProvider.notifier);
    final options = ['Laki-laki', 'Perempuan', 'Lebih memilih tidak menyebutkan'];

    return RegisterStepTemplate(
      title: 'Sekarang,\nkamu itu...',
      isNextEnabled: state.gender.isNotEmpty,
      onNext: onNext,
      content: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: options.map((opt) {
          final isSelected = state.gender == opt;
          return RegisterPillOption(
            label: opt,
            isSelected: isSelected,
            onTap: () => controller.updateGender(opt),
          );
        }).toList(),
      ),
    );
  }
}


// --- STEP 4: BATCH (ANGKATAN) ---
class StepBatch extends ConsumerWidget {
  final VoidCallback onNext;
  const StepBatch({super.key, required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registerControllerProvider);
    final controller = ref.read(registerControllerProvider.notifier);

    final currentYear = DateTime.now().year;
    final years = List.generate(8, (index) => (currentYear - index).toString());

    return RegisterStepTemplate(
      title: 'Kamu mahasiswa\nangkatan berapa?',
      isNextEnabled: state.batch.length == 4,
      onNext: onNext,
      content: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: years.map((year) {
          final isSelected = state.batch == year;
          return RegisterPillOption(
            label: year,
            isSelected: isSelected,
            onTap: () => controller.updateBatch(year),
          );
        }).toList(),
      ),
    );
  }
}
