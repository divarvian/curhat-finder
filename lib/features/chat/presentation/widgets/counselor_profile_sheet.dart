import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/config/router.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/counseling_service.dart';
import '../../domain/counseling_models.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

class CounselorProfileSheet extends ConsumerStatefulWidget {
  final String counselorId;
  final String name;
  final String gender;
  final String faculty;
  final List<String> topics;
  final List<String> hobbies;
  final String operationalHours;
  final bool isOnline;

  const CounselorProfileSheet({
    super.key,
    this.counselorId = '',
    required this.name,
    required this.gender,
    required this.faculty,
    required this.topics,
    required this.hobbies,
    required this.operationalHours,
    required this.isOnline,
  });

  @override
  ConsumerState<CounselorProfileSheet> createState() => _CounselorProfileSheetState();
}

class _CounselorProfileSheetState extends ConsumerState<CounselorProfileSheet> {
  CounselingSessionModel? _activeSession;
  String? _otherCounselorName;
  bool _isLoadingSession = true;

  @override
  void initState() {
    super.initState();
    _checkActiveSession();
  }

  void _checkActiveSession() async {
    try {
      final currentUserId = SupabaseService.currentUserId;
      if (currentUserId != null) {
        final session = await ref.read(counselingServiceProvider).getActiveSessionForStudent(currentUserId);
        if (session != null && mounted) {
          String? otherName;
          if (session.counselorId != widget.counselorId) {
            final profile = await ref.read(counselingServiceProvider).fetchCounselorProfile(session.counselorId);
            otherName = profile?['full_name'] as String? ?? profile?['nickname'] as String?;
          }
          if (mounted) {
            setState(() {
              _activeSession = session;
              _otherCounselorName = otherName;
              _isLoadingSession = false;
            });
          }
          return;
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isLoadingSession = false;
      });
    }
  }

  void _startCounselingFlow(BuildContext context) async {
    Navigator.pop(context); // Tutup sheet profil

    final currentUserId = SupabaseService.currentUserId;
    if (currentUserId == null) {
      // Jika belum login, buka langsung room demo
      ChatRoomRoute(counselorName: widget.name, isOnline: widget.isOnline, sessionId: 'demo').push(context);
      return;
    }

    // Tampilkan Waiting Dialog interaktif
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _CounselingQueueWaitingDialog(
          counselorId: widget.counselorId,
          counselorName: widget.name,
          faculty: widget.faculty,
          gender: widget.gender,
          topics: widget.topics,
          isOnline: widget.isOnline,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveSession = _activeSession != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: AppColors.platinum,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Avatar
          Stack(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.twilightNormal, width: 3),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/profile.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (widget.isOnline)
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent[400],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Identitas
          Text(
            '${widget.name} • ${widget.gender}',
            style: AppTextStyles.heading1.copyWith(
              color: AppColors.twilightDarker,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.lavenderBlush,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              widget.faculty,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.twilightDarker,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Topik Keahlian
          Text(
            'Topik Keahlian',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.twilightDarker,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: widget.topics.map((topic) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.twilightDarker,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  topic,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Jam Operasional
          Text(
            'Jam Operasional',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.twilightDarker,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.operationalHours,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.twilightDarker,
            ),
          ),
          const SizedBox(height: 32),

          // Banner Informasi jika konselor offline dan belum ada sesi aktif
          if (!hasActiveSession && !widget.isOnline && !_isLoadingSession)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.lavender.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.twilightNormal.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 20, color: AppColors.twilightDark),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Konselor sedang offline. Sesi baru hanya dapat dibuka saat konselor online. Silakan pilih konselor lain yang bertanda online.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.twilightDark,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Peringatan Sesi Aktif dengan Konselor Lain
          if (_activeSession != null && _activeSession!.counselorId != widget.counselorId) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.amber.shade800, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Kamu masih memiliki sesi konseling aktif bersama ${_otherCounselorName ?? "konselor lain"}. Selesaikan sesi tersebut untuk memulai sesi baru.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.amber.shade900,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // CTA Button
          SizedBox(
            width: double.infinity,
            child: _isLoadingSession
                ? ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : (_activeSession != null && _activeSession!.counselorId == widget.counselorId)
                    ? ElevatedButton.icon(
                        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
                        label: Text(
                          'Lanjutkan Sesi Konseling',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          ChatRoomRoute(
                            counselorName: widget.name,
                            isOnline: widget.isOnline,
                            sessionId: _activeSession!.id,
                          ).push(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A6B82), // Indigo Twilight tegas
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                      )
                    : (_activeSession != null && _activeSession!.counselorId != widget.counselorId)
                        ? ElevatedButton.icon(
                            icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                            label: Text(
                              'Kembali ke Sesi Aktif',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              ChatRoomRoute(
                                counselorName: _otherCounselorName ?? 'Konselor Sebaya',
                                isOnline: true,
                                sessionId: _activeSession!.id,
                              ).push(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A6B82),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                          )
                        : widget.isOnline
                            ? ElevatedButton(
                                onPressed: () => _startCounselingFlow(context),
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
                                  'Mulai melakukan konseling',
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[300],
                                  disabledBackgroundColor: Colors.grey[300],
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Konselor Sedang Offline',
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
  }
}

class _CounselingQueueWaitingDialog extends ConsumerStatefulWidget {
  final String counselorId;
  final String counselorName;
  final String faculty;
  final String gender;
  final List<String> topics;
  final bool isOnline;

  const _CounselingQueueWaitingDialog({
    required this.counselorId,
    required this.counselorName,
    required this.faculty,
    required this.gender,
    required this.topics,
    required this.isOnline,
  });

  @override
  ConsumerState<_CounselingQueueWaitingDialog> createState() =>
      _CounselingQueueWaitingDialogState();
}

class _CounselingQueueWaitingDialogState
    extends ConsumerState<_CounselingQueueWaitingDialog> {
  StreamSubscription? _queueSub;
  String? _queueId;
  bool _isNavigated = false;
  int _remainingSeconds = 60;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _submitQueue();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 1) {
        if (mounted) {
          setState(() {
            _remainingSeconds--;
          });
        }
      } else {
        timer.cancel();
        _handleTimeout();
      }
    });
  }

  void _handleTimeout() async {
    if (!mounted || _isNavigated) return;
    _isNavigated = true;
    _queueSub?.cancel();
    final qId = _queueId;
    Navigator.of(context).pop();

    if (qId != null) {
      await ref.read(counselingServiceProvider).cancelQueue(qId);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konselor belum sempat merespons. Antrean telah dibatalkan.'),
        ),
      );
    }
  }

  void _submitQueue() async {
    final currentUserId = SupabaseService.currentUserId;
    if (currentUserId == null) return;

    final service = ref.read(counselingServiceProvider);
    final student = ref.read(profileProvider);
    try {
      final queue = await service.requestCounseling(
        studentId: currentUserId,
        counselorId: widget.counselorId,
        studentAlias: student.name.isNotEmpty ? student.name : 'Mahasiswa',
        studentGender: student.gender.isNotEmpty ? student.gender : 'Perempuan',
        studentFaculty: student.faculty.isNotEmpty ? student.faculty : 'FILKOM',
        preferredTopic: widget.topics.isNotEmpty ? widget.topics.first : 'Umum',
      );
      _queueId = queue.id;

      // Dengarkan perubahan status antrean secara realtime
      _queueSub = service.streamStudentQueue(currentUserId).listen((rows) async {
        if (!mounted || _isNavigated) return;
        final matching = rows.firstWhere(
          (r) => r['id'] == _queueId,
          orElse: () => {},
        );

        if (matching['status'] == 'accepted') {
          _isNavigated = true;
          _queueSub?.cancel();
          _countdownTimer?.cancel();
          Navigator.of(context).pop(); // Tutup dialog

          // Ambil session_id langsung dari payload realtime (yang sudah diisi atomik)
          final directSessionId = matching['session_id'] as String?;
          final realSessionId = directSessionId ??
              await ref.read(counselingServiceProvider).getSessionIdByQueueId(_queueId ?? '');

          if (mounted) {
            ChatRoomRoute(
              counselorName: widget.counselorName,
              isOnline: widget.isOnline,
              sessionId: realSessionId ?? _queueId ?? '',
            ).push(context);
          }
        }
      });
    } catch (e) {
      if (mounted) {
        _isNavigated = true;
        _countdownTimer?.cancel();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('offline')
                  ? 'Konselor sedang offline dan tidak menerima antrean baru.'
                  : (e.toString().contains('masih memiliki sesi')
                      ? 'Kamu masih memiliki sesi konseling aktif yang sedang berjalan.'
                      : 'Gagal mengajukan antrean. Silakan coba kembali.'),
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _queueSub?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          _isNavigated = true;
          _queueSub?.cancel();
          _countdownTimer?.cancel();
          final qId = _queueId;
          Navigator.of(context).pop();
          if (qId != null) {
            await ref.read(counselingServiceProvider).cancelQueue(qId);
          }
        }
      },
      child: AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: Color(0xFFF88A8A),
                strokeWidth: 3,
              ),
              const SizedBox(height: 24),
              Text(
                'Menghubungkan ke ${widget.counselorName}...',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.twilightDarker,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Permintaan konseling kamu sedang dikirimkan ke konselor. Menunggu konfirmasi (${_remainingSeconds}d)...',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.wisteriaNormal,
                  fontSize: 13,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.twilightNormal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  _isNavigated = true;
                  _queueSub?.cancel();
                  _countdownTimer?.cancel();
                  final qId = _queueId;
                  Navigator.of(context).pop();
                  if (qId != null) {
                    await ref.read(counselingServiceProvider).cancelQueue(qId);
                  }
                },
                child: const Text('Batalkan Antrean'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
