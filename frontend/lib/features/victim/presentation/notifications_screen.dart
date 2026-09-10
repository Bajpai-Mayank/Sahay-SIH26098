import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/responsive_scaffold.dart';

/// Notifications & Advisory Updates Screen.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Follow-up Session Scheduled',
      'body': 'Your caseworker Pooja Sharma has confirmed tomorrow\'s 11:30 AM check-in call.',
      'time': '2 hours ago',
      'category': 'Appointments',
      'icon': Icons.event_available_rounded,
      'isUnread': true,
    },
    {
      'title': 'Daily Check-in Reminder',
      'body': 'Please take a moment to complete today\'s private well-being questionnaire.',
      'time': 'Yesterday',
      'category': 'Reminders',
      'icon': Icons.edit_note_rounded,
      'isUnread': false,
    },
    {
      'title': 'Privacy & Consent Terms Confirmed',
      'body': 'Consent terms version 1.0 successfully acknowledged and active.',
      'time': '3 days ago',
      'category': 'System',
      'icon': Icons.security_rounded,
      'isUnread': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _notifications.where((n) {
      if (_selectedFilter == 'All') return true;
      return n['category'] == _selectedFilter;
    }).toList();

    return ResponsiveScaffold(
      title: 'Notifications & Updates',
      currentRoute: '/victim/notifications',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Appointments', 'Reminders', 'System'].map((cat) {
                      final isSelected = _selectedFilter == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.s8),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: AppColors.primarySoft,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _selectedFilter = cat);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: AppSpacing.s20),

                // Notifications List
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: List.generate(filtered.length, (index) {
                      final item = filtered[index];
                      final isLast = index == filtered.length - 1;
                      final isUnread = item['isUnread'] as bool;

                      return Column(
                        children: [
                          Container(
                            color: isUnread ? AppColors.primarySoft.withAlpha(20) : Colors.transparent,
                            padding: const EdgeInsets.all(AppSpacing.s16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isUnread ? AppColors.primarySoft : AppColors.surface,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    item['icon'] as IconData,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.s16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item['title'] as String,
                                              style: TextStyle(
                                                fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          if (isUnread)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              margin: const EdgeInsets.only(left: 8),
                                              decoration: const BoxDecoration(
                                                color: AppColors.primary,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['body'] as String,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: AppColors.textSecondary,
                                              height: 1.4,
                                            ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        item['time'] as String,
                                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isLast) const Divider(height: 1, color: AppColors.border),
                        ],
                      );
                    }),
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
