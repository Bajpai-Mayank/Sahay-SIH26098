import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/responsive_scaffold.dart';

/// Interventions and Support Actions Management Screen.
class InterventionsScreen extends StatefulWidget {
  final String? caseId;

  const InterventionsScreen({super.key, this.caseId});

  @override
  State<InterventionsScreen> createState() => _InterventionsScreenState();
}

class _InterventionsScreenState extends State<InterventionsScreen> {
  final List<Map<String, dynamic>> _interventions = [
    {
      'id': 'INT-204',
      'caseId': 'CASE-1042',
      'type': 'Tele-counselling Consultation',
      'status': 'Planned',
      'scheduled': 'Tomorrow, 11:30 AM',
      'desc': 'Scheduled 20-minute follow-up to address reported sleep anxiety and distress escalation.',
    },
    {
      'id': 'INT-198',
      'caseId': 'CASE-1038',
      'type': 'Safety Plan Formulation',
      'status': 'In Progress',
      'scheduled': 'Sep 11, 2026',
      'desc': 'Drafting emergency relocation contingency with district one-stop shelter team.',
    },
    {
      'id': 'INT-182',
      'caseId': 'CASE-1011',
      'type': 'Legal Services Authority Linkage',
      'status': 'Completed',
      'scheduled': 'Sep 05, 2026',
      'desc': 'Linked participant with District Legal Services Authority (DLSA) appointed officer.',
    },
  ];

  void _showCreateDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedType = 'Follow-up Call';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.dialog)),
        title: const Text('New Support Intervention'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: selectedType,
              items: ['Follow-up Call', 'Safety Plan', 'Legal Referral', 'Medical Outreach', 'Shelter Linkage']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (val) => selectedType = val!,
              decoration: InputDecoration(
                labelText: 'Intervention Type',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.input)),
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Case ID / Reference',
                hintText: 'CASE-1042',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.input)),
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            TextField(
              controller: descController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Intervention Outline',
                hintText: 'Describe scheduled action...',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.input)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          AppButton(
            label: 'Create Plan',
            height: 40,
            onPressed: () {
              setState(() {
                _interventions.insert(0, {
                  'id': 'INT-${DateTime.now().millisecond}',
                  'caseId': titleController.text.isEmpty ? 'CASE-1042' : titleController.text,
                  'type': selectedType,
                  'status': 'Planned',
                  'scheduled': 'Upcoming',
                  'desc': descController.text.isEmpty ? 'Scheduled caseworker action' : descController.text,
                });
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('New intervention recorded successfully.'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Interventions & Action Plans',
      currentRoute: '/interventions',
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.s12),
          child: AppButton(
            label: 'New Action',
            icon: Icons.add_rounded,
            height: 38,
            onPressed: _showCreateDialog,
          ),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: Column(
              children: _interventions.map((item) {
                final status = item['status'] as String;
                final isCompleted = status == 'Completed';

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              item['type'] as String,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.s8,
                                vertical: AppSpacing.s4,
                              ),
                              decoration: BoxDecoration(
                                color: isCompleted ? AppColors.secondary.withAlpha(20) : AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(AppRadius.small),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: isCompleted ? AppColors.secondary : AppColors.primaryDark,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Case: ${item['caseId']} · Target: ${item['scheduled']}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: AppSpacing.s8),
                        Text(
                          item['desc'] as String,
                          style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
