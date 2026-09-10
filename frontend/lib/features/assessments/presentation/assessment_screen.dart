import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/models/support_priority.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/priority_badge.dart';
import '../../../shared/widgets/responsive_scaffold.dart';

/// Assessment Overview Screen for Caseworkers.
/// Displays AI-derived support-priority assessments with explicit evidence reasoning.
class AssessmentScreen extends StatelessWidget {
  final String caseId;

  const AssessmentScreen({super.key, required this.caseId});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Assessments: $caseId',
      currentRoute: '/counsellor',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const PriorityBadge(priority: SupportPriority.high),
                      Text(
                        'Support Score: 72/100',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  Text(
                    'Automated Support Priority Engine Output',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Assessed: Today at 02:15 PM · Engine: Mock AI Provider v1.0 · Advisory Only',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.s20),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: AppSpacing.s16),
                  Text(
                    'Evidence Breakdown (Non-Clinical Signals):',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  const _EvidenceRow(
                    label: 'Distress Rating',
                    value: '4/5 (Self-reported check-in)',
                    icon: Icons.person_outline_rounded,
                  ),
                  const _EvidenceRow(
                    label: 'Sleep Disruption',
                    value: '3 consecutive days with score ≤ 2',
                    icon: Icons.bedtime_outlined,
                  ),
                  const _EvidenceRow(
                    label: 'Natural Language Cues',
                    value: 'Fear markers detected (Confidence 0.81)',
                    icon: Icons.chat_outlined,
                  ),
                  const _EvidenceRow(
                    label: 'Longitudinal Slope',
                    value: '+18% distress increase over 7 days',
                    icon: Icons.trending_up_rounded,
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

class _EvidenceRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _EvidenceRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.s12),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
