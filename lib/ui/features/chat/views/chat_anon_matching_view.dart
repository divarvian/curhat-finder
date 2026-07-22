import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ChatAnonMatchingView extends StatefulWidget {
  const ChatAnonMatchingView({super.key});

  @override
  State<ChatAnonMatchingView> createState() => _ChatAnonMatchingViewState();
}

class _ChatAnonMatchingViewState extends State<ChatAnonMatchingView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Simulasi delay pencarian 3 detik, lalu masuk ke chat room
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.pushReplacement('/chat_anon_room'); // Menggunakan pushReplacement agar tidak bisa kembali ke layar ini
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F9),
      body: SafeArea(
        child: Column(
          children: [
            // Header (sama dengan chat tab, cuma sebagai penegas context)
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 16),
              child: Center(
                child: Text(
                  'Chat',
                  style: AppTextStyles.heading1.copyWith(
                    color: AppColors.twilightDarker,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                'Pilih cara cerita yang paling nyaman buat kamu.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.twilightNormal,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Chips visual (Statis hanya untuk dekorasi seperti di mockup)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStaticChip('SupportBuddy', false),
                const SizedBox(width: 8),
                _buildStaticChip('Rooms', false),
                const SizedBox(width: 8),
                _buildStaticChip('Chat Anon', true),
              ],
            ),
            
            const Spacer(),
            
            // Animasi Radar
            SizedBox(
              height: 300,
              width: 300,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildRadarCircle(300, 0.0),
                  _buildRadarCircle(220, 0.3),
                  _buildRadarCircle(140, 0.6),
                  
                  // Mascot di tengah
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/profile.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Teks Status
            Text(
              'Mencari partner ngobrol...',
              style: AppTextStyles.heading1.copyWith(
                color: AppColors.twilightDarker,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Menghubungkanmu secara anonim dengan mahasiswa UB yang sesuai dengan preferensimu',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.wisteriaNormalHover,
                  height: 1.5,
                ),
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Tombol Batal
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.twilightDarker,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Batalkan',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFDE8E9) : Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: isSelected ? const Color(0xFFE2A6A6) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(
          color: isSelected ? AppColors.twilightDarker : AppColors.twilightDark,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRadarCircle(double size, double delay) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        // Simple pulsing logic
        final progress = (_animationController.value + delay) % 1.0;
        final opacity = (1.0 - progress).clamp(0.0, 1.0);
        
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.wisteriaNormal.withOpacity(opacity),
              width: 2,
            ),
          ),
        );
      },
    );
  }
}
