import 'package:flutter/material.dart';
import 'package:curhat_finder/core/theme/app_colors.dart';
import 'package:curhat_finder/core/theme/app_text_styles.dart';
import 'package:curhat_finder/core/widgets/app_avatar.dart';
import 'package:curhat_finder/core/widgets/app_pill.dart';
import '../counselor_profile_sheet.dart';

/// Widget Kartu Konselor Mandiri untuk Tab SupportBuddy
class CounselorCard extends StatelessWidget {
  final String counselorId;
  final String? avatarUrl;
  final String name;
  final String gender;
  final String faculty;
  final List<String> tags;
  final List<String> hobbies;
  final bool isOnline;

  const CounselorCard({
    super.key,
    this.counselorId = '',
    this.avatarUrl,
    required this.name,
    required this.gender,
    required this.faculty,
    required this.tags,
    required this.hobbies,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => CounselorProfileSheet(
            counselorId: counselorId,
            avatarUrl: avatarUrl,
            name: name,
            gender: gender,
            faculty: faculty,
            topics: tags,
            hobbies: hobbies,
            operationalHours: 'Senin - Jum\'at, 18.00 - 21.00 WIB',
            isOnline: isOnline,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppAvatar(
                  imageUrl: avatarUrl,
                  size: 52,
                  isOnline: isOnline,
                  showOnlineBadge: isOnline,
                  badgeSize: 14,
                  badgeBorderWidth: 2,
                  border: Border.all(color: AppColors.twilightNormal, width: 2),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$name • $gender',
                        style: AppTextStyles.heading2.copyWith(
                          color: AppColors.twilightDarker,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        faculty,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.wisteriaNormalHover,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTopicRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicRow() {
    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.maxWidth.isFinite) {
          final fallbackTopics = tags.take(3).toList();
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < fallbackTopics.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                AppPill(
                  label: fallbackTopics[i],
                  backgroundColor: AppColors.twilightDarker,
                  textColor: Colors.white,
                  borderColor: Colors.transparent,
                  borderWidth: 0,
                  fontSize: 11,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ],
            ],
          );
        }

        final maxWidth = constraints.maxWidth;
        final visible = <String>[];
        double currentWidth = 0;

        const TextStyle textStyle = TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          height: 1.0,
        );

        for (final tag in tags) {
          final painter = TextPainter(
            text: TextSpan(text: tag, style: textStyle),
            maxLines: 1,
            textDirection: TextDirection.ltr,
          )..layout();

          // 24 is horizontal padding (12 left + 12 right). Add 2px safety margin.
          final itemWidth = painter.size.width + 26;
          final nextWidth = visible.isEmpty ? itemWidth : currentWidth + 8 + itemWidth;

          if (nextWidth <= maxWidth) {
            visible.add(tag);
            currentWidth = nextWidth;
          } else {
            if (visible.isEmpty) {
              visible.add(tag);
            }
            break;
          }
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < visible.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Flexible(
                child: AppPill(
                  label: visible[i],
                  backgroundColor: AppColors.twilightDarker,
                  textColor: Colors.white,
                  borderColor: Colors.transparent,
                  borderWidth: 0,
                  fontSize: 11,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
