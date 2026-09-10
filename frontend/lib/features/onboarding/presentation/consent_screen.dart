import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_card.dart';

/// Explicit informed consent view conforming to SAHAY-AI privacy boundaries.
class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _dataCollectionConsent = false;
  bool _aiAssistanceConsent = false;
  bool _voiceOptionalConsent = false;

  bool get _canProceed => _dataCollectionConsent && _aiAssistanceConsent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Informed Consent & Privacy'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.s24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 580),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Reassurance Info Card
                  AppCard(
                    backgroundColor: AppColors.primarySoft,
                    borderColor: AppColors.primary.withAlpha(50),
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.shield_outlined, color: AppColors.primaryDark, size: 22),
                        const SizedBox(width: AppSpacing.s12),
                        Expanded(
                          child: Text(
                            'SAHAY-AI is an early-support and well-being assistant. It is NOT a clinical psychiatric service or legal authority. Your dignity and privacy come first.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w500,
                                  height: 1.45,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s24),

                  Text(
                    'Permissions & Transparency',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.s6),
                  Text(
                    'Please review and choose the permissions you wish to grant:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.s8),
                    child: Column(
                      children: [
                        CheckboxListTile(
                          value: _dataCollectionConsent,
                          activeColor: AppColors.primary,
                          title: const Text(
                            'Basic Check-in Logging (Required)',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          subtitle: const Text(
                            'Enables logging mood and routine check-ins on your timeline for your caseworker.',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          onChanged: (val) => setState(() => _dataCollectionConsent = val ?? false),
                        ),
                        const Divider(height: 1),
                        CheckboxListTile(
                          value: _aiAssistanceConsent,
                          activeColor: AppColors.primary,
                          title: const Text(
                            'AI-Assisted Routing (Required)',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          subtitle: const Text(
                            'Permits automated extraction of support signals to notify caseworkers under strict safety rules.',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          onChanged: (val) => setState(() => _aiAssistanceConsent = val ?? false),
                        ),
                        const Divider(height: 1),
                        CheckboxListTile(
                          value: _voiceOptionalConsent,
                          activeColor: AppColors.primary,
                          title: const Text(
                            'Optional Spoken Check-ins',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          subtitle: const Text(
                            'Allows optional voice notes to be transcribed. Audio is never stored permanently.',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          onChanged: (val) => setState(() => _voiceOptionalConsent = val ?? false),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.s32),
                  AppButton(
                    label: 'I Agree & Continue',
                    onPressed: _canProceed ? () => context.go('/login') : null,
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  Center(
                    child: TextButton(
                      onPressed: () => context.pop(),
                      child: const Text(
                        'Go Back',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
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
