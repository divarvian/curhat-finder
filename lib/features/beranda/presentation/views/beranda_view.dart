import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/presentation/widgets/active_session_banner.dart';
import '../../../main_nav/presentation/providers/main_nav_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../data/community_service.dart';
import '../../domain/tip_model.dart';

class BerandaView extends ConsumerStatefulWidget {
  const BerandaView({super.key});

  @override
  ConsumerState<BerandaView> createState() => _BerandaViewState();
}

class _BerandaViewState extends ConsumerState<BerandaView> {
  final TextEditingController _tipsController = TextEditingController();
  final List<String> _filters = const ['Semua', 'Self-care', 'Productivity', 'Afirmasi', 'Musik', 'Curhat'];
  int _selectedFilterIndex = 0;
  Set<String> _likedTipIds = {};
  Set<String> _bookmarkedTipIds = {};
  Stream<List<TipModel>>? _tipsStream;

  @override
  void initState() {
    super.initState();
    _loadUserInteractions();
    _updateStream();
  }

  void _updateStream() {
    final category = _filters[_selectedFilterIndex];
    _tipsStream = ref.read(communityServiceProvider).streamTips(
          category: category == 'Semua' ? null : category,
        );
  }

  void _loadUserInteractions() async {
    try {
      final likes = await ref.read(communityServiceProvider).fetchUserLikedTips();
      final bookmarks = await ref.read(communityServiceProvider).fetchUserBookmarkedTips();
      if (mounted) {
        setState(() {
          _likedTipIds = likes;
          _bookmarkedTipIds = bookmarks;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _tipsController.dispose();
    super.dispose();
  }

  void _onFilterTap(int index) {
    if (_selectedFilterIndex == index) return;
    setState(() {
      _selectedFilterIndex = index;
      _updateStream();
    });
  }

  void _submitTip() async {
    final text = _tipsController.text.trim();
    if (text.isEmpty) return;

    _tipsController.clear();
    final category = _filters[_selectedFilterIndex] == 'Semua' ? 'Self-care' : _filters[_selectedFilterIndex];
    final profile = ref.read(profileProvider);

    try {
      await ref.read(communityServiceProvider).createTip(
            content: text,
            category: category,
            authorFaculty: profile.faculty.isNotEmpty ? profile.faculty : 'FILKOM',
            authorGender: profile.gender.isNotEmpty ? profile.gender : 'Laki-laki',
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tips "$category" berhasil dibagikan! Terima kasih sudah saling menyemangati ✨'),
            backgroundColor: AppColors.twilightDarker,
          ),
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final displayName = authState.username ?? 'Whisky';
    final currentCategory = _filters[_selectedFilterIndex];

    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        // Top Section (Header Background + Header Content + Floating Banner)
        SliverToBoxAdapter(
          child: _buildTopSection(displayName),
        ),

        // Active Counseling Session Banner (Floating jika ada sesi aktif)
        const SliverToBoxAdapter(
          child: ActiveSessionBanner(
            margin: EdgeInsets.fromLTRB(24, 0, 24, 16),
          ),
        ),

        // Input Section ("Bagikan Tips dan Saran Kamu")
        SliverToBoxAdapter(
          child: _buildInputSection(),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),

        // Filter Section
        SliverToBoxAdapter(
          child: _buildFilterSection(),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 16),
        ),

        // Feed list (Stream from Supabase tips, cached reference)
        StreamBuilder<List<TipModel>>(
          stream: _tipsStream,
          builder: (context, snapshot) {
            final tips = snapshot.data ?? [];

            if (snapshot.connectionState == ConnectionState.waiting && tips.isEmpty) {
              return const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(color: AppColors.twilightDarker),
                  ),
                ),
              );
            }

            if (tips.isEmpty) {
              return SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                          'Jadilah yang pertama membagikan tips untuk teman-temanmu di atas!',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = tips[index];
                  return _InteractiveTipCard(
                    key: ValueKey(item.id),
                    item: item,
                    initialIsLiked: _likedTipIds.contains(item.id),
                    initialIsBookmarked: _bookmarkedTipIds.contains(item.id),
                    onToggleLike: (tipId) => ref.read(communityServiceProvider).toggleLikeTip(tipId),
                    onToggleBookmark: (tipId) => ref.read(communityServiceProvider).toggleBookmarkTip(tipId),
                  );
                },
                childCount: tips.length,
              ),
            );
          },
        ),

        // Spasi bawah agar tidak tertutup FAB / Nav Bar
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildTopSection(String displayName) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 1. Latar Belakang Pink melengkung
        Container(
          height: 260,
          decoration: const BoxDecoration(
            color: AppColors.lavenderBlush,
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
              scale: 1.5,
              child: Image.asset(
                'assets/images/pattern.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ),

        // 2. Karakter Mascot
        Positioned(
          right: -10,
          top: 45,
          child: SizedBox(
            width: 200,
            child: Image.asset(
              'assets/images/mascot.png',
              fit: BoxFit.contain,
            ),
          ),
        ),

        // 3. Konten Header dan Banner
        Column(
          children: [
            SafeArea(
              bottom: false,
              left: false,
              right: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                            'Halo $displayName,\nada apa hari ini?',
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
                    const SizedBox(width: 130),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildFloatingBanner(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ],
    );
  }

  Widget _buildFloatingBanner() {
    return Container(
      width: double.infinity,
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
            color: AppColors.twilightDark.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -30,
            bottom: -20,
            child: Transform.scale(
              scaleX: -1,
              child: Icon(
                Icons.volunteer_activism,
                size: 100,
                color: Colors.white.withValues(alpha: 0.15),
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
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(mainNavProvider.notifier).setIndex(1);
                },
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
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _tipsController,
              onSubmitted: (_) => _submitTip(),
              decoration: InputDecoration(
                hintText: 'Berikan tips dan saranmu untuk teman teman...',
                hintStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.wisteriaDark.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: _submitTip,
                    customBorder: const CircleBorder(),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.twilightDarker,
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 20),
                    ),
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
            itemCount: _filters.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedFilterIndex == index;
              return GestureDetector(
                onTap: () => _onFilterTap(index),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF9DADA) : Colors.white,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: isSelected ? AppColors.redNormalHover : AppColors.twilightLight,
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _filters[index],
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isSelected ? AppColors.twilightDarker : AppColors.twilightDark,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Widget Card Mandiri dengan Optimistic UI dan Spring Bounce Animation
class _InteractiveTipCard extends StatefulWidget {
  final TipModel item;
  final bool initialIsLiked;
  final bool initialIsBookmarked;
  final Future<bool> Function(String tipId) onToggleLike;
  final Future<bool> Function(String tipId) onToggleBookmark;

  const _InteractiveTipCard({
    super.key,
    required this.item,
    required this.initialIsLiked,
    required this.initialIsBookmarked,
    required this.onToggleLike,
    required this.onToggleBookmark,
  });

  @override
  State<_InteractiveTipCard> createState() => _InteractiveTipCardState();
}

class _InteractiveTipCardState extends State<_InteractiveTipCard> with SingleTickerProviderStateMixin {
  late int _likesCount;
  late bool _isLiked;
  late bool _isBookmarked;

  late AnimationController _likeAnimController;
  late Animation<double> _likeScaleAnim;

  @override
  void initState() {
    super.initState();
    _likesCount = widget.item.likesCount;
    _isLiked = widget.initialIsLiked;
    _isBookmarked = widget.initialIsBookmarked;

    _likeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _likeScaleAnim = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _likeAnimController, curve: Curves.easeOutBack),
    );
  }

  @override
  void didUpdateWidget(covariant _InteractiveTipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.id != oldWidget.item.id) {
      _likesCount = widget.item.likesCount;
      _isLiked = widget.initialIsLiked;
      _isBookmarked = widget.initialIsBookmarked;
    }
  }

  @override
  void dispose() {
    _likeAnimController.dispose();
    super.dispose();
  }

  void _handleLikeTap() {
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
      if (_likesCount < 0) _likesCount = 0;
    });

    _likeAnimController.forward().then((_) => _likeAnimController.reverse());
    widget.onToggleLike(widget.item.id);
  }

  void _handleBookmarkTap() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    widget.onToggleBookmark(widget.item.id);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.lavenderBlush,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '${item.authorName} • ${item.authorFaculty} • ${item.category}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.twilightDarker,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.more_horiz, color: AppColors.wisteriaNormal, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            item.content,
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
              // Tombol Suka / Like dengan animasi pegas
              InkWell(
                onTap: _handleLikeTap,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      ScaleTransition(
                        scale: _likeScaleAnim,
                        child: Icon(
                          _isLiked ? Icons.favorite : Icons.favorite_border,
                          color: _isLiked ? Colors.redAccent : AppColors.wisteriaNormal,
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 6),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 150),
                        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                        child: Text(
                          '$_likesCount',
                          key: ValueKey<int>(_likesCount),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: _isLiked ? Colors.redAccent : AppColors.wisteriaNormal,
                            fontSize: 12,
                            fontWeight: _isLiked ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tombol Simpan / Bookmark
              InkWell(
                onTap: _handleBookmarkTap,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: _isBookmarked ? AppColors.sunshineYellow : AppColors.wisteriaNormal,
                        size: 19,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isBookmarked ? 'Tersimpan' : 'Simpan',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: _isBookmarked ? AppColors.sunshineYellow : AppColors.wisteriaNormal,
                          fontSize: 12,
                          fontWeight: _isBookmarked ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
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
