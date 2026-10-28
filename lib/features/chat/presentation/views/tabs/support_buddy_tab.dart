import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curhat_finder/core/services/supabase_service.dart';
import 'package:curhat_finder/core/theme/app_colors.dart';
import 'package:curhat_finder/core/theme/app_text_styles.dart';
import 'package:curhat_finder/core/utils/academic_helper.dart';
import 'package:curhat_finder/features/chat/data/counseling_service.dart';
import 'package:curhat_finder/features/chat/presentation/providers/chat_list_provider.dart';
import 'package:curhat_finder/features/chat/presentation/widgets/active_session_banner.dart';
import 'package:curhat_finder/features/chat/presentation/widgets/cards/counselor_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Tab SupportBuddy (Temukan Konselor Sebaya Berdasarkan Topik & Fakultas)
class SupportBuddyTab extends ConsumerStatefulWidget {
  final Stream<List<Map<String, dynamic>>> counselorsStream;

  const SupportBuddyTab({
    super.key,
    required this.counselorsStream,
  });

  @override
  ConsumerState<SupportBuddyTab> createState() => _SupportBuddyTabState();
}

class _SupportBuddyTabState extends ConsumerState<SupportBuddyTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  RealtimeChannel? _presenceChannel;
  Set<String> _onlinePresenceIds = {};

  @override
  void initState() {
    super.initState();
    _presenceChannel = ref.read(counselingServiceProvider).listenOnlineCounselorsPresence((ids) {
      if (mounted) {
        setState(() {
          _onlinePresenceIds = ids;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_presenceChannel != null) {
      SupabaseService.client.removeChannel(_presenceChannel!);
    }
    super.dispose();
  }

  bool _matchesFaculty(String facultyStr, int subCategoryIndex) {
    final upper = facultyStr.toUpperCase();
    switch (subCategoryIndex) {
      case 1:
        return upper.contains('FILKOM') || upper.contains('ILMU KOMPUTER');
      case 2:
        return upper.contains('FIB') || upper.contains('ILMU BUDAYA');
      case 3:
        // Cek Fakultas Teknik eksak, hindari false positive FTP / FTAB
        final tokens = upper.split(RegExp(r'[\s\(\)\,\.]+'));
        return tokens.contains('FT') || upper.contains('FAKULTAS TEKNIK');
      case 4:
        return upper.contains('FISIP') || upper.contains('FBIPK') || upper.contains('BIPK') || upper.contains('ILMU SOSIAL');
      case 5:
        // Cek Fakultas Kedokteran eksak, hindari FKG / FKH
        final tokens = upper.split(RegExp(r'[\s\(\)\,\.]+'));
        return (tokens.contains('FK') && !tokens.contains('FKG') && !tokens.contains('FKH')) ||
            (upper.contains('KEDOKTERAN') && !upper.contains('GIGI') && !upper.contains('HEWAN'));
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatListProvider);

    return Column(
      children: [
        // Floating Banner Sesi Aktif
        const ActiveSessionBanner(
          margin: EdgeInsets.fromLTRB(24, 0, 24, 12),
        ),

        // Search Bar dengan controller interaktif
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
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari nama konselor, topik, atau hobi...',
                hintStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.twilightNormal.withValues(alpha: 0.6),
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.twilightNormal,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18, color: AppColors.wisteriaNormalHover),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Counselor List Realtime
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: widget.counselorsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final counselors = snapshot.data ?? [];

              final filtered = counselors.where((c) {
                final counselorId = c['id'] as String? ?? '';
                final isOnline = (c['is_online'] as bool? ?? false) || _onlinePresenceIds.contains(counselorId);
                final rawFaculty = c['faculty'] as String? ?? '';
                final facultyResolved = AcademicHelper.resolveFaculty(rawFaculty);

                // 1. Filter Sub-Kategori (Online vs Fakultas)
                if (state.selectedSubCategory == 0 && !isOnline) {
                  return false;
                }
                if (state.selectedSubCategory > 0 &&
                    !_matchesFaculty(rawFaculty, state.selectedSubCategory) &&
                    !_matchesFaculty(facultyResolved, state.selectedSubCategory)) {
                  return false;
                }

                // 2. Filter Search Query
                if (_searchQuery.isNotEmpty) {
                  final name = (c['nickname'] ?? c['full_name'] ?? '').toString().toLowerCase();
                  final faculty = facultyResolved.toLowerCase();
                  final topics = ((c['topics'] as List<dynamic>?) ?? []).map((e) => e.toString().toLowerCase()).toList();
                  final hobbies = ((c['hobbies'] as List<dynamic>?) ?? []).map((e) => e.toString().toLowerCase()).toList();

                  final matchName = name.contains(_searchQuery);
                  final matchFaculty = faculty.contains(_searchQuery);
                  final matchTopic = topics.any((t) => t.contains(_searchQuery));
                  final matchHobby = hobbies.any((h) => h.contains(_searchQuery));

                  if (!matchName && !matchFaculty && !matchTopic && !matchHobby) {
                    return false;
                  }
                }

                return true;
              }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_search_outlined,
                          size: 64,
                          color: AppColors.wisteriaNormal.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Konselor Tidak Ditemukan',
                          style: AppTextStyles.heading2.copyWith(
                            color: AppColors.twilightDarker,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Tidak ada konselor yang cocok dengan "$_searchQuery".'
                              : (state.selectedSubCategory == 0
                                  ? 'Belum ada konselor yang online saat ini.'
                                  : 'Belum ada konselor untuk fakultas ini.'),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.wisteriaNormalHover,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final c = filtered[index];
                  final topics = (c['topics'] as List<dynamic>?)
                          ?.map((e) => e.toString())
                          .toList() ??
                      const ['Umum'];
                  final hobbies = (c['hobbies'] as List<dynamic>?)
                          ?.map((e) => e.toString())
                          .toList() ??
                      const ['Mendengarkan'];

                  final counselorId = c['id'] as String? ?? '';
                  final isOnline = (c['is_online'] as bool? ?? false) || _onlinePresenceIds.contains(counselorId);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: CounselorCard(
                      counselorId: counselorId,
                      name: c['nickname'] ?? c['full_name'] ?? 'Konselor',
                      gender: c['gender'] ?? 'Perempuan',
                      faculty: AcademicHelper.resolveFaculty(c['faculty'] as String?),
                      tags: topics,
                      hobbies: hobbies,
                      isOnline: isOnline,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
