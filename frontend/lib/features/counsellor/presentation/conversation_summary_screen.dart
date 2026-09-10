import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_section_header.dart';
import '../../../shared/widgets/responsive_scaffold.dart';

/// Privacy-Preserving Conversation Summary for Caseworkers.
/// Conforms to Section 5: "Do not expose raw private conversations unnecessarily. Present structured signals."
class ConversationSummaryScreen extends StatelessWidget {
  final String caseId;

  const ConversationSummaryScreen({super.key, required this.caseId});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Conversation Signals: $caseId',
      currentRoute: '/counsellor',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Privacy Protection Guard Banner
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
                        child: const Icon(Icons.privacy_tip_outlined, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Privacy Guard Active',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryDark,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'To preserve participant dignity, structured AI thematic markers are displayed instead of raw chat logs.',
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

                // Extracted Session Topics
                const AppSectionHeader(
                  title: 'Extracted Session Topics (Latest)',
                  subtitle: 'High-level thematic tags detected across recent participant interactions.',
                ),
                const SizedBox(height: AppSpacing.s16),

                AppCard(
                  child: Wrap(
                    spacing: AppSpacing.s8,
                    runSpacing: AppSpacing.s8,
                    children: [
                      _TopicChip(label: 'Sleep disturbance (Persistent)', color: AppColors.warning),
                      _TopicChip(label: 'Safety anxiety in neighborhood', color: AppColors.priorityHigh),
                      _TopicChip(label: 'Legal inquiry: Compensation scheme', color: AppColors.primary),
                      _TopicChip(label: 'Expressed appreciation for caseworker', color: AppColors.secondary),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s32),

                // Safety & Emotion Sentiment Markers
                const AppSectionHeader(
                  title: 'Safety & Emotion Sentiment Markers',
                  subtitle: 'Non-diagnostic emotional affect and safety indicators.',
                ),
                const SizedBox(height: AppSpacing.s16),

                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: const [
                      _IndicatorRow(label: 'Dominant Affect Pattern', value: 'Anxious / Apprehensive', isLast: false),
                      _IndicatorRow(label: 'Detected Threat Reference', value: 'Low / Ambient (No weapons mentioned)', isLast: false),
                      _IndicatorRow(label: 'Social Isolation Level', value: 'Moderate (Lives alone)', isLast: false),
                      _IndicatorRow(label: 'Language Dialect Code-Mix', value: 'Hindi / Indian English code-mix', isLast: true),
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

class _TopicChip extends StatelessWidget {
  final String label;
  final Color color;

  const _TopicChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _IndicatorRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _IndicatorRow({required this.label, required this.value, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Text(
                value,
                style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: AppColors.border),
      ],
    );
  }
}
