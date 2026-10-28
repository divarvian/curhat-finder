import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../data/counseling_service.dart';

class CounselingRatingDialog extends ConsumerStatefulWidget {
  final String sessionId;
  final String counselorName;
  final VoidCallback? onSubmitted;
  final VoidCallback? onSkipped;

  const CounselingRatingDialog({
    super.key,
    required this.sessionId,
    required this.counselorName,
    this.onSubmitted,
    this.onSkipped,
  });

  @override
  ConsumerState<CounselingRatingDialog> createState() => _CounselingRatingDialogState();
}

class _CounselingRatingDialogState extends ConsumerState<CounselingRatingDialog> {
  int _selectedRating = 5;
  final TextEditingController _reviewController = TextEditingController();
  final Set<String> _selectedTags = {'Sangat Membantu', 'Ramah & Empatik'};
  bool _isSubmitting = false;

  final List<String> _availableTags = const [
    'Sangat Membantu',
    'Ramah & Empatik',
    'Solutif',
    'Pendengar yang Baik',
    'Memberi Rasa Aman',
    'Menenangkan',
  ];

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      if (widget.sessionId.isNotEmpty) {
        await ref.read(counselingServiceProvider).submitSessionRating(
          sessionId: widget.sessionId,
          rating: _selectedRating,
          reviewNote: _reviewController.text.trim().isEmpty ? null : _reviewController.text.trim(),
          reviewTags: _selectedTags.toList(),
        );
      }
    } catch (_) {}

    if (mounted) {
      Navigator.of(context).pop();
      widget.onSubmitted?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_isSubmitting) {
          Navigator.of(context).pop();
          widget.onSkipped?.call();
        }
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.lavender.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('💖', style: TextStyle(fontSize: 30)),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Sesi Konseling Selesai',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.twilightDarker,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Text(
                'Bagaimana pengalaman konselingmu bersama ${widget.counselorName}? Ulasanmu sangat berarti bagi kami ✨',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.twilightNormal,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Star Rating Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  return IconButton(
                    iconSize: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    icon: Icon(
                      starIndex <= _selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: starIndex <= _selectedRating ? Colors.amber[600] : Colors.grey[300],
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedRating = starIndex;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Quick Tags Selection
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _availableTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedTags.remove(tag);
                        } else {
                          _selectedTags.add(tag);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.wisteriaNormal : AppColors.platinum,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: isSelected ? AppColors.wisteriaNormal : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        tag,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isSelected ? Colors.white : AppColors.twilightDarker,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Catatan Ulasan Opsional
              TextField(
                controller: _reviewController,
                maxLines: 3,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.twilightDarker),
                decoration: InputDecoration(
                  hintText: 'Tulis pesan kesan untuk konselor (opsional)...',
                  hintStyle: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.twilightNormal.withValues(alpha: 0.6),
                  ),
                  filled: true,
                  fillColor: AppColors.platinum.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.wisteriaNormal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    elevation: 0,
                  ),
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Kirim Ulasan & Selesai',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),

              // Tombol Lewati
              TextButton(
                onPressed: _isSubmitting
                    ? null
                    : () {
                        Navigator.of(context).pop();
                        widget.onSkipped?.call();
                      },
                child: Text(
                  'Lewati',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.twilightNormal.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
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
