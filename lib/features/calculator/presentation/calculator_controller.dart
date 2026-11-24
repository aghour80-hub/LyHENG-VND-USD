import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/exchange_rate.dart';
import '../../../data/repositories/exchange_rate_repository.dart';
import '../domain/currency_calculator.dart';
import 'calculator_state.dart';

final calculatorControllerProvider =
    NotifierProvider<CalculatorController, CalculatorState>(CalculatorController.new);

class CalculatorController extends Notifier<CalculatorState> {
  @override
  CalculatorState build() {
    final repo = ref.watch(exchangeRateRepositoryProvider);
    final rate = repo.currentRate;

    ref.listen(activeExchangeRateStreamProvider, (prev, next) {
      if (next.hasValue) {
        _calculateWithRate(next.value!);
      }
    });

    const initial = CalculatorState();
    return _computeState(initial, rate);
  }

  ExchangeRate get _currentRate => ref.read(exchangeRateRepositoryProvider).currentRate;

  void setDirection(CalculationDirection direction) {
    if (state.direction == direction) return;
    String newInput = state.inputString;
    if (direction == CalculationDirection.vndToUsd && (newInput.isEmpty || newInput == '100')) {
      newInput = '2650000';
    } else if (direction == CalculationDirection.usdToVnd && (newInput.isEmpty || newInput == '2650000')) {
      newInput = '100';
    }

    state = _computeState(
      state.copyWith(direction: direction, inputString: newInput),
      _currentRate,
    );
  }

  void swapDirection() {
    final nextDirection = state.direction == CalculationDirection.usdToVnd
        ? CalculationDirection.vndToUsd
        : CalculationDirection.usdToVnd;
    setDirection(nextDirection);
  }

  void appendInput(String char) {
    String current = state.inputString;

    // Prevent multiple decimals
    if (char == '.') {
      if (state.direction == CalculationDirection.vndToUsd) {
        // VND typically does not use decimal coins
        return;
      }
      if (current.contains('.')) return;
      if (current.isEmpty) current = '0';
    }

    // Limit maximum length to prevent overflow
    if (current.length >= 12) return;

    if (current == '0' && char != '.') {
      current = char;
    } else {
      current += char;
    }

    state = _computeState(state.copyWith(inputString: current), _currentRate);
  }

  void deleteChar() {
    if (state.inputString.isEmpty) return;
    final updated = state.inputString.substring(0, state.inputString.length - 1);
    state = _computeState(state.copyWith(inputString: updated), _currentRate);
  }

  void clear() {
    state = state.copyWith(inputString: '', result: null, errorMessage: null);
  }

  void setInput(String value) {
    state = _computeState(state.copyWith(inputString: value), _currentRate);
  }

  void _calculateWithRate(ExchangeRate rate) {
    state = _computeState(state, rate);
  }

  CalculatorState _computeState(CalculatorState inputState, ExchangeRate rate) {
    if (inputState.inputString.isEmpty) {
      return inputState.copyWith(result: null, errorMessage: null);
    }

    try {
      final amount = CurrencyCalculator.parseAndValidateAmount(inputState.inputString);
      if (amount == null) {
        return inputState.copyWith(result: null, errorMessage: 'Invalid input');
      }

      final calcResult = CurrencyCalculator.calculate(
        direction: inputState.direction,
        amount: amount,
        buyRate: rate.buyRate,
        sellRate: rate.sellRate,
      );

      return inputState.copyWith(result: calcResult, errorMessage: null);
    } catch (e) {
      return inputState.copyWith(result: null, errorMessage: e.toString());
    }
  }
}
