import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lyheng_vnd_usd/app/app.dart';
import 'package:lyheng_vnd_usd/app/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Protected navigation: Unauthenticated access to /admin/dashboard redirects to /admin/login', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: LyHengApp(),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Access router and attempt privileged navigation while unauthenticated
    final context = tester.element(find.byType(MaterialApp));
    final container = ProviderScope.containerOf(context);
    final router = container.read(routerProvider);

    router.go('/admin/dashboard');
    await tester.pumpAndSettle();

    // Verify user is redirected to Admin Login screen and NOT shown the dashboard
    expect(find.text('Đăng nhập Quản trị'), findsWidgets);
    expect(find.text('Email quản trị'), findsOneWidget);
    expect(find.text('Mật khẩu'), findsOneWidget);
    expect(find.text('Bảng điều khiển Quản trị'), findsNothing);
  });

  testWidgets('Admin Login form validates empty and malformed credentials', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: LyHengApp(),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 2));

    final context = tester.element(find.byType(MaterialApp));
    final container = ProviderScope.containerOf(context);
    final router = container.read(routerProvider);

    router.go('/admin/login');
    await tester.pumpAndSettle();

    // Tap Sign In with empty fields
    final signInBtn = find.widgetWithText(ElevatedButton, 'Đăng nhập');
    expect(signInBtn, findsOneWidget);
    await tester.tap(signInBtn);
    await tester.pumpAndSettle();

    expect(find.text('Vui lòng nhập email'), findsOneWidget);
    expect(find.text('Vui lòng nhập mật khẩu'), findsOneWidget);

    // Enter invalid email format (no @)
    final emailField = find.widgetWithText(TextFormField, 'Email quản trị');
    await tester.enterText(emailField, 'notanemail');
    await tester.tap(signInBtn);
    await tester.pumpAndSettle();

    expect(find.text('Email không hợp lệ'), findsOneWidget);
  });
}
