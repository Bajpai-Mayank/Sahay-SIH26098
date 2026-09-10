import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/responsive_scaffold.dart';
import '../../../shared/widgets/timeline_item.dart';

/// Chronological Case Timeline View showing Check-ins, Alerts, and Interventions.
class CaseTimelineScreen extends StatelessWidget {
  final String caseId;

  const CaseTimelineScreen({super.key, required this.caseId});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> events = [
      {
        'title': 'High Support Priority Detected',
        'date': 'Today, 02:15 PM',
        'desc': 'AI assessment computed score 72 (HIGH). Fear indicators & sleep disruption flagged for review.',
        'icon': Icons.warning_amber_rounded,
        'color': AppColors.priorityHigh,
      },
      {
        'title': 'Daily Check-in Logged',
        'date': 'Today, 02:10 PM',
        'desc': 'Participant reported mood: 2/5, sleep: 1/5, safety: 3/5 with brief notes.',
        'icon': Icons.edit_calendar_outlined,
        'color': AppColors.primary,
      },
      {
        'title': 'Follow-up Call Completed',
        'date': 'Yesterday, 11:30 AM',
        'desc': 'Caseworker Pooja Sharma conducted 25-minute well-being check and verified safety status.',
        'icon': Icons.phone_callback_rounded,
        'color': AppColors.secondary,
      },
      {
        'title': 'Case Created & Consent Acknowledged',
        'date': 'Sep 02, 2026, 10:00 AM',
        'desc': 'Participant onboarding completed with Version 1.0 explicit consent terms.',
        'icon': Icons.verified_user_outlined,
        'color': AppColors.primaryDark,
      },
    ];

    return ResponsiveScaffold(
      title: 'Timeline: $caseId',
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
                  Text(
                    'Chronological Case Events',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Full audit trail of check-ins, automated alerts, and direct caseworker actions.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.s24),
                  Column(
                    children: List.generate(events.length, (index) {
                      final e = events[index];
                      final isLast = index == events.length - 1;

                      return TimelineItem(
                        title: e['title'] as String,
                        subtitle: e['desc'] as String,
                        date: e['date'] as String,
                        icon: e['icon'] as IconData,
                        iconColor: e['color'] as Color,
                        isLast: isLast,
                      );
                    }),
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
