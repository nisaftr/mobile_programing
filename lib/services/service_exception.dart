class ServiceException implements Exception {
  const ServiceException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

class AuthException extends ServiceException {
  const AuthException(super.message, {super.code});
}
