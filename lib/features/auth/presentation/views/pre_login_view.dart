import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../app/config/router.dart';
import '../../../../core/theme/app_colors.dart';

class PreLoginView extends StatefulWidget {
  const PreLoginView({super.key});

  @override
  State<PreLoginView> createState() => _PreLoginViewState();
}

class _PreLoginViewState extends State<PreLoginView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    // Total durasi animasi 2.5 detik
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Animasi Skala dengan TweenSequence
    _scaleAnimation = TweenSequence<double>([
      // Fase 1: Muncul cepat dari ukuran 0 ke 1 (0-30% durasi)
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 30.0,
      ),
      // Fase 2: Berdenyut/bernafas sedikit, membesar dari 1 ke 1.2 perlahan (30-60% durasi)
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30.0,
      ),
      // Fase 3: Meledak membesar secara masif memenuhi layar hingga skala 35 (60-100% durasi)
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 35.0).chain(CurveTween(curve: Curves.easeInExpo)),
        weight: 40.0,
      ),
    ]).animate(_controller);

    // Animasi Opasitas agar memudar sedikit di akhir sebelum pindah layar
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 80.0),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeOut)), weight: 20.0),
    ]).animate(_controller);

    // Dengarkan status animasi, pindah layar saat selesai
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          const LoginRoute().go(context);
        }
      }
    });

    // Jalankan animasi segera setelah frame pertama dirender
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward();
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
      backgroundColor: AppColors.background,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: child,
              ),
            );
          },
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFB6C1), // Merah Muda (Soft Pink)
                    AppColors.wisteriaNormal, // Biru Keunguan (Periwinkle)
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
