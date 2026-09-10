import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/providers.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_section_header.dart';
import '../../../shared/widgets/responsive_scaffold.dart';

/// Calm, supportive Participant / Victim Home Screen.
/// Strictly conforms to AI Safety Boundary: no raw mental health scores or diagnostic labels.
class VictimHomeScreen extends ConsumerWidget {
  const VictimHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final displayName = user?.fullName.split(' ').first ?? "Participant";

    return ResponsiveScaffold(
      title: 'Support Home',
      currentRoute: '/victim',
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, size: 20),
          tooltip: 'Notifications',
          onPressed: () => context.push('/victim/notifications'),
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
                // Friendly Greeting & Welcome
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, $displayName',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Here to support your comfort, safety, and well-being today.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield_outlined, size: 14, color: AppColors.primaryDark),
                          SizedBox(width: 6),
                          Text(
                            'Private & Protected',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s24),

                // Primary Support Card: "How are you feeling today?"
                AppCard(
                  backgroundColor: AppColors.primarySoft,
                  borderColor: AppColors.primary.withAlpha(60),
                  padding: const EdgeInsets.all(AppSpacing.s24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.s16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_outline_rounded,
                          size: 32,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'How are you feeling today?',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryDark,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.s4),
                            Text(
                              'Take 60 seconds to log your mood, sleep, and routine. Your caseworker is here to support you.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s16),
                      AppButton(
                        width: 140,
                        label: 'Check in now',
                        icon: Icons.edit_calendar_outlined,
                        onPressed: () => context.push('/checkin'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s28),

                // Support Services & Actions Grid
                const AppSectionHeader(
                  title: 'Support Pathways',
                  subtitle: 'Confidential assistance available at your own pace',
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 580;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: isWide ? 2 : 1,
                      mainAxisSpacing: AppSpacing.s14,
                      crossAxisSpacing: AppSpacing.s14,
                      childAspectRatio: isWide ? 2.3 : 2.8,
                      children: [
                        _SupportActionCard(
                          icon: Icons.chat_bubble_outline_rounded,
                          title: 'Talk to Assistant',
                          subtitle: 'Confidential check-in conversational support',
                          tag: '24/7 Available',
                          color: AppColors.primary,
                          onTap: () => context.push('/chat'),
                        ),
                        _SupportActionCard(
                          icon: Icons.handshake_outlined,
                          title: 'Request Human Support',
                          subtitle: 'Connect directly with caseworker Pooja Sharma',
                          tag: 'High Priority',
                          color: AppColors.secondary,
                          onTap: () => context.push('/victim/request-help'),
                        ),
                        _SupportActionCard(
                          icon: Icons.mic_none_rounded,
                          title: 'Optional Voice Check-in',
                          subtitle: 'Speak your thoughts (audio is private and auto-deleted)',
                          tag: 'Optional',
                          color: AppColors.info,
                          onTap: () => context.push('/voice'),
                        ),
                        _SupportActionCard(
                          icon: Icons.assignment_turned_in_outlined,
                          title: 'Support Plan Status',
                          subtitle: 'View your assigned care team and services',
                          tag: 'Active',
                          color: AppColors.success,
                          onTap: () => context.push('/victim/support-status'),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.s28),

                // Upcoming Support / Follow-up Schedule
                const AppSectionHeader(
                  title: 'Upcoming Support',
                  subtitle: 'Scheduled sessions and consultations with your care team',
                ),
                AppCard(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.s12),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: AppRadius.buttonBorderRadius,
                          ),
                          child: const Icon(Icons.event_available, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: AppSpacing.s16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Scheduled Follow-up Call with Pooja Sharma',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Tomorrow at 11:30 AM · Approximately 20 minutes via tele-consult',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/victim/followup'),
                          child: const Text(
                            'View Details →',
                            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.s24),

                // Emergency Assistance Hotline Reference (Calm & Clear)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: AppRadius.cardBorderRadius,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.phone_in_talk_outlined, color: AppColors.primaryDark, size: 20),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: Text(
                          'If you are in immediate physical danger, please dial 112 (National Emergency) or 1091 (Women Helpline).',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
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

class _SupportActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String tag;
  final Color color;
  final VoidCallback onTap;

  const _SupportActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.s10),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: AppRadius.buttonBorderRadius,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 0.8),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
