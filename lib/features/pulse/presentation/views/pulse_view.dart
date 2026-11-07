import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
              const SizedBox(height: 24),

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

                        // Section Header Layanan Utama & Darurat
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Layanan Utama & Darurat',
                              style: AppTextStyles.heading2.copyWith(
                                color: AppColors.twilightDarker,
                                fontSize: 18,
                              ),
                            ),
                            Tooltip(
                              message: 'Informasi ULTKSP & LKM',
                              child: InkWell(
                                onTap: () => _showInstitutionInfoSheet(context),
                                borderRadius: BorderRadius.circular(100),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.twilightLightActive,
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.04),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.info_outline_rounded,
                                    size: 18,
                                    color: AppColors.twilightNormal,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // ULTKSP Emergency Card
                        _buildUltkspCard(),
                        const SizedBox(height: 16),

                        // LKM Counseling Card
                        _buildLkmCard(),
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

  Widget _buildUltkspCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lavenderBlush, // Peach / Pink Latar
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.redNormalHover, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.redNormalHover.withValues(alpha: 0.2),
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Kontak Darurat ULTKSP',
                            style: AppTextStyles.heading1.copyWith(
                              color: AppColors.redDarker,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Tooltip(
                          message: 'Info ULTKSP',
                          child: InkWell(
                            onTap: () => _showInstitutionInfoSheet(context),
                            borderRadius: BorderRadius.circular(100),
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.redNormalHover, width: 1),
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                              child: const Icon(
                                Icons.info_outline_rounded,
                                size: 14,
                                color: AppColors.redDarkHover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Unit Layanan Kekerasan Seksual & Perundungan UB. Siaga 24/7',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.redDarker.withValues(alpha: 0.85),
                        fontSize: 12,
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

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _launchUrl('tel:08113770008'); // Hotline ULTKSP UB
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.redDarkHover,
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
                    _launchUrl('https://wa.me/628113770008'); // Hotline WhatsApp ULTKSP UB
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.redDarkHover,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                      side: const BorderSide(color: AppColors.redNormalHover, width: 1),
                    ),
                  ),
                  child: Text(
                    'Whatsapp',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.redDarkHover,
                      fontWeight: FontWeight.bold,
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

  Widget _buildLkmCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0FA), // Soft lavender pastel latar
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.wisteriaNormalHover, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.wisteriaNormalHover.withValues(alpha: 0.15),
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Layanan Konseling Mahasiswa (LKM)',
                            style: AppTextStyles.heading1.copyWith(
                              color: AppColors.twilightDarker,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Tooltip(
                          message: 'Info LKM',
                          child: InkWell(
                            onTap: () => _showInstitutionInfoSheet(context),
                            borderRadius: BorderRadius.circular(100),
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.wisteriaNormalHover, width: 1),
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                              child: const Icon(
                                Icons.info_outline_rounded,
                                size: 14,
                                color: AppColors.wisteriaDarker,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pusat layanan konseling psikologis, kesehatan mental, & bimbingan sebaya mahasiswa UB.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.twilightDark.withValues(alpha: 0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Image.asset(
                'assets/images/mascot.png',
                width: 68,
                height: 72,
                fit: BoxFit.contain,
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _launchUrl('tel:081230008800'); // Layanan Telepon LKM UB
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.wisteriaNormalHover,
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
                    _launchUrl('https://wa.me/6281230008800'); // Layanan WhatsApp LKM UB
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.twilightDarker,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                      side: const BorderSide(color: AppColors.wisteriaNormalHover, width: 1),
                    ),
                  ),
                  child: Text(
                    'Whatsapp',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.twilightDarker,
                      fontWeight: FontWeight.bold,
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
          // Avatar Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.platinum,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.twilightNormal.withValues(alpha: 0.2)),
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
                if (contact.description != null && contact.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    contact.description!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.twilightNormal,
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (contact.whatsappNumber != null && contact.whatsappNumber!.isNotEmpty) ...[
                Tooltip(
                  message: 'WhatsApp',
                  child: InkWell(
                    onTap: () {
                      final cleanWa = contact.whatsappNumber!.replaceAll(RegExp(r'\D'), '');
                      _launchUrl('https://wa.me/$cleanWa');
                    },
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F8EE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chat_bubble_rounded,
                        color: Color(0xFF25D366),
                        size: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                  minimumSize: const Size(0, 34),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Text(
                  'Telepon',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
