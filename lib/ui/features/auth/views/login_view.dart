import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../view_models/auth_notifier.dart';
import '../../../../core/theme/app_text_styles.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authNotifier = context.read<AuthNotifier>();
      final success = await authNotifier.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        if (success) {
          context.go('/dashboard');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authNotifier.errorMessage ?? 'Email atau password salah. Coba lagi.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.watch<AuthNotifier>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Hero(
                    tag: 'app-logo',
                    child: Image.asset(
                      'assets/icons/icon_launcher.png',
                      height: 100,
                      width: 100,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Masuk Akun',
                    style: AppTextStyles.heading2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gunakan email dan kata sandi Anda untuk mengakses dashboard.',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'nama@email.com',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email wajib diisi';
                      }
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'Format email tidak valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'Kata Sandi',
                      hintText: 'Minimal 6 karakter',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
                        return 'Kata sandi wajib diisi';
                      }
                      if (value.length < 6) {
                        return 'Kata sandi minimal 6 karakter';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _handleLogin(),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: authNotifier.isLoading ? null : _handleLogin,
                    child: authNotifier.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Masuk'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Belum punya akun? ',
                        style: AppTextStyles.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () => context.push('/register'),
                        child: Text(
                          'Daftar di sini',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
