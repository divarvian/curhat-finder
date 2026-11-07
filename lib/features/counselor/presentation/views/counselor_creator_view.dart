import 'package:flutter/material.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_error_translator.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../domain/counselor_model.dart';

class CounselorCreatorView extends StatefulWidget {
  const CounselorCreatorView({super.key});

  @override
  State<CounselorCreatorView> createState() => _CounselorCreatorViewState();
}

class _CounselorCreatorViewState extends State<CounselorCreatorView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _contentController = TextEditingController();
  final _linkController = TextEditingController();

  String _selectedCategory = 'Self-care';
  final _categories = const [
    'Self-care',
    'Stres Akademik',
    'Kecemasan',
    'Manajemen Waktu',
    'Relasi',
  ];

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _contentController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _insertFormat(String prefix, [String suffix = '']) {
    final text = _contentController.text;
    final selection = _contentController.selection;
    if (selection.isValid && selection.start != selection.end) {
      final selectedText = text.substring(selection.start, selection.end);
      final newText = text.replaceRange(
        selection.start,
        selection.end,
        '$prefix$selectedText$suffix',
      );
      _contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.start + prefix.length + selectedText.length + suffix.length,
        ),
      );
    } else {
      final insertPos = selection.isValid ? selection.start : text.length;
      final newText = text.replaceRange(insertPos, insertPos, '$prefix$suffix');
      _contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: insertPos + prefix.length),
      );
    }
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false) || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      final summary = _summaryController.text.trim();
      final content = _contentController.text.trim();
      final link = _linkController.text.trim();

      final fullContent = summary.isNotEmpty
          ? '$summary\n\n$content${link.isNotEmpty ? '\n\nSumber: $link' : ''}'
          : content;

      final profile = await SupabaseService.client
          .from('profiles')
          .select('nickname, full_name, faculty, gender')
          .eq('id', userId ?? '')
          .maybeSingle();

      final authorName = profile?['nickname'] ?? profile?['full_name'] ?? 'Konselor';
      final authorFaculty = profile?['faculty'] ?? 'FILKOM';
      final authorGender = profile?['gender'] ?? 'Laki-laki';

      await SupabaseService.client.from('tips').insert({
        'user_id': userId,
        'title': _titleController.text.trim(),
        'category': _selectedCategory,
        'summary': summary.isNotEmpty ? summary : null,
        'content': fullContent,
        'reference_url': link.isNotEmpty ? link : null,
        'author_name': authorName,
        'author_faculty': authorFaculty,
        'author_gender': authorGender,
        'is_counselor': true,
        'likes_count': 0,
        'bookmarks_count': 0,
      });

      _titleController.clear();
      _summaryController.clear();
      _contentController.clear();
      _linkController.clear();

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Tips berhasil dipublikasikan!'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(AppErrorTranslator.translateDatabaseError(e)),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showMyArticlesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => const _MyArticlesBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Creator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Creator',
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.twilightDarker,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.history_edu_rounded,
                        color: AppColors.twilightDarker,
                      ),
                      tooltip: 'Riwayat Tips',
                      onPressed: _showMyArticlesSheet,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 1. Kategori Tips Dropdown
                _buildFieldLabel('Kategori Tips'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.08),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.twilightNormal,
                      ),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.twilightDarker,
                      ),
                      items: _categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedCategory = val);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Judul Tips
                _buildFieldLabel('Judul Tips *'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Judul wajib diisi' : null,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.twilightDarker,
                  ),
                  decoration: _inputDecoration(
                    hintText: 'Contoh: 5 cara mengelola stres sebelum ujian',
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Isi Ringkasan
                _buildFieldLabel('Isi Ringkasan *'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _summaryController,
                  maxLines: 2,
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Ringkasan wajib diisi' : null,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.twilightDarker,
                  ),
                  decoration: _inputDecoration(
                    hintText:
                        'Tuliskan ringkasan singkat yang jelas dan mudah dipahami mahasiswa.',
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Isi Lengkap dengan Formatting Toolbar
                _buildFieldLabel('Isi *'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Toolbar Row
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.05),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            _buildToolbarButton(
                              label: 'H2',
                              onTap: () => _insertFormat('## '),
                            ),
                            _buildToolbarButton(
                              icon: Icons.format_bold_rounded,
                              onTap: () => _insertFormat('**', '**'),
                            ),
                            _buildToolbarButton(
                              icon: Icons.format_italic_rounded,
                              onTap: () => _insertFormat('*', '*'),
                            ),
                            _buildToolbarButton(
                              icon: Icons.format_list_bulleted_rounded,
                              onTap: () => _insertFormat('- '),
                            ),
                            _buildToolbarButton(
                              icon: Icons.link_rounded,
                              onTap: () => _insertFormat('[Teks link](', ')'),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                      // Text input
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: TextFormField(
                          controller: _contentController,
                          maxLines: 7,
                          validator: (val) =>
                              val == null || val.trim().isEmpty ? 'Isi wajib diisi' : null,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.twilightDarker,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Tuliskan konten tips lengkap disini...',
                            hintStyle: TextStyle(
                              color: AppColors.wisteriaNormal,
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 5. Link Eksternal
                _buildFieldLabel('Link Eksternal (Opsional)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _linkController,
                  keyboardType: TextInputType.url,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.twilightDarker,
                  ),
                  decoration: _inputDecoration(
                    hintText: 'https://example.com/resource',
                  ),
                ),
                const SizedBox(height: 28),

                // 6. Tombol Publikasikan
                Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.lavenderBlush,
                        AppColors.redNormal,
                      ],
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.twilightDarker,
                            ),
                          )
                        : Text(
                            'Publikasikan Tips',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.twilightDarker,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.twilightDarker,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }

  Widget _buildToolbarButton({
    String? label,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: label != null
              ? Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.twilightDarker,
                  ),
                )
              : Icon(icon, size: 18, color: AppColors.twilightDarker),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: AppColors.wisteriaNormal,
        fontSize: 13,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.black.withValues(alpha: 0.08),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.black.withValues(alpha: 0.08),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.wisteriaNormal,
          width: 1.5,
        ),
      ),
    );
  }
}

class _MyArticlesBottomSheet extends StatefulWidget {
  const _MyArticlesBottomSheet();

  @override
  State<_MyArticlesBottomSheet> createState() => _MyArticlesBottomSheetState();
}

class _MyArticlesBottomSheetState extends State<_MyArticlesBottomSheet> {
  final List<CounselorArticle> _articles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyArticles();
  }

  Future<void> _fetchMyArticles() async {
    setState(() => _isLoading = true);
    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      final base = SupabaseService.client.from('tips').select();
      final List<Map<String, dynamic>> response = userId != null
          ? await base.eq('user_id', userId).order('created_at', ascending: false)
          : await base.eq('is_counselor', true).order('created_at', ascending: false);

      final List<dynamic> data = response;
      if (mounted) {
        setState(() {
          _articles.clear();
          _articles.addAll(
            data.map(
              (item) => CounselorArticle.fromJson(item as Map<String, dynamic>),
            ),
          );
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Riwayat Tips Terpublikasi',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.twilightDarker,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? ListView.separated(
                    itemCount: 3,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, _) => AppShimmer(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.platinum,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            AppSkeleton(width: 80, height: 16, borderRadius: 6),
                            SizedBox(height: 8),
                            AppSkeleton(width: double.infinity, height: 18, borderRadius: 4),
                            SizedBox(height: 6),
                            AppSkeleton(width: 140, height: 14, borderRadius: 4),
                          ],
                        ),
                      ),
                    ),
                  )
                : _articles.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada tips yang dipublikasikan.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.wisteriaNormal,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _articles.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final article = _articles[index];
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.platinum,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.lavenderBlush,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        article.category,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.twilightDarker,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.favorite_rounded,
                                          size: 14,
                                          color: Color(0xFFF88A8A),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${article.likesCount}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.wisteriaNormal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  article.title,
                                  style: AppTextStyles.heading3.copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.twilightDarker,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  article.content,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.twilightNormal,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
