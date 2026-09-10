import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_section_header.dart';
import '../../../shared/widgets/metric_card.dart';
import '../../../shared/widgets/responsive_scaffold.dart';

/// District Operational Dashboard for District Leads and Administrative Supervisors.
/// Displays operational metrics, capacity, priority tallies, and service availability.
class DistrictDashboardScreen extends ConsumerWidget {
  const DistrictDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return ResponsiveScaffold(
      title: 'District Overview',
      currentRoute: '/district',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // District zone info card
                AppCard(
                  backgroundColor: AppColors.primarySoft,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.s12),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(AppRadius.small),
                        ),
                        child: const Icon(Icons.location_city_rounded, color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: AppSpacing.s16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'District: Central Administrative Zone',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryDark,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Supervising Lead: ${user?.fullName ?? "Rajesh Verma"} · Real-time operational aggregates',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),

                // KPI Row
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 640;
                    if (isNarrow) {
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: MetricCard(title: 'Total Active Cases', value: '142', icon: Icons.folder_shared_outlined)),
                              const SizedBox(width: AppSpacing.s12),
                              Expanded(child: MetricCard(title: 'Critical Alerts', value: '14', icon: Icons.warning_amber_rounded, accentColor: AppColors.priorityHigh)),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.s12),
                          Row(
                            children: [
                              Expanded(child: MetricCard(title: 'Active Caseworkers', value: '18', icon: Icons.support_agent_rounded, accentColor: AppColors.secondary)),
                              const SizedBox(width: AppSpacing.s12),
                              Expanded(child: MetricCard(title: 'Shelter Utilization', value: '72%', icon: Icons.night_shelter_outlined, accentColor: AppColors.primaryDark)),
                            ],
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(child: MetricCard(title: 'Total Active Cases', value: '142', icon: Icons.folder_shared_outlined)),
                        const SizedBox(width: AppSpacing.s12),
                        Expanded(child: MetricCard(title: 'Critical Alerts', value: '14', icon: Icons.warning_amber_rounded, accentColor: AppColors.priorityHigh)),
                        const SizedBox(width: AppSpacing.s12),
                        Expanded(child: MetricCard(title: 'Active Caseworkers', value: '18', icon: Icons.support_agent_rounded, accentColor: AppColors.secondary)),
                        const SizedBox(width: AppSpacing.s12),
                        Expanded(child: MetricCard(title: 'Shelter Utilization', value: '72%', icon: Icons.night_shelter_outlined, accentColor: AppColors.primaryDark)),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.s32),

                // Caseload Priority Distribution
                const AppSectionHeader(
                  title: 'Caseload Priority Distribution',
                  subtitle: 'Aggregate operational triage breakdown across the district.',
                ),
                const SizedBox(height: AppSpacing.s16),

                AppCard(
                  child: Column(
                    children: const [
                      _DistributionBar(label: 'URGENT (Immediate Outreach Needed)', count: 12, percent: 0.08, color: AppColors.priorityUrgent),
                      SizedBox(height: AppSpacing.s16),
                      _DistributionBar(label: 'HIGH Support Priority', count: 34, percent: 0.24, color: AppColors.priorityHigh),
                      SizedBox(height: AppSpacing.s16),
                      _DistributionBar(label: 'MODERATE Monitoring', count: 68, percent: 0.48, color: AppColors.priorityModerate),
                      SizedBox(height: AppSpacing.s16),
                      _DistributionBar(label: 'LOW / Standard Care', count: 28, percent: 0.20, color: AppColors.secondary),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s32),

                // Service Directory Capacity
                const AppSectionHeader(
                  title: 'District Service Capacity',
                  subtitle: 'Integrated support nodes and real-time operational load.',
                ),
                const SizedBox(height: AppSpacing.s16),

                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: const [
                      _ServiceRow(
                        service: 'One Stop Crisis Shelter (Central)',
                        available: '8 Beds Available',
                        status: '72% Load (Operating)',
                        isLast: false,
                      ),
                      _ServiceRow(
                        service: 'District Legal Services Authority (DLSA)',
                        available: '4 Duty Officers Available',
                        status: 'Optimal (Active)',
                        isLast: false,
                      ),
                      _ServiceRow(
                        service: 'Tele-MANAS Regional Desk',
                        available: 'Connected & Synced',
                        status: 'Online (2.4m avg response)',
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

class _DistributionBar extends StatelessWidget {
  final String label;
  final int count;
  final double percent;
  final Color color;

  const _DistributionBar({
    required this.label,
    required this.count,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            Text('$count cases', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _ServiceRow extends StatelessWidget {
  final String service;
  final String available;
  final String status;
  final bool isLast;

  const _ServiceRow({
    required this.service,
    required this.available,
    required this.status,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(service, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(available, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s10, vertical: AppSpacing.s4),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Text(
                  status,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryDark),
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
