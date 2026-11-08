import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/pulse_provider.dart';
import '../../domain/pulse_contact_model.dart';

class PulseView extends ConsumerStatefulWidget {
  const PulseView({super.key});

  @override
  ConsumerState<PulseView> createState() => _PulseViewState();
}

class _PulseViewState extends ConsumerState<PulseView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _categoryScrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _categoryScrollController.dispose();
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
                        color: Colors.black.withValues(alpha: 0.04),
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
                        color: AppColors.twilightNormal.withValues(alpha: 0.75),
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

              // Filter Chips dengan panah navigasi presisi sesuai mockup
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 32,
                  child: Row(
                    children: [
                      // Panah kiri
                      InkWell(
                        onTap: () {
                          if (_categoryScrollController.hasClients) {
                            _categoryScrollController.animateTo(
                              (_categoryScrollController.offset - 120).clamp(0.0, _categoryScrollController.position.maxScrollExtent),
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(100),
                        child: const Padding(
                          padding: EdgeInsets.only(right: 6, top: 4, bottom: 4),
                          child: Icon(
                            Icons.chevron_left_rounded,
                            size: 20,
                            color: AppColors.twilightNormal,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: _categoryScrollController,
                          scrollDirection: Axis.horizontal,
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
                                  color: isSelected ? AppColors.lavenderBlush : Colors.white,
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    color: isSelected ? AppColors.redNormalHover : AppColors.twilightLight,
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
                      // Panah kanan
                      InkWell(
                        onTap: () {
                          if (_categoryScrollController.hasClients) {
                            _categoryScrollController.animateTo(
                              (_categoryScrollController.offset + 120).clamp(0.0, _categoryScrollController.position.maxScrollExtent),
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(100),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 6, top: 4, bottom: 4),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: AppColors.twilightNormal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Scrollable Content
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => ref.read(pulseProvider.notifier).refreshContacts(),
                  color: AppColors.wisteriaNormalHover,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.isLoading)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: LinearProgressIndicator(
                              color: AppColors.wisteriaNormalHover,
                              backgroundColor: AppColors.lavenderBlush,
                            ),
                          ),

                        // Unified Emergency Contact Card (ULTKSP & LKM)
                        _buildUnifiedEmergencyCard(),
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
                                  color: AppColors.twilightNormal,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInstitutionInfoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            top: 14,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 28,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.twilightLightActive,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Sheet Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.wisteriaLightHover,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.twilightNormal,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tentang ULTKSP & LKM',
                            style: AppTextStyles.heading2.copyWith(
                              color: AppColors.twilightDarker,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Panduan layanan resmi Universitas Brawijaya',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.twilightDark,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.twilightDark),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ULTKSP Section Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.lavenderBlush,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.redNormalHover),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.redDarkHover,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              'ULTKSP',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Unit Layanan Kekerasan Seksual & Perundungan',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.redDarker,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Satgas PPKSP Universitas Brawijaya bertugas menangani, mencegah, dan menindaklanjuti segala bentuk kekerasan seksual, pelecehan verbal/fisik, intimidasi, dan perundungan (bullying) di lingkungan kampus UB.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.redDarker.withValues(alpha: 0.9),
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '• Perlindungan aman, rahasia, dan berkeadilan bagi pelapor/korban.\n• Pendampingan investigasi, mediasi etik, dan bantuan hukum kampus siaga 24/7.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.redDarker.withValues(alpha: 0.85),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // LKM Section Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F0FA),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.wisteriaNormalHover),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.wisteriaNormalHover,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              'LKM',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Layanan Konseling Mahasiswa',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.twilightDarker,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Layanan Konseling Mahasiswa (LKM) berfokus pada kesehatan mental, pendampingan psikologis profesional, serta kesejahteraan emosional seluruh mahasiswa Universitas Brawijaya.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.twilightDarker.withValues(alpha: 0.9),
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '• Konseling tatap muka & daring untuk stres akademik, kecemasan, dan burnout.\n• Bimbingan konseling sebaya dan pendampingan psikologis berlisensi.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.twilightDark.withValues(alpha: 0.85),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Dismiss Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.twilightNormal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Saya Mengerti',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUnifiedEmergencyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lavenderBlush, // Peach / Pink Latar sesuai mockup
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.redNormalHover, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.redNormalHover.withValues(alpha: 0.18),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kontak Darurat\nULTKSP & LKM',
                      style: AppTextStyles.heading1.copyWith(
                        color: AppColors.redDarker,
                        fontSize: 18,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Unit Layanan Terpadu Krisis &\nSupport Psikologikal UB. Siaga 24/7',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.redDarker.withValues(alpha: 0.85),
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Image.asset(
                'assets/images/mascot_emergency.png',
                width: 68,
                height: 72,
                fit: BoxFit.contain,
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Baris 3 Tombol Aksi (ULTKSP, LKM, dan Lingkaran (i))
          Row(
            children: [
              // Tombol ULTKSP (Solid Koral Merah)
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () => _showContactActionSheet(
                      title: 'Kontak Darurat ULTKSP',
                      subtitle: 'Unit Layanan Kekerasan Seksual & Perundungan (Satgas PPKSP UB)',
                      phone: '0811-3770-008',
                      whatsappNumber: '628113770008',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.redDarkHover,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: Text(
                      'ULTKSP',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Tombol LKM (Putih dengan teks koral)
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () => _showContactActionSheet(
                      title: 'Layanan Konseling Mahasiswa (LKM)',
                      subtitle: 'Pusat Layanan Konseling & Pendampingan Psikologis Mahasiswa UB',
                      phone: '0812-3000-8800',
                      whatsappNumber: '6281230008800',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.redDarkHover,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                        side: const BorderSide(color: AppColors.redNormalHover, width: 1.2),
                      ),
                    ),
                    child: Text(
                      'LKM',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.redDarkHover,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Tombol Lingkaran Info (i)
              Tooltip(
                message: 'Informasi ULTKSP & LKM',
                child: InkWell(
                  onTap: () => _showInstitutionInfoSheet(context),
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.redDarkHover,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.info_outline_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showContactActionSheet({
    required String title,
    required String subtitle,
    required String phone,
    String? whatsappNumber,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
        final cleanWa = whatsappNumber?.replaceAll(RegExp(r'\D'), '');

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            top: 14,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.twilightLightActive,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Sheet Title & Description
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppColors.lavenderBlush,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.contact_phone_rounded,
                      color: AppColors.redDarkHover,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.heading2.copyWith(
                            color: AppColors.twilightDarker,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.twilightDark,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.twilightDark),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tombol Telepon
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _launchUrl('tel:$cleanPhone');
                  },
                  icon: const Icon(Icons.phone_rounded, color: Colors.white, size: 20),
                  label: Text(
                    'Panggilan Telepon ($phone)',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.redDarkHover,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              // Tombol WhatsApp (Jika tersedia)
              if (cleanWa != null && cleanWa.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _launchUrl('https://wa.me/$cleanWa');
                    },
                    icon: SvgPicture.asset(
                      'assets/icons/whatsapp.svg',
                      width: 22,
                      height: 22,
                    ),
                    label: Text(
                      'Chat WhatsApp Resmi',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.twilightDarker,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8F8EE),
                      foregroundColor: AppColors.twilightDarker,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                        side: const BorderSide(color: Color(0xFFA6E7BD), width: 1),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
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
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar Icon Pesan Bulat Abu-abu sesuai mockup
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.lavender.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: AppColors.twilightLightActive,
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
                    color: AppColors.twilightDark,
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
                    color: AppColors.twilightNormal,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Tombol Tunggal Hubungi sesuai Mockup
          ElevatedButton(
            onPressed: () => _showContactActionSheet(
              title: contact.name,
              subtitle: contact.description ?? 'Layanan Konseling Fakultas ${contact.faculty}',
              phone: contact.phone,
              whatsappNumber: contact.whatsappNumber,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.wisteriaNormalHover,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
              minimumSize: const Size(0, 38),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Text(
              'Hubungi',
              style: AppTextStyles.labelMedium.copyWith(
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
