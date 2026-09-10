import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/models/support_priority.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_section_header.dart';
import '../../../shared/widgets/responsive_scaffold.dart';

/// Participant-facing Support Status View.
/// Conforms strictly to AI Safety Boundary: presents reassuring care progress, NOT clinical or psychiatric scores.
class SupportStatusScreen extends StatelessWidget {
  const SupportStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const currentPriority = SupportPriority.moderate;

    return ResponsiveScaffold(
      title: 'Support Status',
      currentRoute: '/victim/support-status',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Support Status Hero Card
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.s24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.s20),
                        decoration: const BoxDecoration(
                          color: AppColors.primarySoft,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.volunteer_activism_outlined, size: 44, color: AppColors.primary),
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      Text(
                        'Your Support Plan is Active',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Text(
                        currentPriority.victimFacingStatus,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s32),

                const AppSectionHeader(
                  title: 'Assigned Care Team',
                  subtitle: 'Dedicated professionals coordinating your support.',
                ),
                const SizedBox(height: AppSpacing.s16),

                AppCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary,
                        child: const Text('PS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: AppSpacing.s16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pooja Sharma',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Lead Counsellor · District One-Stop Centre',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s10, vertical: AppSpacing.s4),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.verified_rounded, size: 14, color: AppColors.primaryDark),
                            SizedBox(width: 4),
                            Text(
                              'Active Lead',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s32),

                const AppSectionHeader(
                  title: 'Available Platform Services',
                  subtitle: 'All services are coordinated in complete privacy under your consent terms.',
                ),
                const SizedBox(height: AppSpacing.s16),

                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: const [
                      _ServiceRow(
                        icon: Icons.chat_bubble_outline_rounded,
                        title: 'Daily Well-being Companion',
                        description: 'Self-guided check-ins and responsive supportive routing',
                        status: 'Available 24/7',
                        isLast: false,
                      ),
                      _ServiceRow(
                        icon: Icons.phone_callback_outlined,
                        title: 'Counsellor Tele-check',
                        description: 'Direct audio consultations with your assigned caseworker',
                        status: 'Scheduled',
                        isLast: false,
                      ),
                      _ServiceRow(
                        icon: Icons.gavel_outlined,
                        title: 'Legal Aid Linkage',
                        description: 'Confidential coordination with District Legal Services Authority (DLSA)',
                        status: 'Accessible via Caseworker',
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

class _ServiceRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String status;
  final bool isLast;

  const _ServiceRow({
    required this.icon,
    required this.title,
    required this.description,
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
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.s10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: AppSpacing.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: AppSpacing.s4),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Text(
                  status,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
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
