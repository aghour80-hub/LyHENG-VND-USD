import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lyheng_vnd_usd/app/app.dart';
import 'package:lyheng_vnd_usd/core/localization/locale_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Vietnamese is default and displays accurate localized strings', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: LyHengApp(),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.textContaining('GIÁ MUA'), findsOneWidget);
    expect(find.textContaining('GIÁ BÁN'), findsOneWidget);
    expect(find.text('Sao chép'), findsOneWidget);
    expect(find.text('Chia sẻ'), findsOneWidget);
  });

  testWidgets('Khmer localization renders correctly when locale is set to km', (WidgetTester tester) async {
    final container = ProviderContainer();
    container.read(localeProvider.notifier).setLocale(const Locale('km'));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const LyHengApp(),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Khmer rate titles and labels
    expect(find.textContaining('តម្លៃទិញ'), findsWidgets);
    expect(find.textContaining('តម្លៃលក់'), findsWidgets);
    expect(find.text('ចម្លង'), findsOneWidget);
    expect(find.text('ចែករំលែក'), findsOneWidget);

    container.dispose();
  });

  testWidgets('English localization renders correctly when locale is set to en', (WidgetTester tester) async {
    final container = ProviderContainer();
    container.read(localeProvider.notifier).setLocale(const Locale('en'));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const LyHengApp(),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 2));

    // English rate titles and labels
    expect(find.text('BUY RATE'), findsOneWidget);
    expect(find.text('SELL RATE'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);

    container.dispose();
  });
}
