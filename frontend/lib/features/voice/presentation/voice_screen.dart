import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/responsive_scaffold.dart';

/// Optional Voice Check-in Screen with explicit consent indicator and text fallback.
/// Uses a gentle pulsing recording indicator and clear privacy disclosures.
class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  bool _hasRecorded = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleRecord() {
    setState(() {
      if (_isRecording) {
        _isRecording = false;
        _hasRecorded = true;
      } else {
        _isRecording = true;
        _hasRecorded = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Voice Check-in (Optional)',
      currentRoute: '/voice',
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Consent & Privacy Safeguard Card
                  AppCard(
                    backgroundColor: AppColors.primarySoft,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                'Voice Check-in is 100% Optional',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryDark,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Audio is processed only to transcribe your check-in for your caseworker. Raw audio is auto-deleted within 30 days and never used to train public models.',
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

                  const Spacer(),

                  // Audio Pulse Animation / Recording Circle
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final scale = _isRecording ? 1.0 + (_pulseController.value * 0.12) : 1.0;
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isRecording
                                ? AppColors.secondary.withAlpha(40)
                                : AppColors.primarySoft,
                            border: Border.all(
                              color: _isRecording ? AppColors.secondary : AppColors.primary,
                              width: _isRecording ? 3 : 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (_isRecording ? AppColors.secondary : AppColors.primary).withAlpha(30),
                                blurRadius: _isRecording ? 24 : 12,
                                spreadRadius: _isRecording ? 4 : 0,
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: _toggleRecord,
                              child: Center(
                                child: Icon(
                                  _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                                  size: 60,
                                  color: _isRecording ? AppColors.primaryDark : AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.s24),

                  Text(
                    _isRecording
                        ? 'Recording in progress... Tap to finish'
                        : _hasRecorded
                            ? 'Audio captured successfully (00:14)'
                            : 'Tap the microphone to speak your update',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isRecording
                        ? 'Speak at your own pace. Everything is secure.'
                        : _hasRecorded
                            ? 'Ready to upload and transcribe for your support record.'
                            : 'You can speak in English, Hindi, or your preferred language.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(),

                  // Submission Action
                  if (_hasRecorded) ...[
                    AppButton(
                      label: 'Submit Voice Check-in',
                      icon: Icons.cloud_upload_outlined,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Audio received securely for transcription & support review.'),
                            backgroundColor: AppColors.primaryDark,
                          ),
                        );
                        context.pop();
                      },
                    ),
                    const SizedBox(height: AppSpacing.s12),
                  ],

                  // Fallback Text Option
                  AppOutlinedButton(
                    label: 'Prefer typing? Switch to Text Check-in',
                    icon: Icons.keyboard_outlined,
                    onPressed: () => context.push('/checkin'),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
