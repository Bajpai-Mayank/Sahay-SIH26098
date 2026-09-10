import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/models/support_priority.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_section_header.dart';
import '../../../shared/widgets/priority_badge.dart';
import '../../../shared/widgets/responsive_scaffold.dart';

/// Detailed Case Inspection View for Counsellors.
/// Transparent evidence contributions, clear advisory boundary, direct casework action triggers.
class CaseDetailScreen extends StatelessWidget {
  final String caseId;

  const CaseDetailScreen({super.key, required this.caseId});

  @override
  Widget build(BuildContext context) {
    const priority = SupportPriority.high;

    return ResponsiveScaffold(
      title: 'Case File: $caseId',
      currentRoute: '/counsellor',
      actions: [
        IconButton(
          icon: const Icon(Icons.history_rounded, size: 20),
          tooltip: 'View Case Timeline',
          onPressed: () => context.push('/counsellor/cases/$caseId/timeline'),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Support Priority Summary Card
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const PriorityBadge(priority: priority),
                          Text(
                            'Support Score: 72/100 · Confidence: 0.81',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Text(
                        'Automated Support Priority Assessment',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Generated via Mock AI Provider · Strictly advisory signal, requires human caseworker judgment and corroboration.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s28),

                // Contributing Evidence Signals
                const AppSectionHeader(
                  title: 'Contributing Evidence Signals',
                  subtitle: 'Explainable component factors extracted from check-ins and self-reported updates.',
                ),
                const SizedBox(height: AppSpacing.s16),

                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: const [
                      _SignalTile(
                        name: 'Self-Reported Emotional Distress',
                        value: '0.80',
                        source: 'Daily Check-in (Participant logged 4/5)',
                        color: AppColors.priorityHigh,
                        isLast: false,
                      ),
                      _SignalTile(
                        name: 'Fear & Threat Sentiment Markers',
                        value: '0.75',
                        source: 'Text Check-in Semantic Analysis',
                        color: AppColors.priorityHigh,
                        isLast: false,
                      ),
                      _SignalTile(
                        name: 'Sleep Disruption Pattern',
                        value: '0.70',
                        source: 'Daily Check-in (3 consecutive days ≤ 2)',
                        color: AppColors.priorityModerate,
                        isLast: false,
                      ),
                      _SignalTile(
                        name: 'Longitudinal Distress Trend Slope',
                        value: '+18%',
                        source: 'Historical Timeline Gradient',
                        color: AppColors.warning,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s32),

                // Direct Caseworker Actions
                const AppSectionHeader(
                  title: 'Counsellor Actions & Support Workflows',
                  subtitle: 'Direct interventions and follow-up management.',
                ),
                const SizedBox(height: AppSpacing.s16),

                Wrap(
                  spacing: AppSpacing.s12,
                  runSpacing: AppSpacing.s12,
                  children: [
                    AppButton(
                      label: 'Direct Outreach Call',
                      icon: Icons.phone_in_talk_outlined,
                      height: 44,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Initiating secure tele-contact with $caseId.'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                    ),
                    AppSecondaryButton(
                      label: 'Schedule Follow-up',
                      icon: Icons.calendar_month_outlined,
                      height: 44,
                      onPressed: () => context.push('/interventions?caseId=$caseId'),
                    ),
                    AppOutlinedButton(
                      label: 'View Full Timeline',
                      icon: Icons.timeline_rounded,
                      height: 44,
                      onPressed: () => context.push('/counsellor/cases/$caseId/timeline'),
                    ),
                    AppOutlinedButton(
                      label: 'Conversation Signals',
                      icon: Icons.forum_outlined,
                      height: 44,
                      onPressed: () => context.push('/counsellor/cases/$caseId/conversations'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SignalTile extends StatelessWidget {
  final String name;
  final String value;
  final String source;
  final Color color;
  final bool isLast;

  const _SignalTile({
    required this.name,
    required this.value,
    required this.source,
    required this.color,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(source, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s10, vertical: AppSpacing.s4),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Text(
                  value,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: AppColors.border),
      ],
    );
  }
}
