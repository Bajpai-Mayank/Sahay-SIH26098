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

/// User Profile and Preference Settings Screen.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);

    return ResponsiveScaffold(
      title: 'Account & Preferences',
      currentRoute: '/profile',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // User Identity Card
                AppCard(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          user?.fullName.isNotEmpty == true ? user!.fullName[0] : 'U',
                          style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Text(
                        user?.fullName ?? 'Participant',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? 'user@example.org',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s4),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          user?.role.displayName ?? 'Participant',
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s28),

                // App Preferences
                const AppSectionHeader(
                  title: 'App Preferences',
                  subtitle: 'Appearance and localization options.',
                ),
                const SizedBox(height: AppSpacing.s12),

                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: const Text('Calm dark aesthetic for low-light comfort', style: TextStyle(fontSize: 12)),
                        value: isDarkMode,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) => ref.read(isDarkModeProvider.notifier).setDarkMode(val),
                        secondary: Container(
                          padding: const EdgeInsets.all(AppSpacing.s8),
                          decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
                          child: const Icon(Icons.dark_mode_outlined, size: 20, color: AppColors.primary),
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.border),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(AppSpacing.s8),
                          decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
                          child: const Icon(Icons.language_outlined, size: 20, color: AppColors.primary),
                        ),
                        title: const Text('Language Preference', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: const Text('Preferred interface and audio language', style: TextStyle(fontSize: 12)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              user?.preferredLanguage.toUpperCase() ?? 'EN',
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 18),
                          ],
                        ),
                        onTap: () => context.push('/language'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s28),

                // Privacy & Security
                const AppSectionHeader(
                  title: 'Privacy & Governance',
                  subtitle: 'Consent records, data retention, and audit policy.',
                ),
                const SizedBox(height: AppSpacing.s12),

                AppCard(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(AppSpacing.s8),
                      decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
                      child: const Icon(Icons.security_outlined, size: 20, color: AppColors.primary),
                    ),
                    title: const Text('Consent Settings & Data Retention', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Manage your permissions and review retention windows', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 18),
                    onTap: () => context.push('/privacy'),
                  ),
                ),
                const SizedBox(height: AppSpacing.s32),

                // Sign Out Action
                AppSecondaryButton(
                  label: 'Sign Out of SAHAY-AI',
                  icon: Icons.logout_rounded,
                  height: 44,
                  onPressed: () {
                    ref.read(currentUserProvider.notifier).setUser(null);
                    context.go('/login');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
