import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_text_styles.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Komparasi State Management'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Pilih State Management',
                style: AppTextStyles.heading2,
              ),
              const SizedBox(height: 8),
              Text(
                'Tekan salah satu tombol di bawah untuk melihat contoh implementasi fitur Counter menggunakan framework yang berbeda.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 24),
              _buildSelectorCard(
                context,
                title: 'Provider',
                description: 'Pendekatan state management klasik yang direkomendasikan secara resmi oleh tim Flutter.',
                icon: Icons.unfold_more_outlined,
                routePath: '/provider',
                color: Colors.blue.shade700,
              ),
              const SizedBox(height: 16),
              _buildSelectorCard(
                context,
                title: 'Riverpod',
                description: 'State management modern tanpa dependensi BuildContext, aman terhadap compile-time.',
                icon: Icons.water_drop_outlined,
                routePath: '/riverpod',
                color: Colors.teal.shade700,
              ),
              const SizedBox(height: 16),
              _buildSelectorCard(
                context,
                title: 'BLoC / Cubit',
                description: 'Arsitektur berbasis event-driven untuk memisahkan logika bisnis dari UI secara ketat.',
                icon: Icons.layers_outlined,
                routePath: '/bloc',
                color: Colors.purple.shade700,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectorCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required String routePath,
    required Color color,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => context.push(routePath),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.heading3.copyWith(color: color),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
