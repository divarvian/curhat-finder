import 'package:flutter/material.dart';
import '../../../../app/config/router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _logoRotateAnimation;
  late Animation<double> _revealAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // Dibuat lebih cepat dari sebelumnya (2 detik)
    );

    // Animasi Logo 1: Membesar dari kecil (Pop up dari pojok kiri)
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOutBack), // Bergerak cepat di awal
      ),
    );

    // Animasi Logo 2: Miring ke atas bagian kanan (rotasi), dilakukan SETELAH sampai ukuran asli
    _logoRotateAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -0.2).chain(CurveTween(curve: Curves.easeOut)), 
        weight: 30, // 30% dari waktu rotasi untuk miring ke atas
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.2, end: 0.0).chain(CurveTween(curve: Curves.elasticOut)), // 70% waktu untuk memantul
        weight: 70,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.7), // Dimulai di detik ke 0.3 (Tepat setelah membesar)
      ),
    );

    // Animasi Teks: Terungkap dari kiri ke kanan (Wipe effect)
    _revealAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.9, curve: Curves.easeInOut), // Teks mulai muncul beriringan saat logo miring
      ),
    );

    // Mulai animasi setelah jeda singkat (500ms) agar tidak tertutup transisi Native Splash Screen Android
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _controller.forward();
      }
    });

    // Navigasi otomatis setelah 3.5 detik (menyesuaikan dengan jeda di atas)
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        const OnboardingRoute().go(context);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Platinum (#F4F8FB)
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Kumpulan Animasi Logo
            AnimatedBuilder(
              animation: _logoRotateAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _logoRotateAnimation.value,
                  child: child,
                );
              },
              child: ScaleTransition(
                alignment: Alignment.bottomLeft, // Ini membuat pop-up berpusat dari pojok kiri bawah
                scale: _scaleAnimation,
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 180,
                  height: 180,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.favorite, size: 100, color: AppColors.secondary);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Animasi Teks (Membuka dari kiri ke kanan)
            AnimatedBuilder(
              animation: _revealAnimation,
              builder: (context, child) {
                return ClipRect(
                  clipper: _RevealClipper(_revealAnimation.value),
                  child: child,
                );
              },
              child: RichText(
                text: TextSpan(
                  style: AppTextStyles.displayLarge.copyWith(height: 1.0),
                  children: const [
                    TextSpan(
                      text: 'Curhat ',
                      style: TextStyle(
                        color: AppColors.textPrimary, // Biru dongker
                      ),
                    ),
                    TextSpan(
                      text: 'Finder',
                      style: TextStyle(
                        color: AppColors.secondary, // Biru pastel
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Clipper untuk memotong (masking) teks dan membukanya perlahan dari kiri
class _RevealClipper extends CustomClipper<Rect> {
  final double revealPercent;
  
  _RevealClipper(this.revealPercent);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * revealPercent, size.height);
  }

  @override
  bool shouldReclip(_RevealClipper oldClipper) {
    return oldClipper.revealPercent != revealPercent;
  }
}
