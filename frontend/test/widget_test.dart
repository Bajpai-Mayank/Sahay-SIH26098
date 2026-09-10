import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sahay_ai/app/app.dart';
import 'package:sahay_ai/core/config/app_config.dart';

void main() {
  testWidgets('SAHAY-AI App initializes and displays splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SahayApp(),
      ),
    );

    // Verify initial splash screen branding elements appear
    expect(find.text(AppConfig.appName), findsOneWidget);
    expect(find.text(AppConfig.appTagline), findsOneWidget);

    // Pump past the 1400ms splash timer so that scheduled timers resolve cleanly
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
  });
}
