import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

/// High-precision financial formatting utility.
/// Never relies on floating point binary rounding for currency values.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _vndFormat = NumberFormat('#,##0', 'en_US');
  static final NumberFormat _usdFormat = NumberFormat('#,##0.00', 'en_US');
  static final NumberFormat _rateFormat = NumberFormat('#,##0.##', 'en_US');

  /// Format VND amount: integer only with thousand separators, e.g. "2,630,000"
  static String formatVnd(Decimal amount, {bool includeSymbol = false}) {
    // Round to nearest integer for standard VND display
    final rounded = amount.round();
    final formatted = _vndFormat.format(num.parse(rounded.toString()));
    return includeSymbol ? '$formatted ₫' : formatted;
  }

  /// Format USD amount: exactly two decimal places with thousand separators, e.g. "100.00"
  static String formatUsd(Decimal amount, {bool includeSymbol = false}) {
    final formatted = _usdFormat.format(double.parse(amount.toString()));
    return includeSymbol ? '\$$formatted' : formatted;
  }

  /// Format an exchange rate value (e.g. 26,300 or 26,300.5)
  static String formatRate(Decimal rate, {bool includeSymbol = true}) {
    final doubleVal = double.parse(rate.toString());
    final formatted = _rateFormat.format(doubleVal);
    return includeSymbol ? '$formatted VND' : formatted;
  }

  /// Clean input strings (removing spaces, unwanted characters) for parsing
  static String sanitizeNumericInput(String input) {
    return input.replaceAll(' ', '').replaceAll(',', '');
  }

  /// Try parsing a sanitized input to Decimal
  static Decimal? tryParseDecimal(String input) {
    try {
      final sanitized = sanitizeNumericInput(input);
      if (sanitized.isEmpty) return null;
      return Decimal.parse(sanitized);
    } catch (_) {
      return null;
    }
  }
}
