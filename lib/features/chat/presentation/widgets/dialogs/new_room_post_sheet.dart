import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curhat_finder/core/theme/app_colors.dart';
import 'package:curhat_finder/core/theme/app_text_styles.dart';
import 'package:curhat_finder/features/profile/presentation/providers/profile_provider.dart';
import 'package:curhat_finder/features/chat/data/room_service.dart';

/// Modal Bottom Sheet untuk membuat Postingan Baru di Rooms Kampus
void showNewRoomPostSheet(BuildContext context, WidgetRef ref) {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  String selectedCategory = 'Akademik';
  final categories = ['Akademik', 'Kesepian', 'Keuangan', 'Hubungan', 'Lainnya'];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Curhat di Room Kampus',
                      style: AppTextStyles.heading1.copyWith(
                        fontSize: 20,
                        color: AppColors.twilightDarker,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Postinganmu akan tampil anonim dan bisa didiskusikan bareng mahasiswa UB lainnya.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.twilightNormal,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Pilih Topik Room',
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.twilightDarker,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: categories.map((cat) {
                        final isSel = selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSel,
                          selectedColor: AppColors.twilightDarker,
                          backgroundColor: Colors.grey[100],
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : AppColors.twilightDarker,
                            fontSize: 12,
                          ),
                          onSelected: (val) {
                            if (val) setSheetState(() => selectedCategory = cat);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: 'Judul singkat curhatan...',
                        hintStyle: AppTextStyles.bodySmall.copyWith(
                          color: Colors.grey[400],
                        ),
                        filled: true,
                        fillColor: AppColors.lavender.withValues(alpha: 0.15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: contentController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Ceritakan apa yang sedang kamu rasakan atau alami...',
                        hintStyle: AppTextStyles.bodySmall.copyWith(
                          color: Colors.grey[400],
                        ),
                        filled: true,
                        fillColor: AppColors.lavender.withValues(alpha: 0.15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final title = titleController.text.trim();
                          final content = contentController.text.trim();
                          if (content.isEmpty) return;

                          final profile = ref.read(profileProvider);
                          final facultyTag = profile.faculty.contains('(')
                              ? profile.faculty.split('(').last.replaceAll(')', '').trim()
                              : (profile.faculty.isNotEmpty ? profile.faculty.split(' ').first : 'UB');
                          final authorTag = '${profile.gender.isNotEmpty ? profile.gender : "Mahasiswa"} • $facultyTag';

                          final messenger = ScaffoldMessenger.of(context);
                          Navigator.pop(sheetContext);

                          await ref.read(roomServiceProvider).createRoom(
                            title: title.isNotEmpty ? title : 'Curhat Mahasiswa',
                            content: content,
                            category: selectedCategory,
                            authorTag: authorTag,
                          );

                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Curhatanmu berhasil dibagikan di Room! ✨'),
                              backgroundColor: AppColors.twilightDarker,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.twilightDarker,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Bagikan ke Room',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
