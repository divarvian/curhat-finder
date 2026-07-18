import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/provider_counter_notifier.dart';
import '../../../../core/theme/app_text_styles.dart';

class ProviderCounterView extends StatelessWidget {
  const ProviderCounterView({super.key});

  @override
  Widget build(BuildContext context) {
    final counterNotifier = context.watch<ProviderCounterNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter Provider'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Nilai Counter Saat Ini:',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 12),
              Text(
                '${counterNotifier.count}',
                style: AppTextStyles.heading1.copyWith(fontSize: 72),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: counterNotifier.decrement,
                    child: const Icon(Icons.remove),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: counterNotifier.increment,
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: counterNotifier.reset,
                child: const Text('Reset Counter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
