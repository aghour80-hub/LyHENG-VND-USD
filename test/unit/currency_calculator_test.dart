import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lyheng_vnd_usd/core/errors/app_exception.dart';
import 'package:lyheng_vnd_usd/features/calculator/domain/currency_calculator.dart';

void main() {
  group('CurrencyCalculator Domain Logic Tests', () {
    final buyRate = Decimal.parse('26300');
    final sellRate = Decimal.parse('26500');

    test('USD to VND uses BUY RATE correctly (100 USD * 26,300 = 2,630,000 VND)', () {
      final amount = Decimal.parse('100');
      final result = CurrencyCalculator.calculate(
        direction: CalculationDirection.usdToVnd,
        amount: amount,
        buyRate: buyRate,
        sellRate: sellRate,
      );

      expect(result.direction, equals(CalculationDirection.usdToVnd));
      expect(result.exchangeRateUsed, equals(buyRate));
      expect(result.rawResult, equals(Decimal.parse('2630000')));
      expect(result.formattedResult, contains('2,630,000'));
      expect(result.formattedResult, contains('₫'));
    });

    test('VND to USD uses SELL RATE correctly (2,650,000 VND / 26,500 = 100 USD)', () {
      final amount = Decimal.parse('2650000');
      final result = CurrencyCalculator.calculate(
        direction: CalculationDirection.vndToUsd,
        amount: amount,
        buyRate: buyRate,
        sellRate: sellRate,
      );

      expect(result.direction, equals(CalculationDirection.vndToUsd));
      expect(result.exchangeRateUsed, equals(sellRate));
      expect(result.formattedResult, equals('\$100.00'));
    });

    test('Zero amounts calculation', () {
      final zeroResultUsdToVnd = CurrencyCalculator.calculate(
        direction: CalculationDirection.usdToVnd,
        amount: Decimal.zero,
        buyRate: buyRate,
        sellRate: sellRate,
      );
      expect(zeroResultUsdToVnd.rawResult, equals(Decimal.zero));
      expect(zeroResultUsdToVnd.formattedResult, contains('0'));

      final zeroResultVndToUsd = CurrencyCalculator.calculate(
        direction: CalculationDirection.vndToUsd,
        amount: Decimal.zero,
        buyRate: buyRate,
        sellRate: sellRate,
      );
      expect(zeroResultVndToUsd.formattedResult, equals('\$0.00'));
    });

    test('Negative amount throws CalculationException', () {
      expect(
        () => CurrencyCalculator.calculate(
          direction: CalculationDirection.usdToVnd,
          amount: Decimal.parse('-10'),
          buyRate: buyRate,
          sellRate: sellRate,
        ),
        throwsA(isA<CalculationException>()),
      );
    });

    test('Zero or negative exchange rates throw CalculationException', () {
      expect(
        () => CurrencyCalculator.calculate(
          direction: CalculationDirection.usdToVnd,
          amount: Decimal.parse('100'),
          buyRate: Decimal.zero,
          sellRate: sellRate,
        ),
        throwsA(isA<CalculationException>()),
      );

      expect(
        () => CurrencyCalculator.calculate(
          direction: CalculationDirection.vndToUsd,
          amount: Decimal.parse('100'),
          buyRate: buyRate,
          sellRate: Decimal.parse('-5'),
        ),
        throwsA(isA<CalculationException>()),
      );
    });

    test('Decimal precision for USD cents (100.55 USD * 26,300)', () {
      final amount = Decimal.parse('100.55');
      final result = CurrencyCalculator.calculate(
        direction: CalculationDirection.usdToVnd,
        amount: amount,
        buyRate: buyRate,
        sellRate: sellRate,
      );

      // 100.55 * 26300 = 2644465.0
      expect(result.rawResult, equals(Decimal.parse('2644465')));
      expect(result.formattedResult, contains('2,644,465'));
    });

    test('Division recurring decimal rounding (1,000,000 VND / 26,500 = 37.7358... -> 37.74 USD)', () {
      final amount = Decimal.parse('1000000');
      final result = CurrencyCalculator.calculate(
        direction: CalculationDirection.vndToUsd,
        amount: amount,
        buyRate: buyRate,
        sellRate: sellRate,
      );

      expect(result.formattedResult, equals('\$37.74'));
    });

    test('Large amounts calculation (1,000,000,000 VND and 1,000,000 USD)', () {
      final largeUsd = Decimal.parse('1000000');
      final usdResult = CurrencyCalculator.calculate(
        direction: CalculationDirection.usdToVnd,
        amount: largeUsd,
        buyRate: buyRate,
        sellRate: sellRate,
      );
      expect(usdResult.formattedResult, contains('26,300,000,000'));

      final largeVnd = Decimal.parse('10000000000');
      final vndResult = CurrencyCalculator.calculate(
        direction: CalculationDirection.vndToUsd,
        amount: largeVnd,
        buyRate: buyRate,
        sellRate: sellRate,
      );
      // 10,000,000,000 / 26,500 = 377,358.49
      expect(vndResult.formattedResult, equals('\$377,358.49'));
    });

    test('Input validation parsing helpers', () {
      expect(CurrencyCalculator.parseAndValidateAmount('1,000.50'), equals(Decimal.parse('1000.50')));
      expect(CurrencyCalculator.parseAndValidateAmount('100.'), equals(Decimal.parse('100')));
      expect(CurrencyCalculator.parseAndValidateAmount('-50'), isNull);
      expect(CurrencyCalculator.parseAndValidateAmount('abc'), isNull);
      expect(CurrencyCalculator.parseAndValidateAmount(''), isNull);

      expect(CurrencyCalculator.parseAndValidateRate('26,300'), equals(Decimal.parse('26300')));
      expect(CurrencyCalculator.parseAndValidateRate('0'), isNull);
      expect(CurrencyCalculator.parseAndValidateRate('-100'), isNull);
    });
  });
}
