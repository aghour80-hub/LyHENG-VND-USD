class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => 'AppException(code: $code, message: $message)';
}

class AuthExceptionApp extends AppException {
  const AuthExceptionApp(super.message, {super.code, super.details});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Unauthorized admin access'])
      : super(code: 'UNAUTHORIZED');
}

class CalculationException extends AppException {
  const CalculationException(super.message, {super.code});
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
}

class DatabaseExceptionApp extends AppException {
  const DatabaseExceptionApp(super.message, {super.code, super.details});
}
