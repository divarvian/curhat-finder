import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curhat_finder/core/constants/app_categories.dart';
import 'package:curhat_finder/core/theme/app_colors.dart';
import 'package:curhat_finder/core/theme/app_text_styles.dart';
import 'package:curhat_finder/core/utils/app_error_translator.dart';
import 'package:curhat_finder/core/widgets/app_pill.dart';
import 'package:curhat_finder/features/profile/presentation/providers/profile_provider.dart';
import 'package:curhat_finder/features/chat/data/room_service.dart';
import 'package:curhat_finder/features/chat/presentation/providers/rooms_interaction_provider.dart';

/// Modal Bottom Sheet untuk membuat Postingan Baru di Rooms Kampus
void showNewRoomPostSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => const _NewRoomPostSheetWidget(),
  );
}

class _NewRoomPostSheetWidget extends ConsumerStatefulWidget {
  const _NewRoomPostSheetWidget();

  @override
  ConsumerState<_NewRoomPostSheetWidget> createState() => _NewRoomPostSheetWidgetState();
}

class _NewRoomPostSheetWidgetState extends ConsumerState<_NewRoomPostSheetWidget> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  String _selectedCategory = 'Akademik';
  final List<String> _categories = AppCategories.roomCategories;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handlePost() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (content.isEmpty || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    final profile = ref.read(profileProvider);
    final facultyTag = profile.faculty.contains('(')
        ? profile.faculty.split('(').last.replaceAll(')', '').trim()
        : (profile.faculty.isNotEmpty ? profile.faculty.split(' ').first : 'UB');
    final authorName = profile.name.isNotEmpty ? profile.name : 'Anonim';
    final authorFaculty = facultyTag;
    final authorGender = profile.gender.isNotEmpty ? profile.gender : 'Laki-laki';

    final messenger = ScaffoldMessenger.of(context);

    try {
      final createdRoom = await ref.read(roomServiceProvider).createRoom(
        title: title.isNotEmpty ? title : 'Curhat Mahasiswa',
        content: content,
        category: _selectedCategory,
        authorName: authorName,
        authorFaculty: authorFaculty,
        authorGender: authorGender,
      );

      if (createdRoom != null) {
        ref.read(roomsInteractionProvider.notifier).addOptimisticRoom(createdRoom);
      }

      if (mounted) {
        Navigator.pop(context);
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Curhatanmu berhasil dibagikan di Room! ✨'),
            backgroundColor: AppColors.twilightDarker,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Gagal membagikan curhatan: ${AppErrorTranslator.translateDatabaseError(e)}',
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final maxHeight = MediaQuery.of(context).size.height * 0.88;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
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
            physics: const ClampingScrollPhysics(),
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
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSel = _selectedCategory == cat;
                  return AppPill(
                    label: cat,
                    isSelected: isSel,
                    selectedBackgroundColor: AppColors.twilightDarker,
                    selectedTextColor: Colors.white,
                    selectedBorderColor: AppColors.twilightDarker,
                    backgroundColor: Colors.grey[100],
                    textColor: AppColors.twilightDarker,
                    borderColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    onTap: () {
                      setState(() => _selectedCategory = cat);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
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
                controller: _contentController,
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
                  onPressed: _isSubmitting ? null : _handlePost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.twilightDarker,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _isSubmitting ? 'Mengirim...' : 'Bagikan ke Room',
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
    ),
  );
}
}
