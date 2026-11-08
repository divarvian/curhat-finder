import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curhat_finder/core/constants/app_categories.dart';
import 'package:curhat_finder/core/theme/app_colors.dart';
import 'package:curhat_finder/core/theme/app_text_styles.dart';
import 'package:curhat_finder/core/widgets/app_pill.dart';
import 'package:curhat_finder/features/profile/presentation/providers/profile_provider.dart';
import 'package:curhat_finder/features/beranda/data/community_service.dart';

/// Modal Bottom Sheet Terpadu untuk Membuat & Membagikan Tips Baru
class CreateTipSheet extends ConsumerStatefulWidget {
  final String? initialCategory;

  const CreateTipSheet({
    super.key,
    this.initialCategory,
  });

  static Future<void> show(BuildContext context, {String? initialCategory}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => CreateTipSheet(initialCategory: initialCategory),
    );
  }

  @override
  ConsumerState<CreateTipSheet> createState() => _CreateTipSheetState();
}

class _CreateTipSheetState extends ConsumerState<CreateTipSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final List<String> _categories = AppCategories.tipCategories;
  late String _selectedCategory;
  bool _isSubmitting = false;
  bool _isAnonymous = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'Self-care';
    if (!_categories.contains(_selectedCategory)) {
      _selectedCategory = 'Self-care';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Isi tips tidak boleh kosong ya!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final profile = ref.read(profileProvider);
    final authorName = _isAnonymous
        ? 'Teman Kampus'
        : (profile.name.isNotEmpty ? profile.name : 'Teman Kampus');

    try {
      await ref.read(communityServiceProvider).createTip(
            title: title.isNotEmpty ? title : null,
            content: content,
            category: _selectedCategory,
            authorName: authorName,
            authorFaculty: profile.faculty.isNotEmpty ? profile.faculty : 'FILKOM',
            authorGender: profile.gender.isNotEmpty ? profile.gender : 'Laki-laki',
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tips "$_selectedCategory" berhasil dibagikan! Terima kasih sudah saling menyemangati ✨'),
            backgroundColor: AppColors.twilightDarker,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membagikan tips: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, bottomInset + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.twilightLightActive,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header
          Text(
            'Bagikan Tips & Saran ✨',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.twilightDarker,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Berikan inspirasi atau caramu untuk teman-teman mahasiswa.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.wisteriaDark,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),

          // Kategori Selector
          Text(
            'Kategori:',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.twilightDarker,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return AppPill(
                label: cat,
                isSelected: isSelected,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                onTap: () {
                  setState(() {
                    _selectedCategory = cat;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 18),

          // Judul Field
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Judul Tips (Opsional)',
              hintText: 'Contoh: Tips mengatasi overthinking saat ujian',
              hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.wisteriaNormal),
              labelStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.twilightDarker),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.twilightLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.twilightNormal, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 14),

          // Isi Tips Field
          TextField(
            controller: _contentController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Isi Tips / Saran *',
              hintText: 'Jelaskan caramu atau langkah praktisnya untuk teman-teman...',
              hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.wisteriaNormal),
              labelStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.twilightDarker),
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.twilightLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.twilightNormal, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 16),

          // Switch Anonim
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.lavender.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isAnonymous
                    ? AppColors.twilightDarker.withValues(alpha: 0.15)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isAnonymous
                        ? AppColors.twilightDarker
                        : Colors.grey[400],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isAnonymous ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bagikan sebagai Anonim',
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.twilightDarker,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isAnonymous
                            ? 'Nama aslimu disembunyikan (tampil sebagai Teman Kampus)'
                            : 'Nama profil (${profile.name.isNotEmpty ? profile.name : 'Mahasiswa'}) akan ditampilkan',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.twilightNormal,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _isAnonymous,
                  activeTrackColor: AppColors.twilightDarker,
                  onChanged: (val) {
                    setState(() => _isAnonymous = val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tombol Submit
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.twilightDarker,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      'Bagikan Tips Sekarang',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
