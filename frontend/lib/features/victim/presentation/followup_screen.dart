import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_section_header.dart';
import '../../../shared/widgets/responsive_scaffold.dart';

/// Participant Follow-up Timeline & Appointments Screen.
/// Clean, calm design keeping the participant informed of upcoming sessions.
class FollowupScreen extends StatelessWidget {
  const FollowupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Follow-up Care & Schedule',
      currentRoute: '/victim/followup',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppSectionHeader(
                  title: 'Upcoming Support Sessions',
                  subtitle: 'Confirmed appointments and check-in calls with your care team.',
                ),
                const SizedBox(height: AppSpacing.s16),

                // Featured upcoming appointment card
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.s10,
                              vertical: AppSpacing.s4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            child: const Text(
                              'CONFIRMED',
                              style: TextStyle(
                                color: AppColors.primaryDark,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.event_available_rounded, color: AppColors.primary, size: 22),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      Text(
                        'Well-being Check-in Call with Caseworker',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Caseworker: Pooja Sharma · Tele-consultation via secure line',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.s12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.small),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 18, color: AppColors.primary),
                            const SizedBox(width: AppSpacing.s8),
                            const Text(
                              'Tomorrow, 11:30 AM (approx. 20 mins)',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      Row(
                        children: [
                          Expanded(
                            child: AppSecondaryButton(
                              label: 'Request Reschedule',
                              icon: Icons.calendar_month_outlined,
                              height: 40,
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Reschedule request sent to caseworker.'),
                                    backgroundColor: AppColors.primary,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s32),

                const AppSectionHeader(
                  title: 'Past Support Milestones',
                  subtitle: 'Record of your completed follow-up milestones and care plan updates.',
                ),
                const SizedBox(height: AppSpacing.s16),

                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: const [
                      _MilestoneRow(
                        title: 'Safety Plan Overview Session',
                        subtitle: 'Completed with caseworker Pooja Sharma at OSC desk',
                        date: 'Sep 08, 2026',
                        isLast: false,
                      ),
                      _MilestoneRow(
                        title: 'Initial Intake Check-in Completed',
                        subtitle: 'Onboarding questionnaire registered securely',
                        date: 'Sep 02, 2026',
                        isLast: true,
                      ),
                    ],
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

class _MilestoneRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;
  final bool isLast;

  const _MilestoneRow({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppSpacing.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Text(
                date,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: AppColors.border),
      ],
    );
  }
}
