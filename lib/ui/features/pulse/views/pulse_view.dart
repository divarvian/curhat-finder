import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/pulse_provider.dart';
import '../models/pulse_contact_model.dart';

class PulseView extends ConsumerStatefulWidget {
  const PulseView({super.key});

  @override
  ConsumerState<PulseView> createState() => _PulseViewState();
}

class _PulseViewState extends ConsumerState<PulseView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak dapat membuka tautan: $urlString')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pulseProvider);
    final notifier = ref.read(pulseProvider.notifier);
    final filteredContacts = notifier.filteredContacts;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Background mengikuti scaffold utama
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 16),
                child: Center(
                  child: Text(
                    'Pulse Bantuan',
                    style: AppTextStyles.heading1.copyWith(
                      color: AppColors.twilightDarker,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
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
                    controller: _searchController,
                    onChanged: (value) => notifier.setSearchQuery(value),
                    decoration: InputDecoration(
                      hintText: 'Cari kontak atau layanan...',
                      hintStyle: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.twilightNormal.withOpacity(0.6),
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.twilightNormal,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Filter Chips
              SizedBox(
                height: 32,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20), // Biar jarak kiri kanannya seimbang
                  itemCount: PulseNotifier.categories.length,
                  itemBuilder: (context, index) {
                    final category = PulseNotifier.categories[index];
                    final isSelected = state.selectedFilterIndex == index;
                    
                    return GestureDetector(
                      onTap: () => notifier.setFilterIndex(index),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFDE8E9) : Colors.white,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFE2A6A6) : const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          category,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: isSelected ? AppColors.twilightDarker : AppColors.twilightDark,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Emergency Contact Card
                      _buildEmergencyCard(),
                      const SizedBox(height: 24),

                      // Section Title
                      Text(
                        'Kontak per Fakultas',
                        style: AppTextStyles.heading2.copyWith(
                          color: AppColors.twilightDarker,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Contact List
                      if (filteredContacts.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text(
                              'Tidak ada kontak yang ditemukan.',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.twilightNormal.withOpacity(0.8),
                              ),
                            ),
                          ),
                        )
                      else
                        ...filteredContacts.map((contact) => _buildContactCard(contact)),
                        
                      const SizedBox(height: 100), // Spasi navigasi bawah
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE8E9), // Peach / Pink Latar
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2A6A6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE2A6A6).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Mascot Illustration
          Positioned(
            right: -10,
            top: -15,
            child: Image.asset(
              'assets/images/mascot.png', // Fallback, sebaiknya nanti pakai ilustrasi monster nangis
              width: 80,
              height: 80,
            ),
          ),

          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.55,
                child: Text(
                  'Kontak Darurat ULTKSP',
                  style: AppTextStyles.heading1.copyWith(
                    color: const Color(0xFFB33A3A), // Merah gelap
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.55,
                child: Text(
                  'Unit Layanan Terpadu Krisis & Support Psikologikal UB. Siaga 24/7',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFFB33A3A).withOpacity(0.85),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _launchUrl('tel:119'); // Contoh nomor telepon darurat
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC75555), // Merah
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: Text(
                        'Telepon',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _launchUrl('https://wa.me/6281234567890'); // Contoh URL WA
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFC75555), // Merah
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                          side: const BorderSide(color: Color(0xFFE2A6A6), width: 1), // Border pink
                        ),
                      ),
                      child: Text(
                        'Whatsapp',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: const Color(0xFFC75555),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget _buildContactCard(PulseContact contact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
      child: Row(
        children: [
          // Avatar Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F6F9),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.twilightNormal.withOpacity(0.2)),
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: AppColors.wisteriaNormalHover,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Faculty Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.twilightDarker,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    contact.faculty,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  contact.name,
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.twilightDarker,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  contact.phone,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.twilightNormal.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Hubungi Button
          ElevatedButton(
            onPressed: () {
              // Menghapus semua karakter non-digit dari nomor telepon
              final cleanPhone = contact.phone.replaceAll(RegExp(r'\D'), '');
              _launchUrl('tel:$cleanPhone');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.wisteriaNormalHover, // Biru keunguan muda
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              minimumSize: const Size(0, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Text(
              'Hubungi',
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
