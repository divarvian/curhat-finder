import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/bloc_counter_cubit.dart';
import '../../../../core/theme/app_text_styles.dart';

class BlocCounterView extends StatelessWidget {
  const BlocCounterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter BLoC / Cubit'),
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
              BlocBuilder<BlocCounterCubit, int>(
                builder: (context, count) {
                  return Text(
                    '$count',
                    style: AppTextStyles.heading1.copyWith(fontSize: 72),
                  );
                },
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => context.read<BlocCounterCubit>().decrement(),
                    child: const Icon(Icons.remove),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => context.read<BlocCounterCubit>().increment(),
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => context.read<BlocCounterCubit>().reset(),
                child: const Text('Reset Counter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
