import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/widgets/dialogs/delete_confirmation_dialog.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/tip_model.dart';
import '../providers/tips_interaction_provider.dart';

class TipDetailStep {
  final String title;
  final String body;

  const TipDetailStep({required this.title, required this.body});
}

/// Halaman Detail "Isi Tips" sesuai spesifikasi desain docs/ui/Isi Tips.png
class TipDetailView extends ConsumerStatefulWidget {
  final TipModel? tip;

  const TipDetailView({
    super.key,
    this.tip,
  });

  @override
  ConsumerState<TipDetailView> createState() => _TipDetailViewState();
}

class _TipDetailViewState extends ConsumerState<TipDetailView> with SingleTickerProviderStateMixin {
  late int _localLikesCount;
  bool _isLocalLiked = false;
  bool _isLocalBookmarked = false;

  late AnimationController _likeAnimController;
  late Animation<double> _likeScaleAnim;

  @override
  void initState() {
    super.initState();
    _localLikesCount = widget.tip?.likesCount ?? 99999;
    _isLocalLiked = widget.tip?.isLikedByMe ?? false;
    _isLocalBookmarked = widget.tip?.isBookmarkedByMe ?? false;

    _likeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _likeScaleAnim = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _likeAnimController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _likeAnimController.dispose();
    super.dispose();
  }

  void _handleLikeTap() {
    _likeAnimController.forward().then((_) => _likeAnimController.reverse());
    final tipId = widget.tip?.id;
    if (tipId != null) {
      ref.read(tipsInteractionProvider.notifier).toggleLike(tipId);
    } else {
      setState(() {
        _isLocalLiked = !_isLocalLiked;
        _localLikesCount += _isLocalLiked ? 1 : -1;
      });
    }
  }

  void _handleBookmarkTap() {
    final tipId = widget.tip?.id;
    if (tipId != null) {
      ref.read(tipsInteractionProvider.notifier).toggleBookmark(tipId);
    } else {
      setState(() {
        _isLocalBookmarked = !_isLocalBookmarked;
      });
    }
  }

  void _showMoreOptions(BuildContext context) {
    final currentUserId = SupabaseService.currentUserId;
    final isOwner = widget.tip?.userId != null && widget.tip!.userId == currentUserId;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.twilightLightActive,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                if (isOwner)
                  ListTile(
                    leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFFF87171)),
                    title: Text(
                      'Hapus Tips',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: const Color(0xFFF87171),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final confirmed = await DeleteConfirmationDialog.show(
                        context,
                        title: 'Hapus Tips Ini?',
                        message: 'Tips yang sudah dihapus tidak dapat dipulihkan kembali. Apakah kamu yakin ingin menghapusnya?',
                      );
                      if (confirmed == true && mounted) {
                        try {
                          await ref.read(tipsInteractionProvider.notifier).deleteTip(widget.tip!.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tips berhasil dihapus'),
                                backgroundColor: AppColors.twilightDarker,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/main');
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Gagal menghapus tips: $e'),
                                backgroundColor: Colors.redAccent,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      }
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.share_outlined, color: AppColors.twilightDarker),
                  title: Text('Bagikan Tips', style: AppTextStyles.labelLarge),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tautan tips disalin ke clipboard!')),
                    );
                  },
                ),
                if (!isOwner)
                  ListTile(
                    leading: const Icon(Icons.flag_outlined, color: Colors.redAccent),
                    title: Text('Laporkan Konten', style: AppTextStyles.labelLarge.copyWith(color: Colors.redAccent)),
                    onTap: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Laporan Anda telah kami terima.')),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays >= 7) {
      return '${(diff.inDays / 7).floor()} minggu lalu';
    } else if (diff.inDays >= 1) {
      return '${diff.inDays} hari lalu';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours} jam lalu';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} menit lalu';
    }
    return 'Baru saja';
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.tip;
    final tipId = item?.id;

    final interactionState = ref.watch(tipsInteractionProvider);
    final interactionNotifier = ref.read(tipsInteractionProvider.notifier);

    final isLiked = tipId != null
        ? interactionState.likedTipIds.contains(tipId)
        : _isLocalLiked;
    final isBookmarked = tipId != null
        ? interactionState.bookmarkedTipIds.contains(tipId)
        : _isLocalBookmarked;
    final likesCount = item != null
        ? interactionNotifier.getEffectiveLikesCount(item.id, item.likesCount)
        : _localLikesCount;

    final isCanonical = item == null ||
        item.content.toLowerCase().contains('when yh') ||
        item.content.contains('Pernah ga sih kamu merasa');

    final authorTag = item != null
        ? '${item.authorName} • ${item.category}'
        : 'Kak Sekar • Afirmasi';

    final timeAgo = item != null ? _formatTimeAgo(item.createdAt) : '1 hari lalu';

    final title = isCanonical
        ? 'Tips mengatasi perasaan\nwhen yh berlebih'
        : item.displayTitle;

    final introText = isCanonical
        ? 'Pernah ga sih kamu merasa when yh, ya when yh gitu, when yh secara berlebihan? Di era media sosial sekarang, frasa "kapan ya" alias "when yh" sering banget muncul secara otomatis di kepala kita saat melihat pencapaian, gaya hidup, atau kesuksesan orang lain. Meskipun terlihat sepele sebagai candaan, memelihara perasaan ini terlalu sering bisa menjebak kita dalam siklus rasa insecure dan tidak percaya pada kemampuan diri sendiri.'
        : item.displayDescription;

    final stepsTitle = isCanonical
        ? 'Langkah Nyata Mengurangi Frekuensi "When Yh":'
        : 'Langkah Praktis untuk Kategori "${item.category}":';

    final steps = isCanonical
        ? const [
            TipDetailStep(
              title: '1. Ubah Pertanyaan Menjadi Aksi: ',
              body:
                  'Setiap kali pikiran "when yh" muncul, langsung potong kalimat itu dan ganti dengan kalimat afirmasi positif, seperti: "Waktuku akan tiba, dan sekarang aku sedang berproses."',
            ),
            TipDetailStep(
              title: '2. Praktikkan Jurnal Rasa Syukur: ',
              body:
                  'Luangkan waktu 5 menit setiap malam untuk menulis 3 hal baik yang sudah kamu capai atau miliki hari ini, sekecil apa pun itu.',
            ),
            TipDetailStep(
              title: '3. Fokus pada Jalur Sendiri: ',
              body:
                  'Ingat bahwa garis start dan finish setiap orang berbeda. Membandingkan prosesmu dengan hasil akhir orang lain hanya akan membuang energimu secara sia-sia.',
            ),
          ]
        : const [
            TipDetailStep(
              title: '1. Sadari dan Amati: ',
              body: 'Ambil jeda sejenak untuk mengenali apa yang sedang kamu rasakan saat ini tanpa menghakimi diri.',
            ),
            TipDetailStep(
              title: '2. Ambil Langkah Kecil: ',
              body: 'Terapkan satu tindakan sederhana dari tips ini dalam rutinitas harianmu agar dampaknya terasa nyata.',
            ),
            TipDetailStep(
              title: '3. Rayakan Setiap Progres: ',
              body: 'Hargai setiap usaha kecil yang telah kamu lakukan untuk menjaga kesehatan mentalmu.',
            ),
          ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB0BFE2),
              Color(0xFFF4F8FB),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        // Scrollable content layer
                        Positioned.fill(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 130),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top Action Bar inside the card
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.arrow_back_rounded,
                                          color: AppColors.twilightDarker,
                                          size: 24,
                                        ),
                                        onPressed: () {
                                          if (context.canPop()) {
                                            context.pop();
                                          } else {
                                            context.go('/main');
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.more_horiz_rounded,
                                          color: AppColors.wisteriaNormal,
                                          size: 24,
                                        ),
                                        onPressed: () => _showMoreOptions(context),
                                      ),
                                    ],
                                  ),
                                ),

                                // Content Body
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Title
                                      Text(
                                        title,
                                        style: AppTextStyles.heading2.copyWith(
                                          color: AppColors.twilightDarker,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          height: 1.25,
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      // Author & Category Tag Row
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF9DADA),
                                              borderRadius: BorderRadius.circular(100),
                                            ),
                                            child: Text(
                                              authorTag,
                                              style: AppTextStyles.labelSmall.copyWith(
                                                color: AppColors.twilightDarker,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            timeAgo,
                                            style: AppTextStyles.bodySmall.copyWith(
                                              color: AppColors.twilightNormal.withValues(alpha: 0.8),
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 18),

                                      // Intro Paragraph
                                      Text(
                                        introText,
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: AppColors.twilightDarker.withValues(alpha: 0.9),
                                          height: 1.55,
                                          fontSize: 13.5,
                                        ),
                                      ),
                                      const SizedBox(height: 18),

                                      // Steps Subheading
                                      Text(
                                        stepsTitle,
                                        style: AppTextStyles.labelLarge.copyWith(
                                          color: AppColors.twilightDarker,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.5,
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      // Step Items
                                      ...steps.map(
                                        (step) => Padding(
                                          padding: const EdgeInsets.only(bottom: 12),
                                          child: Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: step.title,
                                                  style: const TextStyle(
                                                    fontFamily: 'Gilroy-Bold',
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.twilightDarker,
                                                    fontSize: 13,
                                                    height: 1.45,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: step.body,
                                                  style: TextStyle(
                                                    fontFamily: 'Gilroy-Regular',
                                                    color: AppColors.twilightDarker.withValues(alpha: 0.88),
                                                    fontSize: 13,
                                                    height: 1.45,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Action Row (Like & Bookmark)
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Like Button
                                          InkWell(
                                            onTap: _handleLikeTap,
                                            borderRadius: BorderRadius.circular(20),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                              child: Row(
                                                children: [
                                                  ScaleTransition(
                                                    scale: _likeScaleAnim,
                                                    child: Icon(
                                                      isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                                      color: isLiked ? Colors.redAccent : AppColors.wisteriaDarkHover,
                                                      size: 20,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    '$likesCount',
                                                    style: AppTextStyles.labelSmall.copyWith(
                                                      color: isLiked ? Colors.redAccent : AppColors.wisteriaDarkHover,
                                                      fontSize: 13,
                                                      fontWeight: isLiked ? FontWeight.bold : FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),

                                          // Bookmark Button
                                          InkWell(
                                            onTap: _handleBookmarkTap,
                                            borderRadius: BorderRadius.circular(20),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                                    color: isBookmarked
                                                        ? AppColors.sunshineYellow
                                                        : AppColors.sunshineYellow,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    isBookmarked ? 'Tersimpan' : 'Simpan',
                                                    style: AppTextStyles.labelSmall.copyWith(
                                                      color: AppColors.sunshineYellow,
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.bold,
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
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Peeking Mascot layer: fixed ("lengket") at the bottom of the card
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: IgnorePointer(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.0),
                                    Colors.white.withValues(alpha: 0.85),
                                    Colors.white,
                                  ],
                                  stops: const [0.0, 0.4, 0.75],
                                ),
                              ),
                              padding: const EdgeInsets.only(top: 24),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Image.asset(
                                  'assets/images/mascot_seek.png',
                                  width: 220,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
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
}
