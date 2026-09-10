import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

/// Clean vertical timeline item with connecting spine, icon bubble, and metadata.
class TimelineItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String date;
  final IconData icon;
  final Color iconColor;
  final Color? iconBackgroundColor;
  final bool isLast;

  const TimelineItem({
    super.key,
    required this.title,
    this.subtitle,
    required this.date,
    this.icon = Icons.check_circle_outline_rounded,
    this.iconColor = AppColors.primary,
    this.iconBackgroundColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Spine + circle indicator
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBackgroundColor ?? iconColor.withAlpha(20),
                shape: BoxShape.circle,
                border: Border.all(color: iconColor.withAlpha(120), width: 1.2),
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 54,
                color: AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: AppSpacing.s16),

        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    Text(
                      date,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
