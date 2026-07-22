import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';

class BerandaView extends StatelessWidget {
  const BerandaView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag, // Menghilangkan keyboard saat layar di-scroll
      slivers: [
        // Top Section (Header Background + Header Content + Floating Banner)
        SliverToBoxAdapter(
          child: _buildTopSection(),
        ),
        
        SliverToBoxAdapter(
          child: _buildInputSection(),
        ),
        
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
        
        SliverToBoxAdapter(
          child: _buildFilterSection(),
        ),
        
        const SliverToBoxAdapter(
          child: SizedBox(height: 16),
        ),
        
        // Feed list
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return _buildFeedCard(index);
            },
            childCount: 3,
          ),
        ),
        
        // Spasi bawah agar tidak tertutup FAB / Nav Bar
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildTopSection() {
    return Stack(
      clipBehavior: Clip.none, // Agar maskot yang keluar jalur tidak terpotong
      children: [
        // 1. Latar Belakang Pink melengkung (Fix height)
        Container(
          height: 260, 
          decoration: const BoxDecoration(
            color: Color(0xFFFDE8E9), // Soft pink kemerahan dasar
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            child: Transform.scale(
              scale: 1.5, // Perbesar gambar agar pattern terlihat lebih besar
              child: Image.asset(
                'assets/images/pattern.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ),

        // 2. Karakter Mascot (Di belakang teks dan banner, absolute position)
        Positioned(
          right: -10, // Digeser sedikit ke kanan lagi
          top: 45, // Dinaikkan ke atas agar lebih pas dengan ukurannya yang baru
          child: SizedBox(
            width: 200, // Diperbesar sesuai permintaan
            child: Image.asset(
              'assets/images/mascot.png',
              fit: BoxFit.contain,
            ),
          ),
        ),

        // 3. Konten Header dan Banner (Dinamis mengatur tinggi keseluruhan)
        Column(
          children: [
            SafeArea(
              bottom: false,
              left: false, // Nonaktifkan penyesuaian horizontal otomatis untuk layar landscape
              right: false, // Agar batas padding kiri-kanan tetap rata 24px seperti komponen di bawahnya
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar Profile
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.twilightNormal, width: 2),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/profile.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          Text(
                            'Halo Whisky,\nada apa hari ini?',
                            style: AppTextStyles.heading1.copyWith(
                              color: AppColors.twilightDarker,
                              fontSize: 22,
                              height: 1.25,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Yuk, luangin waktu buat dirimu sendiri.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.wisteriaDark,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Placeholder kosong untuk memberi ruang agar teks tidak bertabrakan dengan maskot di layar sempit
                    const SizedBox(width: 130), 
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24), // Spasi antara teks header dan banner
            
            // Floating Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildFloatingBanner(),
            ),
            
            const SizedBox(height: 32), // Spasi setelah banner sebelum Input Section
          ],
        ),
      ],
    );
  }

  Widget _buildFloatingBanner() {
    return Container(
      width: double.infinity, // Agar lebarnya konsisten dengan komponen lain (full width minus padding)
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.twilightDark,
            AppColors.wisteriaNormalHover,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.twilightDark.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Watermark icon di kanan
          Positioned(
            right: -30, // Digeser lebih ke kanan agar mepet/sebagian terpotong di pinggir banner
            bottom: -20,
            child: Transform.scale(
              scaleX: -1, // Membalik arah horizontal (kiri-kanan)
              child: Icon(
                Icons.volunteer_activism, // Heart hand icon
                size: 100,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
          ),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lagi pingin ditemenin?',
                style: AppTextStyles.heading2.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ngobrol bareng peer support yang siap dengerin.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 16),
              
              // Button
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.twilightDarker,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Cari Temen Ngobrol',
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bagikan Tips dan Saran Kamu',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.twilightDarker,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Berikan tips dan saranmu untuk teman teman...',
                hintStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.wisteriaDark.withOpacity(0.6),
                  fontSize: 12,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.twilightDarker,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    final List<String> filters = ['Semua', 'Self-care', 'Productivity', 'Afirmasi', 'Musik', 'Curhat'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tips dari teman-teman kamu',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.twilightDarker,
                  fontSize: 16,
                ),
              ),
              Text(
                'Lihat Semua',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.twilightDarker,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20), 
            itemCount: filters.length,
            itemBuilder: (context, index) {
              final isSelected = index == 0; 
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFF9DADA) : Colors.white, // Pink kemerahan
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFE2A6A6) : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  filters[index],
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected ? AppColors.twilightDarker : AppColors.twilightDark,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeedCard(int index) {
    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE8E9), 
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'Anon • Laki-laki • FILKOM',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.twilightDarker,
                    fontSize: 11,
                  ),
                ),
              ),
              const Icon(Icons.more_horiz, color: AppColors.wisteriaNormal, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            index == 0
                ? 'hidup udah agak mantap tapi ada aja postingan #mykisah yang bikin aku ngetik when yah kan aku juga mw'
                : 'ternyata yang paling sakit bukan kalah, tapi sadar kalau gak akan ada lagi "Di kesempatan berikutnya" buat dia.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.twilightDarker,
              height: 1.5,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(index == 0 ? Icons.favorite_border : Icons.favorite, color: Colors.redAccent, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    index == 0 ? '99999' : '77777',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.wisteriaNormal,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.bookmark_border, color: AppColors.sunshineYellow, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Simpan',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.sunshineYellow,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
