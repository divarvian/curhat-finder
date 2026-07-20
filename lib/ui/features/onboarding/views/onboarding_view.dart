import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class OnboardingContent {
  final String imagePath;
  final String title;
  final String description;
  final String buttonText;

  OnboardingContent({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.buttonText,
  });
}

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // Data statis konten onboarding berdasarkan desain
  final List<OnboardingContent> _contents = [
    OnboardingContent(
      imagePath: 'assets/images/onboard_1.png',
      title: 'Ruang Aman\nBuat Cerita',
      description: 'Curhat Finder bantu kamu cerita tanpa takut dihakimi. Anonim, Hangat, dan Dekat',
      buttonText: 'Lanjut',
    ),
    OnboardingContent(
      imagePath: 'assets/images/onboard_2.png',
      title: 'Anonym By\nDefault',
      description: 'Identitasmu kami sembunyikan otomatis. Kamu yang pilih sejauh mana dikenal',
      buttonText: 'Lanjut',
    ),
    OnboardingContent(
      imagePath: 'assets/images/onboard_3.png',
      title: 'Khusus\nMahasiswa UB',
      description: 'Masuk pakai email kampus. Kamu akan mengobrol dengan sesama warga UB',
      buttonText: 'Mulai',
    ),
  ];



  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentIndex < _contents.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/pre_login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Warna background Platinum
      body: SafeArea(
        bottom: false, // Biarkan panel bawah turun mentok layar
        child: Column(
          children: [
            // Area Gambar (Bagian atas)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: _contents.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Image.asset(
                      _contents[index].imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported, size: 100, color: AppColors.wisteriaLightHover),
                    ),
                  );
                },
              ),
            ),
            
            // Panel Putih (Bagian bawah)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04), // Bayangan lembut
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start, // Ratakan teks ke kiri
                  children: [
                    // Handle drag pill (Garis kecil di tengah atas panel)
                    Center(
                      child: Container(
                        width: 48,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.twilightDarker, 
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Judul (Title)
                    Text(
                      _contents[_currentIndex].title,
                      style: AppTextStyles.heading1.copyWith(
                        color: AppColors.twilightDarker,
                        height: 1.2,
                        letterSpacing: -1, 
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Deskripsi (Subtitle)
                    Text(
                      _contents[_currentIndex].description,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.twilightNormal, // Sedikit lebih terang dari judul
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Custom Dot Indicator
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          _contents.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: _currentIndex == index ? 28 : 8, // Titik aktif memanjang
                            decoration: BoxDecoration(
                              color: _currentIndex == index
                                  ? AppColors.twilightDarker // Warna titik aktif
                                  : AppColors.wisteriaLightHover, // Warna titik tidak aktif
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Tombol Aksi (Lanjut / Mulai)
                    SizedBox(
                      width: double.infinity,
                      height: 56, // Tombol sedikit lebih tinggi
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.wisteriaNormal, // Warna tombol biru pastel
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28), // Sudut tombol sangat bulat
                          ),
                        ),
                        child: Text(
                          _contents[_currentIndex].buttonText,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
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
