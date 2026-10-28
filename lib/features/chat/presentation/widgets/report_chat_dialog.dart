import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/anon_chat_service.dart';

class ReportChatDialog extends ConsumerStatefulWidget {
  final String sessionId;
  final VoidCallback? onReportSuccess;

  const ReportChatDialog({
    super.key,
    this.sessionId = '',
    this.onReportSuccess,
  });

  @override
  ConsumerState<ReportChatDialog> createState() => _ReportChatDialogState();
}

class _ReportChatDialogState extends ConsumerState<ReportChatDialog> {
  String? _selectedReason;
  final TextEditingController _detailsController = TextEditingController();
  bool _isSubmitting = false;
  
  final List<String> _reasons = [
    'Hate speech / berbicara kasar',
    'Doxing / pembocoran identitas',
    'Spam / promosi',
    'Saran berbahaya / menyesatkan',
    'Konten self-harm / kekerasan',
    'Lainnya',
  ];

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmitReport() async {
    if (_selectedReason == null || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final success = await ref.read(anonChatServiceProvider).submitReport(
      sessionId: widget.sessionId,
      reason: _selectedReason!,
      details: _detailsController.text.trim().isNotEmpty
          ? _detailsController.text.trim()
          : null,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      ref.invalidate(activeAnonSessionProvider);
      context.pop(true);
      if (widget.onReportSuccess != null) {
        widget.onReportSuccess!();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan berhasil dikirim. Obrolan telah diakhiri demi keamananmu.'),
          backgroundColor: AppColors.twilightDarker,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengirim laporan. Silakan coba beberapa saat lagi.'),
          backgroundColor: AppColors.redNormal,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: AppColors.platinum,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon Mascot
                  Image.asset(
                    'assets/images/profile.png',
                    width: 72,
                    height: 72,
                  ),
                  const SizedBox(height: 16),
                  
                  // Judul
                  Text(
                    'Laporkan Chat',
                    style: AppTextStyles.heading1.copyWith(
                      color: AppColors.twilightDarker,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  Text(
                    'Target : Anonim',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.wisteriaNormalHover,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  Text(
                    'Pilih alasan agar tim moderasi Curhat Finder dapat meninjau tindakan ini.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.wisteriaNormalHover,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Pilihan Radio Button
                  ..._reasons.map((reason) => _buildRadioOption(reason)),
                  
                  if (_selectedReason == 'Lainnya') ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: _detailsController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Tuliskan detail pelanggaran secara singkat...',
                        hintStyle: AppTextStyles.bodySmall.copyWith(color: Colors.grey[500]),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.twilightLight),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.twilightLight.withValues(alpha: 0.6)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.twilightDarker),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  
                  // Tombol Kirim
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_selectedReason != null && !_isSubmitting)
                          ? _handleSubmitReport
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedReason != null
                            ? AppColors.redNormal
                            : Colors.grey[400],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Kirim Laporan & Akhiri Chat',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Tombol Close X di sudut kanan atas
          Positioned(
            right: 16,
            top: 16,
            child: GestureDetector(
              onTap: () => context.pop(false),
              child: const Icon(
                Icons.close,
                color: AppColors.twilightDarker,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String title) {
    final isSelected = _selectedReason == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedReason = title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lavenderBlush : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? AppColors.twilightDarker : AppColors.twilightLight.withValues(alpha: 0.6),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.twilightDarker : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.twilightDarker,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.twilightDarker,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
