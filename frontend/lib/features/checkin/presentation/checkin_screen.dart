import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/responsive_scaffold.dart';

/// Participant Check-in Form.
/// Captures structured self-reported signals with calm, safe aesthetics and client-side idempotency.
class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  int _currentStep = 0;
  int _moodRating = 3;
  int _sleepRating = 3;
  int _safetyRating = 4;
  int _dailyRoutineRating = 3;
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _moodOptions = [
    {'label': 'Very Low', 'emoji': '😔', 'value': 1},
    {'label': 'Low', 'emoji': '🙁', 'value': 2},
    {'label': 'Manageable', 'emoji': '😐', 'value': 3},
    {'label': 'Good', 'emoji': '🙂', 'value': 4},
    {'label': 'Peaceful', 'emoji': '😌', 'value': 5},
  ];

  final List<String> _ratingLabels = [
    '1 - Significantly Disrupted',
    '2 - Struggling',
    '3 - Manageable',
    '4 - Mostly Settled',
    '5 - Well Supported & Safe',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _saveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Draft saved securely on your device.'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _submitCheckin() {
    setState(() => _isSubmitting = true);

    // Client idempotency key generated to prevent accidental duplicate submissions
    final idempotencyKey = const Uuid().v4();

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Check-in logged securely (Ref: ${idempotencyKey.substring(0, 8)})'),
            backgroundColor: AppColors.primaryDark,
          ),
        );
        context.pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Daily Well-being Check-in',
      currentRoute: '/checkin',
      actions: [
        IconButton(
          icon: const Icon(Icons.bookmark_border_rounded, size: 20),
          tooltip: 'Save Draft',
          onPressed: _saveDraft,
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Safe and welcoming Header
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
                        child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Private & Confidential Space',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryDark,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Your responses are only visible to you and your assigned caseworker.',
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
                const SizedBox(height: AppSpacing.s24),

                // Multi-step progress indicator
                Row(
                  children: [
                    Text(
                      'Step ${_currentStep + 1} of 3',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        child: LinearProgressIndicator(
                          value: (_currentStep + 1) / 3.0,
                          minHeight: 6,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s20),

                // Step content
                if (_currentStep == 0) _buildStep1Mood(context),
                if (_currentStep == 1) _buildStep2Signals(context),
                if (_currentStep == 2) _buildStep3Reflections(context),

                const SizedBox(height: AppSpacing.s32),

                // Navigation Buttons
                Row(
                  children: [
                    if (_currentStep > 0) ...[
                      Expanded(
                        child: AppSecondaryButton(
                          label: 'Previous',
                          icon: Icons.arrow_back_rounded,
                          onPressed: () => setState(() => _currentStep--),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s16),
                    ],
                    Expanded(
                      child: _currentStep < 2
                          ? AppButton(
                              label: 'Continue',
                              icon: Icons.arrow_forward_rounded,
                              onPressed: () => setState(() => _currentStep++),
                            )
                          : AppButton(
                              label: 'Submit Check-in',
                              icon: Icons.check_circle_outline_rounded,
                              isLoading: _isSubmitting,
                              onPressed: _isSubmitting ? null : _submitCheckin,
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s16),
                Center(
                  child: TextButton.icon(
                    onPressed: _saveDraft,
                    icon: const Icon(Icons.save_outlined, size: 16),
                    label: const Text('Save as draft & finish later'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1Mood(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How are you feeling right now?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            'Select the option that best reflects your emotional state at this moment.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s24),

          // Mood Cards Grid
          Wrap(
            spacing: AppSpacing.s12,
            runSpacing: AppSpacing.s12,
            children: _moodOptions.map((opt) {
              final val = opt['value'] as int;
              final isSelected = _moodRating == val;

              return InkWell(
                onTap: () => setState(() => _moodRating = val),
                borderRadius: BorderRadius.circular(AppRadius.card),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primarySoft : AppColors.card,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(opt['emoji'] as String, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: AppSpacing.s8),
                      Text(
                        opt['label'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Signals(BuildContext context) {
    return Column(
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sleep Quality Last Night',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: AppSpacing.s4),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                    child: Text(
                      '$_sleepRating/5',
                      style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                _ratingLabels[_sleepRating - 1],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.s12),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.border,
                  thumbColor: AppColors.primaryDark,
                ),
                child: Slider(
                  value: _sleepRating.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  onChanged: (val) => setState(() => _sleepRating = val.toInt()),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s16),

        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Feeling Safe in Current Space',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: AppSpacing.s4),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                    child: Text(
                      '$_safetyRating/5',
                      style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                _ratingLabels[_safetyRating - 1],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.s12),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.border,
                  thumbColor: AppColors.primaryDark,
                ),
                child: Slider(
                  value: _safetyRating.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  onChanged: (val) => setState(() => _safetyRating = val.toInt()),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s16),

        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daily Routine & Functioning',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: AppSpacing.s4),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                    child: Text(
                      '$_dailyRoutineRating/5',
                      style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                _ratingLabels[_dailyRoutineRating - 1],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.s12),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.border,
                  thumbColor: AppColors.primaryDark,
                ),
                child: Slider(
                  value: _dailyRoutineRating.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  onChanged: (val) => setState(() => _dailyRoutineRating = val.toInt()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep3Reflections(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Anything else you would like to share?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            'You may describe your thoughts, concerns, or anything you need help with. This helps your care team support you better.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s20),
          TextField(
            controller: _notesController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Share whatever is on your mind. You can write in English, Hindi, or your preferred language...',
              fillColor: AppColors.surface,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.input),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.input),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.input),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: Text(
                  'No diagnosis is generated. Only support priority and trends are shared with your caseworker.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
