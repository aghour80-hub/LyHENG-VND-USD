import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lyheng_vnd_usd/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('LyHengApp boots smoothly and displays splash branding', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: LyHengApp(),
      ),
    );

    // Initial splash frame verification
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('LyHENG'), findsOneWidget);

    // Advance animation clock to transition beyond splash screen
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify main currency calculator UI renders
    expect(find.text('LyHENG'), findsWidgets);
    expect(find.textContaining('BUY'), findsWidgets);
    expect(find.textContaining('SELL'), findsWidgets);
  });
}
