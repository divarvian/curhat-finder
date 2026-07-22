import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class RoomDetailView extends StatelessWidget {
  const RoomDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.platinum, // Warna background biru pucat
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Konten Detail
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                children: [
                  // Post Card Utama
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // App Bar / Header Post
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(
                                Icons.arrow_back,
                                color: AppColors.twilightDarker,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.lavenderBlush, // Pink pastel background
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                'Laki-laki • FILKOM',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.twilightDarker,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: AppColors.lavenderBlush, width: 1.5),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                'Kesepian',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.twilightDarker,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '1 hari lalu',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.twilightDarker,
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.more_horiz,
                              color: AppColors.wisteriaNormalHover,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Title / Konten Utama
                        Text(
                          'hidup udah agak mantap tapi ada aja postingan #mykisah yang bikin aku ngetik when yah kan aku juga mw',
                          style: AppTextStyles.heading2.copyWith(
                            color: AppColors.twilightDarker,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Body Text
                        Text(
                          'hidup udah agak mantap, kerjaan mulai beres, tidur lumayan teratur, dompet walau tipis masih bisa napas. pokoknya udah mulai ngerasa, "oh... ternyata hidup bisa setenang ini ya."\n\neh terus buka sosmed.\n\nmuncul postingan #mykisah.\n\nisinya orang-orang ketemu pasangan yang baik, dilamar, nikah, anniversary, saling support, dibeliin bunga, dibikinin bekel, diajak healing, dikasih kejutan kecil yang manis-manis.\naku cuma bisa scroll sambil senyum tipis.\nterus tanpa sadar ngetik...\n"when yah..."\n\nkan aku juga mw.\n\nya Allah, aku gak minta yang wah-wah kok. pengen ngerasain jadi tokoh utama di postingan #mykisah sekali aja. 😔',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.twilightDark,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Footer Post Utama
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.favorite_border,
                                  color: Colors.redAccent,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '99999',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: Colors.redAccent,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Icon(
                                  Icons.chat_bubble_outline,
                                  color: AppColors.wisteriaNormalHover,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '99999',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.wisteriaNormalHover,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.bookmark,
                                  color: AppColors.sunshineYellow, // Yellow
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Simpan',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.sunshineYellow, // Yellow
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Input Balasan
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: AppColors.twilightNormal.withValues(alpha: 0.5), width: 1),
                    ),
                    child: Text(
                      'Tulis balasanmu...',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.twilightNormal.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Daftar Komentar
                  _buildComment(
                    author: 'anon123',
                    time: '1 hari lalu',
                    content: 'sini bang kutemenin, when yh...',
                    likes: '1',
                    comments: '0',
                  ),
                  const SizedBox(height: 16),
                  _buildComment(
                    author: 'anon244',
                    time: 'Baru saja',
                    content: '"When ya" bukan sekedar kata spontan yang keluar begitu saja, itu adalah bentuk kecil dari keinginan. sebuah cara lembut untuk mengekspresikan bahwa aku juga ingin, bahwa di dalam diriku ada keinginan yang sama. tapi di baliknya, tersembunyi perasaan yang lebih dalam. "When ya" adalah tanya lirih pada diri sendiri, kapan giliranku untuk merasakannya? kapan aku bisa begitu juga?',
                    likes: '0',
                    comments: '0',
                  ),
                  const SizedBox(height: 100), // Ruang bawah
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComment({
    required String author,
    required String time,
    required String content,
    required String likes,
    required String comments,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        Container(
          width: 40,
          height: 40,
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
        const SizedBox(width: 12),
        
        // Konten Komentar
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$author • $time',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.twilightDarker,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.twilightDark,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              
              // Footer Komentar
              Row(
                children: [
                  const Icon(
                    Icons.favorite_border,
                    color: Colors.redAccent,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    likes,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.redAccent,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.chat_bubble_outline,
                    color: AppColors.wisteriaNormalHover,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    comments,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.wisteriaNormalHover,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
