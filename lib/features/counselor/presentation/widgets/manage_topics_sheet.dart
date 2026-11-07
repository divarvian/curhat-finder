import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Modal Bottom Sheet untuk Kurasi & Pengelolaan Topik Keahlian Konselor
class ManageTopicsSheet extends StatefulWidget {
  final List<String> currentTopics;
  final ValueChanged<List<String>> onSave;

  const ManageTopicsSheet({
    super.key,
    required this.currentTopics,
    required this.onSave,
  });

  static const List<String> canonicalTopics = [
    'Overwhelmed',
    'Hilang arah',
    'Keuangan',
    'Burnout',
    'Hubungan',
    'Keluarga',
    'Anxiety',
    'Akademik',
    'Manajemen Waktu',
    'Karier',
  ];

  static Future<void> show(
    BuildContext context, {
    required List<String> currentTopics,
    required ValueChanged<List<String>> onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => ManageTopicsSheet(
        currentTopics: currentTopics,
        onSave: onSave,
      ),
    );
  }

  @override
  State<ManageTopicsSheet> createState() => _ManageTopicsSheetState();
}

class _ManageTopicsSheetState extends State<ManageTopicsSheet> {
  late final Set<String> _selectedTopics;

  @override
  void initState() {
    super.initState();
    _selectedTopics = Set<String>.from(widget.currentTopics);
  }

  void _toggleTopic(String topic) {
    setState(() {
      if (_selectedTopics.contains(topic)) {
        if (_selectedTopics.length > 1) {
          _selectedTopics.remove(topic);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Minimal pilih 1 topik keahlian utama kamu!'),
              backgroundColor: AppColors.redNormal,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        _selectedTopics.add(topic);
      }
    });
  }

  void _handleSave() {
    if (_selectedTopics.isEmpty) return;
    widget.onSave(_selectedTopics.toList());
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Topik keahlian konseling berhasil diperbarui! ✨'),
        backgroundColor: AppColors.twilightDarker,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
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
            'Kelola Topik Keahlian',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.twilightDarker,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pilih satu atau lebih topik bimbingan yang sesuai dengan kompetensi konselingmu.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.wisteriaNormal,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),

          // Curated Topic Options Wrap
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: ManageTopicsSheet.canonicalTopics.map((topic) {
              final isSelected = _selectedTopics.contains(topic);
              return FilterChip(
                label: Text(topic),
                selected: isSelected,
                onSelected: (_) => _toggleTopic(topic),
                selectedColor: const Color(0xFFFCE6E6),
                backgroundColor: AppColors.platinum,
                checkmarkColor: const Color(0xFFF88A8A),
                labelStyle: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? AppColors.twilightDarker : AppColors.wisteriaDark,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFFF88A8A)
                        : AppColors.twilightLightActive.withValues(alpha: 0.4),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              );
            }).toList(),
          ),

          const SizedBox(height: 28),

          // Tombol Simpan
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _selectedTopics.isNotEmpty ? _handleSave : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF88A8A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Simpan Topik Keahlian (${_selectedTopics.length})',
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
    );
  }
}
