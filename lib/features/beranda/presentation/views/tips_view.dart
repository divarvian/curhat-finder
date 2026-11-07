import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_categories.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_pill.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../data/community_service.dart';
import '../../domain/tip_model.dart';
import '../providers/tips_interaction_provider.dart';
import '../widgets/dialogs/create_tip_sheet.dart';
import '../widgets/interactive_tip_card.dart';

class TipsView extends ConsumerStatefulWidget {
  const TipsView({super.key});

  @override
  ConsumerState<TipsView> createState() => _TipsViewState();
}

class _TipsViewState extends ConsumerState<TipsView> {
  final List<String> _filters = AppCategories.tipFilterCategories;
  int _selectedFilterIndex = 0;
  Stream<List<TipModel>>? _tipsStream;

  @override
  void initState() {
    super.initState();
    _updateStream();
  }

  void _updateStream() {
    final category = _filters[_selectedFilterIndex];
    _tipsStream = ref.read(communityServiceProvider).streamTips(
          category: category == 'Semua' ? null : category,
        );
  }

  void _onFilterTap(int index) {
    if (_selectedFilterIndex == index) return;
    setState(() {
      _selectedFilterIndex = index;
      _updateStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentCategory = _filters[_selectedFilterIndex];

    return Scaffold(
      backgroundColor: AppColors.platinum,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // App Bar Header (Back button, Title, Subtitle)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.twilightDarker, size: 26),
                            onPressed: () => context.pop(),
                          ),
                        ),
                        Text(
                          'Tips',
                          style: AppTextStyles.heading1.copyWith(
                            color: AppColors.twilightDarker,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lihat Tips yang diberikan oleh teman temanmu.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.twilightNormal.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Horizontal Filter Chips
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filters.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedFilterIndex == index;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: AppPill(
                          label: _filters[index],
                          isSelected: isSelected,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          onTap: () => _onFilterTap(index),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Input Section ("Tulis tips yang ingin diberikan...")
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  elevation: 0,
                  child: InkWell(
                    onTap: () {
                      final cat = currentCategory == 'Semua' ? 'Self-care' : currentCategory;
                      CreateTipSheet.show(context, initialCategory: cat);
                    },
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.twilightDarker,
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Tulis tips yang ingin diberikan...',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.twilightNormal.withValues(alpha: 0.75),
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 12),
            ),

            // Tips Feed Stream
            StreamBuilder<List<TipModel>>(
              stream: _tipsStream,
              builder: (context, snapshot) {
                final tips = snapshot.data ?? [];

                if (snapshot.connectionState == ConnectionState.waiting && tips.isEmpty) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const TipCardSkeleton(),
                      childCount: 3,
                    ),
                  );
                }

                if (tips.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.lightbulb_outline, size: 48, color: AppColors.wisteriaNormal),
                            const SizedBox(height: 12),
                            Text(
                              'Belum ada tips di kategori "$currentCategory"',
                              style: AppTextStyles.heading3.copyWith(color: AppColors.twilightDarker, fontSize: 16),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Jadilah yang pertama membagikan tips untuk rekan mahasiswa di atas!',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final interactionState = ref.watch(tipsInteractionProvider);
                final interactionNotifier = ref.read(tipsInteractionProvider.notifier);

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = tips[index];
                      final isLiked = interactionState.likedTipIds.contains(item.id);
                      final isBookmarked = interactionState.bookmarkedTipIds.contains(item.id);
                      final effectiveLikes = interactionNotifier.getEffectiveLikesCount(item.id, item.likesCount);
                      final updatedItem = item.copyWith(likesCount: effectiveLikes);

                      return InteractiveTipCard(
                        key: ValueKey(item.id),
                        item: updatedItem,
                        initialIsLiked: isLiked,
                        initialIsBookmarked: isBookmarked,
                        onToggleLike: (tipId) => ref.read(tipsInteractionProvider.notifier).toggleLike(tipId),
                        onToggleBookmark: (tipId) => ref.read(tipsInteractionProvider.notifier).toggleBookmark(tipId),
                        onTap: () {
                          context.push('/tip_detail', extra: updatedItem);
                        },
                      );
                    },
                    childCount: tips.length,
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 48),
            ),
          ],
        ),
      ),
    );
  }
}
