import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../models/user_role.dart';

/// Navigation item definition for sidebar and bottom navigation.
class NavItem {
  final String label;
  final IconData icon;
  final String route;

  const NavItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}

/// Responsive Scaffold with Desktop Sidebar and Mobile Drawer / Bottom Navigation.
/// Adapts seamlessly for Participant, Counsellor, and District Admin roles.
class ResponsiveScaffold extends ConsumerWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final String currentRoute;

  const ResponsiveScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.currentRoute,
    this.actions,
    this.floatingActionButton,
  });

  List<NavItem> _getNavItems(UserRole? role) {
    if (role == UserRole.counsellor) {
      return const [
        NavItem(label: 'Dashboard', icon: Icons.dashboard_outlined, route: '/counsellor'),
        NavItem(label: 'Priority Queue', icon: Icons.format_list_bulleted_rounded, route: '/counsellor/queue'),
        NavItem(label: 'Alerts', icon: Icons.notifications_active_outlined, route: '/alerts'),
        NavItem(label: 'Interventions', icon: Icons.assignment_outlined, route: '/interventions'),
        NavItem(label: 'Profile', icon: Icons.person_outline_rounded, route: '/profile'),
      ];
    } else if (role == UserRole.districtAdmin) {
      return const [
        NavItem(label: 'Overview', icon: Icons.analytics_outlined, route: '/district'),
        NavItem(label: 'Alerts', icon: Icons.notifications_active_outlined, route: '/alerts'),
        NavItem(label: 'Interventions', icon: Icons.assignment_outlined, route: '/interventions'),
        NavItem(label: 'Profile', icon: Icons.person_outline_rounded, route: '/profile'),
      ];
    } else {
      // Default: Participant / Victim
      return const [
        NavItem(label: 'Home', icon: Icons.home_outlined, route: '/victim'),
        NavItem(label: 'Check-in', icon: Icons.edit_calendar_outlined, route: '/checkin'),
        NavItem(label: 'Assistant', icon: Icons.chat_bubble_outline_rounded, route: '/chat'),
        NavItem(label: 'Voice', icon: Icons.mic_none_rounded, route: '/voice'),
        NavItem(label: 'Request Help', icon: Icons.handshake_outlined, route: '/victim/request-help'),
        NavItem(label: 'Follow-up', icon: Icons.event_available_outlined, route: '/victim/followup'),
        NavItem(label: 'Privacy', icon: Icons.shield_outlined, route: '/privacy'),
      ];
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);
    final navItems = _getNavItems(user?.role);
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.background,
        body: Row(
          children: [
            // Desktop Left Sidebar
            Container(
              width: 240,
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkSurface : AppColors.card,
                border: Border(
                  right: BorderSide(
                    color: isDarkMode ? AppColors.darkBorder : AppColors.border,
                    width: 1.0,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Logo / Branding
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.s20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.s8),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: AppRadius.buttonBorderRadius,
                          ),
                          child: const Icon(
                            Icons.spa_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SAHAY-AI',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                  ),
                            ),
                            Text(
                              user?.role.displayName ?? 'Participant',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Nav Links
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s12,
                        vertical: AppSpacing.s16,
                      ),
                      itemCount: navItems.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final item = navItems[index];
                        final isSelected = currentRoute == item.route ||
                            (item.route != '/counsellor' &&
                                item.route != '/victim' &&
                                currentRoute.startsWith(item.route));

                        return InkWell(
                          borderRadius: AppRadius.buttonBorderRadius,
                          onTap: () {
                            if (currentRoute != item.route) {
                              context.go(item.route);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.s16,
                              vertical: AppSpacing.s12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primarySoft : Colors.transparent,
                              borderRadius: AppRadius.buttonBorderRadius,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  item.icon,
                                  size: 20,
                                  color: isSelected
                                      ? AppColors.primaryDark
                                      : (isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary),
                                ),
                                const SizedBox(width: AppSpacing.s12),
                                Expanded(
                                  child: Text(
                                    item.label,
                                    style: TextStyle(
                                      color: isSelected
                                          ? AppColors.primaryDark
                                          : (isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary),
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Bottom Profile Snippet
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    child: InkWell(
                      borderRadius: AppRadius.buttonBorderRadius,
                      onTap: () => context.push('/profile'),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.primarySoft,
                            child: Text(
                              user?.fullName.isNotEmpty == true ? user!.fullName[0] : 'U',
                              style: const TextStyle(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.fullName ?? 'User',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Switch / Settings',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: Column(
                children: [
                  // Desktop Header
                  Container(
                    height: 64,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
                    decoration: BoxDecoration(
                      color: isDarkMode ? AppColors.darkSurface : AppColors.card,
                      border: Border(
                        bottom: BorderSide(
                          color: isDarkMode ? AppColors.darkBorder : AppColors.border,
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                              ),
                        ),
                        const Spacer(),
                        ...?actions,
                        IconButton(
                          icon: Icon(
                            isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                            size: 20,
                          ),
                          tooltip: 'Toggle Theme',
                          onPressed: () => ref.read(isDarkModeProvider.notifier).toggle(),
                        ),
                      ],
                    ),
                  ),

                  // Content Body
                  Expanded(
                    child: body,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Mobile / Compact Layout
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(title),
        actions: [
          ...?actions,
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 20,
            ),
            tooltip: 'Toggle Theme',
            onPressed: () => ref.read(isDarkModeProvider.notifier).toggle(),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: isDarkMode ? AppColors.darkSurface : AppColors.card,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.s20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.s8),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: AppRadius.buttonBorderRadius,
                      ),
                      child: const Icon(Icons.spa_rounded, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SAHAY-AI',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          user?.role.displayName ?? 'Participant',
                          style: const TextStyle(fontSize: 12, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.s12),
                  children: navItems.map((item) {
                    final isSelected = currentRoute == item.route;
                    return ListTile(
                      leading: Icon(item.icon, color: isSelected ? AppColors.primary : AppColors.textSecondary),
                      title: Text(
                        item.label,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                        ),
                      ),
                      selected: isSelected,
                      selectedTileColor: AppColors.primarySoft,
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonBorderRadius),
                      onTap: () {
                        Navigator.pop(context);
                        if (currentRoute != item.route) {
                          context.go(item.route);
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
