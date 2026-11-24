import 'package:decimal/decimal.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/currency_formatter.dart';

enum CalculationDirection {
  usdToVnd, // Customer sells USD -> Shop buys USD at BUY RATE: VND = USD * BUY RATE
  vndToUsd, // Customer buys USD -> Shop sells USD at SELL RATE: USD = VND / SELL RATE
}

class CalculationResult {
  final CalculationDirection direction;
  final Decimal inputAmount;
  final Decimal exchangeRateUsed;
  final Decimal rawResult;
  final String formattedInput;
  final String formattedResult;
  final String formulaDescription;

  const CalculationResult({
    required this.direction,
    required this.inputAmount,
    required this.exchangeRateUsed,
    required this.rawResult,
    required this.formattedInput,
    required this.formattedResult,
    required this.formulaDescription,
  });
}

class CurrencyCalculator {
  const CurrencyCalculator._();

  /// Calculates currency exchange accurately using [Decimal] arithmetic.
  ///
  /// Direction A: USD -> VND
  /// Formula: VND = USD Amount × BUY RATE
  ///
  /// Direction B: VND -> USD
  /// Formula: USD = VND Amount ÷ SELL RATE
  static CalculationResult calculate({
    required CalculationDirection direction,
    required Decimal amount,
    required Decimal buyRate,
    required Decimal sellRate,
  }) {
    if (amount < Decimal.zero) {
      throw const CalculationException('Amount cannot be negative');
    }

    if (buyRate <= Decimal.zero || sellRate <= Decimal.zero) {
      throw const CalculationException('Exchange rates must be strictly positive');
    }

    switch (direction) {
      case CalculationDirection.usdToVnd:
        // Customer sells USD to exchange shop
        // Shop uses BUY RATE
        final resultVnd = amount * buyRate;
        final roundedVnd = resultVnd.round();
        return CalculationResult(
          direction: direction,
          inputAmount: amount,
          exchangeRateUsed: buyRate,
          rawResult: resultVnd,
          formattedInput: CurrencyFormatter.formatUsd(amount, includeSymbol: true),
          formattedResult: CurrencyFormatter.formatVnd(roundedVnd, includeSymbol: true),
          formulaDescription: '${CurrencyFormatter.formatUsd(amount)} × ${CurrencyFormatter.formatRate(buyRate, includeSymbol: false)} = ${CurrencyFormatter.formatVnd(roundedVnd)} VND',
        );

      case CalculationDirection.vndToUsd:
        // Customer buys USD from exchange shop
        // Shop uses SELL RATE
        // Accurate financial round-to-nearest-cent:
        // Compute cents: (amount * 100 / sellRate).round() / 100
        final centsRational = (amount * Decimal.fromInt(100)) / sellRate;
        final roundedCents = centsRational.round();
        final roundedUsd = (Decimal.fromBigInt(roundedCents) / Decimal.fromInt(100))
            .toDecimal(scaleOnInfinitePrecision: 2);

        return CalculationResult(
          direction: direction,
          inputAmount: amount,
          exchangeRateUsed: sellRate,
          rawResult: roundedUsd,
          formattedInput: CurrencyFormatter.formatVnd(amount, includeSymbol: true),
          formattedResult: CurrencyFormatter.formatUsd(roundedUsd, includeSymbol: true),
          formulaDescription: '${CurrencyFormatter.formatVnd(amount)} ÷ ${CurrencyFormatter.formatRate(sellRate, includeSymbol: false)} = \$${CurrencyFormatter.formatUsd(roundedUsd)}',
        );
    }
  }

  /// Validates an input string as a valid non-negative financial amount
  static Decimal? parseAndValidateAmount(String rawInput) {
    var sanitized = CurrencyFormatter.sanitizeNumericInput(rawInput);
    if (sanitized.isEmpty) return null;
    if (sanitized.endsWith('.')) {
      sanitized = sanitized.substring(0, sanitized.length - 1);
    }
    if (sanitized.isEmpty) return null;
    try {
      final parsed = Decimal.parse(sanitized);
      if (parsed < Decimal.zero) return null;
      return parsed;
    } catch (_) {
      return null;
    }
  }

  /// Validates an exchange rate input
  static Decimal? parseAndValidateRate(String rawInput) {
    var sanitized = CurrencyFormatter.sanitizeNumericInput(rawInput);
    if (sanitized.isEmpty) return null;
    if (sanitized.endsWith('.')) {
      sanitized = sanitized.substring(0, sanitized.length - 1);
    }
    if (sanitized.isEmpty) return null;
    try {
      final parsed = Decimal.parse(sanitized);
      if (parsed <= Decimal.zero) return null;
      return parsed;
    } catch (_) {
      return null;
    }
  }
}
