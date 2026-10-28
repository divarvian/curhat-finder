import 'package:flutter/material.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/counselor_model.dart';

class CounselorForumView extends StatefulWidget {
  const CounselorForumView({super.key});

  @override
  State<CounselorForumView> createState() => _CounselorForumViewState();
}

class _CounselorForumViewState extends State<CounselorForumView> {
  final List<CounselorForumThread> _threads = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchThreads();
  }

  Future<void> _fetchThreads() async {
    setState(() => _isLoading = true);
    try {
      final response = await SupabaseService.client
          .from('counselor_forums')
          .select('*, profiles(full_name, nickname, faculty)')
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      if (mounted) {
        setState(() {
          _threads.clear();
          _threads.addAll(data.map((item) => CounselorForumThread.fromJson(item as Map<String, dynamic>)));
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showCreateThreadDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedTopic = 'Studi Kasus';
    final topics = [
      'Studi Kasus',
      'Etika & Kerahasiaan',
      'Teknik Konseling',
      'Rujukan Krisis',
      'Kesehatan Mental Konselor',
    ];
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                'Mulai Diskusi Supervisi',
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
                        'Topik Diskusi:',
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
                            value: selectedTopic,
                            isExpanded: true,
                            items: topics.map((t) {
                              return DropdownMenuItem(value: t, child: Text(t));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() => selectedTopic = val);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'Judul Diskusi',
                          hintText: 'Misal: Penanganan Mahasiswa Cemas Ujian',
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
                          labelText: 'Uraian Kasus (Tanpa Identitas)',
                          hintText: 'Tuliskan situasi kasus secara anonim untuk meminta saran rekan konselor...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Uraian kasus wajib diisi' : null,
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
                          await SupabaseService.client.from('counselor_forums').insert({
                            'author_id': userId,
                            'title': titleController.text.trim(),
                            'topic': selectedTopic,
                            'content': contentController.text.trim(),
                            'replies_count': 0,
                          });
                        }
                        await _fetchThreads();
                        messenger.clearSnackBars();
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Diskusi baru berhasil dimulai!'),
                            backgroundColor: Color(0xFF4CAF50),
                          ),
                        );
                      } catch (e) {
                        messenger.clearSnackBars();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Gagal memulai diskusi: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Kirim', style: TextStyle(color: Colors.white)),
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
        icon: const Icon(Icons.add_comment_rounded),
        label: const Text('Mulai Diskusi', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: _showCreateThreadDialog,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Bersih
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 12),
              child: Center(
                child: Text(
                  'Forum Konselor',
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
                'Ruang supervisi internal & berbagi studi kasus non-identitas antarkonselor sebaya UB.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.wisteriaNormal,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Konten Forum
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFFF88A8A)),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchThreads,
                      color: const Color(0xFFF88A8A),
                      child: _threads.isEmpty
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
                                            Icons.forum_outlined,
                                            size: 48,
                                            color: Color(0xFFF88A8A),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          'Belum Ada Diskusi',
                                          style: AppTextStyles.heading3.copyWith(
                                            color: AppColors.twilightDarker,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Diskusikan tantangan bimbingan konseling dan mintalah saran dari sesama konselor sebaya kampus.',
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
                              itemCount: _threads.length,
                              itemBuilder: (context, index) {
                                final thread = _threads[index];
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
                                              color: const Color(0xFFEFF3FF),
                                              borderRadius: BorderRadius.circular(100),
                                            ),
                                            child: Text(
                                              thread.topic,
                                              style: AppTextStyles.labelSmall.copyWith(
                                                color: const Color(0xFF4A72E8),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.chat_bubble_outline_rounded,
                                                size: 16,
                                                color: AppColors.wisteriaNormal,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${thread.repliesCount}',
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
                                        thread.title,
                                        style: AppTextStyles.heading3.copyWith(
                                          color: AppColors.twilightDarker,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        thread.content,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.twilightNormal.withValues(alpha: 0.8),
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.person_pin_circle_outlined,
                                            size: 14,
                                            color: AppColors.wisteriaNormal,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${thread.authorName ?? "Konselor"} (${thread.authorFaculty ?? "UB"})',
                                            style: AppTextStyles.labelSmall.copyWith(
                                              color: AppColors.wisteriaNormal,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
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
