import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lyheng_vnd_usd/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Calculator keypad interaction: typing, calculating, and clearing', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: LyHengApp(),
      ),
    );

    // Skip splash screen
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Clear initial input
    final clearBtn = find.byTooltip('Xóa');
    if (clearBtn.evaluate().isNotEmpty) {
      await tester.tap(clearBtn);
      await tester.pumpAndSettle();
    }

    // Tap digit '5' on keypad
    final btn5 = find.widgetWithText(Material, '5');
    expect(btn5, findsWidgets);
    await tester.tap(btn5.first);
    await tester.pumpAndSettle();

    // Tap digit '0' twice
    final btn0 = find.widgetWithText(Material, '0');
    await tester.tap(btn0.first);
    await tester.pumpAndSettle();
    await tester.tap(btn0.first);
    await tester.pumpAndSettle();

    // Verify input displays "500"
    expect(find.text('500'), findsOneWidget);

    // 500 USD * 26,300 = 13,150,000 VND
    expect(find.textContaining('13,150,000'), findsOneWidget);

    // Tap Backspace
    final backspace = find.byIcon(Icons.backspace_outlined);
    expect(backspace, findsOneWidget);
    await tester.tap(backspace);
    await tester.pumpAndSettle();

    // Input is now "50" -> 50 * 26,300 = 1,315,000 VND
    expect(find.text('50'), findsOneWidget);
    expect(find.textContaining('1,315,000'), findsOneWidget);
  });

  testWidgets('Direction switching via Rate Cards and Swap Button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: LyHengApp(),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Initially in USD to VND direction (Formula: VND = USD × Giá Mua)
    expect(find.textContaining('VND = USD × Giá Mua'), findsOneWidget);

    // Tap SELL RATE card to switch to VND -> USD
    final sellCard = find.textContaining('GIÁ BÁN');
    expect(sellCard, findsOneWidget);
    await tester.tap(sellCard);
    await tester.pumpAndSettle();

    // Verify formula switched to VND to USD (Formula: USD = VND ÷ Giá Bán)
    expect(find.textContaining('USD = VND ÷ Giá Bán'), findsOneWidget);

    // Tap swap button to switch back
    final swapBtn = find.byTooltip('Đổi chiều tính');
    expect(swapBtn, findsOneWidget);
    await tester.tap(swapBtn);
    await tester.pumpAndSettle();

    expect(find.textContaining('VND = USD × Giá Mua'), findsOneWidget);
  });

  testWidgets('Copy result displays confirmation SnackBar', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: LyHengApp(),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Tap copy button
    final copyBtn = find.text('Sao chép');
    expect(copyBtn, findsOneWidget);
    await tester.tap(copyBtn);
    await tester.pumpAndSettle();

    // Verify snackbar appears
    expect(find.text('Đã sao chép kết quả'), findsOneWidget);
  });
}
