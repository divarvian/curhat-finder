import 'package:flutter/material.dart';
import 'package:curhat_finder/core/theme/app_colors.dart';
import 'package:curhat_finder/core/theme/app_text_styles.dart';

class RegisterThemeScope extends InheritedWidget {
  final bool isKonselor;

  const RegisterThemeScope({
    super.key,
    required this.isKonselor,
    required super.child,
  });

  static bool of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<RegisterThemeScope>();
    return scope?.isKonselor ?? false;
  }

  @override
  bool updateShouldNotify(RegisterThemeScope oldWidget) => isKonselor != oldWidget.isKonselor;
}

class RegisterStepTemplate extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget content;
  final bool isNextEnabled;
  final VoidCallback? onNext;
  final String buttonText;
  final bool? isKonselor;

  const RegisterStepTemplate({
    super.key,
    required this.title,
    this.subtitle,
    required this.content,
    required this.isNextEnabled,
    this.onNext,
    this.buttonText = "Lanjut",
    this.isKonselor,
  });

  @override
  Widget build(BuildContext context) {
    final konselorMode = isKonselor ?? RegisterThemeScope.of(context);
    final btnBg = konselorMode ? AppColors.counselorRegisterBtn : AppColors.twilightDarker;
    final btnDisabledBg = konselorMode
        ? AppColors.counselorRegisterBtn.withValues(alpha: 0.45)
        : AppColors.twilightDarker.withValues(alpha: 0.5);
    final btnTextColor = konselorMode ? AppColors.twilightNormal : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(
            title,
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.twilightDarker,
              height: 1.2,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.twilightNormal.withValues(alpha: 0.85),
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 32),
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                child: content,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isNextEnabled ? onNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: btnBg,
                disabledBackgroundColor: btnDisabledBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                buttonText,
                style: AppTextStyles.labelLarge.copyWith(
                  color: btnTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class RegisterTextField extends StatelessWidget {
  final String hint;
  final String value;
  final ValueChanged<String> onChanged;
  final TextInputType keyboardType;
  final int maxLength;

  const RegisterTextField({
    super.key,
    required this.hint,
    required this.value,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
    this.maxLength = 50,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      onChanged: onChanged,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: AppTextStyles.bodyLarge.copyWith(
        color: AppColors.twilightDarker,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.wisteriaNormal, width: 2),
        ),
      ),
    );
  }
}

class RegisterPillOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool? isKonselor;

  const RegisterPillOption({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isKonselor,
  });

  @override
  Widget build(BuildContext context) {
    final konselorMode = isKonselor ?? RegisterThemeScope.of(context);
    final selectedBg = konselorMode ? AppColors.counselorRegisterBtn : AppColors.wisteriaNormal;
    final selectedBorder = konselorMode ? AppColors.counselorRegisterBtn : AppColors.wisteriaNormal;
    final selectedTextColor = konselorMode ? AppColors.twilightNormal : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? selectedBorder : const Color(0xFFD9D9D9),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? selectedTextColor : AppColors.twilightDarker,
          ),
        ),
      ),
    );
  }
}
