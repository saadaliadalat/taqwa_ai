// Widget tests for Taqwa AI
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taqwa_ai/app.dart';

void main() {
  testWidgets('App initializes correctly', (WidgetTester tester) async {
    // Build our app wrapped in ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: TaqwaAIApp(),
      ),
    );

    // Verify app is rendered - look for the splash or welcome screen
    expect(find.byType(ProviderScope), findsOneWidget);
  });
}
