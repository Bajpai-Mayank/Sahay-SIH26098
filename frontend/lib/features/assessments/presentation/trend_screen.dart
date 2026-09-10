import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_section_header.dart';
import '../../../shared/widgets/responsive_scaffold.dart';

/// Longitudinal Trend Analysis View for Caseworkers.
class TrendScreen extends StatelessWidget {
  final String caseId;

  const TrendScreen({super.key, required this.caseId});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> trendData = [
      {'date': 'Sep 04', 'score': 45, 'level': 'MODERATE', 'color': AppColors.priorityModerate},
      {'date': 'Sep 06', 'score': 52, 'level': 'MODERATE', 'color': AppColors.priorityModerate},
      {'date': 'Sep 08', 'score': 64, 'level': 'HIGH', 'color': AppColors.priorityHigh},
      {'date': 'Sep 10', 'score': 72, 'level': 'HIGH', 'color': AppColors.priorityHigh},
    ];

    return ResponsiveScaffold(
      title: 'Well-being Trend: $caseId',
      currentRoute: '/counsellor',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Direction Overview Card
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.s10),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withAlpha(20),
                              borderRadius: BorderRadius.circular(AppRadius.small),
                            ),
                            child: const Icon(Icons.trending_up_rounded, color: AppColors.warning, size: 24),
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Trend Direction: INCREASING (Worsening)',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Support score rose from 45 to 72 (+27 pts) across 4 check-ins over the past week.',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s28),

                const AppSectionHeader(
                  title: 'Historical Check-in Data Points',
                  subtitle: 'Continuous record of calculated support priority scores.',
                ),
                const SizedBox(height: AppSpacing.s16),

                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: List.generate(trendData.length, (index) {
                      final pt = trendData[index];
                      final isLast = index == trendData.length - 1;
                      final color = pt['color'] as Color;

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(AppSpacing.s16),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primarySoft,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryDark),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.s14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pt['date'] as String,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Classification: ${pt['level']}',
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s10, vertical: AppSpacing.s4),
                                  decoration: BoxDecoration(
                                    color: color.withAlpha(20),
                                    borderRadius: BorderRadius.circular(AppRadius.small),
                                  ),
                                  child: Text(
                                    'Score: ${pt['score']}',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isLast) const Divider(height: 1, color: AppColors.border),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
