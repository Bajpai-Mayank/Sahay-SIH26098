import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_section_header.dart';
import '../../../shared/widgets/responsive_scaffold.dart';

/// Privacy, Data Retention, and Consent Management Screen.
class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _dataCollectionActive = true;
  bool _aiAssistanceActive = true;
  bool _voiceOptionalActive = false;

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Privacy & Consent Management',
      currentRoute: '/privacy',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Principles Banner
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: AppColors.primary.withAlpha(40)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.s8),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(AppRadius.small),
                        ),
                        child: const Icon(Icons.verified_user_outlined, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Data Protection Principles',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryDark,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Your data is collected under strict role isolation. No conversations are sold or shared with external commercial platforms.',
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
                const SizedBox(height: AppSpacing.s28),

                // Active Consents
                const AppSectionHeader(
                  title: 'Your Active Consents',
                  subtitle: 'You can update or revoke permissions at any time.',
                ),
                const SizedBox(height: AppSpacing.s12),

                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Basic Data Collection', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: const Text('Required for caseworker monitoring and check-in timeline', style: TextStyle(fontSize: 12)),
                        value: _dataCollectionActive,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) => setState(() => _dataCollectionActive = val),
                      ),
                      const Divider(height: 1, color: AppColors.border),
                      SwitchListTile(
                        title: const Text('AI-Assisted Routing & Triage', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: const Text('Assists in computing support priority under human casework review', style: TextStyle(fontSize: 12)),
                        value: _aiAssistanceActive,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) => setState(() => _aiAssistanceActive = val),
                      ),
                      const Divider(height: 1, color: AppColors.border),
                      SwitchListTile(
                        title: const Text('Optional Voice Check-in', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: const Text('Permission to process uploaded audio files for transcription', style: TextStyle(fontSize: 12)),
                        value: _voiceOptionalActive,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) => setState(() => _voiceOptionalActive = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s28),

                // Data Retention Policy
                const AppSectionHeader(
                  title: 'Automated Retention Policy',
                  subtitle: 'Strict lifecycle windows defined to minimize retained data footprint.',
                ),
                const SizedBox(height: AppSpacing.s12),

                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _PolicyPoint(
                        title: 'Raw audio assets',
                        desc: 'Auto-deleted within 30 days following secure transcription.',
                      ),
                      SizedBox(height: AppSpacing.s8),
                      _PolicyPoint(
                        title: 'Check-in logs & distress signals',
                        desc: 'Retained only during active case management and monitoring.',
                      ),
                      SizedBox(height: AppSpacing.s8),
                      _PolicyPoint(
                        title: 'Audit & event logs',
                        desc: 'Preserved with pseudonymized hash IDs for compliance and traceability.',
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

class _PolicyPoint extends StatelessWidget {
  final String title;
  final String desc;

  const _PolicyPoint({required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 5),
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.s10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textPrimary, height: 1.4),
              children: [
                TextSpan(text: '$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: desc, style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
