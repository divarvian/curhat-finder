import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/config/router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/anon_chat_service.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

class ChatAnonMatchingView extends ConsumerStatefulWidget {
  final String mode;

  const ChatAnonMatchingView({
    super.key,
    this.mode = 'Cuma mau didengar',
  });

  @override
  ConsumerState<ChatAnonMatchingView> createState() => _ChatAnonMatchingViewState();
}

class _ChatAnonMatchingViewState extends ConsumerState<ChatAnonMatchingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Timer? _countdownTimer;
  StreamSubscription? _sessionSubscription;
  String? _currentSessionId;
  int _secondsRemaining = 15;
  bool _isCancelled = false;
  bool _hasNavigated = false;
  bool _isTimeout = false;
  bool _isConnectingToBot = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _startMatchmaking();
  }

  void _startMatchmaking() async {
    final anonService = ref.read(anonChatServiceProvider);
    final userProfile = ref.read(profileProvider);
    final userAlias = 'Mahasiswa ${userProfile.gender == 'Laki-laki' ? 'Bro' : 'Sis'}';

    try {
      final matchResult = await anonService.joinMatchmaking(
        mode: widget.mode,
        userAlias: userAlias,
      );

      if (_isCancelled || !mounted) return;
      _currentSessionId = matchResult.sessionId;

      // Skenario 1: Langsung dapat partner sebagai joiner (matched == true)
      if (matchResult.matched) {
        _navigateToRoom(matchResult.sessionId);
        return;
      }

      // Skenario 2: Masuk antrean sebagai creator, dengarkan perubahan sesi realtime
      _listenToSessionChanges(matchResult.sessionId);
      _startCountdownTimer(matchResult.sessionId);
    } catch (_) {
      // Fallback jika offline/kendala lokal: tetap hitung mundur lalu beri pilihan
      _currentSessionId = 'local-session';
      _startCountdownTimer('local-session');
    }
  }

  void _listenToSessionChanges(String sessionId) {
    final anonService = ref.read(anonChatServiceProvider);
    _sessionSubscription?.cancel();
    _sessionSubscription = anonService.streamSession(sessionId).listen((session) {
      if (session != null && session.user2Id != null && session.isActive) {
        _navigateToRoom(sessionId);
      }
    });
  }

  void _startCountdownTimer(String sessionId) {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isCancelled || !mounted) {
        timer.cancel();
        return;
      }

      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        _handleTimeout();
      }
    });
  }

  void _handleTimeout() {
    if (_hasNavigated || _isCancelled || !mounted) return;
    _countdownTimer?.cancel();
    _animationController.stop();
    setState(() {
      _isTimeout = true;
      _secondsRemaining = 0;
    });
  }

  Future<void> _handleStartBotChat() async {
    if (_isConnectingToBot || _hasNavigated || !mounted) return;
    setState(() {
      _isConnectingToBot = true;
    });
    final sessionId = _currentSessionId ?? 'local-session';
    await _switchToCompanionFallback(sessionId);
  }

  void _handleRetryMatchmaking() {
    if (_currentSessionId != null && _currentSessionId != 'local-session') {
      ref.read(anonChatServiceProvider).cancelMatchmaking(_currentSessionId!);
    }
    _currentSessionId = null;
    _sessionSubscription?.cancel();
    _countdownTimer?.cancel();
    setState(() {
      _isTimeout = false;
      _secondsRemaining = 15;
      _isConnectingToBot = false;
    });
    _animationController.repeat();
    _startMatchmaking();
  }

  Future<void> _switchToCompanionFallback(String sessionId) async {
    if (_hasNavigated || _isCancelled || !mounted) return;
    final anonService = ref.read(anonChatServiceProvider);
    await anonService.enableCompanionFallback(sessionId, widget.mode);
    if (_isCancelled || !mounted) return;
    _navigateToRoom(sessionId);
  }

  void _navigateToRoom(String sessionId) {
    if (_hasNavigated || _isCancelled || !mounted) return;
    _hasNavigated = true;
    _countdownTimer?.cancel();
    _sessionSubscription?.cancel();
    ChatAnonRoomRoute(sessionId: sessionId, mode: widget.mode).replace(context);
  }

  void _handleCancel() {
    _isCancelled = true;
    _countdownTimer?.cancel();
    _sessionSubscription?.cancel();

    if (_currentSessionId != null && !_hasNavigated && _currentSessionId != 'local-session') {
      ref.read(anonChatServiceProvider).cancelMatchmaking(_currentSessionId!);
    }

    context.pop();
  }

  @override
  void dispose() {
    _isCancelled = true;
    _countdownTimer?.cancel();
    _sessionSubscription?.cancel();

    if (_currentSessionId != null && !_hasNavigated && _currentSessionId != 'local-session') {
      ref.read(anonChatServiceProvider).cancelMatchmaking(_currentSessionId!);
    }

    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleCancel();
      },
      child: Scaffold(
        backgroundColor: AppColors.platinum,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 8),
                child: Center(
                  child: Text(
                    'Chat',
                    style: AppTextStyles.heading1.copyWith(
                      color: AppColors.twilightDarker,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              Center(
                child: Text(
                  'Pilih cara cerita yang paling nyaman buat kamu.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.twilightNormal,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Chips visual
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStaticChip('SupportBuddy', false),
                  const SizedBox(width: 8),
                  _buildStaticChip('Rooms', false),
                  const SizedBox(width: 8),
                  _buildStaticChip('Chat Anon', true),
                ],
              ),
              const SizedBox(height: 8),

              // Content: Switch between Searching & Timeout
              Expanded(
                child: _isTimeout ? _buildTimeoutState() : _buildSearchingState(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchingState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const Spacer(),
                  // Animasi Radar
                  SizedBox(
                    height: 260,
                    width: 260,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _buildRadarCircle(260, 0.0),
                        _buildRadarCircle(195, 0.33),
                        _buildRadarCircle(130, 0.66),

                        // Mascot di tengah
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.twilightDarker.withValues(alpha: 0.15),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/profile.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Teks Status & Countdown
                  Text(
                    'Mencari partner ngobrol...',
                    style: AppTextStyles.heading1.copyWith(
                      color: AppColors.twilightDarker,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Menghubungkan dalam $_secondsRemaining detik',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.redNormalHover,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Menghubungkanmu secara anonim dengan sesama mahasiswa UB (${widget.mode})',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.wisteriaNormalHover,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tombol Tindakan
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Opsi Langsung Ngobrol dengan Teman Virtual
                        if (_currentSessionId != null)
                          TextButton.icon(
                            onPressed: _isConnectingToBot ? null : _handleStartBotChat,
                            icon: const Icon(Icons.psychology_alt_outlined, size: 20, color: AppColors.twilightDarker),
                            label: Text(
                              'Mulai dengan Teman Virtual sekarang',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.twilightDarker,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        // Tombol Batal
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _handleCancel,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.twilightDarker,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Batalkan',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeoutState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          // Ikon Status
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.lavenderBlush,
              border: Border.all(
                color: AppColors.redNormalHover.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person_search_rounded,
              size: 38,
              color: AppColors.redNormalHover,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Menemukan Partner',
            style: AppTextStyles.heading1.copyWith(
              color: AppColors.twilightDarker,
              fontSize: 22,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Belum ada mahasiswa lain yang sedang aktif mencari teman cerita di mode "${widget.mode}" saat ini. Tapi jangan khawatir, kamu tetap bisa bercerita!',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.twilightNormal,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Kartu Teman Virtual (Bot AI) dengan Penjelasan Transparan
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.redNormalHover.withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.twilightDarker.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.lavenderBlush,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: AppColors.redNormalHover.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.smart_toy_rounded, size: 14, color: AppColors.redNormalHover),
                          const SizedBox(width: 4),
                          Text(
                            'BOT AI OTOMATIS',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.redNormalHover,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Tersedia 24/7',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.twilightDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Ngobrol dengan Teman Virtual',
                  style: AppTextStyles.heading2.copyWith(
                    fontSize: 16,
                    color: AppColors.twilightDarker,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Asisten AI kami siap mendengarkan semua curhatmu kapan saja tanpa menghakimi, dengan respons hangat, empati, dan solutif.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.twilightDark,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isConnectingToBot ? null : _handleStartBotChat,
                    icon: _isConnectingToBot
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                    label: Text(
                      _isConnectingToBot ? 'Menghubungkan...' : 'Mulai Ngobrol dengan Teman Virtual',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.twilightDarker,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tombol Coba Cari Lagi
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isConnectingToBot ? null : _handleRetryMatchmaking,
              icon: const Icon(Icons.refresh_rounded, size: 18, color: AppColors.twilightDarker),
              label: Text(
                'Coba Cari Teman Mahasiswa Lagi',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.twilightDarker,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.twilightNormal.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Tombol Kembali
          TextButton(
            onPressed: _isConnectingToBot ? null : _handleCancel,
            child: Text(
              'Kembali ke Menu Chat',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.twilightDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStaticChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.lavenderBlush : Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: isSelected ? AppColors.redNormalHover : AppColors.twilightLight,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(
          color: isSelected ? AppColors.twilightDarker : AppColors.twilightDark,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRadarCircle(double size, double delay) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final progress = (_animationController.value + delay) % 1.0;
        final opacity = (1.0 - progress).clamp(0.0, 1.0);
        
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.wisteriaNormal.withValues(alpha: opacity * 0.7),
              width: 2,
            ),
          ),
        );
      },
    );
  }
}
