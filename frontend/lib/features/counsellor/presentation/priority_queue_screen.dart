import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/models/support_priority.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/priority_badge.dart';
import '../../../shared/widgets/responsive_scaffold.dart';

/// Priority Caseload Triage Queue for Counsellors.
/// Displays ranked cases with clear advisory status indicators and explainable summaries.
class PriorityQueueScreen extends StatefulWidget {
  final String? initialFilter;

  const PriorityQueueScreen({super.key, this.initialFilter});

  @override
  State<PriorityQueueScreen> createState() => _PriorityQueueScreenState();
}

class _PriorityQueueScreenState extends State<PriorityQueueScreen> {
  late String _activeFilter;

  final List<Map<String, dynamic>> _mockCases = [
    {
      'id': 'CASE-1042',
      'priority': SupportPriority.urgent,
      'score': 88,
      'trend': 'INCREASING',
      'lastCheckin': '2 hours ago',
      'summary': 'Fear-related language pattern, 3 consecutive nights with sleep disturbance',
      'alerts': 2,
    },
    {
      'id': 'CASE-1038',
      'priority': SupportPriority.urgent,
      'score': 84,
      'trend': 'INCREASING',
      'lastCheckin': '4 hours ago',
      'summary': 'Reported immediate safety concern during check-in session',
      'alerts': 1,
    },
    {
      'id': 'CASE-1045',
      'priority': SupportPriority.urgent,
      'score': 81,
      'trend': 'STABLE',
      'lastCheckin': '1 day ago',
      'summary': 'Communication withdrawal pattern detected across 48 hours',
      'alerts': 1,
    },
    {
      'id': 'CASE-1029',
      'priority': SupportPriority.high,
      'score': 74,
      'trend': 'INCREASING',
      'lastCheckin': '5 hours ago',
      'summary': 'Elevated distress rating (4/5), sleep disruption reported',
      'alerts': 0,
    },
    {
      'id': 'CASE-1011',
      'priority': SupportPriority.high,
      'score': 68,
      'trend': 'STABLE',
      'lastCheckin': '1 day ago',
      'summary': 'Follow-up requested regarding District Legal Aid Services linkage',
      'alerts': 0,
    },
    {
      'id': 'CASE-1004',
      'priority': SupportPriority.moderate,
      'score': 48,
      'trend': 'DECREASING',
      'lastCheckin': '6 hours ago',
      'summary': 'Self-reported positive routine progression in follow-up check-in',
      'alerts': 0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _activeFilter = widget.initialFilter?.toUpperCase() ?? 'ALL';
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _mockCases.where((c) {
      if (_activeFilter == 'ALL') return true;
      final p = c['priority'] as SupportPriority;
      return p.label == _activeFilter;
    }).toList();

    return ResponsiveScaffold(
      title: 'Priority Attention Queue',
      currentRoute: '/counsellor/queue',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Filter bar
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['ALL', 'URGENT', 'HIGH', 'MODERATE'].map((filter) {
                      final isSelected = _activeFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.s8),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          selectedColor: AppColors.primarySoft,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _activeFilter = filter);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: AppSpacing.s20),

                // Case list
                Column(
                  children: filtered.map((c) {
                    final p = c['priority'] as SupportPriority;
                    final isIncreasing = c['trend'] == 'INCREASING';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                      child: InkWell(
                        onTap: () => context.push('/counsellor/cases/${c['id']}'),
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    c['id'] as String,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                  ),
                                  const Spacer(),
                                  PriorityBadge(priority: p),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.s8),
                              Text(
                                c['summary'] as String,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textPrimary,
                                      height: 1.4,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.s16),
                              Row(
                                children: [
                                  const Icon(Icons.history_toggle_off, size: 14, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    c['lastCheckin'] as String,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(width: AppSpacing.s16),
                                  Icon(
                                    isIncreasing ? Icons.trending_up_rounded : Icons.trending_flat_rounded,
                                    size: 16,
                                    color: isIncreasing ? AppColors.warning : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    c['trend'] as String,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isIncreasing ? AppColors.warning : AppColors.textSecondary,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Review Details',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.primary),
                                ],
                              ),
                            ],
                          ),
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
