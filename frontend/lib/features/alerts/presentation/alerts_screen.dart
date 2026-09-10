import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/responsive_scaffold.dart';

/// Operational Alerts Center for Caseworkers and District Leads.
class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final List<Map<String, dynamic>> _alerts = [
    {
      'id': 'ALT-901',
      'caseId': 'CASE-1042',
      'severity': 'CRITICAL',
      'title': 'Safety-Sensitive Language Cue Detected',
      'desc': 'Threat statement identified in participant message. Immediate human caseworker review recommended.',
      'time': '35 mins ago',
      'acknowledged': false,
    },
    {
      'id': 'ALT-899',
      'caseId': 'CASE-1038',
      'severity': 'CRITICAL',
      'title': 'Priority Escalated to URGENT',
      'desc': 'Support score crossed critical threshold (Score 84). Requires prompt caseworker telephone outreach.',
      'time': '2 hours ago',
      'acknowledged': false,
    },
    {
      'id': 'ALT-892',
      'caseId': 'CASE-1045',
      'severity': 'WARNING',
      'title': 'Consecutive Missed Check-ins',
      'desc': 'Participant has not submitted check-in for 48 hours following distress escalation.',
      'time': '5 hours ago',
      'acknowledged': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Safety & Priority Alerts',
      currentRoute: '/alerts',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Reassurance
                AppCard(
                  backgroundColor: AppColors.primarySoft,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.s10),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(AppRadius.small),
                        ),
                        child: const Icon(Icons.notifications_active_outlined, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: AppSpacing.s14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Caseworker Attention Center',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryDark,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Alerts require direct human review and verification before initiating outreach actions.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s20),

                // Alerts list
                Column(
                  children: _alerts.map((a) {
                    final isCritical = a['severity'] == 'CRITICAL';
                    final isAck = a['acknowledged'] as bool;
                    final severityColor = isCritical ? AppColors.priorityHigh : AppColors.warning;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                      child: AppCard(
                        borderColor: isCritical ? severityColor.withAlpha(140) : null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.s8,
                                    vertical: AppSpacing.s4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: severityColor.withAlpha(20),
                                    borderRadius: BorderRadius.circular(AppRadius.small),
                                  ),
                                  child: Text(
                                    a['severity'] as String,
                                    style: TextStyle(
                                      color: severityColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.s10),
                                Text(
                                  a['caseId'] as String,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const Spacer(),
                                Text(
                                  a['time'] as String,
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.s12),
                            Text(
                              a['title'] as String,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              a['desc'] as String,
                              style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: AppSpacing.s16),
                            Row(
                              children: [
                                AppSecondaryButton(
                                  label: 'Open Case File',
                                  icon: Icons.folder_open_outlined,
                                  height: 38,
                                  onPressed: () => context.push('/counsellor/cases/${a['caseId']}'),
                                ),
                                const SizedBox(width: AppSpacing.s12),
                                if (!isAck)
                                  AppButton(
                                    label: 'Acknowledge',
                                    icon: Icons.check_circle_outline_rounded,
                                    height: 38,
                                    onPressed: () {
                                      setState(() => a['acknowledged'] = true);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Alert ${a['id']} acknowledged.'),
                                          backgroundColor: AppColors.primaryDark,
                                        ),
                                      );
                                    },
                                  )
                                else
                                  Row(
                                    children: const [
                                      Icon(Icons.check_circle_rounded, size: 16, color: AppColors.secondary),
                                      SizedBox(width: 4),
                                      Text(
                                        'Acknowledged',
                                        style: TextStyle(color: AppColors.secondary, fontSize: 13, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
