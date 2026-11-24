import '../domain/currency_calculator.dart';

class CalculatorState {
  final CalculationDirection direction;
  final String inputString;
  final CalculationResult? result;
  final String? errorMessage;

  const CalculatorState({
    this.direction = CalculationDirection.usdToVnd,
    this.inputString = '100',
    this.result,
    this.errorMessage,
  });

  CalculatorState copyWith({
    CalculationDirection? direction,
    String? inputString,
    CalculationResult? result,
    String? errorMessage,
  }) {
    return CalculatorState(
      direction: direction ?? this.direction,
      inputString: inputString ?? this.inputString,
      result: result ?? this.result,
      errorMessage: errorMessage,
    );
  }
}
