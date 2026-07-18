import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../auth/view_models/auth_notifier.dart';
import '../../../../core/theme/app_text_styles.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.watch<AuthNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthNotifier>().logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_circle_outlined,
                size: 100,
                color: Colors.blueGrey,
              ),
              const SizedBox(height: 24),
              Text(
                'Selamat Datang,',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '${authNotifier.username}',
                style: AppTextStyles.heading1,
              ),
              const SizedBox(height: 8),
              Text(
                '${authNotifier.email}',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  context.read<AuthNotifier>().logout();
                  context.go('/login');
                },
                child: const Text('Keluar Akun'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
