import 'package:flutter/material.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/counselor_model.dart';

class CounselorCreatorView extends StatefulWidget {
  const CounselorCreatorView({super.key});

  @override
  State<CounselorCreatorView> createState() => _CounselorCreatorViewState();
}

class _CounselorCreatorViewState extends State<CounselorCreatorView> {
  final List<CounselorArticle> _articles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  Future<void> _fetchArticles() async {
    setState(() => _isLoading = true);
    try {
      final response = await SupabaseService.client
          .from('counselor_articles')
          .select()
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      if (mounted) {
        setState(() {
          _articles.clear();
          _articles.addAll(data.map((item) => CounselorArticle.fromJson(item as Map<String, dynamic>)));
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showCreateArticleDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedCategory = 'Self-care';
    final categories = ['Self-care', 'Stres Akademik', 'Kecemasan', 'Manajemen Waktu', 'Relasi'];
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                'Tulis Artikel Edukasi',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.twilightDarker,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kategori:',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.twilightNormal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F7F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.platinum),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCategory,
                            isExpanded: true,
                            items: categories.map((cat) {
                              return DropdownMenuItem(value: cat, child: Text(cat));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() => selectedCategory = val);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'Judul Artikel',
                          hintText: 'Misal: 5 Cara Mengatasi Burnout Skripsi',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Judul wajib diisi' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: contentController,
                        maxLines: 6,
                        decoration: InputDecoration(
                          labelText: 'Isi Teks Psikoedukasi',
                          hintText: 'Tuliskan panduan atau tips relaksasi yang bermanfaat...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Konten artikel wajib diisi' : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    'Batal',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.wisteriaNormal),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF88A8A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      final messenger = ScaffoldMessenger.of(this.context);
                      Navigator.of(dialogContext).pop();
                      try {
                        final userId = SupabaseService.client.auth.currentUser?.id;
                        if (userId != null) {
                          await SupabaseService.client.from('counselor_articles').insert({
                            'author_id': userId,
                            'title': titleController.text.trim(),
                            'category': selectedCategory,
                            'content': contentController.text.trim(),
                            'likes_count': 0,
                          });
                        }
                        await _fetchArticles();
                        messenger.clearSnackBars();
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Artikel berhasil dipublikasikan!'),
                            backgroundColor: Color(0xFF4CAF50),
                          ),
                        );
                      } catch (e) {
                        messenger.clearSnackBars();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Gagal menerbitkan artikel: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Publikasikan', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFF88A8A),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_note_rounded),
        label: const Text('Tulis Artikel', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: _showCreateArticleDialog,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Bersih
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 12),
              child: Center(
                child: Text(
                  'Creator Studio',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.twilightDarker,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Publikasikan artikel psikoedukasi dan tips kesehatan mental untuk mahasiswa.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.wisteriaNormal,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Konten Creator
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFFF88A8A)),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchArticles,
                      color: const Color(0xFFF88A8A),
                      child: _articles.isEmpty
                          ? ListView(
                              children: [
                                const SizedBox(height: 80),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.04),
                                                blurRadius: 15,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.draw_outlined,
                                            size: 48,
                                            color: Color(0xFFF88A8A),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          'Belum Ada Artikel',
                                          style: AppTextStyles.heading3.copyWith(
                                            color: AppColors.twilightDarker,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Ketuk tombol "Tulis Artikel" di bawah untuk mulai berbagi wawasan psikoedukasi dengan rekan mahasiswa.',
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            color: AppColors.wisteriaNormal,
                                            fontSize: 13,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              itemCount: _articles.length,
                              itemBuilder: (context, index) {
                                final article = _articles[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 14),
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.03),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
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
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFF0F0),
                                              borderRadius: BorderRadius.circular(100),
                                            ),
                                            child: Text(
                                              article.category,
                                              style: AppTextStyles.labelSmall.copyWith(
                                                color: const Color(0xFFF88A8A),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.favorite_rounded,
                                                size: 16,
                                                color: Color(0xFFF88A8A),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${article.likesCount}',
                                                style: AppTextStyles.bodySmall.copyWith(
                                                  color: AppColors.wisteriaNormal,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        article.title,
                                        style: AppTextStyles.heading3.copyWith(
                                          color: AppColors.twilightDarker,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        article.content,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.twilightNormal.withValues(alpha: 0.8),
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
