import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/config/router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/register_controller.dart';
import '../providers/auth_provider.dart';
import '../../../counselor/domain/counselor_model.dart';
import '../../../counselor/presentation/providers/counselor_provider.dart';
import '../../../profile/domain/user_profile_model.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../widgets/register_steps/register_steps_basic.dart';
import '../widgets/register_steps/register_steps_academic.dart';
import '../widgets/register_steps/register_steps_final.dart';
import '../../../../core/utils/academic_helper.dart';

class RegisterView extends ConsumerStatefulWidget {
  final bool isKonselor;
  const RegisterView({super.key, this.isKonselor = false});

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final PageController _pageController = PageController();
  final int _totalSteps = 7;

  void _nextStep() {
    final state = ref.read(registerControllerProvider);
    if (state.currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      ref.read(registerControllerProvider.notifier).nextStep(_totalSteps);
    } else {
      _submitForm();
    }
  }

  void _prevStep() {
    final state = ref.read(registerControllerProvider);
    if (state.currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      ref.read(registerControllerProvider.notifier).previousStep();
    } else {
      context.pop();
    }
  }

  void _submitForm() async {
    final registerCtrl = ref.read(registerControllerProvider.notifier);
    final state = ref.read(registerControllerProvider);
    final role = widget.isKonselor ? 'konselor' : 'mahasiswa';
    final cleanName = state.nickname.isNotEmpty ? state.nickname : state.fullName;
    final fallbackEmail = '${cleanName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '')}@student.ub.ac.id';

    final email = registerCtrl.inputEmail.isNotEmpty ? registerCtrl.inputEmail : fallbackEmail;
    final password = registerCtrl.inputPassword.isNotEmpty ? registerCtrl.inputPassword : 'password123';

    // Tampilkan loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(color: AppColors.twilightDarker),
      ),
    );

    final facultyName = AcademicHelper.resolveFaculty(state.facultyId);
    final prodiName = AcademicHelper.resolveProdi(state.prodiId);

    final success = await ref.read(authProvider.notifier).register(
      email: email,
      password: password,
      role: role,
      fullName: state.fullName.isNotEmpty ? state.fullName : 'Pengguna Baru',
      nickname: state.nickname.isNotEmpty ? state.nickname : cleanName,
      gender: state.gender.isNotEmpty ? state.gender : 'Lainnya',
      batchYear: state.batch.isNotEmpty ? state.batch : '2025',
      faculty: facultyName,
      studyProgram: prodiName,
      hobbies: state.hobbies.toList(),
      topics: state.topics.toList(),
    );

    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop(); // Tutup loading dialog
    }

    if (!success) {
      if (mounted) {
        final err = ref.read(authProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err ?? 'Pendaftaran gagal. Silakan periksa kembali data Anda.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    // Perbarui state profil seketika agar Beranda dan Profil langsung menampilkan data yang diinput
    final hobbiesList = state.hobbies.toList();
    final topicsList = state.topics.toList();

    if (widget.isKonselor) {
      ref.read(counselorProvider.notifier).updateProfile(
        CounselorProfile(
          name: state.nickname.isNotEmpty ? state.nickname : state.fullName,
          email: email,
          faculty: facultyName,
          studyProgram: prodiName,
          batchYear: state.batch.isNotEmpty ? state.batch : '2025',
          gender: state.gender.isNotEmpty ? state.gender : 'Perempuan',
          role: 'Konselor',
          avatarPath: 'assets/images/mascot.png',
          topics: topicsList.isNotEmpty ? topicsList : ['Anxiety', 'Stres', 'Burnout'],
          isOnline: true,
          activeSessions: 0,
          totalHelped: 0,
          responseTime: '5m',
        ),
      );
      ref.read(counselorProvider.notifier).initializeSupabaseSync();
    } else {
      ref.read(profileProvider.notifier).updateProfile(
        UserProfile(
          name: state.nickname.isNotEmpty ? state.nickname : state.fullName,
          role: 'Mahasiswa',
          email: email,
          faculty: facultyName,
          studyProgram: prodiName,
          batchYear: state.batch.isNotEmpty ? state.batch : '2025',
          gender: state.gender.isNotEmpty ? state.gender : 'Perempuan',
          hobby: hobbiesList.isNotEmpty ? hobbiesList.join(', ') : 'Belum diisi',
          avatarPath: 'assets/images/mascot.png',
        ),
      );
      ref.read(profileProvider.notifier).reloadProfile();
    }

    if (!mounted) return;

    // Redirect to respective main nav
    if (widget.isKonselor) {
      const CounselorPendingRoute().go(context);
    } else {
      const MainRoute().go(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Latar Belakang Glowing
        Positioned.fill(
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: AppColors.background,
            body: Stack(
              children: [
                Positioned(
                  top: -150,
                  left: -50,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                    child: Container(
                      width: 350,
                      height: 350,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFFB6C1), // Soft Pink Glow
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -100,
                  left: -100,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.wisteriaNormal, // Periwinkle Blue Glow
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Konten Utama
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildProgressBar(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      StepFullName(onNext: _nextStep),
                      StepNickname(onNext: _nextStep),
                      StepGender(onNext: _nextStep),
                      StepBatch(onNext: _nextStep),
                      StepFaculty(onNext: _nextStep),
                      StepProdi(onNext: _nextStep),
                      StepFinal(isKonselor: widget.isKonselor, onNext: _nextStep),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, right: 32.0, top: 16.0, bottom: 8.0),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _prevStep,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.arrow_back_ios_new, color: AppColors.twilightDarker, size: 22),
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Register',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.twilightDarker,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 30), // 32 (kanan) + 30 = 62px = 24 (kiri) + 38 (lebar tombol). Membuat teks benar-benar di tengah layar.
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final state = ref.watch(registerControllerProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(_totalSteps, (index) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index == _totalSteps - 1 ? 0 : 8.0),
                  height: 4,
                  decoration: BoxDecoration(
                    color: index <= state.currentStep ? const Color(0xFF4A6B9C) : const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            'Langkah - ${state.currentStep + 1}',
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 10,
              color: AppColors.wisteriaNormal,
            ),
          ),
        ],
      ),
    );
  }
}
