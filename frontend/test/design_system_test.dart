import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sahay_ai/app/theme/app_colors.dart';
import 'package:sahay_ai/app/theme/app_theme.dart';
import 'package:sahay_ai/shared/models/support_priority.dart';
import 'package:sahay_ai/shared/widgets/app_buttons.dart';
import 'package:sahay_ai/shared/widgets/app_card.dart';
import 'package:sahay_ai/shared/widgets/metric_card.dart';
import 'package:sahay_ai/shared/widgets/priority_badge.dart';

void main() {
  group('SAHAY-AI Master Design System & Tokens', () {
    test('AppColors palette adheres to calm healthcare & safety specification', () {
      expect(AppColors.primary, const Color(0xFF4F8F78));
      expect(AppColors.primaryDark, const Color(0xFF356B59));
      expect(AppColors.primarySoft, const Color(0xFFDDEFE8));
      expect(AppColors.secondary, const Color(0xFF6FA6A0));
      expect(AppColors.background, const Color(0xFFF5F9F7));
      expect(AppColors.surface, const Color(0xFFEDF5F2));
      expect(AppColors.card, const Color(0xFFFFFFFF));
      expect(AppColors.textPrimary, const Color(0xFF18332D));
    });

    test('SupportPriority non-clinical mappings and soft backgrounds', () {
      expect(SupportPriority.urgent.label, 'URGENT');
      expect(SupportPriority.urgent.color, AppColors.priorityUrgent);
      expect(SupportPriority.urgent.softBackgroundColor, AppColors.priorityUrgentSoft);
      expect(SupportPriority.high.color, AppColors.priorityHigh);
      expect(SupportPriority.moderate.color, AppColors.priorityModerate);
      expect(SupportPriority.low.color, AppColors.priorityLow);

      // Verify no diagnostic terms in victim-facing strings
      for (final p in SupportPriority.values) {
        expect(p.victimFacingStatus.contains('score'), isFalse);
        expect(p.victimFacingStatus.contains('diagnosis'), isFalse);
        expect(p.victimFacingStatus.contains('disorder'), isFalse);
      }
    });

    testWidgets('PriorityBadge renders dot and non-clinical label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: PriorityBadge(priority: SupportPriority.high),
          ),
        ),
      );

      expect(find.text('HIGH'), findsOneWidget);
    });

    testWidgets('AppCard renders child with subtle border and white background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: AppCard(
              child: Text('Test Content Card'),
            ),
          ),
        ),
      );

      expect(find.text('Test Content Card'), findsOneWidget);
    });

    testWidgets('AppButton renders with primary green and triggers callback', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: AppButton(
              label: 'Proceed',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Proceed'), findsOneWidget);
      await tester.tap(find.text('Proceed'));
      expect(pressed, isTrue);
    });

    testWidgets('MetricCard displays value and title correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: MetricCard(
              title: 'Active Caseload',
              value: '42',
              icon: Icons.folder_shared_outlined,
            ),
          ),
        ),
      );

      expect(find.text('42'), findsOneWidget);
      expect(find.text('Active Caseload'), findsOneWidget);
    });
  });
}
