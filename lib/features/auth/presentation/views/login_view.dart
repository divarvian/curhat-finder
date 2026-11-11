import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/config/router.dart';
import '../controllers/register_controller.dart';
import '../providers/auth_provider.dart';
import '../../../counselor/presentation/providers/counselor_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/ub_email_validator.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    // Tutup keyboard secara bersih sebelum proses verifikasi & navigasi
    FocusManager.instance.primaryFocus?.unfocus();
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final rawInput = _emailController.text.trim();
    final password = _passwordController.text;
    final formattedEmail = UbEmailValidator.formatLoginEmail(rawInput);

    if (!UbEmailValidator.isUbEmail(formattedEmail)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(UbEmailValidator.invalidDomainMessage),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // 1. Cek apakah akun sudah terdaftar di Supabase
    final exists = await ref.read(authProvider.notifier).checkUserExists(formattedEmail);
    if (!mounted) return;

    if (!exists) {
      // Simpan kredensial ke registerController agar digunakan saat registrasi
      ref.read(registerControllerProvider.notifier).setCredentials(
        email: formattedEmail,
        password: password,
      );

      // Pastikan keyboard tertutup sebelum berpindah halaman
      FocusManager.instance.primaryFocus?.unfocus();
      FocusScope.of(context).unfocus();

      // Akun belum terdaftar: Otomatis arahkan ke alur pemilihan peran dan pendaftaran
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akun belum terdaftar. Silakan pilih peran dan lengkapi profil kamu.'),
          backgroundColor: AppColors.twilightDarker,
          duration: Duration(seconds: 3),
        ),
      );
      const RoleRoute().go(context);
      return;
    }

    // 2. Jika akun sudah ada, lakukan verifikasi kata sandi (login)
    final success = await ref.read(authProvider.notifier).login(formattedEmail, password);
    if (!mounted) return;

    if (success) {
      final auth = ref.read(authProvider);
      if (auth.role == 'konselor') {
        await ref.read(counselorProvider.notifier).initializeSupabaseSync();
        if (!mounted) return;
        if (auth.isVerified) {
          const CounselorMainRoute().go(context);
        } else {
          const CounselorPendingRoute().go(context);
        }
      } else {
        await ref.read(profileProvider.notifier).reloadProfile();
        if (!mounted) return;
        const MainRoute().go(context);
      }
    } else {
      final auth = ref.read(authProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Password yang kamu masukkan salah. Silakan coba lagi.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // Widget Kustom untuk TextField
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hintText,
    FocusNode? focusNode,
    void Function(String)? onFieldSubmitted,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDF0F0), // Warna soft pink muda (seperti di mockup)
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04), // Bayangan sangat lembut
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        onFieldSubmitted: onFieldSubmitted,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.twilightDarker),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.twilightNormal.withValues(alpha: 0.6)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          suffixIcon: suffixIcon,
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Stack(
      children: [
        // Lapisan Latar Belakang Tetap (Tidak ikut naik saat keyboard muncul)
        Positioned.fill(
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: AppColors.background,
            body: Stack(
              children: [
                // Latar Belakang Glowing Pink (Kiri Atas)
                Positioned(
                  top: -150,
                  left: -100,
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
                
                // Latar Belakang Glowing Biru (Kiri Bawah)
                Positioned(
                  bottom: -50,
                  left: -100,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                    child: Container(
                      width: 250,
                      height: 250,
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

        // Lapisan Konten Utama (Berjalan di atas latar belakang, bisa di-scroll saat keyboard naik)
        Scaffold(
          backgroundColor: Colors.transparent, // Tembus pandang agar latar terlihat
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Bagian Isi Form (Rata Kiri)
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Selamat Datang !',
                            style: AppTextStyles.displaySmall.copyWith(
                              color: AppColors.twilightDarker,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Masuk menggunakan akun siam kamu yaa~',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.twilightNormal,
                            ),
                          ),
                          const SizedBox(height: 40),

                          _buildCustomTextField(
                            controller: _emailController,
                            hintText: 'Email/Username',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
                            validator: UbEmailValidator.validateLoginInput,
                          ),
                          const SizedBox(height: 24),

                          _buildCustomTextField(
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            hintText: 'Password',
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _handleLogin(),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: AppColors.twilightNormal.withValues(alpha: 0.6),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 40),

                          // Tombol Masuk
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7D1D4), // Soft kemerahan sedikit lebih gelap dari field
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04), // Bayangan lembut
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(24),
                                onTap: authState.isLoading ? null : _handleLogin,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                                  child: Center(
                                    child: authState.isLoading
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.twilightDarker,
                                            ),
                                          )
                                        : Text(
                                            'Masuk',
                                            style: AppTextStyles.labelLarge.copyWith(
                                              color: AppColors.twilightDarker,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Footer Syarat & Ketentuan
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.twilightNormal,
                          fontSize: 12, // Teks sedikit lebih kecil
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(text: 'Dengan masuk atau mendaftar, Anda menyetujui\nKetentuan '),
                          TextSpan(
                            text: 'Layanan',
                            style: const TextStyle(color: AppColors.wisteriaNormal), // Warna biru muda
                            recognizer: TapGestureRecognizer()..onTap = () {},
                          ),
                          const TextSpan(text: ' dan '),
                          TextSpan(
                            text: 'Kebijakan Privasi',
                            style: const TextStyle(color: AppColors.wisteriaNormal), // Warna biru muda
                            recognizer: TapGestureRecognizer()..onTap = () {},
                          ),
                          const TextSpan(text: ' kami.'),
                        ],
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
    );
  }
}
