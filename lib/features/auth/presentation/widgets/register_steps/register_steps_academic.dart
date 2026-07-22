import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter_template/core/theme/app_colors.dart';
import 'package:flutter_starter_template/core/theme/app_text_styles.dart';
import '../../controllers/register_controller.dart';
import '../../providers/faculty_prodi_provider.dart';
import 'register_step_template.dart';

// --- STEP 5: FACULTY ---
class StepFaculty extends ConsumerWidget {
  final VoidCallback onNext;
  const StepFaculty({super.key, required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registerControllerProvider);
    final controller = ref.read(registerControllerProvider.notifier);
    final dataAsync = ref.watch(facultyProdiProvider);

    return RegisterStepTemplate(
      title: 'Kamu dari\nfakultas mana?',
      isNextEnabled: state.facultyId.isNotEmpty,
      onNext: onNext,
      content: dataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Gagal memuat data: $err')),
        data: (data) {
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: data.fakultas.map((fac) {
              final isSelected = state.facultyId == fac['id'];
              return RegisterPillOption(
                label: fac['singkatan'], 
                isSelected: isSelected, 
                onTap: () => controller.selectFaculty(fac['id'])
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

// --- STEP 6: PRODI ---
class StepProdi extends ConsumerWidget {
  final VoidCallback onNext;
  const StepProdi({super.key, required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registerControllerProvider);
    final controller = ref.read(registerControllerProvider.notifier);
    final dataAsync = ref.watch(facultyProdiProvider);

    return RegisterStepTemplate(
      title: 'Kalo program\nstudinya?',
      isNextEnabled: state.prodiId.isNotEmpty,
      onNext: onNext,
      content: dataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Gagal memuat data: $err')),
        data: (data) {
          final groupedProdi = controller.getGroupedProdi(data.prodi);
          
          if (groupedProdi.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Pilih fakultas terlebih dahulu',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.twilightLight),
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: groupedProdi.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 12, top: 20),
                    child: Text(
                      entry.key,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.twilightLight,
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: entry.value.map((prodi) {
                      final isSelected = state.prodiId == prodi['id'];
                      return RegisterPillOption(
                        label: prodi['display'], 
                        isSelected: isSelected, 
                        onTap: () => controller.selectProdi(prodi['id'])
                      );
                    }).toList(),
                  ),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
