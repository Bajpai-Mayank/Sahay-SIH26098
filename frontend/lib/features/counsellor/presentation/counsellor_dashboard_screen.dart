import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/providers.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/models/support_priority.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_section_header.dart';
import '../../../shared/widgets/metric_card.dart';
import '../../../shared/widgets/priority_badge.dart';
import '../../../shared/widgets/responsive_scaffold.dart';

/// Primary Demonstration Screen for Caseworkers & Counsellors.
/// Showcases Caseload Triage, Priority Breakdown, Explainable Signals, and Direct Intervention Actions.
class CounsellorDashboardScreen extends ConsumerWidget {
  const CounsellorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final counsellorName = user?.fullName ?? 'Pooja Sharma';

    return ResponsiveScaffold(
      title: 'Counsellor Dashboard',
      currentRoute: '/counsellor',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, size: 20),
          tooltip: 'Refresh Caseload Queue',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Caseload queue refreshed.'),
                backgroundColor: AppColors.primary,
              ),
            );
          },
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header Row
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary,
                      child: const Text('PS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: AppSpacing.s14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            counsellorName,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'One Stop Centre (OSC) · Central Zone · Active Duty',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    AppSecondaryButton(
                      label: '5 Safety Alerts',
                      icon: Icons.notifications_active_outlined,
                      height: 38,
                      onPressed: () => context.push('/alerts'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s24),

                // Attention Summary Header Card
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDark.withAlpha(30),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Caseload Requiring Active Attention: 18',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          TextButton.icon(
                            onPressed: () => context.push('/counsellor/queue'),
                            icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.primarySoft, size: 16),
                            label: const Text(
                              'Open Triage Queue',
                              style: TextStyle(color: AppColors.primarySoft, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      Row(
                        children: [
                          _PriorityCounterCard(
                            label: 'URGENT',
                            count: 3,
                            color: AppColors.priorityUrgent,
                            onTap: () => context.push('/counsellor/queue?priority=urgent'),
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          _PriorityCounterCard(
                            label: 'HIGH',
                            count: 7,
                            color: AppColors.priorityHigh,
                            onTap: () => context.push('/counsellor/queue?priority=high'),
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          _PriorityCounterCard(
                            label: 'MODERATE',
                            count: 8,
                            color: AppColors.priorityModerate,
                            onTap: () => context.push('/counsellor/queue?priority=moderate'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),

                // Metrics KPI Row
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 640;
                    if (isNarrow) {
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: MetricCard(title: 'Active Caseload', value: '42', icon: Icons.folder_shared_outlined)),
                              const SizedBox(width: AppSpacing.s12),
                              Expanded(child: MetricCard(title: 'High Support Need', value: '7', icon: Icons.warning_amber_rounded, accentColor: AppColors.priorityHigh)),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.s12),
                          Row(
                            children: [
                              Expanded(child: MetricCard(title: 'Pending Follow-ups', value: '5', icon: Icons.event_note_outlined, accentColor: AppColors.secondary)),
                              const SizedBox(width: AppSpacing.s12),
                              Expanded(child: MetricCard(title: 'Open Safety Plans', value: '12', icon: Icons.assignment_outlined, accentColor: AppColors.primary)),
                            ],
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(child: MetricCard(title: 'Active Caseload', value: '42', icon: Icons.folder_shared_outlined)),
                        const SizedBox(width: AppSpacing.s12),
                        Expanded(child: MetricCard(title: 'High Support Need', value: '7', icon: Icons.warning_amber_rounded, accentColor: AppColors.priorityHigh)),
                        const SizedBox(width: AppSpacing.s12),
                        Expanded(child: MetricCard(title: 'Pending Follow-ups', value: '5', icon: Icons.event_note_outlined, accentColor: AppColors.secondary)),
                        const SizedBox(width: AppSpacing.s12),
                        Expanded(child: MetricCard(title: 'Open Safety Plans', value: '12', icon: Icons.assignment_outlined, accentColor: AppColors.primary)),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.s32),

                // Highlighted Primary Attention Case: CASE-1042 (Prompt Section 15)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AppSectionHeader(
                      title: 'Featured Priority Case Review',
                      subtitle: 'Algorithmic multi-signal synthesis flagged for human assessment.',
                    ),
                    TextButton(
                      onPressed: () => context.push('/counsellor/queue'),
                      child: const Text('View All in Queue'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s16),

                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CASE-1042',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Assigned: Sep 04, 2026 · Last Check-in: 2 hours ago',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                          const PriorityBadge(priority: SupportPriority.high),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      const Divider(color: AppColors.border),
                      const SizedBox(height: AppSpacing.s12),

                      // Metric items
                      Wrap(
                        spacing: AppSpacing.s24,
                        runSpacing: AppSpacing.s12,
                        children: const [
                          _CaseworkerMetric(label: 'Support Priority', value: 'HIGH (Score 72/100)'),
                          _CaseworkerMetric(
                            label: 'Longitudinal Trend',
                            value: 'INCREASING (Distress Slope +18%)',
                            valueColor: AppColors.warning,
                          ),
                          _CaseworkerMetric(label: 'AI Confidence Level', value: '0.81 (High Quality Inputs)'),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s20),

                      // Explainable evidence factors
                      Text(
                        'Explainable Evidence Signals (Non-Clinical):',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      const _EvidenceBullet(text: 'Fear-related language pattern noted in recent text check-in'),
                      const _EvidenceBullet(text: 'Sleep difficulty and disturbance reported 3 consecutive days'),
                      const _EvidenceBullet(text: 'Threat statement detected during participant support chat'),
                      const _EvidenceBullet(text: 'Distress score rising over 3 consecutive check-ins'),

                      const SizedBox(height: AppSpacing.s20),
                      const Divider(color: AppColors.border),
                      const SizedBox(height: AppSpacing.s16),

                      // Direct Caseworker Actions
                      Wrap(
                        spacing: AppSpacing.s12,
                        runSpacing: AppSpacing.s12,
                        children: [
                          AppButton(
                            label: 'Contact Participant',
                            icon: Icons.phone_in_talk_outlined,
                            height: 42,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Initiating secure tele-contact with CASE-1042.'),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                            },
                          ),
                          AppSecondaryButton(
                            label: 'Schedule Follow-up',
                            icon: Icons.calendar_month_outlined,
                            height: 42,
                            onPressed: () => context.push('/interventions?caseId=CASE-1042'),
                          ),
                          AppOutlinedButton(
                            label: 'Safety Plan',
                            icon: Icons.assignment_add,
                            height: 42,
                            onPressed: () => context.push('/interventions?caseId=CASE-1042'),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.timeline_rounded, size: 18),
                            label: const Text('Full Timeline'),
                            onPressed: () => context.push('/counsellor/cases/CASE-1042/timeline'),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                            label: const Text('Acknowledge'),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Alert acknowledged for CASE-1042.'),
                                  backgroundColor: AppColors.primaryDark,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s32),

                // Secondary Navigation Section
                Row(
                  children: [
                    Expanded(
                      child: _NavCard(
                        icon: Icons.list_alt_rounded,
                        title: 'Triage Priority Queue',
                        subtitle: '18 Pending Reviews',
                        onTap: () => context.push('/counsellor/queue'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s16),
                    Expanded(
                      child: _NavCard(
                        icon: Icons.assignment_outlined,
                        title: 'Support Interventions',
                        subtitle: 'Active Safety Plans & Care Actions',
                        onTap: () => context.push('/interventions'),
                      ),
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

class _PriorityCounterCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final VoidCallback onTap;

  const _PriorityCounterCard({
    required this.label,
    required this.count,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.small),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12, horizontal: AppSpacing.s8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(20),
            borderRadius: BorderRadius.circular(AppRadius.small),
            border: Border.all(color: color.withAlpha(160), width: 1.5),
          ),
          child: Column(
            children: [
              Text(
                count.toString(),
                style: TextStyle(
                  color: color,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CaseworkerMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _CaseworkerMetric({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _EvidenceBullet extends StatelessWidget {
  final String text;

  const _EvidenceBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.s10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _NavCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.card),
      onTap: onTap,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.s10),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(height: AppSpacing.s12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
