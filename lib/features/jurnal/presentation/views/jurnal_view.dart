import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/jurnal_provider.dart';

class JurnalView extends ConsumerStatefulWidget {
  const JurnalView({super.key});

  @override
  ConsumerState<JurnalView> createState() => _JurnalViewState();
}

class _JurnalViewState extends ConsumerState<JurnalView> {
  final TextEditingController _checkInController = TextEditingController();
  final TextEditingController _sambatController = TextEditingController();

  void _saveCheckIn() {
    final state = ref.read(jurnalProvider);
    if (state.selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih perasaanmu hari ini dulu ya!')),
      );
      return;
    }

    ref.read(jurnalProvider.notifier).saveCheckIn(_checkInController.text);
    _checkInController.clear();
    
    // Hide keyboard
    FocusScope.of(context).unfocus();
  }

  void _saveSambat() {
    if (_sambatController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tulis keluhanmu terlebih dahulu!')),
      );
      return;
    }

    ref.read(jurnalProvider.notifier).saveSambat(_sambatController.text);
    _sambatController.clear();
    
    // Hide keyboard
    FocusScope.of(context).unfocus();
  }

  String _getMoodImagePath(int moodIndex) {
    switch (moodIndex) {
      case 0: return 'assets/images/happy.png';
      case 1: return 'assets/images/flat.png';
      case 2: return 'assets/images/tired.png';
      case 3: return 'assets/images/sad.png';
      case 4: return 'assets/images/angry.png';
      default: return 'assets/images/happy.png';
    }
  }

  @override
  void dispose() {
    _checkInController.dispose();
    _sambatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jurnalProvider);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.wisteriaLight, // Light blue-ish background
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 16),
                child: Center(
                  child: Text(
                    'Jurnal',
                    style: AppTextStyles.heading1.copyWith(
                      color: AppColors.twilightDarker,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),

              // Toggle Tab
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => ref.read(jurnalProvider.notifier).setTab(0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: state.selectedTab == 0 ? AppColors.twilightDarker : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Chek-In',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: state.selectedTab == 0 ? Colors.white : AppColors.twilightDarker,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => ref.read(jurnalProvider.notifier).setTab(1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: state.selectedTab == 1 ? AppColors.twilightDarker : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Sambat',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: state.selectedTab == 1 ? Colors.white : AppColors.twilightDarker,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Content based on tab
              Expanded(
                child: IndexedStack(
                  index: state.selectedTab,
                  children: [
                    _buildCheckInContent(state),
                    _buildSambatContent(state),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckInContent(JurnalState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Bagaimana Kabarmu Hari ini?',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.twilightDarker,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Mood Emoticons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMoodIcon(0, 'Senang', state),
              _buildMoodIcon(1, 'Biasa saja', state),
              _buildMoodIcon(2, 'Lelah', state),
              _buildMoodIcon(3, 'Sedih', state),
              _buildMoodIcon(4, 'Marah', state),
            ],
          ),
          const SizedBox(height: 24),
          
          // Form Input
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: TextField(
              controller: _checkInController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Apa yang membuatmu merasa begitu?\n[Opsional]',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.twilightNormal.withValues(alpha: 0.6),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveCheckIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.twilightDarker,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                'Simpan Jurnal',
                style: AppTextStyles.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Divider Line
          Center(
            child: Container(
              width: 100,
              height: 2,
              color: AppColors.twilightNormal.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(height: 24),
          
          // Riwayat Section
          Text(
            'Riwayat Jurnal Kamu',
            style: AppTextStyles.heading1.copyWith(
              color: Colors.white, // In mockup it is white text on blue bg
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 16),
          
          if (state.checkInHistory.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'Belum ada riwayat jurnal. Tulis jurnal\npertamamu di atas!',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.twilightNormal.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          else
            ...state.checkInHistory.map((item) => _buildHistoryCard(item)),
            
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSambatContent(JurnalState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Form Bebas',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.twilightDarker,
                  fontSize: 20,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.redNormal, // Pinkish background
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5), width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock, color: Colors.redAccent, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Privat',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Keluarkan semua unek unek kamu!!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.twilightDarker,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          
          // Form Input
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: TextField(
              controller: _sambatController,
              maxLines: 7,
              decoration: InputDecoration(
                hintText: 'Curahkan seluruh kekesalanmu di sini...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.twilightNormal.withValues(alpha: 0.6),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveSambat,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.twilightDarker,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                'Simpan Sambat',
                style: AppTextStyles.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          
          // Riwayat Section
          Text(
            'Riwayat Sambatan Kamu',
            style: AppTextStyles.heading1.copyWith(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 16),
          
          if (state.sambatHistory.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'Belum ada keluhan nih~',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.twilightNormal.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          else
            ...state.sambatHistory.map((item) => _buildHistoryCard(item)),
            
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildMoodIcon(int index, String label, JurnalState state) {
    final isSelected = state.selectedMood == index;
    final imagePath = _getMoodImagePath(index);
    return GestureDetector(
      onTap: () => ref.read(jurnalProvider.notifier).setMood(index),
      child: Column(
        children: [
          AnimatedScale(
            scale: isSelected ? 1.25 : 1.0, // Scale up 25% when selected
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            child: SizedBox(
              width: 50,
              height: 50,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: AppTextStyles.labelSmall.copyWith(
              color: isSelected ? AppColors.twilightDarker : AppColors.twilightDark,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
              fontSize: isSelected ? 12 : 10,
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(JurnalHistoryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    item.imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.title,
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.twilightDarker,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                item.date,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.twilightNormal.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.twilightDarker,
              height: 1.5,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
