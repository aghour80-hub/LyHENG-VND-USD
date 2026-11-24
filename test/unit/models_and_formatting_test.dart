import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lyheng_vnd_usd/core/utils/currency_formatter.dart';
import 'package:lyheng_vnd_usd/core/utils/date_formatter.dart';
import 'package:lyheng_vnd_usd/data/models/admin_user.dart';
import 'package:lyheng_vnd_usd/data/models/exchange_rate.dart';
import 'package:lyheng_vnd_usd/data/models/exchange_rate_history.dart';

void main() {
  group('Models Serialization Tests', () {
    test('ExchangeRate JSON serialization and deserialization', () {
      final now = DateTime.now();
      final rate = ExchangeRate(
        id: 'test-rate-uuid',
        buyRate: Decimal.parse('26300.5'),
        sellRate: Decimal.parse('26500.25'),
        version: 5,
        updatedAt: now,
        updatedBy: 'admin-uuid',
        isActive: true,
      );

      final json = rate.toJson();
      expect(json['buy_rate'], equals('26300.5'));
      expect(json['sell_rate'], equals('26500.25'));
      expect(json['version'], equals(5));

      final restored = ExchangeRate.fromJson(json);
      expect(restored.id, equals('test-rate-uuid'));
      expect(restored.buyRate, equals(rate.buyRate));
      expect(restored.sellRate, equals(rate.sellRate));
      expect(restored.version, equals(5));
      expect(restored.isActive, isTrue);
    });

    test('ExchangeRate SQLite serialization and deserialization', () {
      final now = DateTime.now();
      final rate = ExchangeRate(
        id: 'sqlite-rate-uuid',
        buyRate: Decimal.parse('26300'),
        sellRate: Decimal.parse('26500'),
        version: 2,
        updatedAt: now,
        isDemo: true,
      );

      final sqliteMap = rate.toSqlite();
      expect(sqliteMap['is_demo'], equals(1));
      expect(sqliteMap['is_active'], equals(1));

      final restored = ExchangeRate.fromSqlite(sqliteMap);
      expect(restored.id, equals('sqlite-rate-uuid'));
      expect(restored.isDemo, isTrue);
      expect(restored.version, equals(2));
    });

    test('ExchangeRateHistory JSON and SQLite mapping', () {
      final now = DateTime.now();
      final history = ExchangeRateHistory(
        id: 'hist-uuid',
        buyRate: Decimal.parse('26200'),
        sellRate: Decimal.parse('26400'),
        version: 1,
        createdAt: now,
        actionType: 'PUBLISH',
      );

      final json = history.toJson();
      expect(json['action_type'], equals('PUBLISH'));
      final fromJson = ExchangeRateHistory.fromJson(json);
      expect(fromJson.actionType, equals('PUBLISH'));

      final sqliteMap = history.toSqlite();
      final fromSqlite = ExchangeRateHistory.fromSqlite(sqliteMap);
      expect(fromSqlite.version, equals(1));
      expect(fromSqlite.buyRate, equals(Decimal.parse('26200')));
    });

    test('AdminUser JSON mapping', () {
      final now = DateTime.now();
      final admin = AdminUser(
        id: 'admin-row-id',
        userId: 'auth-user-id',
        role: 'admin',
        createdAt: now,
      );

      final json = admin.toJson();
      expect(json['role'], equals('admin'));
      final restored = AdminUser.fromJson(json);
      expect(restored.userId, equals('auth-user-id'));
    });
  });

  group('CurrencyFormatter and DateFormatter Tests', () {
    test('CurrencyFormatter formats VND integer correctly without decimals', () {
      final amount = Decimal.parse('2630000');
      expect(CurrencyFormatter.formatVnd(amount), equals('2,630,000'));
      expect(CurrencyFormatter.formatVnd(amount, includeSymbol: true), equals('2,630,000 ₫'));
    });

    test('CurrencyFormatter formats USD with exactly two decimal places', () {
      final amount = Decimal.parse('100.5');
      expect(CurrencyFormatter.formatUsd(amount), equals('100.50'));
      expect(CurrencyFormatter.formatUsd(amount, includeSymbol: true), equals('\$100.50'));
    });

    test('CurrencyFormatter sanization removes spaces and commas', () {
      expect(CurrencyFormatter.sanitizeNumericInput(' 1, 234, 567.89 '), equals('1234567.89'));
    });

    test('DateFormatter handles full, short and fallback parsing', () {
      final dt = DateTime(2026, 11, 24, 15, 30, 45);
      expect(DateFormatter.formatShort(dt), contains('24/11/2026'));
      expect(DateFormatter.formatFull(dt), contains('24/11/2026'));
      expect(DateFormatter.formatIsoOrFallback(null), equals('N/A'));
      expect(DateFormatter.formatIsoOrFallback('invalid-date'), equals('N/A'));
    });
  });
}
