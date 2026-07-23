import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ZenModal extends StatefulWidget {
  const ZenModal({super.key});

  @override
  State<ZenModal> createState() => _ZenModalState();
}

class _ZenModalState extends State<ZenModal> with SingleTickerProviderStateMixin {
  int _selectedDuration = 1; // 1, 2, or 5 minutes
  
  // State for animation and timer
  bool _isPlaying = false;
  String _breathingText = 'Siap?';
  int _remainingSeconds = 0;
  Timer? _timer;
  
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Controller untuk durasi 1 fase napas (Tarik atau Hembus) = 4 detik
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    
    // Animasi membesar (Tarik napas) dari ukuran asli (1.0) ke 1.35x lebih besar
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );
    
    // Dengarkan status animasi untuk bolak-balik (Tarik -> Hembus -> Tarik)
    _controller.addStatusListener((status) {
      if (!_isPlaying) return;
      
      if (status == AnimationStatus.completed) {
        // Selesai membesar (Tarik napas selesai) -> Mulai mengecil (Hembuskan)
        setState(() {
          _breathingText = 'Hembuskan...';
        });
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        // Selesai mengecil (Hembus selesai) -> Mulai membesar (Tarik napas)
        setState(() {
          _breathingText = 'Tarik Napas...';
        });
        _controller.forward();
      }
    });
  }

  void _startExercise() {
    setState(() {
      _isPlaying = true;
      _remainingSeconds = _selectedDuration * 60;
      _breathingText = 'Tarik Napas...';
    });
    
    // Selalu mulai dari 0.0 untuk menghindari status controller yang tersangkut di akhir
    _controller.forward(from: 0.0);
    
    // Mulai timer hitung mundur
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 1) {
          _remainingSeconds--;
        } else {
          _stopExercise(completed: true);
        }
      });
    });
  }

  void _stopExercise({bool completed = false}) {
    _timer?.cancel();
    
    // 1. SET STATE TERLEBIH DAHULU agar listener animasi (yang mengecek _isPlaying)
    // mengabaikan perubahan status apa pun yang terjadi saat controller di-reset.
    setState(() {
      _isPlaying = false;
      _breathingText = completed ? 'Selesai! 🎉\nMau coba lagi?' : 'Siap?';
    });

    // 2. BARU HENTIKAN DAN RESET CONTROLLER
    // Jika value = 0.0 dipanggil sebelum setState(_isPlaying = false), 
    // listener akan terpicu secara sinkron dan menjalankan forward() lagi tanpa disengaja.
    _controller.stop();
    _controller.value = 0.0; 
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Base size is 45% of screen width, but capped between 150 and 220
    final baseSize = (screenWidth * 0.45).clamp(150.0, 220.0);
    // Reserve space for the maximum scale (1.35x) plus some extra for the glow shadow
    final layoutSize = baseSize * 1.45;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.twilightDarker, // Biru pekat di atas
              AppColors.wisteriaNormalHover, // Biru terang di bawah
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        // Close button
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0, top: 8.0),
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white, size: 32),
                              onPressed: () {
                                _timer?.cancel();
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ),
                        
                        // Mascot & Texts
                        Image.asset(
                          'assets/images/zen.png', // Sementara menggunakan maskot utama
                          height: 110,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Zen Relaksasi',
                          style: AppTextStyles.heading1.copyWith(color: Colors.white, fontSize: 24),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 48.0),
                          child: Text(
                            _isPlaying 
                              ? 'Fokus pada lingkaran. Bernapaslah perlahan.' 
                              : 'Ikuti lingkaran bernapas untuk meredakan ketegangan fisik dan kecemasanmu',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              height: 1.4,
                            ),
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Breathing Circle with Animation
                        SizedBox(
                          width: layoutSize,
                          height: layoutSize,
                          child: Center(
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: Container(
                                width: baseSize, 
                                height: baseSize, 
                                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [
                        AppColors.lavenderBlush, // Very light peach
                        AppColors.redNormal, // redNormal from AppColors
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.wisteriaLightActive.withValues(alpha: 0.5), // Light blueish white glow
                        blurRadius: 50, // Reduced blur
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _breathingText,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.heading1.copyWith(
                            color: AppColors.twilightDarker,
                            fontSize: _isPlaying ? 20 : 24, // Smaller font
                          ),
                        ),
                        if (_isPlaying) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.twilightNormal.withValues(alpha: 0.7),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
              
              const Spacer(),
              
              // Bottom Controls
              if (!_isPlaying) ...[
                // Duration Selection
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildDurationChip(1),
                    _buildDurationChip(2),
                    _buildDurationChip(5),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Start Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.lavenderBlush,
                          AppColors.redNormal,
                        ],
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: _startExercise,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        'Mulai Latihan',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.twilightDarker,
                        ),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Stop Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                    ),
                    child: TextButton(
                      onPressed: () => _stopExercise(completed: false),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        'Berhenti Latihan',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 40),
            ],
          ),
          ),
          ),
          );
          },
          ),
        ),
      ),
    );
  }

  Widget _buildDurationChip(int minutes) {
    bool isSelected = _selectedDuration == minutes;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDuration = minutes;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: isSelected
              ? null
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.lavenderBlush,
                    AppColors.redNormal,
                  ],
                ),
          border: isSelected ? Border.all(color: Colors.white, width: 1.5) : null,
        ),
        child: Text(
          '$minutes Menit',
          style: AppTextStyles.bodyLarge.copyWith(
            color: isSelected ? Colors.white : AppColors.twilightDarker,
            fontWeight: isSelected ? FontWeight.normal : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
