import 'package:flutter/material.dart';
import '../models/support_priority.dart';

/// Accessible Support Priority Chip: displays dot + priority text on soft background.
/// Never relies on color alone (includes text and clear shape).
class SupportPriorityChip extends StatelessWidget {
  final SupportPriority priority;
  final bool compact;

  const SupportPriorityChip({
    super.key,
    required this.priority,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: priority.softBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: priority.color.withAlpha(90),
          width: 0.9,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: priority.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            priority.label,
            style: TextStyle(
              color: priority.color,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Backwards-compatible alias for existing screens.
class PriorityBadge extends StatelessWidget {
  final SupportPriority priority;
  final bool showLabel;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return SupportPriorityChip(priority: priority);
  }
}
